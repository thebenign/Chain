-- aabb vs aabb swept collision testing

local vec2 = require("vec2")
local lineIntersects = require("lineLine")

local test = function(a, b)
  local normal = 0
  local hit = vec2(0, 0)
  
  local segment1, segment2
  
  segment2 = {b.x-b.hw, b.y-b.hh, b.x+b.hw, b.y-b.hh}
  segment1 = {a.position.x, a.position.y, a.position.x + a.velocity:toSegment().x, a.position.y + a.velocity:toSegment().y}
  
  -- expand the second rectangle by half the width of the first rectangle (Minkowski's principle)
  
  --local b_expanded_w = b.w + a.w / 2
  --local b_expanded_h = b.h + a.h / 2
  
  return lineIntersects(unpack(segment1), unpack(segment2))
  
end

return test