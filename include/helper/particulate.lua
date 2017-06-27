-- PARTICLE 2

local emitter = setmetatable({img = love.graphics.newImage("part4.tga")}, {__call = function(t, x, y) return t.new(x, y); end})
emitter.__index = emitter

emitter.defaults = {
    dt  = 0,    -- delta time
    t   = 0,    -- timer
    lt  = 500,   -- life timer
    pps = 1,    -- particles per step
    
    x      = 0,
    y      = 0,
    a      = 0,    -- angle in radians
    spread = math.pi*2,    -- angle variation in radians
    rot_s  = 0,    -- speed of sprite rotation (1 = full rotation in lifetime)
    dist   = 0,    -- distance away from center that particles with spawn
    max_s  = 2,    -- pixels per step movement
    min_s  = .1,   -- minimum speed
    fric   = .01,  -- friction
    acc_a  = 0,    -- acceleration angle in radians
    acc_s  = 0,    -- acceleration speed
    
    rgb   = {200,200,200,180},
    hsl   = {255,255,128,128},
    color_model = "hsl",
    scale = 1,
    shrink = true,
    
    camera = true,
    run = true,
    
    }
    
function emitter:build()

end

function emitter:set(t)
    for k, v in pairs(t) do
        self[k] = v
    end
end

function emitter.hsl2rgb(h,s,l,a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
        elseif h < 2 then r,g,b = x,c,0
        elseif h < 3 then r,g,b = 0,c,x
        elseif h < 4 then r,g,b = 0,x,c
        elseif h < 5 then r,g,b = x,0,c
        else              r,g,b = c,0,x
    end
return (r+m)*255,(g+m)*255,(b+m)*255,a
end
    
function emitter.new(...)
    local arg = {...}
    local t = setmetatable(
        {
            batch = love.graphics.newSpriteBatch(emitter.img, 15000, "stream"),
            obj = {},
            enum = 0
        }, emitter)
    
    for k, v in pairs(emitter.defaults) do
        t[k] = v
    end
    t.x = arg[1] or 0
    t.y = arg[2] or 0
    
    return t
end

function emitter:update()
    local cos, sin, rand = math.cos, math.sin, math.random
    self.dt = self.dt + 1
    
    if self.dt > self.t then
        self.dt = 0
        for i = 1, self.pps do
            self.enum = self.enum + 1
            local obj = {}
            for k, v in pairs(emitter.defaults) do
                obj[k] = self[k]
            end
            obj.a = obj.a + rand()*obj.spread-(obj.spread*.5)
            obj.mag = obj.min_s + rand()*(obj.max_s-obj.min_s)
            obj.x = obj.x + cos(obj.a)*obj.dist
            obj.y = obj.y + sin(obj.a)*obj.dist
            self.obj[self.enum] = obj
        end
    end
    
    local obj, scale
    local r,g,b,a
    self.batch:clear()
    
    for k = self.enum, 1, -1 do
        obj = self.obj[k]
        obj.dt = obj.dt + 1
        
        if obj.dt > obj.lt then
            self.obj[k] = self.obj[self.enum]
            self.enum = self.enum - 1
            goto skip
        end
        
        --obj.a, obj.mag = emitter.addvec(obj.a, obj.mag, obj.acc_a, obj.acc_s)
        --if obj.mag > obj.max_s then obj.mag = obj.max_s end
        obj.mag = obj.mag - obj.fric
        if obj.mag < 0 then obj.mag = 0 end
        obj.x = obj.x + cos(obj.a)*obj.mag
        obj.y = obj.y + sin(obj.a)*obj.mag
        
        r, g, b, a = obj.rgb[1], obj.rgb[2], obj.rgb[3], obj.rgb[4]
        
        scale = (1-obj.dt/obj.lt) * obj.scale
        
        self.batch:setColor(r, g, b, (1-obj.dt/obj.lt)*a)
        self.batch:add(obj.x, obj.y, (obj.dt/obj.lt)*math.pi*obj.rot_s, scale, scale, 32, 32)
        
        ::skip::
    end
end

function emitter.addvec(a1,m1,a2,m2)
    
    local new_y = math.sin(a1)*m1 + math.sin(a2)*m2
    local new_x = math.cos(a1)*m1 + math.cos(a2)*m2
    
    return math.atan2(new_y, new_x), math.sqrt(new_x^2 + new_y^2)
    
end

function emitter:draw(...)
    local arg = {...}
    local x, y = arg[1] or 0, arg[2] or 0
    love.graphics.setBlendMode("add")
    love.graphics.setColor(self.rgb)
    love.graphics.draw(self.batch, x, y)
    love.graphics.setBlendMode("alpha")
end



return emitter