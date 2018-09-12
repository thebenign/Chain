-- Axis Aligned Bounding Box object

local vec2 = require("vec2")

local aabb = setmetatable({}, {__call = function(t, x, y, w, h) return t.new(x, y, w, h) end})
aabb.__index = aabb

aabb.new = function(x, y, w, h)
  return setmetatable({x = x, y = y, w = w, h = h, is_centered = false}, aabb)
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
