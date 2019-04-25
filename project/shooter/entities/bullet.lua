local bullet = chain.register()

bullet:has("position", "velocity", "sprite", "geometry", "timer")

bullet.sprite:set("laserBlue07", 0)
bullet.sprite:setOrigin("center")
bullet.sprite.color = {1,1,1,.4}

local lt = bullet.timer:new(30)

lt.call = function()
    bullet:destroy()
end


return bullet