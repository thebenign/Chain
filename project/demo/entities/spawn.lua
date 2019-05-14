local spawn = chain.register()

spawn:has("timer")

local bubble_timer = spawn.timer(60, true)

bubble_timer.call = function()
    chain.new("bubble")
end


return spawn