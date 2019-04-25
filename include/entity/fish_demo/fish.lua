local fish = chain.register()

fish:has("position", "velocity", "sprite", "timer", "label")

--local loc = fish.label(fish.position.x)
--loc:setWidth(128)


local deck = chain.data.spriteDeck("fishTile_073", "fishTile_075", "fishTile_077", "fishTile_079", "fishTile_081", "fishTile_101")

fish.sprite:set(deck, 1)
fish.sprite:setOrigin("center")
--fish.sprite.blend = "add"

fish.velocity:set(math.random()*(math.pi*2), math.random()*3)
fish.velocity.grav_mag = .03
fish.velocity.grav_dir = math.rad(0)
fish.velocity.max = 4

fish.position.a = fish.velocity.dir

local lt = fish.timer()

lt:set(600, false)

lt.call = function()
  fish:destroy()
end

function fish.update()
    fish.sprite:setRotation(fish.velocity.dir)
    fish.position.a = fish.velocity.dir
    --loc:setText(string.format("Fishy boi\nx = %i", fish.position.x))
    
  if fish.position.x < -100 then
    fish.position.x = 1000
  end
  if fish.position.x > 1000 then
    fish.position.x = -100
  end
  if fish.position.y < -50 then
    fish.position.y = 680
  end
  if fish.position.y > 680 then
    fish.position.y = -50
  end
end

return fish