function love.conf(t)
    t.identity = "Ironstar"
    t.window.resizable = true
    t.window.borderless = false
    t.window.vsync=true
    t.window.width=900
    t.window.height=720
    t.window.title="Ironstar Arena"
    
    t.accelerometerjoystick = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
    t.modules.thread = false
end