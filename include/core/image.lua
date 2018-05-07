-- loads all images in /assets/img/ recursively. The _image_ table will match the directory structure.

local image = {}

local image_directory = "/assets/img/"

image.null = love.graphics.newImage("/assets/img/null3.png")



-- recursive file enumerator

local enumerate

enumerate = function(dir, ...)
    local level = select(1, ...) and select(1, ...) or image -- if recursion has occured, select the table at the current level, or else just start at the image table
    print(level)
    local items = love.filesystem.getDirectoryItems(dir)
    
    for i, v in ipairs(items) do -- loop through each item on this level
        local info = love.filesystem.getInfo(dir..v) -- get the item info
        print(dir..v)
        if info.type == "file" then
            local name = string.match(v, "[%w_-]+") -- string match for file name, discarding extension
            level[name] = love.graphics.newImage(dir..v) -- load the image
            
        elseif info.type == "directory" then
            level[v] = {}  -- create the next level for the image table
            enumerate(dir..v.."/", level[v])  -- recursively call the enumerator to continue loading the next level
        end
    end
end

enumerate(image_directory)


return image