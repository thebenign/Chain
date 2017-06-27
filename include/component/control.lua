local control = {}
control.__index = control

function control.give(entity)
    return setmetatable({button={}, unbutton = {}, press = {}}, control)
end

function control:on(button, call)
    self.button[button] = {
        call = call,
        pressed = false
        }
end

function control:onRelease(button, call)
    if type(button) == "table" then
        for i, b in ipairs(button) do
            self.unbutton[b] = call
        end
    else
        self.unbutton[button] = call
    end
end
function control:onPress(button, call)
    if type(button) == "table" then
        for i, b in ipairs(button) do
            self.press[b] = call
        end
    else
        self.press[button] = call
    end
end
function control:update()
    for button, table in pairs(self.control.button) do
        if love.keyboard.isDown(button) then
            table.call(self)
            if not table.pressed and self.control.press[button] then
                self.control.press[button](self)
            end
            table.pressed = true
        elseif table.pressed and self.control.unbutton[button] then
            self.control.unbutton[button](self)
            table.pressed = false
        end
    end
end

return control