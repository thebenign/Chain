local include_path = love.filesystem.getSource().."/include/"

package.path = package.path .. ";"
..include_path.."core/?.lua;"
..include_path.."component/?.lua;"
..include_path.."entity/?.lua;"
..include_path.."helper/?.lua;"
..include_path.."data/?.lua;"

local env = require("env")
local world = require("world")
local entity = require("ecs")

require("run")

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    entity.new("background")
    entity.new("banner")
    entity.new("spawn")
    world.startMusic(1)
end

function love.update(dt)
    env.dt = env.dt + dt
    if env.dt >= env.t then
        world.update()
        entity.update()
        env.dt = env.dt - env.t
        if love.mouse.isDown(1) then
            
            --for i = 1, 2 do
            local ball = entity.new("fish")
            ball.position:set(love.mouse.getPosition())
            --end
        end
        
    end
end

function love.mousepressed(x, y, b, t)

end


function love.draw()
    entity.draw()
end