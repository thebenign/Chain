local image = {}

local files = love.filesystem.getDirectoryItems("/assets/img/")

image.null = love.graphics.newImage("/assets/img/null3.png")
for i, v in ipairs(files) do
    local name = string.match(v, "[%w_-]+")
    image[name] = love.graphics.newImage("/assets/img/"..v)
end

return image