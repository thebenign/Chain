local velocity = {
    trig = require("trig")
    }
velocity.__index = velocity

function velocity.give(entity)
    return setmetatable({dir = 0, mag = 0, fric = 0, max = 0}, velocity)
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

function velocity:update(alpha)
        self.position.x, self.position.y = velocity.trig.translate(self.position.x, self.position.y, self.velocity.dir, self.velocity.mag*alpha)
        self.velocity.mag = self.velocity.mag - ((self.velocity.mag > self.velocity.fric) and self.velocity.fric or 0)
        if self.velocity.mag < self.velocity.fric then self.velocity.mag = 0 end
end

function velocity:set(dir, mag)
    self.dir = dir
    self.mag = mag
end

return velocity