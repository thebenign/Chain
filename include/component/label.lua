-- label

-- import some stuff
local camera = require("camera")
local remove = require("compositor").remove
local default_font = require("world").default_font

local label = {}

local component_metatable = {
  __index = label,
  __call = function(t, text, z) return label.new(t, text, z) end
}
  
local instance_metatable = {
  setText = function(self, t)
    self.text = t
    local width, lines = default_font:getWrap(t, self.w-self.pad*2)
    self.lines = lines
    self.h = #lines * default_font:getHeight()+self.pad*2
  end,
  setWidth = function(self, w)
    self.w = w
  end,
  setColor = function(self, fg, bg)
    self.fg_color = fg
    self.bg_color = bg
  end,
  setPosition = function(self, x, y)
    self.x = x
    self.y = y
  end
  
}
instance_metatable.__index = instance_metatable

local shape = {
  rounded = function() end
}
  
  

function label.give(entity)
  return setmetatable(
    {
      count = 0, 
      position = entity.position
    }, component_metatable
  )
end

function label.new(entity, text, ...)
  entity.count = entity.count + 1
  local arg = {...}
  
  entity[entity.count] =
  setmetatable(
    {
      lines = {},
      w = 60,
      h = 16,
      pad = 2,
      text_align = "center",
      shape = "rounded",
      z = arg[1] or 1,
      bg_color = {.9,.9,.9,.6},
      fg_color = {.1,.1,.1,.8},
      x = 0,
      y = 0,
      rot = 0,
      draw = label.draw,
      position = entity.position
    }, instance_metatable
  )
  entity[entity.count]:setText(text or "label")
  
  label.addDrawable(entity[entity.count])
  return entity[entity.count]
end

function label:destroy()
  for i = 1, self.label.count do
    remove(self.label[i].id)
  end
  return true
end


function label:draw()
  love.graphics.setColor(self.bg_color)
  love.graphics.rectangle(
    "fill",
    self.position.x + self.x,
    self.position.y + self.y,
    self.w,
    self.h,
    6, 6
  )
  
  love.graphics.setColor(self.fg_color)
  
  love.graphics.printf(
    self.text,
    self.position.x + self.x + self.pad,
    self.position.y + self.y + self.pad,
    self.w - self.pad, 
    self.text_align
  )
  
  love.graphics.setColor(1,1,1,1)
end

return label