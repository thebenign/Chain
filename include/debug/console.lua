-- Engine console
-- Provides interface to the debugger and other chain environments

local console = {
    active = false,
    height = 200,
    bar_height = 24,
    padding = 8,
    line = ""
}
local font = love.graphics.getFont()

local event = require("core.event")

event.hook("input", function(text)
        console.line = console.line..text
    end
)

function console.update()
    if console.active then
        --print(io.stdin:read())
    end
end

function console.draw()
    if console.active then
        love.graphics.setColor(0,0,0,.5)
        love.graphics.rectangle("fill", 0, 600-console.height, 900, 600)
        love.graphics.rectangle("fill", console.padding, 600-console.bar_height-console.padding, 900-console.padding*2, console.bar_height)
        love.graphics.rectangle("line", console.padding, 600-console.bar_height-console.padding, 900-console.padding*2, console.bar_height)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(" >", console.padding+4, 600-console.bar_height-console.padding+4)
        love.graphics.print(console.line, 32, 600-console.bar_height-console.padding+4)
        love.graphics.print("_", font:getWidth(console.line)+32, 600-console.bar_height-console.padding+4)
    end
end

return console