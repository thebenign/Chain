local sprite = {
    image = require("compositor").image,
    remove = require("compositor").remove
}

sprite.__index = sprite

local lgDraw = love.graphics.draw
local camera = require("camera")

function sprite.give(entity)
    
    local s = {
        entity = entity,
        color = {255,255,255,255},
        scale = 1, 
        rot = 0, 
        origin_x = 0, 
        origin_y = 0,
        relative = true,
        quad_frame = 1,
        quad_offset = 0,
        quad_range = 0,
        animate = false,
        anim_t = 1,
        anim_dt = 0,
        anim_run = true
        }
    return setmetatable(s, sprite)
end

function sprite:set(img, z)
    self.img = sprite.image[img]
    self.z = z
end

function sprite:setOrigin(...)
    local arg = {...}
    assert(arg and #arg < 3, 'Wrong number of arguments to sprite:setOrigin(). Expected either the string "center" or x, y')
    if arg[1] == "center" then
        self.origin_x = self.img:getWidth()/2
        self.origin_y = self.img:getHeight()/2
    elseif type(arg[1]) == "number" and type(arg[2]) == "number" then
        self.origin_x = arg[1]
        self.origin_y = arg[2]
    else
        error("sprite:setOrigin() failed with an unknown cause.")
    end
    
end

function sprite:setScale(s)
    self.scale = s
end

function sprite:setRotation(r)
    self.rot = r
end

function sprite:activate()
    assert(self.img, "Attempt to activate a sprite component which has no image. Use sprite:set() first.")
    sprite.addDrawable(self)
end
    
function sprite:update()
    if self.animate and self.anim_run then
        self.anim_dt = self.anim_dt + 1
        if self.anim_dt > self.anim_t then
            local frame = self.quad_frame  -- huh?
            
            self.anim_dt = 0
        end
    end
end

function sprite:destroy()
    sprite.remove(self.id)
    return true
end

function sprite:draw()
    local x_off = self.relative and camera.x or 0
    local y_off = self.relative and camera.y or 0
    if not self.quad then
        lgDraw(
            self.img, 
            self.entity.position.x-x_off,
            self.entity.position.y-y_off, 
            self.rot,
            self.scale,
            self.scale,
            self.origin_x,
            self.origin_y
        )
    else
    end
end

return sprite