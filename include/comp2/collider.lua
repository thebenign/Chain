-- collider version 2: good luck

local sh = require("sh")

local collider = {}

local mt = {
    with = function(self, w)
        self.collides_with[w] = true
        return({
                f = self.collides_with,
                w = w,
                does = function(self, func)
                    self.f[w] = func
                end
            }
        )
    end
}
mt.__index = mt


function collider:give()
    return setmetatable(
        {
            cells = {},
            dynamic = true,
            collides_with = {}
        }
        , mt)
      
end

return collider