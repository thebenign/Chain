
local rectangle = {}
rectangle.__index = rectangle

function rectangle.new(x, y, w, h)
    return setmetatable({x = x, y = y, w = w, h = h}, rectangle)
end

function rectangle:getPoints()
    return {self.x, self.y, self.x+self.w, self.y, self.x, self.y+self.h, self.x+self.w, self.y+self.h}
end

function rectangle:rotate(angle)
    --linear rotate
end

function rectangle:scale(s)
    self.w = self.w * s
    self.h = self.h * s
end
