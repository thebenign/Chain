local velocity = {}
velocity.__index = velocity

local trig = require("helper.chmath")

function velocity.give(entity)
    return setmetatable({dir = 0, mag = 0, fric = 0, max = 12, grav_dir = math.pi/2, grav_mag = 0}, velocity)
end

function velocity:add(dir, mag)
    local dir1, mag1 = self.dir, self.mag
    local dir2, mag2 = dir, mag
    
    local new_y = math.sin(dir1)*mag1 + math.sin(dir2)*mag2
    local new_x = math.cos(dir1)*mag1 + math.cos(dir2)*mag2
    
    self.dir = math.atan2(new_y, new_x)
    self.mag = math.sqrt(new_x^2 + new_y^2)
    
    if self.mag > self.max then self.mag = self.max end
    
end

function velocity:update()
    velocity.add(self.velocity, self.velocity.grav_dir, self.velocity.grav_mag)
    
    self.position.x, self.position.y = trig.translate(self.position.x, self.position.y, self.velocity.dir, self.velocity.mag)
    self.position._dirty = true
    
    self.velocity.mag = self.velocity.mag - ((self.velocity.mag > 0) and self.velocity.fric or 0)
    if self.velocity.mag < 0 then self.velocity.mag = 0 end
end

function velocity:set(dir, mag)
    self.dir = dir
    self.mag = mag
end

function velocity:toSegment()
  return {x = math.cos(self.dir) * self.mag, y = math.sin(self.dir) * self.mag}
end

local function decompose(dir, mag)
    return math.cos(dir) * mag, math.sin(dir) * mag
end
local function compose(x, y)
    return math.atan2(y, x), math.sqrt(x^2 + y^2)
end

function velocity:clampAxis(axis, limit)
    local x, y = decompose(self.dir, self.mag)
    if axis == "horizontal" then
        x = x < -limit and -limit or x > limit and limit or x
    elseif axis == "vertical" then
        y = y < -limit and -limit or y > limit and limit or y
    end
    self.dir, self.mag = compose(x, y)
end


return velocity