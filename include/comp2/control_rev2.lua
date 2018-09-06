local chainAssign = require("chain_assign")

local control = {}
local allowed_keys = {"press", "release", "down"}

function control.give()
  return chainAssign(allowed_keys)
end

function control:update()
  for k, v in pairs(self.down) do
    if k ~= "table_string" and k ~= "lhs" then
      if love.keyboard.isDown(k) then
        v(self)
      end
    end
  end
end
