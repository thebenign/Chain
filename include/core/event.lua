-- event hooks 

local event = {}
local list = {
    keyboard = {n=0},
    mouse = {n=0},
    input = {n=0},
    err = {n=0},
}

function love.textinput(text)
    event.input(text)
end

function event.hook(what, func)
    local this_event = list[what]
    if this_event then
        this_event.n = this_event.n + 1
        this_event[this_event.n] = func
    end
end

function event.input(text)
    for i = 1, list.input.n do
        list.input[i](text)
    end
end

function event.update()
    
end

return event