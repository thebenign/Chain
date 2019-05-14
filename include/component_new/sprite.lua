local sprite = {}

sprite.__index = sprite

local lgDraw = love.graphics.draw
local camera = require("core.camera")

local add = require ("system.compositor").add
local remove = require("system.compositor").remove

local data_type = require("data.data_type_def")

function sprite.give(entity)
    
    local s = {
        entity = entity,
        color = {1,1,1,1},
        xs = 1, 
        ys = 1,
        rot = 0, 
        origin_x = 0, 
        origin_y = 0,
        relative = true,
        quad_frame = 1,
        quad_offset = 0,
        quad_range = 0,
        animated = false,
        anim_t = 1,
        anim_dt = 0,
        anim_run = false,
        anim_frame = 1,
        anim_frames = 1,
        anim_loop = false,
        active = true,
        shuffle = false, -- allow random sprite shuffling
        blend = "alpha"
        }
    return setmetatable(s, sprite)
end

function sprite:set(img, z)
    if img._type and img._type == data_type.sprite_deck then
        self.img = img[math.random(img._count)]
    else
        if type(img) == "userdata" and img:typeOf("Drawable") then
            self.img = img
        end
    end
    
    self.z = z or 1
    add(self)
end
function sprite:createTilesheet(cols, rows)
    local quad = {}
    local swidth, sheight = self.img:getDimensions()
    local quad_width = math.floor(swidth/cols)
    local quad_height = math.floor(sheight/rows)
    for i = 0, (cols*rows)-1 do
        local x = (i % cols) * quad_width
        local y = math.floor(i / cols) * quad_height
        quad[i+1] = love.graphics.newQuad(x, y, quad_width, quad_height, swidth, sheight)
    end
    self.quad = quad
end

function sprite:setAnimation(cols, rows, frames, delay)
    self:createTilesheet(cols, rows)
    self.anim_delay = delay
    self.anim_frames = frames
    self.animated = true
end

function sprite:animationPlay()
    self.anim_run = true
end
function sprite:animationStop()
    self.anim_frame = 1
    self.anim_dt = 0
    self.anim_run = false
end
function sprite:animationPause()
    self.anim_run = false
end
function sprite:animationSetFrame(f)
    self.anim_fram = f
end
function sprite:animationLoop(bool)
    self.anim_loop = bool
end

function sprite:setShuffle()
    
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

function sprite:setScale(x, y)
    self.xs = x
    self.ys = y
end

function sprite:setRotation(r)
    self.rot = r
end

function sprite:setColor(...)
    local args = {...}
    if #args == 4 then
        self.color = args
    elseif #args == 3 then
        self.color = {args[1], args[2], args[3], 1}
    else
        error("Wrong number of arguments to sprite:setColor, expected 3 or 4", 0)
    end
end

--[[
function sprite:activate()
    assert(self.img, "Attempt to activate a sprite component which has no image. Use sprite:set() first.")
    sprite.addDrawable(self)
end
]]
function sprite:update()
    local this = self.sprite
    if this.animated and this.anim_run then
        this.anim_dt = this.anim_dt + 1
        if this.anim_dt > this.anim_delay then
            this.anim_dt = 0
            this.anim_frame = (this.anim_frame % this.anim_frames) + 1
        end
        if this.anim_frame == this.anim_frames and not this.anim_loop then
            this.anim_run = false
        end
    end
end

function sprite:destroy()
    remove(self.sprite.id)
    return true
end

function sprite:draw()
    local camx = self.entity.position.camera and camera.x or 0
    local camy = self.entity.position.camera and camera.y or 0
    love.graphics.push("all")
    love.graphics.setBlendMode(self.blend)
    love.graphics.setColor(self.color)
    love.graphics.translate(-camx, -camy)
    if not self.quad then
        lgDraw(
            self.img, 
            math.floor(self.entity.position.x),
            math.floor(self.entity.position.y), 
            self.entity.position.a,
            self.xs,
            self.ys,
            self.origin_x,
            self.origin_y
        )
    else
        lgDraw(
            self.img, 
            self.quad[self.anim_frame],
            math.floor(self.entity.position.x),
            math.floor(self.entity.position.y), 
            self.entity.position.a,
            self.xs,
            self.ys,
            self.origin_x,
            self.origin_y
        )
    end
    love.graphics.pop()
    --love.graphics.setColor(1,1,1,1)
    --love.graphics.setBlendMode("alpha")
end

return sprite