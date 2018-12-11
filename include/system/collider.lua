-- collider system version 2

-- import the spatial hash and world size
local sh = require("system.sh")
local world = require("core.world").getSize()

-- define the collider
local collider = {
    -- list of tracked "collidables"
    list = {},
    -- keep track of how many
    count = 0,
    -- define the types of collisions which can occur
    type_list = {["rectangle"] = 1, ["aabb"] = 2, ["circle"] = 3, ["point"] = 4, ["segment"] = 5}
  }

-- add to collider
function collider.add(entity)
    collider.count = collider.count + 1
    collider.list[collider.count] = entity
    entity._collider_id = collider.count
end    

function collider.remove(entity)
    collider.list[entity._collider_id] = collider.list[collider.count]
    collider.count = collider.count - 1
end
    
function collider.update()
    local pair_list = {}
    for i = 1, collider.count do
        
    end
    
end


return collider