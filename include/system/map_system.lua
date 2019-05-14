-- Map System

local compAdd = require("system.compositor").add
local compRem = require("system.compositor").remove
local camera = require("core.camera")
local newEntity = require("template.entity").newCollider

local map = {
    background_color = {0,0,0},
    tilesets = {},
    layers = {},
    comp_handle = {},
    collider_objects = {},
    entities = {},
}

local function loadTilesets(data, project)
    local ts = {}
    for i, tileset in ipairs(data.tilesets) do
        ts[i] = {}
        ts[i].quad = {}
        if tileset.image then
            ts[i].image = love.graphics.newImage("project/"..project.."/maps/"..tileset.image)
        else
            local imagedata = love.image.newImageData(tileset.tilewidth * tileset.tilecount, tileset.tileheight)
            for tile_i, tile in ipairs(tileset.tiles) do
                imagedata:paste(
                    love.image.newImageData("project/"..project.."/maps/"..tile.image),
                    (tile_i-1)*tileset.tilewidth, tileset.tileheight-tile.height,
                    0, 0,
                    tile.width, tile.height
                )
            end
            ts[i].vertical_offset = data.tileheight - tileset.tileheight
            ts[i].image = love.graphics.newImage(imagedata)
        end
        
        for j = 0, tileset.tilecount-1 do
            
            local x = (j % (tileset.columns > 0 and tileset.columns or tileset.tilecount)) * tileset.tilewidth
            local y = math.floor(j / (tileset.columns > 0 and tileset.columns or tileset.tilecount)) * tileset.tileheight
            ts[i].quad[tileset.firstgid + (tileset.tiles[1] and tileset.tiles[j+1].id or j)] = love.graphics.newQuad(
                x, y, 
                tileset.tilewidth, tileset.tileheight, 
                tileset.imagewidth or tileset.tilewidth*tileset.tilecount, tileset.imageheight or tileset.tileheight)
        end
    end
    return ts
end

local function getTilesetFromGid(data, gid)
    for i, tileset in ipairs(data.tilesets) do
        if gid >= tileset.firstgid and gid <= tileset.firstgid + (tileset.tiles[1] and tileset.tiles[tileset.tilecount].id or tileset.tilecount) then
            return i
        end
    end
    
    error("Unable to add GID: "..gid..". No tileset contains this GID")
end


local function loadLayers(data)
    local lt = {}
    local count = 0
    for i, layer in ipairs(data.layers) do
        if layer.type == "tilelayer" and layer.visible then
            count = count + 1
            lt[count] = {}
            lt[count].opacity = layer.opacity
            lt[count].z = layer.properties.z or 1
            local tilesets_used = {}
            local batches = 0
            
            for j = 1, layer.width * layer.height do
                local gid = layer.data[j]
                
                if gid ~= 0 then
                    local working_set = getTilesetFromGid(data, gid)
                    
                    local x = ((j-1) % layer.width) * data.tilewidth
                    local y = math.floor((j-1) / layer.height) * data.tileheight + (map.tilesets[working_set].vertical_offset or 0)
                    
                    if not tilesets_used[working_set] then
                        batches = batches + 1
                        tilesets_used[working_set] = batches
                        lt[count][batches] = love.graphics.newSpriteBatch(map.tilesets[working_set].image, layer.width * layer.height, "static")
                    end
                    lt[count][tilesets_used[working_set]]:add(map.tilesets[working_set].quad[gid], x, y)
                end
            end
        end
    end
    lt.count = count
    return lt
end

local function drawLayer(layer)
    return function()
        for i = 1, #layer do
            love.graphics.draw(layer[i], math.floor(-camera.x), math.floor(-camera.y))
        end
    end
end

local function makeCompositorHandles(data)
    for i = 1, map.layers.count do
        map.comp_handle[i] = {}
        map.comp_handle[i].draw = drawLayer(map.layers[i])
        map.comp_handle[i].z = map.layers[i].z
        compAdd(map.comp_handle[i])
    end
end
local function createColliderObj(data, visible)
    
    if data.shape == "rectangle" then
        local ent = newEntity()
        ent.position.x = data.x
        ent.position.y = data.y
        local rect = ent.geometry:new("rectangle")
        rect:set(data.width, data.height, 0, 0, math.rad(data.rotation), visible)
        local collider = ent.collider:using(rect)
        collider.static = true
        return ent
    end
    return nil
end

local function loadColObj(data)
    local layer_count = 0
    local ct = {}
    for i, layer in ipairs(data.layers) do
        if layer.type == "objectgroup" then
            if layer.properties.collider then
                layer_count = layer_count + 1
                ct[layer_count] = {}
                for j, object in ipairs(layer.objects) do
                    local obj = createColliderObj(object, layer.visible)
                    ct[layer_count][j] = obj
                end
            end
        end
    end
    return ct
end

function map.load(data)
    local project = require("core.ecs").state.project
    -- Properties
    map.background_color = data.backgroundcolor and {data.backgroundcolor[1]/255, data.backgroundcolor[2]/255, data.backgroundcolor[3]/255} or {0,0,0}
    love.graphics.setBackgroundColor(map.background_color)
    camera.max_x = data.width*data.tilewidth
    camera.max_y = data.height*data.tileheight
    
    -- Tilesets and tile layers
    map.tilesets = loadTilesets(data, project)
    map.layers = loadLayers(data)
    makeCompositorHandles(data)
    
    -- Objects
    map.collider_objects = loadColObj(data)
end

function map.update()
    
end

return map