local particle = {
    enum = 0,
    entity_map = {},
    linked_list = {},
    img = love.graphics.newImage("/data/particle/fire_02_small.png"),
    camera = require("core.camera"),
    hsl2rgb = require("helper.hsl2rgb")
}

local comp_add = require("system.compositor").add
local comp_rem = require("system.compositor").remove

particle.halfw = particle.img:getWidth()/2
particle.halfh = particle.img:getHeight()/2

particle.defaults = {
    dt  = 0,    -- delta time
    t   = 0,    -- timer
    lt  = 10,   -- life timer
    pps = 3,    -- particles per step
    
    x      = 0,
    y      = 0,
    a      = 0,    -- velocity angle in radians
    r      = 0,    -- sprite rotation in radians
    spread = math.pi*2,    -- random angle variation in radians
    rot_s  = 2,    -- speed of sprite rotation (1 = full rotation in lifetime)
    dist   = 0,    -- distance away from center that particles spawn
    max_s  = 5,    -- maximum pixels per step movement
    min_s  = 0,    -- minimum pixels per step
    fric   = .1,   -- friction
    acc_a  = 0,    -- acceleration angle in radians (not yet implemented)
    acc_s  = 0,    -- acceleration speed            (not yet implemented)
    
    rgb   = {200,00,250,255},
    hsl   = {0,128,90,255},
    color_model = "hsl",
    scale = .4,
    shrink = true,
    rotate = true,
    camera = true,
    run = true,
    random_rotation = true,
}

particle.__index = particle

-- Internal Functions

function particle.give(entity)
    particle.enum = particle.enum + 1
    particle.entity_map[entity] = particle.entity_map[entity] or {_inst_count = 0, parent = entity}
    particle.linked_list[particle.enum] = particle.entity_map[entity]
    
    return setmetatable({
            
            map_id = particle.entity_map[entity],
            list_id = particle.enum,
            parent = entity
            
        }, particle)
end

function particle:newSystem(...)
    local arg = {...}
    assert(#arg == 0 or #arg == 2, "Wrong number of arguments to newSystem, expected 2 or none")
    assert(#arg == 0 or type(arg[1]) == "number" and type(arg[2]) == "number", "Wrong type to newSystem, expected \"number\"")
    
    local system_container = self.map_id
    system_container._inst_count = system_container._inst_count + 1
    local count = system_container._inst_count
    --local system = system_container[count]
    
    local system = setmetatable(
        {
            batch = love.graphics.newSpriteBatch(particle.img, 1000, "stream"),
            obj = {},
            enum = 0
            
        }, particle)
    
    for k, v in pairs(particle.defaults) do
        system[k] = v
    end
    system.x = arg[1] or 0
    system.y = arg[2] or 0
    system.z = 50
    system_container[count] = system
    
    comp_add(system)
    return system
end

function particle.update(entity)
    local systems = entity.particle.map_id
    for i = 1, systems._inst_count do
        if systems[i].following then
            systems[i].x = entity.position.x
            systems[i].y = entity.position.y
        elseif systems[i].following then
            systems[i].x, systems[i].y = systems[i].following.position.x, systems[i].following.position.y
        end
        systems[i]:instanceUpdate()
    end
end

function particle:instanceUpdate()
    local cos, sin, rand = math.cos, math.sin, math.random
    self.dt = self.dt + 1
    
    if self.dt > self.t and self.run then
        self.dt = 0
        for i = 1, self.pps do
            self.enum = self.enum + 1
            local obj = {}
            for k, v in pairs(particle.defaults) do
                obj[k] = self[k]
            end
            if obj.random_rotation then
                obj.r = rand(math.pi*2)
            end
            obj.rgb = particle.hsl2rgb(self.hsl[1],self.hsl[2],self.hsl[3],self.hsl[4])
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
        
        scale = self.shrink and math.min(((1-obj.dt/obj.lt) * obj.scale)^.6, self.scale) or self.scale
        
        local rot = obj.r + (obj.dt/obj.lt)*math.pi*obj.rot_s
        self.batch:setColor(r, g, b, math.min(((1-obj.dt/obj.lt)*a)^1.6,255))
        self.batch:add(obj.x, obj.y, rot, scale, scale, particle.halfw, particle.halfh)
        
        ::skip::
    end
end

function particle.destroy(entity)
    entity.particle._d = true
    local instance = entity.particle.map_id
    for i = 1, instance._inst_count do
        instance[i].run = false
        if instance[i].enum == 0 then
            instance._inst_count = instance._inst_count - 1
        end
    end
    if instance._inst_count == 0 then
        particle._remove(entity)
        return true
    end
end

function particle._remove(entity)
    local id = entity.particle.list_id
    particle.linked_list[id] = particle.linked_list[particle.enum]
    particle.linked_list[id].parent.particle.list_id = id
    particle.enum = particle.enum - 1
    particle.entity_map[entity] = nil
    --print(collectgarbage("count"))
end


-- User facing functions

function particle:follow(entity)
    self.following = entity
end

function particle:followFunction(x, y)
    self._fFunction = function()
        return x(), y()
    end
end

function particle:setPosition(x, y)
    self.x, self.y = x, y
end

function particle:setSingle(k, v)
    self[k] = v
end

function particle:setColor(hsl)
    self.hsl = hsl
end

function particle:get(k)
    return self[k]
end
    
function particle:set(system, setting_table)
    local table = self.map_id
    local systems, system_n, settings_n
    local set_type = type(system)
    local all = false
    local pairs = pairs
    if set_type == "table" then
        if system.batch then
            systems = {system}
            system_n = 1
        else
            systems = system
            system_n = #system
        end
    elseif set_type == "string" and system == "all"then
        all = true
    else
        error("Wrong target to particle:set, target may be any: particle system, table of particle systems, or the string \"all\"")
    end
    for i = 1, (all and table._inst_count or system_n) do
        for k, v in pairs(setting_table) do
            if all then
                table[i][k] = v
            else
                systems[i][k] = v
            end
        end
    end
end

-- End of user functions

function particle.draw()
    local entity, system
    love.graphics.setBlendMode("add")
    for i = 1, particle.enum do
        entity = particle.linked_list[i]
        for j = 1, entity._inst_count do
            system = entity[j]
            
            love.graphics.draw(system.batch, -particle.camera.x, -particle.camera.y)
        end
    end
    love.graphics.setBlendMode("alpha")
end

return particle