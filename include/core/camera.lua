local camera = {
    x = 0,
    y = 0,
    scale = 1,
    max_x = math.huge,
    max_y = math.huge,
    rolloff = .3,
    follow_distance = 10,
}

local message = require("debug.debugger").newMessage
local chmath = require("helper.chmath")
local env = require("core.env")

function camera.follow(entity)
    if entity then
        camera.entity = entity
    else
        message("error", "Expected an entity as first parameter, got nil. Nothing to follow")
    end
end

function camera.update()
    if camera.entity then
        -- Get a target from the follow entity
        local target_x, target_y = camera.entity.position.x, camera.entity.position.y
        
        local dist = chmath.distance(target_x, target_y, camera.x+env.window_w/2, camera.y+env.window_h/2)
        local dir =  chmath.theta(target_x, target_y, camera.x+env.window_w/2, camera.y+env.window_h/2)
        local nx, ny = camera.x, camera.y
        
        -- create a small deadzone
        dist = (dist > 1) and dist or 0
        -- Move the camera toward the target
        if dist > camera.follow_distance then
            nx, ny = chmath.translate(camera.x, camera.y, dir, (dist-camera.follow_distance)*.05)
        end
        -- clamp the camera from 0 to max
        nx = nx < 0 and 0 or nx > camera.max_x-env.window_w and camera.max_x-env.window_w or nx
        ny = ny < 0 and 0 or ny > camera.max_y-env.window_h and camera.max_y-env.window_h or ny
        camera.x = nx
        camera.y = ny
    end
end

function camera.set(x, y)
    camera.x = x
    camera.y = y
end

return camera