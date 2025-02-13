Player = Container:extend()

function Player:init()

    local args = {
        health = { curr = 100, max = 100 },
        speed = 200,                      -- normale horizontale Bewegungsgeschwindigkeit
        pos = { x = 100, y = 300, w = 32, h = 32},         -- Startposition (y=300 entspricht hier dem Boden)
        direction_facing = "south",
        path = {is = false, x = 0, y = 0}
    }

    Container.init(self, args)
    local success, atlas = pcall(require, "ressources/player/spriteatlas")
    if success then
        local sprite = Sprite(atlas, {
            scale = {pos = 1, img = 1},
            s_pos = {x = 0, y = 0},
            o_pos = {x = self.args.pos.x, y = self.args.pos.y},
            anim_args = atlas.animations
        })
        Container.add_child(self, sprite)
        self.args.pos = {x = self.args.pos.x, y = self.args.pos.y, w = sprite.scale.x, h = sprite.scale.y}
    else
        print("Failed to load sprite atlas")
    end
end

function Player:draw()
    if self.args.path.is then
        love.graphics.setColor(0, 0, 1, 1)
        love.graphics.line(self.args.pos.x + self.args.pos.w / 2, self.args.pos.y + self.args.pos.h / 2, self.args.path.x, self.args.path.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
    Container.draw(self)
end

function Player:update(dt)
    local controller = game.Objects.controller
    local moving = self.args.direction_facing
    local dx, dy = 0, 0

    if controller.mouse.r then
        self.args.path = {
            is = true,
            x = controller.mouse.x,
            y = controller.mouse.y
        }
    end

    if controller.keys['a'] or controller.keys['left'] or controller.con.axis[1] and controller.con.axis[1] < 0 then
        dx = dx - 1
        moving = "west"
    end

    if controller.keys['d'] or controller.keys['right'] or controller.con.axis[1] and controller.con.axis[1] > 0 then
        dx = dx + 1
        moving = "east"
    end

    if controller.keys['w'] or controller.keys['up']  or controller.con.axis[1] and controller.con.axis[2] < 0 then
        dy = dy - 1
        moving = "north"
    end

    if controller.keys['s'] or controller.keys['down']  or controller.con.axis[1] and controller.con.axis[2] > 0 then
        dy = dy + 1
        moving = "south"
    end

    if dx ~= 0 and dy ~= 0 then
        local length = math.sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length
    end

    self.args.pos.x = self.args.pos.x + dx * self.args.speed * dt
    self.args.pos.y = self.args.pos.y + dy * self.args.speed * dt

    if dx == 0 and dy == 0 then
        if moving == "north" then
            self.children[1]:change_animation(2)
        elseif moving == "east" then
            self.children[1]:change_animation(1)
        elseif moving == "south" then
            self.children[1]:change_animation(1)
        elseif moving == "west" then
            self.children[1]:change_animation(1)
        end
        return
    end

    if moving ~= self.args.direction_facing then
        if moving == "north" then
            self.children[1]:change_animation(4)
        elseif moving == "east" then
            self.children[1]:change_animation(1)
        elseif moving == "south" then
            self.children[1]:change_animation(3)
        elseif moving == "west" then
            self.children[1]:change_animation(1)
        end
        self.args.direction_facing = moving
    end

    Container.update(self, dt)
end