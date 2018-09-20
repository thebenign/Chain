
local sub = chain.register()

sub:has("position", "sprite", "velocity", "control", "timer")

sub.position:set(450, 300)
sub.sprite:set("sub", 2)
sub.sprite:setOrigin("center")
sub.sprite.scale = .25

sub.velocity.fric = 0.01
sub.velocity.max = 20

local bub_time = sub.timer(6, true)
local moving = false

bub_time.call = function()
    if moving then 
        local bubble = chain.new("bubble") 
        bubble.position.x = sub.position.x-100
        bubble.position.y = sub.position.y
        end
end


sub.control:on("right", function()
        sub.velocity:add(0, .5)
        moving = true
    end)
sub.control:on("left", function()
        sub.velocity:add(math.pi, .5)
        moving = true
    end)
sub.control:on("up", function()
        sub.velocity:add(math.rad(270), .5)
        moving = true
    end)
sub.control:on("down", function()
        sub.velocity:add(math.pi/2, .5)
        moving = true
    end)

sub.control:onRelease({"up","down","left","right"}, function() moving = false end)

function sub.update()
  
  if sub.position.x < -100 then
    sub.position.x = 1000
  end
  if sub.position.x > 1000 then
    sub.position.x = -100
  end
  if sub.position.y < -50 then
    sub.position.y = 680
  end
  if sub.position.y > 680 then
    sub.position.y = -50
  end
end

return sub