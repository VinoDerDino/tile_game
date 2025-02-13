Camera = Object:extend()

function Camera:init()
    self.x = 0
    self.y = 0
end

function Camera:setPos(x, y)
    self.x = x
    self.y = y
end

function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
    love.graphics.pop()
end