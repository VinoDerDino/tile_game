require "core.engine.object"
require "game"
require "core.engine.container"
require "core.engine.sprite"
require "core.engine.camera"
require "core.engine.controller"
require "core.loadingbar"
require "core.game.player"
require "core.game.world"
require "core.ui.uicomponent"
require "core.ui.label"
require "core.ui.button"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    game = Game()
    game:set_obj()
    game:init_scenes()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    if game.Objects.controller then game.Objects.controller:keyPressed(key) end
end

function love.keyreleased(key)
    if game.Objects.controller then game.Objects.controller:keyReleased(key) end
end

function love.gamepadpressed(joystick, button)
    if game.Objects.controller then game.Objects.controller:gamepadpressed(joystick, button) end
end

function love.joystickaxis(joystick, axis, value)
    if game.Objects.controller then game.Objects.controller:joystickaxis(joystick, axis, value) end
end

function love.resize(w, h)
    game.args.w = w
    game.args.h = h
end