local sound = {}
local files = love.filesystem.getDirectoryItems("/assets/sfx/")

for i, v in ipairs(files) do
    if love.filesystem.isFile("/assets/sfx/"..v) then
        local name = string.match(v, "[%w_-]+")
        sound[name] = love.audio.newSource("/assets/sfx/"..v, "static")
    end
end

return sound