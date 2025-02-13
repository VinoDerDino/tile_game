Sprite = Object:extend()

function Sprite:init(sprite_atlas, args)
    self.args = args
    self.atlas = sprite_atlas

    self.img_scale = args.scale.img or 1
    self.pos_scale = args.scale.pos or 1

    self.scale = {
        x = self.atlas.px * self.img_scale,
        y = self.atlas.py * self.img_scale,
        s = self.img_scale
    }
    
    self.pos = {
        x = args.o_pos.x,
        y = args.o_pos.y
    }

    if args.anim_args then
        self:setup_animations(args.anim_args)
    end

    self:set_sprite_pos(args.s_pos)
    table.insert(game.O.Sprite, self)
end

function Sprite:change_animation(i)
    if i <= 0 or i > #self.animations then return end
    self.curr_anim = i
end

function Sprite:setup_animations(anim_args)
    local anim_count = #anim_args
    if anim_count <= 0 then print("LOSER") return end

    self.animations = {}
    self.curr_anim = 1

    for _, data in ipairs(anim_args) do
        local animation = {
            type           = data.type or "linear",
            frame_count    = data.frame_count or #data.frames,
            frames         = {},
            current_frame  = 1,
            timer          = 0
        }
    
        local frame_count  = animation.frame_count
        local frame_time   = data.frame_time or 0.2
    
        for i = 1, frame_count do
            local fx = data.frames[i][1]
            local fy = data.frames[i][2]
            local length = frame_time
            if animation.type == "timed" and data.frames[i][3] then
                length = data.frames[i][3]
            end
            table.insert(animation.frames, {
                px = fx,
                py = fy,
                length = length
            })
        end

        table.insert(self.animations, animation)
    end
end

function Sprite:update(dt, x, y)
    if x and y then
        self.pos.x = x
        self.pos.y = y
    end

    if self.animations and self.curr_anim then
        local anim = self.animations[self.curr_anim]
        local frames = anim.frames
        if #frames > 0 then
            anim.timer = anim.timer + dt
            local current = frames[anim.current_frame]

            if anim.timer >= current.length then
                anim.timer = anim.timer - current.length
                anim.current_frame = anim.current_frame + 1
                if anim.current_frame > #frames then
                    anim.current_frame = 1
                end
            end

            local frame = frames[anim.current_frame]
            self.sprite:setViewport(
                frame.px * self.atlas.px,
                frame.py * self.atlas.py,
                self.scale.x,
                self.scale.y
            )
        end
    end
end

function Sprite:set_sprite_pos(sprite_pos)
    self.sprite_pos = sprite_pos
    self.sprite = love.graphics.newQuad(
        self.sprite_pos.x * self.atlas.px,
        self.sprite_pos.y * self.atlas.py,
        self.atlas.px,
        self.atlas.py,
        self.atlas.image:getDimensions()
    )
end

local function degrees_to_radians(degrees)
    return degrees * math.pi / 180
end

function Sprite:draw()
    love.graphics.draw(
        self.atlas.image,
        self.sprite,
        self.pos.x * self.pos_scale,  -- Positionsskalierung und Verschiebung
        self.pos.y * self.pos_scale,  -- Positionsskalierung und Verschiebung
        0,
        self.img_scale,                         -- Bildskalierung (Skalierung des Quad)
        self.img_scale                          -- Bildskalierung (Skalierung des Quad)
    )
    if game.states.debug then
        local mouse = game.Objects.controller.mouse
        local mouse_within_x = self.pos.x * self.pos_scale < mouse.x and 
                               (self.pos.x * self.pos_scale + self.atlas.px * self.img_scale) > mouse.x
        local mouse_within_y = self.pos.y * self.pos_scale < mouse.y and 
                               (self.pos.y * self.pos_scale + self.atlas.py * self.img_scale) > mouse.y
        if mouse_within_x and mouse_within_y then
            self:draw_bounding_rect()
        end
    end
end

function Sprite:draw_bounding_rect()
    love.graphics.setColor(1, 0.4, 0.3, 1)
    love.graphics.rectangle(
        "line",
        self.pos.x * self.pos_scale, 
        self.pos.y * self.pos_scale, 
        self.scale.x,                -- self.scale.x ist bereits mit img_scale multipliziert
        self.scale.y                 -- self.scale.y ist bereits mit img_scale multipliziert
    )
    love.graphics.setColor(game.args.colors.background_amp)
end