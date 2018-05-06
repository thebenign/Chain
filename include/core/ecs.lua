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
local entity = setmetatable({
    enum = 0,
    list = {},
    component = {},
    entity = {},
    data = {},
    }, {__call = function(t, name) return t.new(name) end})

entity.__index = entity

-- Load extra core modules
local compositor = require("compositor")
local dpairs = require("dpairs")
local env = require("env")

-- Load data types
entity.data.map = require("data_map")
entity.data.spriteDeck = require("sprite_deck")
local utf8 = require("utf8")

-- Load components
for i, file in dpairs("/include/component/") do
    entity.component[file] = require(file)
    setmetatable(entity.component[file], entity)
end

-- ===============================================================

-- Creates and returns a list of all entities with _id matching id
function entity.find(id)
    local list = {}
    local found = false
    for i = 1, entity.enum do
        if entity.list[i]._id == id then
            list[#list+1] = entity.list[i]
            found = true
        end
    end
    return found and list or nil
end

-- This is the function which creates a new instance of an entity.
-- There must be an entity script called _name.lua_
function entity.new(name,...)
    local reg_ent = {id = name}
    local arg = {...}
    local parent = arg[1] or nil
    
    local stack_back = setmetatable(
        {
            register = function()
                reg_ent.parent = parent
                return setmetatable(reg_ent, entity)
            end,
            new = function(name)
                return entity.new(name, reg_ent)
            end
        }, entity)
    
    --local ent = require(name)(stack_back)
    local fenv = getfenv()
    fenv._id = name

    local ent = entity.entity[name]()
    entity.enum = entity.enum + 1
    entity.list[entity.enum] = ent


    return ent
end

-- Must be called at the top of your entity file to be able to use
-- the features of the ECS. Your entity will not function without it.
function entity.register()
    return setmetatable({_draw_count = 0, _drawable = {}}, entity)
end

-- Call this method to destroy an entity. Entities can only destroy themselves.
function entity:destroy()
    self._d = true
end

-- Call this method after _register_ to acquire components.
function entity:has(...)
    local args = {...}
    self._comp_enum = #args
    local fenv = getfenv()
    
    for i, v in ipairs(args) do
        assert(entity.component[v], '"'..fenv._id..'" tried to acquire component "'..v..'" which does not exist')
        self[v] = entity.component[v].give(self)
        self[i] = v
    end
end

function entity:addDrawable()
    --self._draw_count = self._draw_count + 1
    --self._drawable[self._draw_count] = typeof
    compositor.add(self)
end

function entity:setID(id)
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
function entity.update()
    local ent, comp, ak
    for i = entity.enum, 1, -1 do
        ent = entity.list[i]
        
        if rawget(ent, "update") then
            ent.update()
        end
        
        for c = 1, ent._comp_enum do
            --comp = entity.component[ent[c]]
            --comp.update(ent)
            
            if rawget(entity.component[ent[c]], "update") then
                entity.component[ent[c]].update(ent)
            end
            
        end
        
        if ent._d then
            local enum = entity.list[i]._comp_enum
            for c = enum, 1, -1 do
                comp = entity.component[ent[c]]
                if rawget(comp, "destroy") then
                    ak = comp.destroy(ent)
                    if ak then ent:removeComponent(c) end
                else
                    ent:removeComponent(c)
                end
            end
            if ent._comp_enum == 0 then
                entity.list[i] = entity.list[entity.enum]
                entity.enum = entity.enum - 1
            end
        end
        
    end
end

function entity:removeComponent(comp)
    self[comp] = self[self._comp_enum]
    self._comp_enum = self._comp_enum - 1
    
end

-- Call this function from your love.draw()
-- It handles all the drawable compositing so you don't have to.
function entity.draw()
    if env.full_redraw then love.graphics.clear(love.graphics.getBackgroundColor()) end
    compositor.draw()
    --entity.component.particle.draw()
    --entity.component.gui.draw()
    --entity.component.collider.draw()
    love.graphics.print("Entities: "..entity.enum, 32, 32)
    love.graphics.print("FPS: "..love.timer.getFPS(), 32, 48)
end

-- Following code imports the game entities. They are not run until _new_ is called.

for i, file in dpairs("include/entity/") do
  
    -- Environment default.
    local entity_env = setmetatable({
        chain = {
            register = function() return setmetatable({_draw_count = 0, _drawable = {}, id = file}, entity) end,
            find = entity.find,
            new = entity.new,
            data = entity.data
        }
    }, {__index = _G}) -- keep the global table

    local func, err
    func, err = loadfile("include/entity/"..file..".lua") -- load entity files
    if err then 
        print(
            "The entity loader encountered an error while attempting to load \""..file.."\": \n "
            ..utf8.char(0x21b3)..err.."\n"
            .."The entity will not be loaded"
            ) -- check for errors
    else
        entity.entity[file] = setfenv(func, entity_env) -- assign the loaded entity function to its table
    end
    
    
end


return entity