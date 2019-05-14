local emitter = chain.register()

emitter:has("timer", "particle")

local rain = emitter.particle:newSystem()

rain.spread = 0
rain.min_s = 10
rain.max_s = 10
rain.lt = 100
rain.dist = 100
rain.scale = .25
rain.rot_s = 0
rain.fric = 0
rain.hsl = {150, 255, 200, .6}
rain.a = math.rad(130)
rain.r = math.rad(130)
rain.pps = 1
rain.rotate = false
rain.random_rotation = false
rain.run = true


local inst_timer = emitter.timer(1, true)

function emitter.update()
    rain.x = chain.camera.x+math.random(1700)
    rain.y = chain.camera.y-200
end

inst_timer.call = function()
    chain.new("splash")
end


return emitter