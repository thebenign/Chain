local pos = {}

pos.__index = function(t, k)
    print("ent accessing comp:")
    print("ID: "..t.id)
    return pos
end

function pos.getX(id)
    return id
end

print("creating component: "..tostring(pos))


local ent = {pos = setmetatable({id = 1}, pos)}
print("creating entity link: "..tostring(ent.pos))

print(ent.pos.x)