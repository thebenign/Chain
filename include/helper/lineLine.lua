-- Line to line intersection test by Dan Fox https://stackoverflow.com/questions/9043805/test-if-two-lines-intersect-javascript-function
-- converted to Lua

local function intersects(a,b,c,d,p,q,r,s)
  local det, gamma, lambda = 0, 0, 0
  det = (c - a) * (s - q) - (r - p) * (d - b)
  if (det == 0) then
    return false
  else
    lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det
    gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det
    
    local hit_x, hit_y
    hit_x = a + lambda * (c-a)
    hit_y = b + lambda * (d-b)
    
    print(hit_x, hit_y)
    
    return (0 < lambda and lambda < 1) and (0 < gamma and gamma < 1)
  end
end
return intersects