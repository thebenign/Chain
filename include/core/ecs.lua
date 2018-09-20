--[[
  == Entity Component System ==
    The ECS functions in much the same way as you expect.
    There are components defined in their respective component modules
    and entities are defined in lua files in the entity folder.
    Making a new entity is as simple as defining what components that entity
    will acquire.
    The heart of the ECS is the update callback. Once called, it steps through
    every active entity, updating all its components.
    Every component has an _update_ function and every entity calls their owned
    component's update as a method. This affords great flexibility because
    any entity can have any component or combination of components.
    But it also implies that each component is not aware of eachother.
    Mostly this is a good thing, but it can be hard to get things to work the
    way you want them to when you're not used to it.

]]

-- Love2D version 11 is required
local ma, mi, re, code = love.getVersion()
if ma < 11 then
  error("The version of Love2D installed is lower than 11.0.0 but Chain requires version 11.0.0 or higher. Update your version of Love2D.", 0)
end

-- Construct the core
local chain = setmetatable({
    enum = 0,         -- enumerate the entities for faster iteration
    list = {},        -- entity instance reference table
    component = {},   -- component table
    entity = {},      -- table of loaded entity files
    data = {},        -- data type table
    geometry = {},    -- geometry table
    }, {__call = function(t, name) return t.new(name) end})

chain.__index = chain

-- Load extra core modules
local compositor = require("compositor")
local image = require("image")
local dpairs = require("dpairs")
local env = require("env")

-- Load data types
chain.data.map = require("data_map")
chain.data.spriteDeck = require("sprite_deck")
chain.data.chainAssign = require("chain_assign")
chain.data.vec2 = require("vec2")
local utf8 = require("utf8")

-- Load Geometries
chain.geometry.aabb = require("aabb")

-- Load components
for i, file in dpairs("/include/component/") do
    chain.component[file] = require(file)
    setmetatable(chain.component[file], chain)
end

-- ===============================================================

-- _find_ Creates and returns a list of all entities which match _id_
function chain.find(id)
    local list = {}
    local found = false
    for i = 1, chain.enum do
        if chain.list[i]._id == id then
            list[#list+1] = chain.list[i]
            found = true
        end
    end
    return found and list or nil
end

-- This is the function which creates a new instance of an entity.
-- There must be an entity script called _name.lua_
function chain.new(name,...)
    local reg_ent = {id = name}
    local arg = {...}
    local parent = arg[1] or nil
    
    local stack_back = setmetatable(
        {
            register = function()
                reg_ent.parent = parent
                return setmetatable(reg_ent, chain)
            end,
            new = function(name)
                return chain.new(name, reg_ent)
            end
        }, chain)
    
    --local ent = require(name)(stack_back)
    local fenv = getfenv()
    fenv._id = name

    local ent = chain.entity[name]()
    chain.enum = chain.enum + 1
    chain.list[chain.enum] = ent


    return ent
end

-- Must be called at the top of your entity file to be able to use
-- the features of the ECS. Your entity will not function without it.
function chain.register()
    return setmetatable({_draw_count = 0, _drawable = {}}, chain)
end

-- Call this method to destroy an entity. Entities can only destroy themselves.
function chain:destroy()
    self._d = true
end

-- Call this method after _register_ to acquire components.
function chain:has(...)
    local args = {...}
    self._comp_enum = #args
    local fenv = getfenv()
    
    for i, v in ipairs(args) do
        assert(chain.component[v], '"'..fenv._id..'" tried to acquire component "'..v..'" which does not exist')
        self[v] = chain.component[v].give(self)
        self[i] = v
    end
end


function chain:addDrawable()
    --self._draw_count = self._draw_count + 1
    --self._drawable[self._draw_count] = typeof
    compositor.add(self)
end

function chain:setID(id)
    self._id = id
end

-- Call this function from your love.update() function.
-- Entity instances are updated by calling their components as methods.
-- If the entity requested destruction, it sends destroy requests to components.
-- The component may respond immediately or do some cleanup first.
-- Once all the components have cleaned up, the entity intance is destroyed.
-- If an entity requests destruction, it is flagged as non-existant, so you don't
-- have to worry about it continuing to do things after you destroy it,
-- even if the components are still cleaning up.
function chain.update()
    local ent, comp, ak
    for i = chain.enum, 1, -1 do
        ent = chain.list[i]
        
        if rawget(ent, "update") then
            ent.update()
        end
        
        for c = 1, ent._comp_enum do
            --comp = chain.component[ent[c]]
            --comp.update(ent)
            
            if rawget(chain.component[ent[c]], "update") then
                chain.component[ent[c]].update(ent)
            end
            
        end
        
        if ent._d then
            local enum = chain.list[i]._comp_enum
            for c = enum, 1, -1 do
                comp = chain.component[ent[c]]
                if rawget(comp, "destroy") then
                    ak = comp.destroy(ent)
                    if ak then ent:removeComponent(c) end
                else
                    ent:removeComponent(c)
                end
            end
            if ent._comp_enum == 0 then

        chain.list[i] = chain.list[chain.enum]
                chain.enum = chain.enum - 1
            end
        end
        
    end
end

function chain:removeComponent(comp)
    self[comp] = self[self._comp_enum]
    self._comp_enum = self._comp_enum - 1
    
end

-- Call this function from your love.draw()
-- It handles all the drawable compositing so you don't have to.
function chain.draw()
    if env.full_redraw then love.graphics.clear(love.graphics.getBackgroundColor()) end
    compositor.draw()
    --chain.component.particle.draw()
    --chain.component.gui.draw()
    --chain.component.collider.draw()
    love.graphics.print("Entities: "..chain.enum, 32, 32)
    love.graphics.print("FPS: "..love.timer.getFPS(), 32, 48)
end

-- Following code imports the game entities. They are not run until _new_ is called.
local cwd = love.filesystem.getSource()

for i, file in dpairs("include/entity/") do
  
    -- Environment default.
    local entity_env = setmetatable({
        chain = {
            register = function() return setmetatable({_comp_enum = 0, _draw_count = 0, _drawable = {}, id = file}, chain) end,
            find = chain.find,
            new = chain.new,
            data = chain.data,
            geometry = chain.geometry,
            image = image
        }
    }, {__index = _G}) -- keep the global table

    local func, err
    func, err = loadfile(cwd.."/include/entity/"..file..".lua") -- load entity files
    if err then 
        print(
            "The entity loader encountered an error while attempting to load \""..file.."\": \n "
            ..utf8.char(0x21b3)..err.."\n"
            .."The entity will not be loaded"
            ) -- check for errors
    else
        chain.entity[file] = setfenv(func, entity_env) -- assign the loaded entity function to its table
    end
    
    
end

return chain
