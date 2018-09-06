-- Chained assignment prototype


-- Note: Within **chainMeta**, all index evaluations are done using rawget.
-- If an index is evaluated and doesn't exist, it triggers the __index metamethod.
-- If this happens within __index, we get a stack overflow.
local chainMeta = {
  __index = function(table, key)      -- When a non-existing key is indexed:
    table[key] = {}                   -- instantiant the new index as a table
    
    if rawget(table, "is_root") then  -- check to see if the parent is the root of the chain
      table[key].root = table         -- if so, store the parent in the 'root' variable for access later
    else
      table[key].root = table.root    -- if not, store the parent's pre-existing reference to root.
    end
    
    --print("index triggered: "..tostring(table)..", "..key) -- quick debugging lines
    --print("Creating new table: ".. tostring(table[key]))
    
    return setmetatable(table[key], getmetatable(table)) -- return the new table with the same metatable as its parent.
  end,
  
  __call = function(table, ...)       -- When the table is called as a method:
    
    local arg = {...}                 
    local calling_table = arg[1]      -- the first argument of a method call is always the table itself
                                      -- the second argument is the value we want to set.

    if rawget(calling_table, "is_root") then    -- if the calling table is the root of the chain, then this is the left hand side
      table[arg[2]] = {}                        -- of the equation.
      table.table_string = arg[2]               -- temporarily store the table key we are going to modify,
      table.lhs = true                          -- and flag it as lhs.
    elseif rawget(calling_table, "lhs") then                -- if the calling table is the lhs,
      calling_table[calling_table.table_string] = arg[2]    -- then we grab the table key we stored earlier and assign our value.
    end
    
    return table -- just return exactly as we came in.
  end,
  
}

return function(...)
  -- arguments are a comma separated list of strings allowed as table names.
  -- If the name is not provided, it will be rejected on construction.
  local table = {is_root = true, allowed_names = {...}}
  return setmetatable(table, chainMeta)
end