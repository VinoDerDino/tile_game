return {
    px = 64,
    py = 64,
    sw = 1,
    sh = 1,
    image = love.graphics.newImage("assets/sprites/player.png"),
    animations = {
        { -- Idle south
            type = "linear",
            frame_time = 0.01,
            frames = {
                {0, 0},{0, 0},
            }
        },
        { -- Idle north
            type = "linear",
            frame_time = 0.01,
            frames = {
                {0, 1},{0, 1}
            }
        },
        { -- Walk south
            type = "linear",
            frame_time = 0.2,
            frames = {
                {1, 0}, {2, 0}, {3, 0}, {4, 0},
            }
        },
        { -- Walk north
            type = "linear",
            frame_time = 0.2,
            frames = {
                {1, 1}, {2, 1}, {3, 1}, {4, 1},
            }
        }
    }
}