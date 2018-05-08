local banner = chain.register()

banner:has("sprite", "position")

banner.position:set(450, 128)

banner.sprite:set(chain.image["banner-01"], 0)
banner.sprite:setOrigin("center")
banner.sprite.color = {1,1,1,.05}
banner.sprite.scale = .3

return banner