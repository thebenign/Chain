local hero = chain.register()

hero:has("position", "sprite", "velocity", "control", "geometry", "collider")

hero.sprite:set(chain.image["raindrop"], 30)
hero.sprite:setOrigin("center")
--hero.sprite:setAnimation(6, 1, 6, 3)

hero.position:set(3000, 5200)
local cam = chain.new("camera")

-- physics
local grav = 0.6
local jump_velocity = 14
local can_jump = true
local max_speed = 5
local speed = 1
local air_speed = .2

hero.velocity.grav_dir = math.pi/2
hero.velocity.grav_mag = 0.5
hero.velocity.max = 16

local rect = hero.geometry:new("rectangle")
rect:set(0, 0, 64, 66, 0, 0, 0, false)

local collider = hero.collider:using(rect)

collider.call = function(entity, msuv)
    
    if msuv.y < 0 then
        hero.velocity.grav_mag = 0
        hero.velocity.fric = 1.5
        can_jump = true
        speed = 1.5
    end
end

hero.update = function()
    cam.position:set(hero.position:get())
    if not hero.collider.colliding then
        hero.velocity.grav_mag = grav
        hero.velocity.fric = 0
        can_jump = false
    else
        
    end
end

hero.control:on("up", function()
        if can_jump then
            hero.velocity:add(math.rad(270), jump_velocity)
            can_jump = false
            speed = .2
        end
    end
)
hero.control:on("space", function()
        local e = chain.new("splash")
        e.position:set(hero.position:get())
    end
)

hero.control:on("left", function()
        hero.velocity:add(math.pi, speed)
        hero.velocity:clampAxis("horizontal", max_speed)
        mirror = -1
        hero.sprite.xs = -1
    end
)
hero.control:on("right", function()
        hero.velocity:add(0, speed)
        hero.velocity:clampAxis("horizontal", max_speed)
        mirror = 1
        hero.sprite.xs = 1
    end
)

return hero