-- collider version 2: good luck

-- import the spatial hash and world size
local sh = require("sh")
local world = require("world").getSize()

-- define the collider
local collider = {
  list = {},
  enum = {}
  }

function collider:give()
  collider.enum = collider.enum + 1
  collider.list[collider.enum] = self
  
  -- create the unique collider handler for the entity
  local c = {
    id = collider.enum, -- Entity's position in the collider list
    cells = {},         -- Entity's reference to cells it spans in spatial hash
    collides_with = {}, -- Explicit list of entities this entity collides with
    is_solid = true,    -- Solid objects are implicitly globally collidable
  }
  return c
end

function collider:update()
  
end


return collider