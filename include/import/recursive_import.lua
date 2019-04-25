
-- recursive directory iterator

return function(dir, table, ...)
    -- fix trailing slash
    if string.sub(dir, -1) ~= "/" then
        dir = dir.."/"
    end
    
    -- get the filter table
    local filter = {}
    local filtered = false
    for i, v in ipairs(select(1, ...) and select(1, ...) or {}) do
        filter[v] = i
        filtered = true
    end
    -- recursion coroutine
    local function traverse(dir, ...)
        local node = select(1, ...) and select(1, ...) or table
        
        local items = love.filesystem.getDirectoryItems(dir)
        
        for i, v in ipairs(items) do
            local info = love.filesystem.getInfo(dir..v)
            
            if not string.match(v, "^%.") then -- ignore hidden files/folders
                -- if the item is a file, match the filetype filter values
                if info.type == "file" and (filtered and filter[string.match(v, "[^%.]+$")] or not filtered) then
                        -- string match for file name, discarding extension
                        local name = string.match(v, "[%w%s_-]+")
                        -- yield the coroutine, returning the values for table insertion
                        coroutine.yield(node, name, dir..v)
                elseif info.type == "directory" then
                    node[v] = {}  -- create the next node in the table
                    traverse(dir..v.."/", node[v])  -- recursively call traverse
                end
            end
        end
    end
    
    local co = coroutine.create(function() traverse(dir) end)
    
    return function()
        local _, node, name, path = coroutine.resume(co)
        return node, name, path
    end
    
    
end
