--[[--
#Entity Component System

Entities are defined in lua scripts located in the **.projectproject_name/entities/** directory.  
They are checked for errors and loaded as a chunk into Chain's **import** table, but are not run.  
**chain.new** runs the entity script and creates a new instance of an entity in Chain's **state** table.  

Components are defined within the **./include/component/** directory.  
These are imported as a chunk in Chain's **component** table and are run immediately.  
Each component must include the functions **give** and **update**  
When the Chain **update** function is called, all entity instances call method **update** within their owned components  
as methods of the instance.  

Systems are defined within the **./include/system/** directory.  
They are imported with **require()** and therefore are run immediately.  
Systems directly update the engine state within **chain.state** and are responsible for the majority of  
logic and state progression. With access to all entity instances, systems can make complex interactions  
between entities (i.e. collision detection).  
The order in which systems execute is important to bear in mind when including it in the update flow,  
otherwise changes may occur in a strange order which may not reflect an accurate game state.  

##Game Loop Flow  
**chain.update(dt)** should be called within the **love.update(dt)** callback.  
This function is run on a fixed time-step defined in **./include/core/env.lua**  
Chain then steps through each entity instance and updates their component methods.  
The majority of systems execute after this point, performing their main **update** function.  

**chain.draw()** should be called within the **love.draw()** callback.  
Drawing is handled with the Compositor system. This system is not part of the game loop,  
and not bound to a fixed time-step. Drawing occurs whenever the graphics card reports a v-sync.

]]

local chain = {
        
    import = {
        scene = {},
        entity = {},
        image = {},
        map = {},
        sound = {},
    },
    -- Game state table. Do not update these properties manually. Chain calls, components, and systems will make updates
    -- to these states automatically. Reading these values is okay.
    state = {
        project = "",       -- project title
        scene = "",         -- current active scene
        entity = {},        -- Entity instance table
        entity_count = 0,   -- counter
        persist = {},       -- Persistent instances are never discarded on scene change.
        persist_count = 0,  -- counter
        map = {},           -- active map
    },
    
    component = {},
    
    system = {
        collider = {},
        compositor = {},
        map = {},
    },
    
    data = {}
}

chain.__index = chain

-- ===============================================================
-- =================== Chain definitions here ====================
-- ===============================================================

-- Load Systems
local compositor = require("system.compositor")
local collider = require("system.collider_system")
local map = require("system.map_system")

-- Load extra core modules

-- importers
local importImages = require("import.import_images")
local importScenes = require("import.import_scenes")
local importMaps = require("import.import_maps")
local importEntities = require("import.import_entities")
local importComponents = require("import.import_components")

-- helpers
local dpairs = require("helper.dpairs")
local camera = require("core.camera")
local constructor = require("core.construct_project")
local console = require("debug.console")

-- environment stuff
chain.env = require("core.env")
chain.world = require("core.world")
chain.camera = camera

-- Load data types
chain.data.map = require("data.data_map")
chain.data.spriteDeck = require("data.sprite_deck")
chain.data.chainAssign = require("data.chain_assign")
chain.data.vec2 = require("data.vec2")
chain.data.hash = require("data.hash")
chain.data.unordered_list = require("data.unordered_list")
chain.data.dol = require("data.dol")

-- This is just so we can display special characters in the error messages
local utf8 = require("utf8")

-- ===============================================================
-- =================== Chain functions here ======================
-- ===============================================================

--- Returns a new instance of an entity
-- @tparam entity name The entity script to load
-- @tparam[opt] instance parent Gives the new instance a reference to a parent instance
-- @return New entity instance
function chain.new(name,...)
    
    local parent = select(1, ...) or nil
    
    local co = coroutine.create(chain.import.entity[name])
    local no_err, inst = coroutine.resume(co)
    chain.state.entity_count = chain.state.entity_count + 1
    inst._id = chain.state.entity_count
    inst._parent = parent
    inst._name = name
    inst.getParent = function() return inst._parent end
    no_err, inst = coroutine.resume(co)
    if no_err then
        chain.state.entity[chain.state.entity_count] = inst
    else
        error(inst)
    end
    return inst
end

-- Call this method to destroy an entity. Entities can only destroy themselves.
function chain:destroy()
    self._d = true
end

-- Call this method after _register_ to acquire components.
function chain:has(...)
    self._component = {}
    self._comp_enum = 0
    for i = 1, select("#", ...) do
        local comp = select(i, ...)
        assert(chain.component[comp], self._name..' tried to acquire component "'..comp..'" which does not exist')
        self[comp] = chain.component[comp].give(self)
        self._component[i] = comp
        self._comp_enum = self._comp_enum + 1
    end
end

-- Remove component from an entity instance
-- This function should NOT be called from within an entity instance.
-- Some components need to clean up when removed, otherwise the entity will break.
local function removeComponent(instance, comp)
    instance[comp] = instance[instance._comp_enum]
    instance._comp_enum = instance._comp_enum - 1
end

local function updateEntities()
    for i = chain.state.entity_count, 1, -1 do
        local ent = chain.state.entity[i]
        
        -- When checking entities and components for update methods, we need to bear in mind their metatables.
        -- Because Chain also has an update method, a regular check will ascend the metatable and return chain.update.
        -- Using rawget ignores metatables
        
        for c = 1, ent._comp_enum do
            local component = chain.component[ent._component[c]]
            if component.update then
                component.update(ent)
            end
        end
        
        if ent.update then
            ent.update()
        end
        
        if ent._d then
            for c = ent._comp_enum, 1, -1 do
                local component = chain.component[ent._component[c]]
                if component.destroy then
                    local ak = component.destroy(ent)
                    if ak then removeComponent(ent, c) end
                else
                    removeComponent(ent, c)
                end
            end
            if ent._comp_enum == 0 then
                chain.state.entity[i] = chain.state.entity[chain.state.entity_count]
                -- remove the only reference to the instance table, allowed to be garbage collected
                chain.state.entity[chain.state.entity_count] = nil
                chain.state.entity_count = chain.state.entity_count - 1
            end
        end
        
    end
end

--- Updates the game state
-- @param dt delta time
-- @return Nothing
function chain.update(dt)
    chain.env.dt = chain.env.dt + dt
    
    if chain.env.dt >= chain.env.t then
        chain.world.update()
        console.update()
        -- update all entities
        updateEntities()
        -- update systems
        collider.update()
        
        chain.env.dt = chain.env.dt - chain.env.t
    end
end

--- Draw the scene
function chain.draw()
    if chain.env.full_redraw then love.graphics.clear(love.graphics.getBackgroundColor()) end
    compositor.draw()
    collider.draw()
    if chain.env.debug then
        love.graphics.print("Entities: "..chain.state.entity_count, 32, 32)
        love.graphics.print("FPS: "..love.timer.getFPS(), 32, 48)
    end
    console.draw()
end

--- Load a new scene
-- @param scene An imported scene script
function chain.loadScene(scene)
    if chain.import.scene[scene] then
        chain.import.scene[scene]()
    else
        error("Attempting to load scene \""..scene..".lua\" but no scene file was imported by this name.\nIf the scene file exists, please check the console for import errors.", 0)
    end
end

--- Load a project. Call this early in _main.lua_, before or inside _love.load()_
-- @tparam string project The name of the project to load
function chain.load(project)
    -- Set up project and import
    assert(type(project)=="string", "Incorrect parameter type to Chain.load(). Expected String")
    local file_info = love.filesystem.getInfo("/project/"..project.."/")
    if not file_info then
        constructor.ask(project)
    end
    local t = love.timer.getTime()
    chain.state.project = project
    love.window.setTitle(project:gsub("^%l", string.upper))
    chain.component = importComponents(chain)
    chain.import.image = importImages(project)
    chain.import.map = importMaps(project)
    chain.import.scene = importScenes(project, chain)
    chain.import.entity = importEntities(project, chain)
    print("Import time: "..love.timer.getTime()-t)
    -- Start the game
    local init_params = require("project."..project..".init")
    if init_params.scene then
        chain.loadScene(init_params.scene)
    end
end

return chain