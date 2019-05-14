
local position = {
    list = chain.data.unordered_list(),
    data_list = chain.data.dol("x", "y", "a", "mov_relative", "cam_relative", "dirty")
    }
position.__index = position

function position.give(entity)
    local t = {x = 0, y = 0, a = 0, is_relative = false, camera = true, _dirty = true}
    return setmetatable(t, position)
end

function position:relative(bool) -- set position relative to last position
    self.is_relative = bool
end

function position:cameraRelative(bool) -- set position relative to world space (true) or screen space (false)
    self.camera = bool
end

function position:set(x, y)
  if self.is_relative then
    self.x = self.x + x
    self.y = self.y + y
  else
    self.x = x
    self.y = y
  end
  self._dirty = true
end

function position:get()
    return self.x, self.y
end

return position