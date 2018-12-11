local collider = {
    list = {},
    cell = {},
    enum = 0,
    size = 150,
    resolvers = {
        c2r = require("c2r"),
        c2c = require("c2c"),
        none = function() end
    },
    env = require("env"),
    world = require("world").getSize(),
    cam = require("camera"),
    map = require("map")
}

collider.__index = collider
collider.w = math.ceil(collider.world[1]/collider.size)

function collider:give()
    collider.enum = collider.enum + 1
    collider.list[collider.enum] = self
    return setmetatable({
            id = collider.enum, 
            cells = {l = {}, n = {}},
            hash = {},
            l = {},
            n = 0,
            dynamic = true,
            collides_with = {},
            collider_call = {},
            _blocked_by = {}
            }, collider)
end

function collider:collidesWith(...)
    local arg = {...}
    self.has_resolvers = true
    for i = 1, #arg do
        self.collides_with[arg[i]] = collider.resolvers.none
    end
end

function collider:blockedBy(...)
    local arg = {...}
    for i = 1, #arg do
        self._blocked_by[arg[i]] = true
    end
end

function collider:setAction(with, resolver)
    self.collides_with[with] = collider.resolvers[resolver]
end

function collider:setFunctionOn(with, func)
    self.collider_call[with] = func
end
    
function collider:setType(t, ...)
    local arg = {...}
    if t == "rectangle" then
        self.w = arg[1]
        self.h = arg[2]
        self.addMethod = collider.addRectangle
    elseif t == "circle" then
        self.r = arg[1]
        self.w = arg[1]*2
        self.h = arg[1]*2
        self.addMethod = collider.addCircle
    elseif t == "point" then
        self.w = 0
        self.h = 0
    elseif t == "map" then
        collider.addMethod = collider.addRectangle
        collider.addMap()
        self.dynamic = false
    else
        error(t.." is not a valid collider type")
    end
    self.t = t
end

function collider:remove()
    local gcell, ecell
    for i = 1, self.collider.n do
        ecell = self.collider.cells
        gcell = collider.cell[ecell.l[i]]
        collider.cell[self.collider.cells.l[i]].l[self.collider.cells.n[i]] = 
        collider.cell[self.collider.cells.l[i]].l[collider.cell[self.collider.cells.l[i]].n]
        collider.cell[self.collider.cells.l[i]].n = collider.cell[self.collider.cells.l[i]].n - 1
    end
end

function collider:add()
    self.collider.addMethod(self)
    local collider_cell, e_cell
    for i = 1, self.collider.n do
        e_cell = self.collider.cells.l[i]
        collider.cell[e_cell] = collider.cell[e_cell] or {l={},n=0}
        collider_cell = collider.cell[e_cell]
        collider_cell.n = collider_cell.n + 1
        collider_cell.l[collider_cell.n] = self
        self.collider.cells.n[i] = collider_cell.n
    end
end

function collider.addCircle(self)
    return collider.updateCells(self, self.position.x-self.collider.r, self.position.y-self.collider.r, self.collider.w, self.collider.h)
end

function collider:addRectangle()
    return collider.updateCells(self, self.position.x, self.position.y, self.collider.w, self.collider.h)
end

function collider.addMap()
    local map_obj, map_data
    map_data = collider.map.map_data.map
    
    for i = 1, map_data.layers[1].width*map_data.layers[1].height do
        if map_data.layers[1].data[i] > 0 then
            map_obj = collider.map.entityFromData(i-1)
            map_obj.collider = collider.give(map_obj)
            map_obj.collider.w = map_data.tilewidth
            map_obj.collider.h = map_data.tileheight
            map_obj.collider.dynamic = false
            map_obj._id = "map"
            collider.add(map_obj)
        end
    end
end

function collider.getCell(x, y)
    local tx, ty
    tx = x/collider.size
    ty = y/collider.size
    return (ty-ty%1)*collider.w+(tx-tx%1)+1
end


function collider.updateCells(self, x, y, w, h)
    local c, n = 0, 0
    local tx, ty
    for i = 1, self.collider.n do
        self.collider.hash[self.collider.l[i]] = nil
        self.collider.cells.l[i] = nil
    end
    for i = 1, 4 do
        tx = (x + (i%2==0 and 0 or w-1)) / collider.size
        ty = (y + (i>2 and 0 or h-1)) / collider.size
        c = (ty-ty%1)*collider.w+(tx-tx%1)+1
        
        if not self.collider.hash[c] then
            n = n + 1
            self.collider.l[n] = c
            self.collider.hash[c] = true
            self.collider.cells.l[n] = c
        end
    end
    self.collider.n = n
end

function collider:update()
    if self.collider.dynamic then
        collider.remove(self)
        collider.add(self)
    end
    local entity, hit
    for i = 1, self.collider.n do
        for j = 1, collider.cell[self.collider.cells.l[i]].n do
            entity = collider.cell[self.collider.cells.l[i]].l[j]
            if self ~= entity and self.collider.has_resolvers and self.collider.collides_with[entity._id] then
                hit = collider.resolvers.c2r(
                    {x = self.position.x, y = self.position.y, r = self.collider.r},
                    {x = entity.position.x, y = entity.position.y, w = entity.collider.w, h = entity.collider.h}
                )
                if hit then
                    if hit.delta.x then
                        self.position.x = self.position.x + hit.delta.x
                        local norm = math.rad(hit.normal.x * 180)
                        self.velocity.dir = 2 * norm - math.pi - self.velocity.dir
                    end
                    if hit.delta.y then
                        self.position.y = self.position.y + hit.delta.y
                        local norm = math.rad(hit.normal.y * 90)
                        self.velocity.dir = 2 * norm - math.pi - self.velocity.dir
                    end
                    --self.velocity.mag = self.velocity.mag*.75
                    if self.collider.collider_call[entity._id] then
                        self.collider.collider_call[entity._id](self)
                    end
                    if entity.collider.collider_call[self._id] then
                        entity.collider.collider_call[self._id](entity)
                    end
                end
            end
            --if hit then break end
        end
        
    end
    
    ENUM = collider.enum
end

function collider:destroy()
    local id = self.collider.id
    collider.remove(self)
    collider.list[collider.enum].collider.id = id
    collider.list[id] = collider.list[collider.enum]
    collider.enum = collider.enum - 1
    return true
end

function collider.draw()
    love.graphics.setColor(255,255,255,150)
    local cam_x = math.floor(collider.cam.x)
    local cam_y = math.floor(collider.cam.y)
    local floor = math.floor
    --if collider.env.debug then
        for y = 0, collider.w-1 do
            for x = 0, collider.w-1 do
                love.graphics.print(collider.cell[y*collider.w+x+1] and collider.cell[y*collider.w+x+1].n or 0,x*collider.size-cam_x, y*collider.size-cam_y)
                love.graphics.rectangle("line", x*collider.size-cam_x, y*collider.size-cam_y, collider.size, collider.size)
            end
        end
    --end
    love.graphics.setColor(255,255,255,255)
end

return collider