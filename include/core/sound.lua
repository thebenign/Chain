local sound = {}
local files = love.filesystem.getDirectoryItems("/assets/sfx/")

for i, v in ipairs(files) do
    local info = love.filesystem.getInfo("/assets/sfx/"..v)
    if info.type == "file" then
        local name = string.match(v, "[%w_-]+")
        sound[name] = love.audio.newSource("/assets/sfx/"..v, "static")
    end
end

return sound