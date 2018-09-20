-- Axis Aligned Bounding Box object

local vec2 = require("vec2")
local compositor = require("compositor")

--local aabb = setmetatable({}, {__call = function(t, x, y, w, h) return t.new(x, y, w, h) end})
local aabb = {}
aabb.__index = aabb

aabb.new = function()
  return setmetatable({x = 0, y = 0, x_off = 0, y_off = 0, w = 32, h = 32, hw = 16, hh = 16, is_centered = true}, aabb)
end

function aabb:set(x_off, y_off, w, h)
  self.x_off = x_off
  self.y_off = y_off
  self.x = self.entity.position.x + x_off
  self.y = self.entity.position.x + y_off
  self.w = w
  self.h = h
  self.hw = w/2
  self.hh = h/2
  self.z = 100
  --compositor.add(self)
end

function aabb:center(is_centered)
  self.is_centered = is_centered
end

function aabb:scale(s)
  self.w = self.w * s
  self.h = self.h * s
end

function aabb:getPoints()
  local half_w, half_h = self.w/2, self.h/2
  return {
    vec2(self.x - (self.is_centered and half_w or 0), self.y - (self.is_centered and half_h or 0)),
    vec2(self.x + (self.is_centered and half_w or self.w), self.y - (self.is_centered and half_h or 0)),
    vec2(self.x - (self.is_centered and half_w or 0), self.y + (self.is_centered and half_h or half_h)),
    vec2(self.x + (self.is_centered and half_w or self.w), self.y + (self.is_centered and half_h or half_h))
  }
end

function aabb:update()
  self.x = self.entity.position.x + self.x_off
  self.y = self.entity.position.y + self.y_off
end

function aabb:draw()
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

return aabb