Game = Object:extend()

function Game:init()

    self.args = {
        w = 800,
        h = 600,
        font = love.graphics.newFont(14, "mono"),
        fps = 0,
        seed = os.time(),
        colors = {
            morning = {0.8, 0.7, 0.5, 1},
            noon = {1, 1, 1, 1},
            evening = {0.8, 0.5, 0.3, 1},
            night = {0.2, 0.2, 0.4, 1}
        },
        daytime = 0
    }

    self.states = {
        running = true,
        paused = false,
        debug = true
    }

    self.Scenes = {
        loadingbar = {is = false, o = nil},
        menue = {is = false, o = nil},
        level = {is = false, o = nil},
    }

    self.Objects = {
        camera = nil,
        player = nil,
        controller = nil,
        debug_menue = nil
    }

    self.Data = {

    }

    self.O = {
        Container = {},
        Sprite = {}
    }

    math.randomseed(self.args.seed)
    self:get_data()
end

function Game:get_data()
    s, self.Data.spritesheets = pcall(require, "ressources/spritesheets/sprites") 
end

function Game:create_debug()
    local menue_args = {
        pos = {x = 0, y = 0},
        style = {
            w = 100,
            h = 100,
            border_radius = 5,
            flex = true,
            padding = 15,
            margin = 15,
            color = {0.3, 0.3, 0.3, 1}
        }
    }
    local menue = UIComponent(menue_args)
    menue:add_label({text = "Mouse x: 0", style = {padding = 0, margin = 0}})
    menue:add_label({text = "Mouse y: 0", style = {padding = 0, margin = 0}})
    menue:add_label({text = "Player x: 0", style = {padding = 0, margin = 0}})
    menue:add_label({text = "Player y: 0", style = {padding = 0, margin = 0}})
    menue:add_label({text = "Container count: 0", style = {padding = 0, margin = 0}})
    menue:add_label({text = "Sprite count: 0", style = {padding = 0, margin = 0}})
    menue:add_label({text = "FPS: 0", style = {padding = 0, margin = 0}})
    menue:add_label({text = "Daytime: 0", style = {padding = 0, margin = 0}})
    menue:add_button({text = "TIME = 0", style = {padding = 0, margin = 0, color = {1, 0, 0, 1}, b_color = {0.7, 0.7, 0.7, 1}}, func = function()
        game.args.daytime = 0
   end})
    menue:add_button({text = "TIME = 0.25", style = {padding = 0, margin = 0, color = {1, 0, 0, 1}, b_color = {0.7, 0.7, 0.7, 1}}, func = function()
        game.args.daytime = 6
    end})
    menue:add_button({text = "TIME = 0.50", style = {padding = 0, margin = 0, color = {1, 0, 0, 1}, b_color = {0.7, 0.7, 0.7, 1}}, func = function()
        game.args.daytime = 12
    end})
    menue:add_button({text = "TIME = 0.75", style = {padding = 0, margin = 0, color = {1, 0, 0, 1}, b_color = {0.7, 0.7, 0.7, 1}}, func = function()
        game.args.daytime = 18
    end})

    self.Objects.debug_menue = menue
end

function Game:set_obj()
    self.Objects.camera = Camera()
    self.Objects.player = Player()
    self.Objects.controller = Controller()

    if self.states.debug then
        self:create_debug()
    end
end

function Game:init_scenes()
    self.Scenes.loadingbar = {is = false, o = Loadingbar(0, "Loading")}
    self.Scenes.level = {is = true, o = World("level1")}
end

local function interpolate_color(color1, color2, factor)
    local result = {}
    for i = 1, 4 do
        result[i] = color1[i] + (color2[i] - color1[i]) * factor
    end
    return result
end

function Game:update(dt)

    self.args.daytime = self.args.daytime + dt * 0.1
    if self.args.daytime >= 24 then
        self.args.daytime = 0
    end

    if self.Objects.controller:isKeyReleased('escape') then
        self.states.debug = not self.states.debug
    end

    local time = self.args.daytime
    if time < 6 then
        self.args.colors.background_amp = interpolate_color(game.args.colors.night, game.args.colors.morning, time / 6)
    elseif time < 12 then
        self.args.colors.background_amp = interpolate_color(game.args.colors.morning, game.args.colors.noon, (time - 6) / 6)
    elseif time < 18 then
        self.args.colors.background_amp = interpolate_color(game.args.colors.noon, game.args.colors.evening, (time - 12) / 6)
    else
        self.args.colors.background_amp = interpolate_color(game.args.colors.evening, game.args.colors.night, (time - 18) / 6)
    end

    self.args.fps = math.floor(1 / dt)
    if self.states.debug then
        self.Objects.debug_menue:update()
        self.Objects.debug_menue.children[1]:update_text("Mouse x: " .. self.Objects.controller.mouse.x)
        self.Objects.debug_menue.children[2]:update_text("Mouse y: " .. self.Objects.controller.mouse.y)
        self.Objects.debug_menue.children[3]:update_text("Player x: " .. self.Objects.player.args.pos.x)
        self.Objects.debug_menue.children[4]:update_text("Player y: " .. self.Objects.player.args.pos.y)
        self.Objects.debug_menue.children[5]:update_text("Container count: " .. #self.O.Container)
        self.Objects.debug_menue.children[6]:update_text("Sprite count: " .. #self.O.Sprite)
        self.Objects.debug_menue.children[7]:update_text("FPS: " .. self.args.fps)
        self.Objects.debug_menue.children[8]:update_text("Daytime: " .. self.args.daytime)
    end
    if self.states.paused then return end

    self.Objects.player:update(dt)
    self.Objects.controller:update(dt)
    if self.Objects.controller.con.axis[3] ~= 0 or self.Objects.controller.con.axis[4] ~= 0 then
        self.Objects.camera:setPos(self.Objects.player.args.pos.x - self.args.w / 2 + self.Objects.controller.con.axis[3] * 100, self.Objects.player.args.pos.y - self.args.h / 2 + self.Objects.controller.con.axis[4] * 100)
    else
        self.Objects.camera:setPos(self.Objects.player.args.pos.x - self.args.w / 2, self.Objects.player.args.pos.y - self.args.h / 2)
    end

    for _, scene in pairs(self.Scenes) do
        if scene.is then
            scene.o:update()
        end
    end
end

function Game:draw()


    if self.Scenes.loadingbar.is then
        self.Scenes.loadingbar.o:draw()
    elseif self.Scenes.menue.is then
        self.Scenes.menue.o:draw()
    elseif self.Scenes.level.is then
        self.Objects.camera:apply()
        self.Scenes.level.o:draw()
        self.Objects.player:draw()
        self.Objects.camera:clear()
    end

    
    if self.states.debug then
        self.Objects.debug_menue:draw()
    end
end