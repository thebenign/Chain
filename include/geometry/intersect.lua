-- intersection tests

local intersect = {}

local getDelta = function(entity)
    return {x = entity.position.x + math.cos(entity.velocity.dir)*entity.velocity.mag,
            y = entity.position.y + math.sin(entity.velocity.dir)*entity.velocity.mag}
end

intersect.segment = function(self, entity)
    local delta = getDelta(entity)
    local scaleX = 1 / delta.x
end
