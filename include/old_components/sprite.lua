local sprite = {
    zenum = 0,
    zlist = {},
    image_table = require("image"),
    batch_table = require("map"),
    camera = require("camera")
    }
sprite.__index = sprite

function sprite.give(entity)
    local s = {
        img = sprite.image_table.null,
        color = {255,255,255,255},
        scale = 1, 
        rot = 0, 
        origin_x = 0, 
        origin_y = 0
        }
    setmetatable(s, sprite)
    return s
end

function sprite:setBatch(batch)
    self.img = sprite.batch_table.map_batch
end

function sprite:setSprite(img)
    self.img = sprite.image_table[img]
end

function sprite:setOrigin(x, y)
    self.origin_x, self.origin_y = x, y
end

function sprite.remove(id)
    for i = id, sprite.zenum-1 do
        sprite.zlist[i] = sprite.zlist[i+1]
        sprite.zlist[i].sprite.id = sprite.zlist[i].sprite.id - 1
    end
    sprite.zenum = sprite.zenum - 1
end

function sprite:register(ent, z)
    ent.sprite.z = z
    self:addZ(ent, z)
end

function sprite:addZ(entity, z)
    entity.sprite.z = z
    local new_list = {}
    local found = false
    
    for i = 1, sprite.zenum do
        if z < sprite.zlist[i].sprite.z or found then
            new_list[i] = sprite.zlist[i - (found and 1 or 0)]
            new_list[i].sprite.id = i
        else
            new_list[i] = entity
            self.id = i
            found = true
        end
    end
    sprite.zenum = sprite.zenum + 1
    if not found then
        new_list[sprite.zenum] = entity
        entity.sprite.id = sprite.zenum
    else
        new_list[sprite.zenum] = sprite.zlist[sprite.zenum - 1]
        new_list[sprite.zenum].sprite.id = sprite.zenum
    end
    
    sprite.zlist = new_list
    collectgarbage()
end

function sprite.update(entity)
end

function sprite:destroy()
    sprite.remove(self.sprite.id)
    return true
end

function sprite.draw()
    local entity
    for i = sprite.zenum, 1, -1 do
        entity = sprite.zlist[i]
        love.graphics.setColor(255,255,255,255)
        if entity.sprite.quad then

        else
            love.graphics.draw(
                entity.sprite.img,
                math.floor(entity.position.x-(entity.position.relative and sprite.camera.x or 0)),
                math.floor(entity.position.y-(entity.position.relative and sprite.camera.y or 0)), 
                entity.sprite.rot, 
                entity.sprite.scale, 
                entity.sprite.scale, 
                entity.sprite.origin_x, 
                entity.sprite.origin_y
            )
        end
    end
end

return sprite