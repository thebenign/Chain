local chmath = {}

-- return the distance between two points
function chmath.distance(x1, y1, x2, y2)
    return math.sqrt((y1-y2)^2 + (x1-x2)^2)
end

-- return the arc tangent of two points
function chmath.theta(x1, y1, x2, y2)
    return math.atan2(y1 - y2, x1 - x2)
end

-- return a new x, y pair transformed by a vector of direction and magnitude
function chmath.translate(x, y, dir, mag)
    -- returns x and y as two values
    return x + math.cos(dir)*mag, y + math.sin(dir)*mag
end

-- return a signed -1 or 1 matching the sign of the argument
function chmath.sign(n)
    return n < 0 and -1 or 1
end

return chmath