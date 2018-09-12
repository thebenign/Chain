-- spatial hash

local world = require("world")

-- === Helper Functions ===

local function collapse(sh_inst, vec)
  return vec.y * sh_inst.h_cells + vec.x
end


-- ===


local shash = {}
shash.__index = shash


function shash.new(cell_size)
    local self = setmetatable(
        {
            cell_size = cell_size or 64,
            cell = {},
            list = {},
        }
        , shash
    )
    
    self.h_cells = math.ceil(world.w / self.cell_size)
    
    return self
end

function shash:add(entity, geometry)
    
end

function shash:getCellFromGeometry(geometry)
    -- start over-engineered code
    
    --[[local cells = {}
    
    local c, n = 0, 0
    local points = geometry:getPoints()
    local tx, ty

    for i = 1, 4 do
        tx = points[i*2-1] / self.cell_size
        ty = points[i*2] / self.cell_size
        c = (ty-ty%1)*collider.w+(tx-tx%1)+1
        
        if not self.collider.hash[c] then
            n = n + 1
            self.collider.l[n] = c
            self.collider.hash[c] = true
            self.collider.cells.l[n] = c
        end
    end
    ]]
    
    local cells = {}
    local count = 0
    local point = geometry:getPoints()
    
    local cell_x = math.floor(point[1].x / self.cell_size)
    local cell_y = math.floor(point[1].y / self.cell_size)
    
    local range_x = math.floor(point[4].x / self.cell_size)
    local range_y = math.floor(point[4].y / self.cell_size)
    
    for y = cell_y, range_y do
      for x = cell_x, range_x do
        count = count + 1
        cells[count] = collapse(self, {x, y})
      end
    end
    
    return cells
end