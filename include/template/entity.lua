-- returns various entity templates
local template = {}

function template.newCollider()
    local chain = require("core.ecs")
    local ent = setmetatable({}, chain)
    ent._name = "Collider Template"
    ent:has("position", "geometry", "collider")
    return ent
end

return template