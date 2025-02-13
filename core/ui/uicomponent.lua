UIComponent = Container:extend()

local function normalizeSpacing(value)
    if type(value) == "number" then
        return { l = value, r = value, t = value, b = value }
    else
        value = value or {}
        return {
            l = value.l or 0,
            r = value.r or 0,
            t = value.t or 0,
            b = value.b or 0,
        }
    end
end

function UIComponent:init(args)
    self.args = args or {}
    local args = self.args

    args.pos = args.pos or { x = 10, y = 10 }
    args.snap = args.snap or "left"

    args.style = args.style or {}
    args.style.w            = args.style.w            or 50
    args.style.h            = args.style.h            or 50
    args.style.border_radius = args.style.border_radius or 0
    args.style.flex         = args.style.flex         or false
    args.style.color        = args.style.color        or { 0.8, 0.8, 0.8, 1 }
    args.style.padding      = normalizeSpacing(args.style.padding)
    args.style.margin       = normalizeSpacing(args.style.margin)

    args.content = args.content or {}
    args.content.text = args.content.text or nil
    args.content.sprite = args.content.sprite or nil
    args.content.pos = args.content.pos or { x = 0, y = 0 }
    args.content.style = args.content.style or {}
    if not args.content.style.color then
        local bg = args.style.color
        args.content.style.color = { 1 - bg[1], 1 - bg[2], 1 - bg[3], 1 }
    end
    args.content.style.alignment = args.content.style.alignment or "center"

    local containerArgs = {
        pos = {
            x = args.pos.x,
            y = args.pos.y,
            w = args.style.w,
            h = args.style.h,
        },
        style   = args.style,
        content = args.content,
    }
    Container.init(self, containerArgs)
end

function UIComponent:update()
    for _, child in ipairs(self.children) do
        if child.update then 
            child:update()
        end
    end
end

function UIComponent:resize()
    local snap = self.args.snap or "left"
    local screenW = game.args.dimensions.w
    local screenH = game.args.dimensions.h

    -- Hole die beim Erstellen gespeicherten Originalwerte
    local orig = self.args.original_pos or { x = 10, y = 10 }

    if snap == "right" then
        -- Beim "right"-Snap wird der originale Abstand vom rechten Rand beibehalten:
        self.args.pos.x = screenW - orig.x
        self.args.pos.y = orig.y
    elseif snap == "left" then
        -- Beim "left"-Snap bleibt der originale Abstand vom linken Rand erhalten:
        self.args.pos.x = orig.x
        self.args.pos.y = orig.y
    elseif snap == "top" then
        self.args.pos.x = orig.x
        self.args.pos.y = orig.y
    elseif snap == "bottom" then
        -- Beim "bottom"-Snap: Abstand vom unteren Rand beibehalten
        self.args.pos.x = orig.x
        self.args.pos.y = screenH - orig.y
    else
        -- Falls kein Snap-Modus definiert ist, wird standardmäßig zentriert.
        -- Hier kannst du noch zusätzliche Logik einfügen, um einen gewünschten
        -- Offset relativ zur Bildschirmmitte beizubehalten.
        self.args.pos.x = (screenW / 2) - ((game.args.original_dimensions and game.args.original_dimensions.w or 0) / 2 - orig.x)
        self.args.pos.y = (screenH / 2) - ((game.args.original_dimensions and game.args.original_dimensions.h or 0) / 2 - orig.y)
    end
end

function UIComponent:draw_self()
    local pos     = self.args.pos
    local style   = self.args.style
    local content = self.args.content

    love.graphics.setColor(style.color)
    if style.border_radius and style.border_radius > 0 then
        love.graphics.rectangle("fill", pos.x, pos.y, style.w, style.h, style.border_radius)
    else
        love.graphics.rectangle("fill", pos.x, pos.y, style.w, style.h)
    end

    if content then
        if content.text then
            local textX = pos.x + content.pos.x
            local textY = pos.y + content.pos.y
            love.graphics.setColor(content.style.color)
            love.graphics.print(content.text, textX, textY)
        elseif content.sprite then
            content.sprite:draw()
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function UIComponent:draw()
    local pos   = self.args.pos
    local style = self.args.style

    local prevScissorX, prevScissorY, prevScissorW, prevScissorH = love.graphics.getScissor()
    love.graphics.setScissor(pos.x, pos.y, style.w, style.h)

    self:draw_self()
    Container.draw(self)

    if prevScissorX then
        love.graphics.setScissor(prevScissorX, prevScissorY, prevScissorW, prevScissorH)
    else
        love.graphics.setScissor()
    end
end

function UIComponent:add_child(args, child)
    local parentPos   = self.args.pos
    local parentPad   = self.args.style.padding
    local childMargin = child.args.style.margin
    local direction   = self.args.style.direction or "vertical"

    local newX, newY

    if self.args.style.flex and self.children and #self.children > 0 then
        local lastChild = self.children[#self.children]
        if direction == "vertical" then
            newX = parentPos.x + parentPad.l + childMargin.l
            newY = lastChild.args.pos.y + lastChild.args.style.h + (lastChild.args.style.margin.b or 0) + childMargin.t
        else
            newX = lastChild.args.pos.x + lastChild.args.style.w + (lastChild.args.style.margin.r or 0) + childMargin.l
            newY = parentPos.y + parentPad.t + childMargin.t
        end
    elseif args.rel_pos then
        newX = parentPos.x + parentPad.l + args.rel_pos.x + childMargin.l
        newY = parentPos.y + parentPad.t + args.rel_pos.y + childMargin.t
    else
        newX = parentPos.x + parentPad.l + childMargin.l
        newY = parentPos.y + parentPad.t + childMargin.t
    end

    child.args.pos.x = newX
    child.args.pos.y = newY

    Container.add_child(self, child)

    local maxRight  = 0
    local maxBottom = 0
    for _, child in ipairs(self.children) do
        local childRight  = child.args.pos.x + child.args.style.w + (child.args.style.margin.r or 0)
        local childBottom = child.args.pos.y + child.args.style.h + (child.args.style.margin.b or 0)
        if childRight > maxRight then
            maxRight = childRight
        end
        if childBottom > maxBottom then
            maxBottom = childBottom
        end
    end

    local newTotalWidth  = (maxRight  - parentPos.x) + parentPad.r
    local newTotalHeight = (maxBottom - parentPos.y) + parentPad.b

    if newTotalWidth  > self.args.style.w then
        self.args.style.w = newTotalWidth
    end
    if newTotalHeight > self.args.style.h then
        self.args.style.h = newTotalHeight
    end
end

function UIComponent:add_label(args)
    self:add_child(args or {}, Label(args))
end

function UIComponent:add_button(args)
    self:add_child(args or {}, Button(args))
end
