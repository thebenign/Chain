
local position = {
    list = chain.data.unordered_list(),
    data = chain.data.dol("x", "y", "a", "mov_relative", "cam_relative", "dirty")
    }

position.__index = function(entity, k)
    return position.data[k][entity.id]
end


function position.add(entity)
    local id = position.list:add(entity)
    position.data:add(0, 0, 0, false, true, true)
    return setmetatable({id = id}, position)
end

function position.remove(entity)
    position.list:remove(entity)
    position.data:remove(entity.position.id)
end

function position:moveRelative(bool) -- set position relative to last position
    position.data.mov_relative[self.id] = bool
end

function position:cameraRelative(bool) -- set position relative to world space (true) or screen space (false)
    position.data.cam_relative[self.id] = bool
end

function position:set(x, y)
    local rel = position.data.mov_relative[self.id]
    position.data.x[self.id] = x + rel and position.data.x[self.id] or 0
    position.data.y[self.id] = y + rel and position.data.y[self.id] or 0
end

function position:get()
    return position.data.x[self.id], position.data.y[self.id]
end

return position