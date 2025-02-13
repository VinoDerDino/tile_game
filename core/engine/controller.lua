Controller = Object:extend()

function Controller:init()
    self.keys = {}
    self.keys_released = {}
    self.mouse = {
        l = false,
        r = false,
        x = 0,
        y = 0
    }
    self.con = {
        button = {},
        axis = {0, 0, 0, 0}
    }
    self.visible = true
end

function Controller:update(dt)
    self.mouse = {
        l = love.mouse.isDown(1),
        r = love.mouse.isDown(2),
        x = love.mouse.getX(),
        y = love.mouse.getY()
    }
    self.keys_released = {}
    self.con.buttons = {}
end

function Controller:gamepadpressed(joystick, button)
    self.con.buttons[button] = true
    love.mouse.setVisible(false)
end

function Controller:joystickaxis(joystick, axis, value)
    if math.abs(value) < 0.1 then 
        self.con.axis[axis] = 0
        return 
    end
    love.mouse.setVisible(false)
    self.con.axis[axis] = value
end

function Controller:keyPressed(key)
    self.keys[key] = true
    love.mouse.setVisible(true)
end

function Controller:keyReleased(key)
    self.keys[key] = false
    self.keys_released[key] = true
end

function Controller:isKeyDown(key)
    return self.keys[key] or false
end

function Controller:isKeyReleased(key)
    return self.keys_released[key] or false
end