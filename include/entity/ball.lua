local ball = chain.register()

ball:has("position", "velocity", "sprite")

ball.sprite:set("coin", 1)

ball.velocity:set(math.random()*6, math.random()*2)

return ball