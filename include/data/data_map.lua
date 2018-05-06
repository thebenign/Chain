-- simple map

local map = setmetatable(
    {list = {}, count = 0},
    {__call = function(t, w, h) map.new(w, h) end}
)
map.__index = map

map.new = function(w, h)
    -- constructor
    map.count = map.count + 1
    local map_obj = {
        w = w,
        h = h,
        size = w*h,
        id = map.count
    }
    setmetatable(map_obj, map)
    
    map.list[map.count] = map_obj
    
    return map_obj
end

function map.remove(self)
    map.list[self.id] = map.list[map.count]
    map.count = map.count - 1
end

return map