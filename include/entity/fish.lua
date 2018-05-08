local fish = chain.register()

fish:has("position", "velocity", "sprite", "timer", "label")

--local loc = ball.label(fish.position.x)
--loc:setWidth(128)


local deck = chain.data.spriteDeck("fishTile_073", "fishTile_075", "fishTile_077", "fishTile_079", "fishTile_081", "fishTile_101")

fish.sprite:set(deck, 1)
fish.sprite:setOrigin("center")
--fish.sprite.blend = "add"

fish.velocity:set(math.random()*(math.pi*2), math.random()*2)
fish.velocity.grav_mag = .02
fish.velocity.grav_dir = math.rad(0)
fish.velocity.max = 3

fish.sprite.rot = fish.velocity.dir

local lt = fish.timer()

lt:set(600, false)

lt.call = function()
  fish:destroy()
end

function fish.update()
    fish.sprite:setRotation(fish.velocity.dir)
    --loc:setText(string.format("Fishy boi\nx = %i", fish.position.x))
end

return fish