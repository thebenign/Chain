local function load_map(name)
    local f = "assets.maps."..name
    local map = require(f)
    local tilesets = {}
    for i, v in ipairs(map.tilesets) do
        tilesets[i] = love.graphics.newImage("assets/maps/"..v.image)
    end
    
    
    return {map = map, tilesets = tilesets}
end

return load_map