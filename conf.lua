function love.conf(t)
    t.window.resizable = true
    t.window.borderless = false
    t.window.vsync=true
    t.window.width=900
    t.window.height=600
    t.window.title="Untitled Game"
    
    t.accelerometerjoystick = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
    t.modules.thread = false
end