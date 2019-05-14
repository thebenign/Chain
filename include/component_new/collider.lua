
local cs = require("system.collider_system")

local collider = {}
collider.__index = collider

local instance_mt = {
    
    }

function collider.give(entity)
    return setmetatable({count = 0, entity = entity},collider)
end

function collider:using(geo)
    self.count = self.count + 1
    self[self.count] = 
    setmetatable({
            geo = geo,
            cell_i = {},
            cell_n = {},
            range = {l=-1, t=-1,r=-1,b=-1},
            cell_count = nil,
            solid = true,
            static = false,
            call = function() end,
            colliding = false,
            entity = self.entity
        }, instance_mt
    )
    
    cs.add(self[self.count])  -- add new collider object to the collider system
    return self[self.count]
end

function collider:remove(id)
    cs.remove(id)
end

function collider.destroy(entity)
    for i = 1, entity.collider.count do
        cs.remove(entity.collider[i])
    end
    return true
end

return collider