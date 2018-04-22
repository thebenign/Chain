local position = {}
position.__index = position

function position.give(entity)
    return setmetatable({x = 0, y = 0, a = 0, relative = false, camera = true}, position)
end

function position:relative(bool) -- set position relative to old position
    self.relative = bool
end

function position:cameraRelative(bool) -- set position relative to world space (true) or screen space (false)
    self.camera = bool
end

function position:set(x, y)
  if self.relative then
    self.x = self.x + x
    self.y = self.y + y
  else
    self.x = x
    self.y = y
  end
end

function position:get()
    return self.x, self.y
end

return position