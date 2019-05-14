local utf8 = require("utf8")
local traverse = require("import.recursive_import")

return function(chain)
    local component_table = {}
    local dir = "/include/component/"
    
    local env = setmetatable({
            chain = chain
            }, {__index = _G}
        )
    
    for node, name, path in traverse(dir, component_table, {"lua"}) do
        
        local func, err
        func, err = loadfile("."..path) -- load component as chunk
        if err then
            print(
                "Component Import encountered an error while attempting to import \""..name.."\": \n "
                ..utf8.char(0x21b3)..err.."\n"
                .."This component will not be loaded"
            ) -- check for errors
        else
            node[name] = setfenv(func, env)() -- assign the chunk as a function with our special environment
        end
    end

    return component_table
end