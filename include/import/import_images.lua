-- loads all images in _dir_ recursively. Returns new _image_table_ matching the directory structure.

local traverse = require("import.recursive_import")

return function(project)
    local image_table = {}
    local dir = "/project/"..project.."/assets/images/"
    
    for node, name, path in traverse(dir, image_table, {"png", "tga"}) do
        node[name] = love.graphics.newImage(path)
    end
    
    return image_table
end