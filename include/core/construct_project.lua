local constructor = {}

local path = "/project/"
local directories = {"/assets", "/assets/images", "/assets/music", "/assets/particles", "/assets/sfx", "/entities", "/maps", "/scenes"}
local files = {"/init.lua"}

function constructor.create(project)
    for _, v in ipairs(directories) do
        local success = love.filesystem.createDirectory(path..project..v)
        assert(success, "Unable to create \""..v.."\" directory. Aborting")
    end
    for _, v in ipairs(files) do
        local success, message = love.filesystem.write(path..project..v, "-- Init script template\r\n-- Returns a table of initialization values to the core.\r\n-- To load a scene from the project scenes directory, add field 'scene = \"name_of_scene\"'; Do not include '.lua' file extension\r\n\r\n return {}")
        assert(success, "Unable to create \""..v.."\" file. Aborting")
    end
end

function constructor.ask(project)
    local answer = love.window.showMessageBox(
        "New Project", 
        "No folder: \""..project.."\" was found in the project directory. Would you like to start a new project?\n"..
        "This will create a new folder under /project/ called: \""..project.."\"\n"..
        "The directory hierarchy will also be automatically constructed.",
        {"Yes", "No"},
        "info",
        "false")
    if answer == 1 then
        constructor.create(project)
    else
        love.event.quit()
    end
end


return constructor