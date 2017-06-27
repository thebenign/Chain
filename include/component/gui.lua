local gui = {
    element = {},
    enum = 0,
    container = {},
    gui_mt = require("gui_mt"),
    }

gui.__index = gui

function gui.give(entity)
    return setmetatable({}, gui)
end

function gui.newContainer(...)
    local arg = {...}
    local x, y, w, h
    x = arg[1] or -1
    y = arg[2] or x
    w = arg[3] or -1
    h = arg[4] or w
    
    if arg[1] then
        x = arg[1]
        y = arg[2] or x
    end
    if arg[3] then
        w = arg[3]
        h = arg[4] or w
    end
    
    local container = setmetatable({
        x = x,
        y = y,
        w = w,
        h = h
    }, gui.gui_mt)
    container.__index = container
    return container
end

function gui.newElement(class, x, y, w, h)
    gui.enum = gui.enum + 1
    local element = {
        x = x,
        y = y,
        w = w,
        h = h,
        text = "",
        padding = 0,
        filled = true,
        outline = false,
        rounded = 0,
        color = {200,200,200},
        text_color = {0,0,0},
    }
    
    gui.element[gui.enum] = setmetatable(element, gui)
    return element
end

function gui:setDimensions(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function gui:setText(text)
    self.text = text
end

function gui:setRadius(r)
    self.rounded = r
end

function gui:setPadding(px)
    self.padding = px
end

function gui.update()
    
end

function gui.draw()
    local element, fill
    for i = 1, gui.enum do
        element = gui.element[i]
        fill = element.filled and "fill" or "line"
        love.graphics.setColor(element.color)
        love.graphics.rectangle(fill, element.x, element.y, element.w, element.h, element.rounded)
        love.graphics.setColor(element.text_color)
        love.graphics.print(element.text, element.x+element.padding, element.y+element.padding)
    end
end

return gui