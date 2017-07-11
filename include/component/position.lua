local position = {}
position.__index = position

function position.give(entity)
    return setmetatable({x = 0, y = 0, a = 0, relative = true}, position)
end

function position:setRelative(bool)
    self.relative = bool
end

function position:set(x, y)
    self.x = x
    self.y = y
end

function position:get()
    return self.x, self.y
end

return position