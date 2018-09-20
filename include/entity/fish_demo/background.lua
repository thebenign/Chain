local bg = chain.register()

bg:has("sprite", "position")

local batch = love.graphics.newSpriteBatch(chain.image.pattern23, 16, "dynamic")

for y = 0, 2 do
    for x = 0, 3 do
        batch:add(x*256, y*256)
    end
end

bg.sprite:set(batch, 0)
bg.sprite:setColor(.4,.6,1,.6)


return bg