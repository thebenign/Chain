local hero = chain.register()

hero:has("position", "velocity", "sprite")

hero.position:set(300, 300)
hero.sprite:set(chain.image.Player_Blue.playerBlue_roll, 1)



return hero