--[[
#Data Oriented List class (think struct of arrays)
Creates a very simple table of unordered lists with a single index referencing the same position on all lists
Effectively changing a table of tables into an associative and concurrent table of key arrays
This data driven approach to tables of keys may perform faster than the "table of tables" approach
]]

local ul = require("data.unordered_list")

local dol = setmetatable({}, {__call = function(t, ...) return t.new(...) end})
dol.__index = dol

function dol.new(...)
    local n = select("#", ...)
    local t = {_count = 0, _params = n, _keys = {}}
    for i = 1, n do
        local key = select(i, ...)
        assert(type(key) == "string", "Argument #"..i.." to dol.new is the wrong type.\nExpected type: string, but recieved type: "..type(key))
        t[key] = {}
        t._keys[i] = key
    end
    
    return setmetatable(t, dol)
end

function dol:add(...)
    self._count = self._count + 1
    for i = 1, self._params do
        self[self._keys[i]][self._count] = select(i, ...)
    end
    return self._count
end

function dol:set(id, key, val)
    self[key][id] = val
end

function dol:setAll(id, ...)
    for i = 1, self._params do
        self[self._keys[i]][id] = select(i, ...)
    end
end

function dol:remove(id)
    for i = 1, self._params do
        self[self._keys[i]][id] = self[self._keys[i]][self._count]
    end
    self._count = self._count - 1
end

function dol:get(key, id)
    return self[key][id]
end

return dol