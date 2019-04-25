
local chain = require("chain")

local block = {}

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    chain.load("raindrop")
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