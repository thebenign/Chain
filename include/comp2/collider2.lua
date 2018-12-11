-- collider version 2: good luck

-- define the collider
local collider = {
  list = {},
  count = {},
  type_list = {["rectangle"] = 1, ["aabb"] = 2, ["circle"] = 3, ["point"] = 4, ["segment"] = 5}
  }

-- chain give
function collider:give()

  local c = {
    id = collider.count, -- Entity's position in the collider list
    cells = {},         -- Entity's reference to cells it spans in spatial hash
    collides_with = {}, -- Explicit list of entities this entity collides with
    is_solid = true,    -- Solid objects are implicitly globally collidable
  }
  return c
end

function collider:update()
    local pair_list = {}
    for i = 1, #self.cells do
        for j = 1, #collider.list[self.cells[i]] do
            
    end
    
end


return collider