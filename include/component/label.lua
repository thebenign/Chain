-- label

-- import some stuff
local camera = require("core.camera")
local remove = require("system.compositor").remove
local default_font = require("core.world").default_font

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
      entity = entity,
      count = 0, 
      position = entity.position
    }, component_metatable
  )
end

function label.new(component, text, ...)
  component.count = component.count + 1
  local arg = {...}
  
  component[component.count] =
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
      entity = component.entity
    }, instance_metatable
  )
  component[component.count]:setText(text or "label")
  
  label.addDrawable(component[component.count])
  return component[component.count]
end

function label:destroy()
  for i = 1, self.label.count do
    remove(self.label[i].id)
  end
  return true
end


function label:draw()
    local adj_pos = {
        x = self.entity.position.x + self.x - (self.entity.position.camera and camera.x or 0),
        y = self.entity.position.y + self.y - (self.entity.position.camera and camera.y or 0)
    }
    
  love.graphics.setColor(self.bg_color)
  love.graphics.rectangle(
    "fill",
    adj_pos.x,
    adj_pos.y,
    self.w,
    self.h,
    6, 6
  )
  
  love.graphics.setColor(self.fg_color)
  
  love.graphics.printf(
    self.text,
    adj_pos.x + self.pad,
    adj_pos.y + self.pad,
    self.w - self.pad, 
    self.text_align
  )
  
  love.graphics.setColor(1,1,1,1)
end

return label