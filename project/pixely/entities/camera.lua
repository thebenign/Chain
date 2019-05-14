local cam = chain.register()

cam:has("position")

chain.camera.follow(cam)

return cam