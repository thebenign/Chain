local timer = {}


-- Master metatable. Provides meta function for calling table as function.
local mt = {
    __index = timer,
    __call = function(t, time, loop) return timer.new(t, time, loop) end
}

-- Instance metatable provides metamethod for instances. Functions and methods within this metatable are exposed to the user.
local instance_mt = {
    set = function(self, t, loop)
        self.t = t
        self.loop = loop
    end,
    start = function(self)
        self.run = true
    end,
    stop = function(self)
        self.run = false
        self.t = 0
    end,
    pause = function(self)
        self.run = false
    end,
    reset = function(self)
        self.t = 0
    end
}
instance_mt.__index = instance_mt

-- Universal "give" function. Returns reference to this component with constructor,
-- which the core passes to the entity. Only called from the core.
function timer.give(entity)
    return setmetatable({count = 0}, mt)
end

-- Method called from entity's reference to this component. Returns timer object.
function timer:new(t, loop)
    -- increment counter
    self.count = self.count + 1
    -- Abuse lua's tables being both an associated list and array at the same time.
    -- Use the reference table's array part to contain the instance objects.
    self[self.count] = 
    setmetatable({
            t = t or 60,
            dt = 0,
            call = function() end,
            loop = loop or false,
            run = true
        }, instance_mt
    )
    -- Since everything is a table, and a table is a first class citizen, we assign
    -- a mixed table of values and functions to the array of the the reference table.
    -- Then set its metatable to instance_mt which contains its private set of methods
    return self[self.count]
end

-- update method for entity's timer reference. loops through instances.
function timer:update()
    for i = self.timer.count, 1, -1 do
        if self.timer[i].run then
            self.timer[i].dt = self.timer[i].dt + 1
        end
        if self.timer[i].dt > self.timer[i].t then
            self.timer[i].call(self)
            self.timer[i].dt = 0
            if not self.timer[i].loop then
                self.timer[i].run = false
            end
        end
    end
end

return timer