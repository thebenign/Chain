local bubble = chain.register()

bubble:has("sprite", "position", "velocity", "timer")

local deck = chain.data.spriteDeck("fishTile_123", "fishTile_125")
local lt = bubble.timer(1100, false)

bubble.sprite:set(deck, 4)
bubble.sprite:setColor(1,1,1,.35)
bubble.sprite.blend = "add"

bubble.position:set(math.random(900), 620)
bubble.velocity:set(math.rad(270), .6)

lt.call = function()
    bubble:destroy()
end

local random_angle = math.random()*math.pi*2

bubble.update = function()
    bubble.position.x = bubble.position.x + math.cos(bubble.position.y/64+random_angle)/4
end


return bubble