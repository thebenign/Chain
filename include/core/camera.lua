local camera = {
    x = 0,
    y = 0,
    rolloff = .6,
    follow_distance = 32,
    distance = require("trig").distance,
    theta = require("trig").theta,
    translate = require("trig").translate,
    env = require("env")
}

function camera.follow(entity)
    camera.entity = entity
end

function camera.update()
    if camera.entity then
        local dist = camera.distance(camera.entity.position.x, camera.entity.position.y, camera.x+camera.env.window_w/2, camera.y+camera.env.window_h/2)
        local dir = camera.theta(camera.entity.position.x, camera.entity.position.y, camera.x+camera.env.window_w/2, camera.y+camera.env.window_h/2)
        local nx, ny = camera.x, camera.y
        dist = (dist > .25) and dist or 0
        if dist > camera.follow_distance then
            nx, ny = camera.translate(camera.x, camera.y, dir, (dist-camera.follow_distance)^camera.rolloff)
        end

        camera.x = nx
        camera.y = ny
    end
end

return camera