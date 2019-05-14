local splash = chain.register()

splash:has("position", "sprite", "timer")

splash.sprite:set(chain.image["splash_sheet"], 35)
splash.sprite.color = {.6, .6, .8, .7}
splash.sprite:setScale(math.random()*.25+.25, math.random()*.25+.25)
splash.sprite:setAnimation(6, 1, 6, 1)
splash.sprite:animationPlay()

splash.sprite.blend = "add"

splash.position:set(math.random(2000)+1600, 5750)

local timer = splash.timer(10, false)

timer.call = function()
    splash:destroy()
end

return splash