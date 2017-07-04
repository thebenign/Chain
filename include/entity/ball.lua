return function(entity)
    local ball = entity.register()
    
    ball:has("sprite", "position")
    
    ball.sprite:set("coin", 1)
    ball.sprite:activate()
    
    return ball
    
end
