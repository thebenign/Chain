-- The compositor accepts a drawable reference and adds it to the draw system.
-- For the sake of speed, z sorting is done for every entry at the time of addition.
-- This guarantees a nearly sorted list at all times and gives us linear sort times.

local comp = {
    list = {},
    count = 0,
    image = require("image"),
    batch = {}
}
comp.__index = comp


function comp.update()

end


function comp.draw()
    for i = comp.count, 1, -1 do
        comp.list[i]:draw()
    end
end

function comp:add()
    
    local found = false
    
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