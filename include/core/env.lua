local env = {
    t = 1/60, -- game time step, typically 1/60 for 60 time steps per second
    dt = 0,   -- delta time incrementer
    alpha = 0, -- reserved for future use
    debug = false, -- enable debug mode
    full_redraw = false -- enable complete erasure of canvas on every frame. Turning this off could improve frame rate, but may lead to graphical artifacts if you are not covering the entire game canvas with graphics on every frame.
}

require("slam")

love.window.setMode(0,0)

env.window_w, env.window_h = love.window.getMode()

function env.getEnv()
    return env
end

-- Some defaults for input and other things. Placing initialization code here may be a good idea.

love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.graphics.setDefaultFilter("linear", "linear")

return env