-- Check if running Love2D framework
if not love then
    error("Chain requires the Love2D framework, but it was started in the standard Lua environment. Please start Chain from the Love2D runtime.")
end

-- Love2D version 11 is required
local ma, mi, re, code = love.getVersion()
if ma < 11 then
  error("The version of Love2D installed is lower than 11.0.0 but Chain requires version 11.0.0 or higher. Please update your version of Love2D.", 0)
end

package.path = package.path .. ";" .. love.filesystem.getSource().."/include/?.lua;"

local chain = require("core.ecs")

require("core.run")

return chain