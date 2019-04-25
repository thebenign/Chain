local block = chain.register()

block:has("position", "geometry", "collider")

block.position:set(500, 700)

local square = block.geometry:new("rectangle")
square:set(0,0,64,64,32,32,0, true)


local collider = block.collider:using(square)
collider.static = true



return block