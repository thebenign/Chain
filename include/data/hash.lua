-- new spatial hash prototype
-- This data structure is designed prioritizing speed over readability.
-- Generating as few tables as possible necessarily obfuscates some of the function calls.

--== Some local hidden helper functions ==--

local world = require("core.world").getSize()

-- Get the minimum bounding rectangle of the geometry

-- Fast floor
local function floor(n)
    return n - n % 1
end

local function getMbr(geo, div)
    
    local left = geo[1]
    local right = left
    local top = geo[2]
    local bottom = top
    
    for i = 3, #geo, 2 do
        if geo[i] < left then
            left = geo[i]
        elseif geo[i] > right then
            right = geo[i]
        end
        
        if geo[i+1] < top then
            top = geo[i+1]
        elseif geo[i+1] > bottom then
            bottom = geo[i+1]
        end
    end
    return floor(left/div), floor(top/div), floor(right/div), floor(bottom/div)
end
-- collapse (hash) a 2D table location into the cell table value
local function collapse(sh_inst, x, y)
  return y * sh_inst.h_cells + x
end

--====--

-- Set up the metatable to call the table as a function
local hash = {}
local mt = {__call = function(t, size) return hash.new(t, size) end}
setmetatable(hash, mt)



-- called when _Hash_ is called as a function, returns a new hash instance
function hash:new(size)
    local new = {
        size = size,
        h_cells = math.ceil(world.w/size),
        cell = {},
        cpl = {count = 0}
        }
    return setmetatable(new, {__index = hash})
end

function hash:update(obj)
    -- get the minimum bounding range
    if obj.entity.position._dirty then
        --print("position changed")
        local l, t, r, b = getMbr(obj.geo.v, self.size)
        -- check to see if it's changed
        if l ~= obj.range.l or t ~= obj.range.t or r ~= obj.range.r or b ~= obj.range.b then
            --print("cell changed"..l, t, r, b)
            -- if changed, update the obj's cell table and range
            obj.changed = true
            if obj.cell_count then
                self:remove(obj)
                self:updateCpl(obj)
            end
            self:setObjCell(obj, l, t, r, b)
            self:add(obj)
            self:updateCpl(obj)
        end
    end
end

function hash:add(obj)
    obj.cell_n = {}
    for i = 1, obj.cell_count do
        if not self.cell[obj.cell_i[i]] then self.cell[obj.cell_i[i]] = {n = 0} end
        local working_cell = self.cell[obj.cell_i[i]] -- more readable name
        working_cell.n = working_cell.n + 1
        working_cell[working_cell.n] = obj
        obj.cell_n[obj.cell_i[i]] = working_cell.n
    end
end

function hash:remove(obj)
    for i = 1, obj.cell_count do
        local working_cell = self.cell[obj.cell_i[i]]
        working_cell[working_cell.n].cell_n[obj.cell_i[i]] = obj.cell_n[obj.cell_i[i]]
        working_cell[obj.cell_n[obj.cell_i[i]]] = working_cell[working_cell.n]
        working_cell[working_cell.n] = nil
        working_cell.n = working_cell.n - 1
    end
    
end

function hash:updateCpl(obj)
    for i = 1, obj.cell_count do
        local working_cell = self.cell[obj.cell_i[i]]
        if working_cell.n > 1 and not working_cell.cpl_id then
            --print("adding cell: ("..tostring(working_cell)..") to CPL")
            self.cpl.count = self.cpl.count + 1
            self.cpl[self.cpl.count] = working_cell
            working_cell.cpl_id = self.cpl.count
        end
        if working_cell.n < 2 and working_cell.cpl_id then
            --print("removing cell from CPL")
            self.cpl[self.cpl.count].cpl_id = working_cell.cpl_id
            self.cpl[working_cell.cpl_id] = self.cpl[self.cpl.count]
            working_cell.cpl_id = nil
            self.cpl.count = self.cpl.count - 1
        end
    end
end

-- calculates the cells which the geometry occupies and pushes the list
-- into the object's _cells_ table
function hash:setObjCell(obj, l, t, r, b)
    local count = 0

    for y = t, b do
        for x = l, r do
            count = count + 1
            obj.cell_i[count] = collapse(self, x, y)+1
        end
    end
    obj.range.l, obj.range.t, obj.range.r, obj.range.b = l, t, r, b
    obj.cell_count = count
end

return hash