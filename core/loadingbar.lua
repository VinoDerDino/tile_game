Loadingbar = Object:extend()

function Loadingbar:init(progress, text)
    self.background = {41/255, 42/255, 50/255, 1}
    local length = game.args.w * 0.8
    local height = game.args.h * 0.05
    self.pos = {
        x = (game.args.w - length) / 2,
        y = game.args.h * 0.8,
        w = length,
        h = height
    }

    self.state = {
        progress = progress or 0,
        alive = true,
        success = true,
        text = text or nil
    }
end

function Loadingbar:setSuccess(success)
    self.state.success = success
end

function Loadingbar:update(dt)
     if self.state.progress < 1 then
        self.state.progress = math.min(self.state.progress + dt * 0.4, 1)
    end
end

function Loadingbar:resize()
    local length = game.args.w * 0.8
    local height = game.args.h * 0.05
    self.pos = {
        x = (game.args.w - length) / 2,
        y = game.args.h * 0.8,
        w = length,
        h = height
    }
end

function Loadingbar:draw()
    love.graphics.setBackgroundColor(self.background)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.pos.w, self.pos.h)
    love.graphics.setColor(1, 1, 1, 1)
    if self.state.text then
        love.graphics.print(self.state.text, self.pos.x, self.pos.y - 20)
    end
    love.graphics.rectangle("fill", self.pos.x + 1, self.pos.y + 1, (self.pos.w * self.state.progress) - 1, self.pos.h - 1)
end