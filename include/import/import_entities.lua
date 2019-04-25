local utf8 = require("utf8")
local traverse = require("import.recursive_import")

return function(project, chain)
    local entity_table = {}
    local dir = "/project/"..project.."/entities/"

    for node, name, path in traverse(dir, entity_table, {"lua"}) do
        local env = setmetatable({
            chain = {
                register = function() return setmetatable({_comp_enum = 0, _draw_count = 0, _drawable = {}, id = name}, chain) end,
                find = chain.find,
                new = chain.new,
                data = chain.data,
                image = chain.import.image,
                camera = chain.camera,
                loadScene = chain.loadScene
                }
            }, {__index = _G}) -- keep the global table

        local func, err
        func, err = loadfile("."..path) -- load scene file
        if err then
            print(
                "The entity importer encountered an error while attempting to import \""..name.."\": \n "
                ..utf8.char(0x21b3)..err.."\n"
                .."The entity will not be loaded"
            ) -- check for errors
        else
            node[name] = setfenv(func, env) -- assign the scene file
        end
    end

    return entity_table
end