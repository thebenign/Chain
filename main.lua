
local chain = require("chain")



function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    chain.new("ship")
    --entity.new("banner")
    --entity.new("spawn")
    --entity.new("sub")
    --world.startMusic(1)
end

function love.update(dt)
    chain.env.dt = chain.env.dt + dt
    if chain.env.dt >= chain.env.t then
        chain.world.update()
        chain.update()
        chain.env.dt = chain.env.dt - chain.env.t
    end
end

function love.draw()
    chain.draw()
end