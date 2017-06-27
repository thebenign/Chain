local music = {}
local files = love.filesystem.getDirectoryItems("/assets/music/")

for i, v in ipairs(files) do
    local name = string.match(v, "[%w_-]+")
    music[i] = love.audio.newSource("/assets/music/"..v, "stream")
end

return music