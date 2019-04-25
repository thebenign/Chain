-- spatial hash

local world = require("core.world")
local vec2 = require("data.vec2")

-- === Helper Functions ===

-- accepts a 2D index and returns a collapsed 1D index for the spatial hash
local function collapse(sh_inst, x, y)
  return (y-1) * sh_inst.h_cells + x
end

-- returns minimum bounding rectangle for polygon
local function getMbr(geo)
    local left = geo.v[1]
    local right = left
    local top = geo.v[2]
    local bottom = top
    
    for i = 3, #geo.v, 2 do
        if geo.v[i] < left then
            left = geo.v[i]
        elseif geo.v[i] > right then
            right = geo.v[i]
        end
        
        if geo.v[i+1] < top then
            top = geo.v[i+1]
        elseif geo.v[i+1] > bottom then
            bottom = geo.v[i+1]
        end
    end
    return {min = vec2(left, top), max = vec2(right, bottom)}
end

local function updateCPL(sh)
    
end
-- ===


local shash = {}
shash.__index = shash


function shash.new(cell_size)
    local self = setmetatable(
        {
            cell_size = cell_size or 64,
            cell = {}, -- cell container
            cpl = {count = 0}   -- collision prospect list; tracks cells which contain more than one obj
                                -- This is an easy check, but doing it this way prevents thousands of checks per frame
        }
        , shash
    )
    
    self.h_cells = math.ceil(world.w / self.cell_size)
    
    return self
end

-- add object to the spatial hash
function shash:add(obj)
    local cells = self:getCellFromGeometry(obj.geo) -- get cells from geometry relative to spatial hash
    local working_cell
    obj.cells.count = cells.count
    
    for i = 1, cells.count do
        if not self.cell[cells[i]] then self.cell[cells[i]] = {count = 0} end
        working_cell = self.cell[cells[i]]
        
        working_cell.count = working_cell.count + 1       -- increment the cell count
        working_cell[working_cell.count] = obj            -- add the obj to the cell
        obj.cells[i] = {}
        obj.cells[i].indice = cells[i]    -- keep track of the cell position
        obj.cells[i].sub_indice = working_cell.count -- keep track of sub position
        
        
        if working_cell.count > 1 and (not working_cell.cpl_pointer) then  -- update the CPL
            self.cpl.count = self.cpl.count + 1
            self.cpl[self.cpl.count] = cells[i] -- add the working cell index to the top of the cpl stack
            working_cell.cpl_pointer = self.cpl.count -- track pointer to cpl index
        end
    end
end

-- remove object from the spatial hash
function shash:remove(obj)
    local working_cell
    local sub_cell
    for i = 1, obj.cells.count do
        working_cell = self.cell[obj.cells[i].indice]
        sub_cell = obj.cells[i].sub_indice
        --print(obj.cells[i].sub_indice)
        
        --working_cell[working_cell.count].sub_indice = obj.cells[i].sub_indice
        working_cell[obj.cells[i].sub_indice] = working_cell[working_cell.count]
        working_cell.count = working_cell.count - 1
        
        if working_cell.count < 2 and working_cell.cpl_pointer then
            self.cell[self.cpl[self.cpl.count]].cpl_pointer = working_cell.cpl_pointer
            self.cpl[working_cell.cpl_pointer] = self.cpl[self.cpl.count]
            self.cpl.count = self.cpl.count - 1
            working_cell.cpl_pointer = nil
        end
    end
    obj.cells = {}
end

function shash:addLink()
    
end


-- perform function on unique pairs in the cell
function shash:cellPairs(cell)
    local c_pairs = {}
    for i = 1, cell.count do
            c_pairs[i] = {}
        for j = (i+1), cell.count do
        end
    end
    
end



function shash:getCellFromGeometry(geo)
    
    local cells = {}
    local count = 0
    
    local range = getMbr(geo)
    
    local cell_x = math.floor(range.min.x / self.cell_size)
    local cell_y = math.floor(range.min.y / self.cell_size)
    
    local range_x = math.floor(range.max.x / self.cell_size)
    local range_y = math.floor(range.max.y / self.cell_size)
    

    
    for y = cell_y, range_y do
      for x = cell_x, range_x do
        count = count + 1
        cells[count] = collapse(self, x, y)
      end
    end
    cells.count = count
    return cells
end

return shash