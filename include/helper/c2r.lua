local collisions = {abs = math.abs}

function collisions.circleRect(circle, rect)
    local cdx, cdy
    local cornerDistance_sq
    cdx = collisions.abs(circle.x - (rect.x+rect.w/2))
    cdy = collisions.abs(circle.y - (rect.y+rect.h/2))

    if cdx > rect.w/2 + circle.r then return false end
    if cdy > rect.h/2 + circle.r then return false end

    if cdx <= rect.w/2 then return true end
    if cdy <= rect.h/2 then return true end

    cornerDistance_sq = (cdx - rect.w/2)^2 + (cdy - rect.h/2)^2

    return (cornerDistance_sq <= (circle.r^2))
end

local function circleRect2(circle, rect)
    --intersectPoint: (point) ->
    local function sign(x)
        return x>0 and 1 or x<0 and -1 or 0
    end
    
    local dir = math.atan2(circle.y-(rect.y+rect.h/2), circle.x-(rect.x+rect.w/2))
    local point = {x=circle.x-math.cos(dir)*circle.r, y=circle.y-math.sin(dir)*circle.r}
    local dx = point.x - (rect.x + rect.w/2)
    local px = (rect.w/2) - math.abs(dx)
    if px <=0 then
        return false
    end

    local dy = point.y - (rect.y + rect.h/2)
    local py = (rect.h/2) - math.abs(dy)
    if py <= 0 then
        return false
    end

    local hit = {}
    hit.point = point
    hit.delta = {}
    hit.normal = {}
    hit.pos = {}

    if px < py then
        local sx = sign(dx)
        hit.delta.x = px * sx
        hit.normal.x = sx
        hit.pos.x = rect.x + ((rect.w/2) * sx)
        hit.pos.y = point.y
    else
        local sy = sign(dy)
        hit.delta.y = py * sy
        hit.normal.y = sy
        hit.pos.x = circle.x
        hit.pos.y = point.y + ((rect.w/2) * sy)
    end
    return hit
end
return circleRect2