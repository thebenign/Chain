local chain = require("chain")

function love.load(arg)
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
        require("mobdebug").coro()
    end
    
    chain.load("shooter")
end

function love.update(dt)
    chain.update(dt)
end

function love.draw()
    chain.draw()
end