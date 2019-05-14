
local state = {}
state.__index = state

local state_mt = {__call = function(t) return state.new(t) end}

local instance_mt = {
    add = function(self, ...)
        local n = select("#", ...)
        for i = 1, n do
            self[select(i, ...)] = i
            self._count = self._count + 1
        end
    end
}
instance_mt.__index = instance_mt
instance_mt.__call = function(t, k) return t[k] end

function state.give()
    return setmetatable({count = 0}, state_mt)
end

function state:new()
    self.count = self.count + 1
    local instance = setmetatable({_count = 0}, instance_mt)
    self[self.count] = instance
    return instance
end

return state