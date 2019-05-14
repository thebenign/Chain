-- Unordered list class
-- Entries in this list are always appended to the end.
-- Removals are achieved through an inverse lookup table
-- When an entry is removed, its value is replaced with the last entry, then the last entry is nilled for proper garbage collection
-- This list has O(1) entry and removal time but has no lookup methods so can never be ordered

local list = setmetatable({}, {__call = function(t) return t.new() end})
list.__index = list

function list.new()
    local t = setmetatable({count = 0, id_lookup = {}}, list)
    return t
end

function list:add(item)
    self.count = self.count + 1
    self[self.count] = item
    self.id_lookup[item] = self.count
    return self.count
end

local function rem(self, item)
    local id = self.id_lookup[item]
    self[id] = self[self.count]
    self.id_lookup[self[self.count]] = id
    self[self.count] = nil
    self.id_lookup[item] = nil
    self.count = self.count - 1
    return true
end

function list:remove(item)
    if self.id_lookup[item] then
        return rem(self, item)
    else
        return false
    end
end

function list:removeById(id)
    if self[id] then
        return rem(self, self[id])
    else
        return false
    end
end

function list:getId(item)
    return self.id_lookup[item]
end

function list:getItem(id)
    return self[id]
end

return list