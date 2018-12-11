package.path = package.path .. ";" .. love.filesystem.getSource().."/include/?.lua"

local chain = require("core.ecs")

require("core.run")

return chain