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
    
    --[[
    local new_list = {}
    local found = false

    for i = 1, comp.count do
        if z < comp.list[i].z or found then
            new_list[i] = comp.list[i - (found and 1 or 0)]
            new_list[i].id = i
        else
            new_list[i] = self
            self.id = i
            found = true
        end
    end
    comp.count = comp.count + 1
    if not found then
        new_list[comp.count] = self
        self.id = comp.count
    else
        new_list[comp.count] = comp.list[comp.count - 1]
        new_list[comp.count].id = comp.count
    end
    comp.list = new_list
    ]]
end


function comp.remove(id)
    for i = id, comp.count-1 do
        comp.list[i] = comp.list[i+1]
        comp.list[i].id = comp.list[i].id - 1
    end
    comp.count = comp.count - 1
end

return comp