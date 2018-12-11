local geo_list = {
  ["aabb"] = require("geometry.aabb"),
  ["rectangle"] = require("geometry.rectangle")
}

local compRemove = require("system.compositor").remove

local geo = {}

local mt = {
    __index = geo,
    __call = function(_, self, geo_type) return geo.new(self, geo_type) end
}

function geo.give(entity)
    return setmetatable({entity = entity, count = 0}, mt)
end

function geo:new(geo_type)
    -- increment counter
    self.count = self.count + 1
    self[self.count] = geo_list[geo_type].new()
    self[self.count].entity = self.entity
    return self[self.count]
end

function geo:destroy()
    for i = 1, self.geometry.count do
        compRemove(self.geometry[i].id)
    end
    return true
end

function geo:remove()
  
end

function geo:update()
  for i = 1, self.geometry.count, 1 do
    self.geometry[i]:update()
  end
end


return geo