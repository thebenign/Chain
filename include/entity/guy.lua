local guy = chain.register()

guy:has("position", "velocity")

--local body = guy.geometry:new("aabb")

guy.position:set(math.random(900)-64, math.random(600)-128)
--guy.position:relative(true)

--body:set(48, 138, 32, 64)

--guy.sprite:set(chain.image.tiles.character_wizard, 4)

--guy.control:on("space", function() end)

--[[
guy.control:on("left", function()
    guy.position:set(-2, 0)
  end
)
guy.control:on("right", function()
    guy.position:set(2, 0)
  end
)
guy.control:on("up", function()
    guy.position:set(0, -2)
  end
)
guy.control:on("down", function()
    guy.position:set(0, 2)
  end
)
]]

function guy.update()
  
end
return guy