Container = Object:extend()

function Container:init(args)
    self.args = args or {}
    args.pos = args.pos or {x = 0, y = 0, w = 1, h = 1}

    self.states = {
        hover = {can = true, is = false},
        child_hover = {can = true, is = false},
        click = {can = true, is = false},
        focus = {can = true, is = false},
        on_release = {can = true, is = false}
    }

    self.children = {}
    table.insert(game.O.Container, self)
end

function Container:add_child(child, name)
    table.insert(self.children, child)
end

function Container:remove_child(child, index)
    if child ~= nil then
        for i, c in ipairs(self.children) do
            if c == child then
                table.remove(self.children, i)
                break
            end
        end
    else
        table.remove(self.children, index)
    end
end

function Container:check_click()
    if not self.states.hover.is then 
        self.states.click.is = false
        return 
    end

    if self.states.on_release.is then
        self.states.on_release.is = false
        self.states.focus.is = not self.states.focus.is
    end

    if game.Objects.controller.mouse.l then
        self.states.click.is = true
    else
        if self.states.click.is then
            self.states.on_release.is = true
            self.states.click.is = false
        end
    end
end

function Container:check_hover()
    if not self.states.hover.can then return end
    local mouse = game.Objects.controller.mouse

    if mouse.x > self.args.pos.x and mouse.x < (self.args.pos.x + self.args.pos.w) and mouse.y > self.args.pos.y and mouse.y < (self.args.pos.y + self.args.pos.h) then
        self.states.hover.is = true
    else
        self.states.hover.is = false
    end

    if not self.states.child_hover.can then return end

    local bool = false
    for _, c in ipairs(self.children) do
        if c.states and c.states.hover.can and c.check_hover then
            if c:check_hover() then
                bool = true
            end
        end
    end
    self.states.child_hover.is = bool
end

function Container:update(dt)
    self:check_hover()
    self:check_click()
    for _, child in ipairs(self.children) do
        child:update(dt, self.args.pos.x, self.args.pos.y)
    end
end

function Container:draw()
    for _, child in ipairs(self.children) do
        child:draw(self.args.pos)
    end
    -- self:draw_bounding_rect()
end

function Container:draw_bounding_rect()
    love.graphics.setColor(1, (self.states.hover.is and 1 or 0), 0, 1)
    love.graphics.setLineWidth(1 + (self.states.focus.is and 1 or 0))
    love.graphics.rectangle("line", self.args.pos.x, self.args.pos.y, self.args.pos.w, self.args.pos.h)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end