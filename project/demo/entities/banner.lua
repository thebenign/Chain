local banner = chain.register()

banner:has("sprite", "position")

banner.position:set(450, 100)

banner.sprite:set(chain.image.backgrounds["banner-nobg-glow"], 0)
banner.sprite:setOrigin("center")
banner.sprite.color = {1,1,1,.8}
banner.sprite.scale = .8

return banner