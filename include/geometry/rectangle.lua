local compAdd = require("system.compositor").add
local camera = require("core.camera")
local vec2 = require("data.vec2")

local rectangle = {}
rectangle.__index = rectangle

local getVertices = function(x, y, w, h, ox, oy, r)
    -- calculate vertice list
    local vertList = {
        x - ox, y - oy,
        x + (w - ox), y - oy,
        x + (w - ox), y + (h - oy),
        x - ox, y + (h - oy)
    }
    -- rotate vertices by r
    local s, c, px, py, nx, ny
    s = math.sin(r)
    c = math.cos(r)
    for i = 0, 3 do
        px = vertList[i*2+1]
        py = vertList[i*2+2]
        
        vertList[i*2+1] = x + c * (px - x) - s * (py - y)
        vertList[i*2+2] = y + s * (px - x) + c * (py - y)
    end
    return vertList
end

function rectangle.new()
    return setmetatable({}, rectangle)
end

function rectangle:set(x, y, w, h, ox, oy, r)
    self.x = x; self.y = y
    self.w = w; self.h = h
    self.r = r
    self.z = 100
    self.ox = ox; self.oy = oy
    self.v = getVertices(x, y, w, h, ox, oy, r)
    compAdd(self)
end

function rectangle:getPoints()
    return {self.x, self.y, self.x+self.w, self.y, self.x, self.y+self.h, self.x+self.w, self.y+self.h}
end

function rectangle:rotate(r)

end

function rectangle:scale(s)
    self.w = self.w * s
    self.h = self.h * s
end

function rectangle:update()
    self.x = self.entity.position.x
    self.y = self.entity.position.y
    local x, y, w, h, ox, oy = self.x, self.y, self.w, self.h, self.ox, self.oy
    local vertList = {
        x - ox, y - oy,
        x + (w - ox), y - oy,
        x + (w - ox), y + (h - oy),
        x - ox, y + (h - oy)
    }
    local s, c, px, py, nx, ny
    s = math.sin(self.r)
    c = math.cos(self.r)
    for i = 0, 3 do
        px = vertList[i*2+1]
        py = vertList[i*2+2]
        
        vertList[i*2+1] = x + c * (px - x) - s * (py - y)
        vertList[i*2+2] = y + s * (px - x) + c * (py - y)
    end
    self.v = vertList
end

function rectangle:project(axis)
    axis = axis:normalize()
    local min = 

function rectangle:draw()
    local x_off = self.entity.position.camera and camera.x or 0
    local y_off = self.entity.position.camera and camera.y or 0
    love.graphics.translate(-x_off, -y_off)
    love.graphics.polygon("line", self.v)
    love.graphics.origin()
end

return rectangle