-- collider system version 2

-- import the spatial hash and world size
local hash = require("data.hash")(128)
local world = require("core.world").getSize()
local sat = require("helper.sat").sat
local camera = require("core.camera")
local debug = require("core.env").debug

-- hidden helper functions

local function normalize(x, y)
    local mag = math.sqrt(x^2 + y^2)
    -- don't divide by zero
    if mag == 0 then mag = 0.00001 end
    return x/mag, y/mag
end

local function dot(x1, y1, x2, y2)
    return x1 * x2 + y1 * y2
end



-- define the collider
local collider = {
    -- list of tracked "collidables"
    list = {},
    -- keep track of how many
    count = 0,
    -- define the types of collisions which can occur
    type_list = {["rectangle"] = 1, ["aabb"] = 2, ["circle"] = 3, ["point"] = 4, ["segment"] = 5}
  }

-- add to collider
function collider.add(obj)
    collider.count = collider.count + 1 -- increment the counter
    collider.list[collider.count] = obj -- 
    obj._collider_id = collider.count
end    

function collider.remove(obj)
    -- fix: collapse id count
    collider.list[obj._collider_id] = collider.list[collider.count]
    collider.count = collider.count - 1
end

function collider.update()
    -- step through registered entities, remove their old location and re-add
    for i = 1, collider.count do
        hash:update(collider.list[i])
    end
    
    -- step through collision prospect linked list
    
    local working_cell
    local working_entity
    local msuv, mag
    local normx, normy
    local vseg
    local dotp, dot_sign
    --print("---")
    for i = 1, hash.cpl.count do
        working_cell = hash.cpl[i] --sh.cell[sh.cpl[i]]
        --print(sh.cpl[i])
        for j = 1, working_cell.n do
            for k = (j+1), working_cell.n do
                
                --print(sh.cpl[i], j..": "..tostring(working_cell[j]), k..": "..tostring(working_cell[k]))
                
                working_entity = working_cell[k].entity
                
                msuv, mag = sat(working_cell[k].geo:asVec2(), working_cell[j].geo:asVec2())
                
                if msuv and mag then
                    if not working_cell[k].static then
                        working_cell[j].call()


                        -- get the velocity as a cardinal vec2
                        vseg = working_entity.velocity:toSegment()

                        -- normalize the velocity segment
                        normx, normy = normalize(vseg.x, vseg.y)

                        -- take the dot product against the rotated surface normal
                        dotp = dot(normx, normy, msuv.y, msuv.x)

                        -- take the sign
                        dot_sign = 0
                        dot_sign = dotp < 0 and -1 or 1

                        -- flip the x,y to get the perpendicular normal,
                        -- then multiply by the sign of the dot product for correct projection sign
                        working_entity.velocity.dir = math.atan2(msuv.x*dot_sign, msuv.y*dot_sign)
                        working_entity.velocity.mag = working_entity.velocity.mag*math.abs(dotp)

                        -- move the entity outside of the collision bounds
                        working_entity.position.x = working_entity.position.x + msuv.x * mag
                        working_entity.position.y = working_entity.position.y + msuv.y * mag

                        -- update the geometry to reflect changes
                        working_cell[k].geo:update()
                    end
                end
            end
        end
    end
end

function collider.draw()
    if debug then
        local xo, yo = camera.x, camera.y
        local col, row = math.ceil(world.h/hash.size), math.ceil(world.w/hash.size)
        local gb = 1
        for y = 1, col do
            for x = 1, row do
                if x*128 > xo and x*128 < xo + 1100 and y*128 > yo and y*128 < yo+900 then
                    gb = (sh.cell[(y-1) * col + x] and sh.cell[(y-1) * col + x].count > 0) and 0 or 1
                    love.graphics.setColor(1, gb, gb)
                    love.graphics.rectangle("line", x*hash.size-xo-hash.size, y*hash.size-yo-hash.size, hash.size, hash.size)
                    love.graphics.print(hash.cell[(y-1) * col + x] and hash.cell[(y-1) * col + x].n or 0, x*hash.size-xo-hash.size+4, y*hash.size-yo-hash.size+32)
                    love.graphics.print((y-1) * col + x, x*hash.size-xo-hash.size+4, y*hash.size-yo-hash.size+4)
                    love.graphics.setColor(1,1,1)

                end
            end
        end
    end
    --[[
    local cpl_list = ""
    for i = 1, hash.cpl.count do
        cpl_list = cpl_list..tostring(hash.cpl[i])..", "
    end
    love.graphics.print("CPLs: "..hash.cpl.count.."\nCPL List: "..cpl_list, 64, 64)--]]
end
return collider