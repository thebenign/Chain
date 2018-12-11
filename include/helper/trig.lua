local trig = {
    sqrt = math.sqrt,
    atan2 = math.atan2,
    cos = math.cos,
    sin = math.sin
    }

-- return the distance between two points
function trig.distance(x1, y1, x2, y2)
    return trig.sqrt((y1-y2)^2 + (x1-x2)^2)
end

-- return the arc tangent of two points
function trig.theta(x1, y1, x2, y2)
    return trig.atan2(y1 - y2, x1 - x2)
end

-- return a new x, y pair translated by a vector of direction and magnitude
function trig.translate(x, y, dir, mag)
    -- returns x and y as two values
    return x + trig.cos(dir)*mag, y + trig.sin(dir)*mag
end

-- return a signed -1 or 1 matching the sign of the argument
function trig.sign(n)
    return n < 0 and -1 or 1
end

return trig