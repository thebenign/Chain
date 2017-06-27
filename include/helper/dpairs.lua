--[[return function (dir, ext, ...)
    local files = love.filesystem.getDirectoryItems(dir)
    local i = 0
    local string, name = "", ""
    
    local function iterator(ext)
        i = i + 1
        if not files[i] then return nil end
        string = files[i]
        if love.filesystem.isFile(dir..string) then
            name = string.match(string, "[%w_-]+")
        end
        return i, name
    end
    return iterator, i, name
end
]]
return function (dir)
    local files = love.filesystem.getDirectoryItems(dir)
    local i = 0
    
    return function ()
        i = i + 1
        if not files[i] then return nil end
        return i, string.match(files[i], "[%w_-]+")
    end
end