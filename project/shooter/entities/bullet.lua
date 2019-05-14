local bullet = chain.register()

bullet:has("position", "velocity", "sprite", "geometry", "timer", "collider")

bullet.position:set(bullet._parent.position:get())
bullet.velocity:set(bullet._parent.position.a, 12)
bullet.position.a = bullet._parent.position.a + math.pi/2
bullet.position:relative(true)
bullet.position:set(math.cos(bullet.velocity.dir)*50, math.sin(bullet.velocity.dir)*50)
bullet.position:relative(false)

bullet.sprite:set(chain.image.spaceMissiles_033, 0)
bullet.sprite:setOrigin("center")
bullet.sprite.color = {1,1,1,.4}

local bound = bullet.geometry:new("rectangle")
local w, h = chain.image.spaceMissiles_033:getDimensions()
bound:set(w, h, bullet.sprite.origin_x, bullet.sprite.origin_y, bullet.position.a, false)
local collide = bullet.collider:using(bound)

collide.call = function(ent, msuv)
    if ent._name == "Collider Template" then
        bullet:destroy()
    end
end

local lt = bullet.timer:new(120)

lt.call = function()
    bullet:destroy()
end


return bullet