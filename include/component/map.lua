local map = {
    map_data = {},
    map_batch = {},
    load_map = require("load_map")
    }
map.__index = map

function map:give()
    self.id = "map"
    return setmetatable({}, map)
end

function map.entityFromData(i)
    local data = map.map_data.map
    return {
        position = {
            x = (i%data.width)*data.tilewidth,
            y = (math.floor(i/data.width))*data.tileheight
            }
        }
end


function map:new(name)
    map.map_data = map.load_map(name)
    map.map_batch = map.makeBatch(map.map_data)
end

function map.makeBatch(map_table)
    local data = map_table.map
    local tilesets = map_table.tilesets
    
    local batch = love.graphics.newSpriteBatch(tilesets[1], data.height*data.width, "static")
    local quad = {}
    local qh = data.tilesets[1].imagewidth/data.tilesets[1].tilewidth
    local qv = data.tilesets[1].imageheight/data.tilesets[1].tileheight
    for i = 0, qh*qv-1 do
        quad[i+1] = love.graphics.newQuad(
            i%qh * data.tilesets[1].tilewidth,
            math.floor(i/qh)*data.tilesets[1].tileheight,
            data.tilesets[1].tilewidth,
            data.tilesets[1].tileheight,
            data.tilesets[1].imagewidth,
            data.tilesets[1].imageheight
        )
    end
    for i = 1, #data.layers[1].data do
        if data.layers[1].data[i] > 0 then
            batch:add(
                quad[data.layers[1].data[i]], 
                (i-1)%data.width*data.tilesets[1].tilewidth, 
                math.floor((i-1)/data.height)*data.tilesets[1].tileheight
            )
        end
    end
    return batch
end

function map.update()
end

return map