local env = {
    icon = love.image.newImageData("data/icons/05-12-18-small.png"),
    t = 1/60, -- game time step, typically 1/60 for 60 time steps per second
    dt = 0,   -- delta time incrementer
    alpha = 0, -- reserved for future use
    debug = false, -- enable debug mode
    background_color = {0,0,0},
    full_redraw = true -- enable complete erasure of canvas on every frame. Turning this off could improve frame rate, but may lead to graphical artifacts if you are not covering the entire game canvas with graphics on every frame.
}

-- Some defaults for input and other things. Placing initialization code here may be a good idea.

--require("slam")

io.stdout:setvbuf("no")  -- Don't buffer console output
love.graphics.setBackgroundColor(env.background_color)
local ico = love.window.setIcon(env.icon)
if env.debug then
    print(ico and "Window icon changed successfully" or "Unable to change window icon")
end

env.window_w, env.window_h = love.window.getMode()

love.keyboard.setKeyRepeat(true)
love.keyboard.setTextInput(false)
love.graphics.setDefaultFilter("nearest", "nearest")

return env