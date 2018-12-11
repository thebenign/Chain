-- return a table of sprites to be used for random drawing
local img = require("system.compositor").image
local data_type = require("data.data_type_def")

return function(...)
    local arg = {...}
    local deck = {}
    
    assert(arg, "Attempting to create a sprite deck with no sprites. A sprite deck must include at least one sprite")
    
    for i = 1, #arg do
        assert(img[arg[i]], "No image named \""..arg[i].."\" was found.")
        deck[i] = img[arg[i]]
    end
    
    deck._type = data_type.sprite_deck
    deck._count = #arg
    
    return deck
end