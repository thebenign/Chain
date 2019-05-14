-- The compositor accepts a drawable reference and adds it to the draw system.
-- For the sake of speed, z sorting is done for every entry at the time of addition.
-- This guarantees a nearly sorted list at all times and gives us linear sort times.

-- Dev goal: attempt to build a spatial hash around this principle to sort within buckets
-- Such that drawables display in correct z sequence and have passive viewport occlusion.
local camera = require("core.camera")

local comp = {
    list = {},
    count = 0,
}
comp.__index = comp


function comp.update()

end


function comp.draw()
    for i = comp.count, 1, -1 do
        love.graphics.scale(camera.scale)
        comp.list[i]:draw()
        love.graphics.origin()
    end
end

function comp:add()
    if not self.z then self.z = 1 end
    local found = false
    
    -- linear time sort [O(n)]
    for i = 1, comp.count do
        if comp.list[i].z < self.z then
            found = i
            break
        end
    end
    if found then
        for i = comp.count, found , -1 do
            comp.list[i+1] = comp.list[i]
            comp.list[i+1].id = comp.list[i+1].id + 1
        end
        self.id = found
        comp.list[found] = self
    else
        self.id = comp.count+1
        comp.list[comp.count+1] = self
    end
    
    comp.count = comp.count + 1
end


function comp.remove(id)
    for i = id, comp.count-1 do
        comp.list[i] = comp.list[i+1]
        comp.list[i].id = comp.list[i].id - 1
    end
    comp.count = comp.count - 1
end

return comp