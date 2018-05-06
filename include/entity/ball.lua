local ball = chain.register()

ball:has("position", "velocity", "sprite", "timer", "label")

--local loc = ball.label(ball.position.x)

--ball.label:setText()

local deck = chain.data.spriteDeck("fishTile_073", "fishTile_075", "fishTile_077", "fishTile_079", "fishTile_081", "fishTile_101")

ball.sprite:set(deck, 1)
ball.sprite:setOrigin("center")

ball.velocity:set(math.random()*6, math.random()*4)

ball.sprite.rot = ball.velocity.dir

ball.lt = ball.timer()

ball.lt:set(200, false)

ball.lt.call = function()
  ball:destroy()
end

function ball.update()
    ball.sprite:setRotation(ball.velocity.dir)
end

return ball