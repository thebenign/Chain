-- loads all images in _dir_ recursively. Returns new _map_table_ matching the directory structure.

local traverse = require("import.recursive_import")

return function(project)
    local map_table = {}
    local dir = "/project/"..project.."/maps/"
    
    for node, name, path in traverse(dir, map_table, {"lua"}) do
        -- traverse returns a path. remove the prefix slash and file extension; convert slashes to dots for require
        node[name] = require(string.gsub(path:sub(2, -5), "/","."))
    end
    
    return map_table
end