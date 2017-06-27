local trig = {
    sqrt = math.sqrt,
    atan2 = math.atan2,
    cos = math.cos,
    sin = math.sin
    }

function trig.distance(x1, y1, x2, y2)
    return trig.sqrt((y1-y2)^2 + (x1-x2)^2)
end

function trig.theta(x1, y1, x2, y2)
    return trig.atan2(y1 - y2, x1 - x2)
end

function trig.translate(x, y, dir, mag)
    return x + trig.cos(dir)*mag, y + trig.sin(dir)*mag
end

return trig