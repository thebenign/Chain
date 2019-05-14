local kirby = chain.register()

kirby:has("position", "sprite", "control", "timer", "state")

print(kirby.getParent())

kirby.position:set(100, 100)
kirby.position:relative(true)

-- Sprite setup
kirby.sprite:set(chain.image.kirby.kirby_common, 10)
kirby.sprite:setOrigin(12, 0)
kirby.sprite:createTilesheet(10, 6)

-- animation timers
local at_walk = kirby.timer()
local at_jump = kirby.timer()
local at_descend = kirby.timer()

local at_blink = kirby.timer(80); at_blink:start()
local at_blink_tween = kirby.timer(2, true)

-- common timers
local ct_run = kirby.timer()

-- animation states
local anim_state = kirby.state()
anim_state:add("stand", "duck", "walk")
local state = "stand"

local walking = false
local standing = true
local blink_count = 0

-- movement constants

local speed = {
    x = {1.265,0,1.265},
    y = {}
}

-- timer callbacks
at_blink.call = function()
    at_blink_tween:start()
    at_blink:stop()
    kirby.sprite.anim_frame = 2
end

at_blink_tween.call = function()
    if blink_count > 2 or not standing then
        at_blink_tween:set(2)
        at_blink_tween:stop()
        at_blink:reset()
        at_blink:start()
        blink_count = 0
        return
    end
    if at_blink_tween.t == 2 then
        at_blink_tween:set(15)
        kirby.sprite.anim_frame = 1
        blink_count = blink_count + 1
    else
        at_blink_tween:set(2)
        kirby.sprite.anim_frame = 2
    end
end

-- generic updates

function kirby.update()
    if standing and not at_blink.run then
        at_blink:start()
    elseif not standing then
        at_blink:stop()
    end
end

-- controls
kirby.control:on("left", 
    function()
        kirby.sprite:setScale(-1, 1)
        kirby.position:set(-speed.x[anim_state[state]], 0)
        state = "walk"
    end
)
kirby.control:on("right", 
    function()
        kirby.sprite:setScale(1, 1)
        kirby.position:set(speed.x[anim_state[state]], 0)
        state = "walk"
    end
)
kirby.control:on("down", 
    function()
        kirby.sprite.anim_frame = 21
        standing = false
        state = "duck"
    end
)
kirby.control:onRelease("down", 
    function()
        kirby.sprite.anim_frame = 1
        standing = true
        state = "stand"
    end
)

return kirby