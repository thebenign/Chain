local world = {
    camera = require("core.camera"),
    music = require("core.music"),
    global_volume = .5,
    volume_lt = {["add"]=1, ["sub"]=-1},
    w = 2600,
    h = 2600,
    state = 0,
    state_script = {},
    default_font = love.graphics.newFont("data/fonts/KenVector Future.ttf", 14)
}

love.graphics.setFont(world.default_font)

function world.changeState(state)
    world.state = state
    
end

function world.update()
    world.camera.update()
end

function world.setSize(w, h)
    world.w = w
    world.h = h
end

function world.getSize()
    return {w = world.w, h = world.h}
end

function world.camFollow(entity)
    world.camera.follow(entity)
end

function world.startMusic(source)
    world.music[source]:setLooping(true)
    world.music[source]:setVolume(.6*world.global_volume)
    world.music[source]:play()
end

function world.setGlobalVolume(...)
  local arg = {...}
  if arg and arg[2] then
    if world.volume_lt[arg[1]] and type(arg[2])=="number" then
      world.global_volume = world.global_volume + arg[2] * world.volume_lt[arg[1]]
      print(world.global_volume)
    end
  elseif arg then
    if type(arg[1])=="number" then
      world.global_volume = arg[1]
    end
  end
  world.global_volume = math.min(1, math.max(0, world.global_volume))
  love.audio.setVolume(world.global_volume)
end


return world