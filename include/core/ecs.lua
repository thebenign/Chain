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

-- Chain data structure
-- 
local chain = {
        
    import = {
        scene = {},
        entity = {},
        image = {},
        map = {},
        sound = {},
    },
    state = {
        project = "",
        scene = "",
        entity_count = 0,
        entity = {},
        map = {},
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
local collider = require("system.collider-system")

-- Load extra core modules

-- importers
local importImages = require("import.import_images")
local importScenes = require("import.import_scenes")
local importMaps = require("import.import_maps")
local importEntities = require("import.import_entities")


-- Loaders. Invoking the loader for an imported resource is what actually makes it active in the world.
--local loadMap = require("load.map")

-- helpers
local dpairs = require("helper.dpairs")
local camera = require("core.camera")

-- environment stuff
chain.env = require("core.env")
chain.world = require("core.world")


-- Load data types
chain.data.map = require("data.data_map")
chain.data.spriteDeck = require("data.sprite_deck")
chain.data.chainAssign = require("data.chain_assign")
chain.data.vec2 = require("data.vec2")
chain.data.hash = require("data.hash")

-- This is just so we can display special characters in the error messages
local utf8 = require("utf8")

-- Load components
for i, file in dpairs("/include/component/") do
    chain.component[file] = require("component."..file)
    setmetatable(chain.component[file], chain)
end

-- ===============================================================
-- =================== Chain functions here ======================
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
-- There must be an entity script called _name_.lua
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

    local ent = chain.import.entity[name]()
    chain.state.entity_count = chain.state.entity_count + 1
    chain.state.entity[chain.state.entity_count] = ent


    return ent
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

-- Call this function from your love.update() function.
-- Entity instances are updated by calling their components as methods.
-- If the entity requested destruction, it sends destroy requests to components.
-- The component may respond immediately or do some cleanup first.
-- Once all the components have cleaned up, the entity intance is destroyed.
-- After an entity requests destruction, it is flagged as non-existant, so you don't
-- have to worry about it continuing to do things after you destroy it,
-- even if the components are still cleaning up.
function chain.update()

    -- update all entities
    local ent, comp, ak
    for i = chain.state.entity_count, 1, -1 do
        ent = chain.state.entity[i]
        
        -- When checking entities and components for update methods, we need to bear in mind their metatables.
        -- Because Chain also has an update method, a regular check will ascend the metatable and return chain.update.
        -- Using rawget ignores metatables
        
        for c = 1, ent._comp_enum do
            if rawget(chain.component[ent[c]], "update") then
                chain.component[ent[c]].update(ent)
            end
        end
        
        if rawget(ent, "update") then
            ent.update()
        end
        
        if ent._d then
            for c = ent._comp_enum, 1, -1 do
                comp = chain.component[ent[c]]
                if rawget(comp, "destroy") then
                    ak = comp.destroy(ent)
                    if ak then ent:removeComponent(c) end
                else
                    ent:removeComponent(c)
                end
            end
            if ent._comp_enum == 0 then

                chain.state.entity[i] = chain.state.entity[chain.enum]
                chain.state.entity_count = chain.state.entity_count - 1
            end
        end
        
    end
    
    -- update systems
    collider.update()
end

function chain:removeComponent(comp)
    self[comp] = self[self._comp_enum]
    self._comp_enum = self._comp_enum - 1
    
end

-- Call this function from your love.draw()
-- It handles all the drawable compositing so you don't have to.
function chain.draw()
    if chain.env.full_redraw then love.graphics.clear(love.graphics.getBackgroundColor()) end
    compositor.draw()
    collider.draw()
    if chain.env.debug then
        love.graphics.print("Entities: "..chain.enum, 32, 32)
        love.graphics.print("FPS: "..love.timer.getFPS(), 32, 48)
    end
end

function chain.loadScene(scene)
    if chain.import.scene[scene] then
        local env = setmetatable({
                scene = {},
                chain = {
                    new = chain.new,
                    data = chain.data,
                    camera = camera,
                    --loadMap = 
                }
                }, {__index = _G})
        setfenv(chain.import.scene[scene], env)
        chain.import.scene[scene]()
    else
        error("Attempting to load scene \""..scene..".lua\" but no scene file was imported by this name.\nIf the scene file exists, please check the console for import errors.", 0)
    end
end

-- Load a project. Call this early in _main.lua_, before or inside _love.load()_
function chain.load(project)
    -- Set up project and import
    assert(type(project)=="string", "Incorrect parameter type to Chain.load(). Expected String")
    local file_info = love.filesystem.getInfo("/project/"..project.."/")
    assert(file_info and file_info.type == "directory", "Unable to load project \""..project.."\". No project folder was found by that name.\nPlease ensure there is a folder named \""..project.."\" in the project directory.")
    chain.state.project = project
    love.window.setTitle(project:gsub("^%l", string.upper))
    chain.import.scene = importScenes(project)
    chain.import.image = importImages(project)
    chain.import.map = importMaps(project)
    chain.import.entity = importEntities(project, chain)
    --importEntities()
    
    -- Start the game
    local init_params = require("project."..project..".init")
    chain.loadScene(init_params.scene)
end

return chain