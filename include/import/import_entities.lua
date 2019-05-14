local utf8 = require("utf8")
local traverse = require("import.recursive_import")

return function(project, chain)
    local entity_table = {}
    local dir = "/project/"..project.."/entities/"

    local env = setmetatable({chain = {
            find = chain.find,
            data = chain.data,
            image = chain.import.image,
            camera = chain.camera,
            loadScene = chain.loadScene,
            --new = function() end,
            register = function()
                local instance = {
                    _comp_enum = 0,
                    _draw_count = 0,
                    _drawable = {},
                    has = chain.has,
                    destroy = chain.destroy,
                    newChild = function(self, entity) return chain.new(entity, self) end
                }
                coroutine.yield(instance)
                return instance
            end
        }
    }, {__index = _G}) -- keep the global table

    for node, name, path in traverse(dir, entity_table, {"lua"}) do
        
        local func, err
        func, err = loadfile("."..path) -- load entity chunk
        if err then
            print(
                "The entity importer encountered an error while attempting to import \""..name.."\": \n "
                ..utf8.char(0x21b3)..err.."\n"
                .."The entity will not be loaded"
            ) -- check for errors
        else
            node[name] = setfenv(func, env) -- assign the chunk as a function with our special environment
        end
    end

    return entity_table
end