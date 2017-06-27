return function(c1, c2)
    return math.sqrt((c1.y-c2.y)^2 + (c1.x-c2.x)^2) < c1.r+c2.r
end