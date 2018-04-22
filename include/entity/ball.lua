local ball = chain.register()

ball:has("position", "velocity", "sprite", "timer")

ball.sprite:set("ball_blue", 1)

--[[ball.velocity:set(math.random()*6, math.random()*2)

ball.lt = ball.timer()

ball.lt:set(200, false)

ball.lt.call = function()
  ball:destroy()
end
]]

return ball