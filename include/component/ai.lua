local ai = {

}
ai.__index = ai

function ai.give(entity)
    return setmetatable({}, ai)
end

function ai:setBehaviour(b)
end

-- Behaviours

function ai.follow(target, min, max)
    
end

return ai