local env = {
    icon = love.image.newImageData("med.png"),
    t = 1/60, -- game time step, typically 1/60 for 60 time steps per second
    dt = 0,   -- delta time incrementer
    alpha = 0, -- reserved for future use
    debug = false, -- enable debug mode
    background_color = {.8,.8,.8},
    full_redraw = true -- enable complete erasure of canvas on every frame. Turning this off could improve frame rate, but may lead to graphical artifacts if you are not covering the entire game canvas with graphics on every frame.
}

-- Some defaults for input and other things. Placing initialization code here may be a good idea.

require("slam")

io.stdout:setvbuf("no")  -- Don't buffer console output
love.graphics.setBackgroundColor(env.background_color)
print("Set window icon success: "..tostring(love.window.setIcon(env.icon)))

env.window_w, env.window_h = love.window.getMode()

love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.graphics.setDefaultFilter("linear", "linear")

return env