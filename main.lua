local include_path = love.filesystem.getSource().."/include/"

package.path = package.path .. ";"
..include_path.."core/?.lua;"
..include_path.."component/?.lua;"
..include_path.."entity/?.lua;"
..include_path.."helper/?.lua;"

local env = require("env")
local world = require("world")
local entity = require("ecs")

require("run")

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
end

function love.update(dt)
    env.dt = env.dt + dt
    if env.dt >= env.t then
        world.update()
        entity.update(1)
        env.dt = env.dt - env.t
    end
end

function love.mousepressed(x, y, b, t)
    local ball = entity.new("ball")
    ball.position:set(x-16, y-16)
end


function love.draw()
    entity.draw()
end