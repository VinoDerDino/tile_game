Level = Object:extend()

local function assign_atlas(atli, info)
    if not atli[info] then
        atli[info] = {
            px = info.px,
            py = info.py,
            s_pos = info.s_pos,
            image = love.graphics.newImage("assets/sprites/" .. info.file_name)
        }
    end
    return atli[info]
end

function Level:init(name)
    local path = "ressources/level/" .. name
    local success, file = pcall(require, path)
    if not success then
        print("Unable to load the level " .. name)
        self.success = false
        return
    end

    self.success = true
    self.dim = {w = file.dim.w, h = file.dim.h}
    self.tiles = {}
    self:init_tiles(file, game.Data.spritesheets)
    self.props = file.props
    self.enemies = file.enemies
end

function Level:init_tiles(file, spritesheets)
    local layout, scale, tile_definitions = file.layout, file.scale, file.tile_definitions 
    local atli = {}
    for i = 1, #layout do
        local atlas = assign_atlas(atli, spritesheets[tile_definitions[layout[i]]])
        self.tiles[i] = Sprite(
            atlas,
            {
                scale = {img = scale.tile.img or 1, pos = scale.tile.pos or 1},
                o_pos = {x = (i - 1) % self.dim.w * atlas.px, y = math.floor((i - 1) / self.dim.w) * atlas.py},
                s_pos = {x = atlas.s_pos.x, y = atlas.s_pos.x},
                anim_args = atlas.anim_args or nil
            }
        )
    end
end

function Level:update(dt)
    
end

function Level:draw()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    for _, tile in ipairs(self.tiles) do
        tile:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
end