
local utf8 = require("utf8")
local traverse = require("import.recursive_import")

return function(project)
    local scene_table = {}
    local dir = "/project/"..project.."/scenes/"
    
    for node, name, path in traverse(dir, scene_table, {"lua"}) do
        local func, err
        func, err = loadfile("."..path) -- load scene file
        if err then
            print(
                "The scene importer encountered an error while attempting to import \""..name.."\": \n "
                ..utf8.char(0x21b3)..err.."\n"
                .."The scene cannot be loaded"
            ) -- check for errors
        else
            node[name] = func -- assign the scene file
        end
    end
    
    return scene_table
end