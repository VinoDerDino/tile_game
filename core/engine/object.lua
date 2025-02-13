Object = {}
Object.__index = Object
function Object:init()
end

function Object:extend()
    local class = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            class[k] = v
        end
    end

    class.__index = class
    class.super = self
    setmetatable(class, self)
    return class
end

function Object:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function Object:__call(...)
    local obj = setmetatable({}, self)
    obj:init(...)
    return obj
end