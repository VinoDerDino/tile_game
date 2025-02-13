Button = Object:extend()

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

function Button:init(args)
    self.args = args or {}

    self.args.text = args.text or "Default"
    self.args.pos = args.pos or {x = 0, y = 0}
    self.args.style = {
        color = args.style.color or {1, 1, 1, 1},
        b_color = args.style.b_color or nil,
        w = game.args.font:getWidth(self.args.text),
        h = game.args.font:getHeight(self.args.text)
    }

    self.args.style.border_color = {
        self.args.style.color[1] * 0.5,
        self.args.style.color[2] * 0.5,
        self.args.style.color[3] * 0.5,
        1
    }

    self.args.style.padding      = normalizeSpacing(args.style.padding)
    self.args.style.margin       = normalizeSpacing(args.style.margin)

    self.args.func = args.func or function ()
        return
    end
end

function Button:update()
    local x, y, w, h = self.args.pos.x, self.args.pos.y, self.args.style.w, self.args.style.h
    local mouse = game.Objects.controller.mouse

    if x <= mouse.x and mouse.x <= (x + w) and y <= mouse.y and mouse.y <= (y + h) then
        if mouse.l then
            self.args.func()
        end
    end
end

function Button:draw(m_pos)
    local x, y, w, h = self.args.pos.x, self.args.pos.y, self.args.style.w, self.args.style.h

    if self.args.style.b_color then
        love.graphics.setColor(self.args.style.b_color)
        love.graphics.rectangle("fill", x, y, w, h)
    end

    love.graphics.setColor(self.args.style.color)
    love.graphics.print(self.args.text, x, y)

    love.graphics.setColor(self.args.style.border_color)
    love.graphics.rectangle("line", x - 1, y - 1, w + 2, h + 2)

    love.graphics.setColor(1, 1, 1, 1)
end

function Button:update_text(text)
    self.args.text = text
    self.args.style = {
        color = self.args.style.color,
        b_color = self.args.style.b_color,
        w = game.args.font:getWidth(self.args.text),
        h = game.args.font:getHeight(self.args.text)
    }
end