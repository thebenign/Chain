local compAdd = require("system.compositor").add
local camera = require("core.camera")
local vec2 = require("data.vec2")

local rectangle = {}
rectangle.__index = rectangle

local setVertices = function(x, y, w, h, ox, oy, r)
    -- calculate vertice list
    local vertList = {
        vec2.new(x - ox, y - oy),
        vec2.new(x + (w - ox), y - oy),
        vec2.new(x + (w - ox), y + (h - oy)),
        vec2.new(x - ox, y + (h - oy))
    }
    -- rotate vertices by r
    local s, c, px, py, nx, ny
    s = math.sin(r)
    c = math.cos(r)
    for i = 1, 4 do
        px = vertList[i].x
        py = vertList[i].y
        
        vertList[i].x = x + c * (px - x) - s * (py - y)
        vertList[i].y = y + s * (px - x) + c * (py - y)
    end
    return vertList
end

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
    return setmetatable({visible = false}, rectangle)
end

function rectangle:set(x, y, w, h, ox, oy, r,...)
    local vis = {...}
    self.x = x; self.y = y
    self.w = w; self.h = h
    self.old_r = nil -- if set, updates rotation of rectangle
    self.r = r
    self.z = 100
    self.ox = ox; self.oy = oy
    self.v = getVertices(x, y, w, h, ox, oy, r)
    if vis[1] then compAdd(self) end
end

-- returns the vert list as a vec2 list
function rectangle:asVec2()
    local list = {}
    for i = 0, 3 do
        list[i+1] = vec2(self.v[i*2+1], self.v[i*2+2])
    end
    return list
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
    --local min = 
end

function rectangle:draw()
    local x_off = self.entity.position.camera and camera.x or 0
    local y_off = self.entity.position.camera and camera.y or 0
    love.graphics.translate(-x_off, -y_off)
    love.graphics.polygon("line", self.v)
    love.graphics.origin()
end

return rectangle