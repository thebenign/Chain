-- spatial hash

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
end

function shash:add(entity, geometry)
    
end

function shash:getCellFromGeometry(geometry)
    local cells = {}
    
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
    
    return cells
end
