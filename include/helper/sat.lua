local vec2 = require("data.vec2")

local s = {}

local function getEdgeNormals(verts)
    if verts == nil then return nil end
    local edge_normals = {}
    local edge, normal
    
    for i = 1, #verts do -- loop over all vertices
        
        edge = verts[i] - (verts[i + 1] or verts[1]) -- get the current edge vector
        
        normal = edge:getNormal() -- get the surface normal of the vector
        
        normal = normal:normalize() -- normalize
        
        edge_normals[#edge_normals + 1] = normal
    end
    return edge_normals
end

local function project(verts, axis)
    local min = axis:dot(verts[1]) -- get the first projections
    local max = min
    local proj
    
    for i = 2, #verts do -- loop over all vertices
        proj = axis:dot(verts[i]) -- current projection
        if proj < min then
            min = proj
        elseif proj > max then
            max = proj
        end
    end
    return min, max
end


function s.sat(poly1, poly2)
    local axes = getEdgeNormals(poly1)
    local axes2 = getEdgeNormals(poly2)
    local min_penetration_axis = nil
    local axis, p1min, p1max, p2min, p2max
    local overlap = math.huge
    local o, new_low
    local len1 = #axes
    local len2 = #axes2
    local mul = 1
    for i = 1, len2 do axes[len1+i] = axes2[i] end
    for i = 1, #axes do
        axis = axes[i]
        p1min, p1max = project(poly1, axis)
        p2min, p2max = project(poly2, axis)
        
        if p1min > p2max or p2min > p1max then
            return nil, nil
        end
        
        o = math.min(p1max, p2max) - math.max(p1min, p2min)
        --o = (p1max-p2max) - (p1min - p2min)
        --print(p1min, p1max,", ",p2min, p2max)
        --print(o)
        if o <= overlap and (p1max-p1min)>(p2max-p1min) then 
            overlap = o
            min_penetration_axis = axis
            --print(axis)
            
            --if o < (p2max-p1min) and o < (p1max-p2min) then mul = -1 end
        end
        
        --print("-")
    end
    
    return min_penetration_axis, overlap*mul --overlap
end

return s