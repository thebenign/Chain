local sfx = {
    sound_table = require("sound"),
    listener = false
    }
sfx.__index = sfx

function sfx.give(entity)
    return setmetatable({sound_list = {}}, sfx)
end

function sfx:new(source)
    self.sound_list[source] = sfx.sound_table[source]
end

function sfx:play(source, looping)
    self.sound_list[source]:setLooping(looping)
    local _ = self.sound_list[source]:play()
end

function sfx:setVolume(source, vol)
    self.sound_list[source]:setVolume(vol)
end
function sfx:setPosition(source, x, y)
    self.sound_list[source]:setPosition(x, y, 0)
end


function sfx:setListener(entity)
    sfx.listener = entity
end

function sfx.update()
    if sfx.listener then
        love.audio.setPosition(sfx.listener.position.x, sfx.listener.position.y, 0)
    end
end

return sfx