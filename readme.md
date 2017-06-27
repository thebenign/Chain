# Unnest Game Development Suit
![alt text](https://github.com/thebenign/unnest/blob/master/icons/banner.png "Banner Image")

## What is it?
Unnest is a rapid game development engine built in Lua for Love2D.

## How does it work?
Unnest is built around the core principles of an Entity Component System, you can [read about it here.](https://en.wikipedia.org/wiki/Entity%E2%80%93component%E2%80%93system)  
A game object is represented by an empty table, called an "entity". To shape it, we add behaviours called "components".  
These components can be anything that defines a game object like how it moves, what it looks like, etc.  
Once you define an entity, it is loaded into the game and its behaviors update automatically.  
Because an entity can be composed of any combination of components, the entire game is created in this way.  
There are no constraints on what an entity does.

## Example  
This script will create a new entity with a sprite and some features we might like to have in a game object.
First we'll look at a complete object script, then we'll break it down
```Lua
return function(entity) 
    local ball = entity.register()
    
    ball:has("sprite", "position", "velocity", "control")
    
    ball.sprite:set("ball", 3)
    ball.sprite:setOrigin("center")
    ball.sprite:setScale(.25)
    ball.sprite:activate()
    
    ball.position:set(300, 300)
    
    ball.control:keyDown("left", function()
        ball.position.x = ball.position.x - 1
    end)

    ball.control:keyDown("right", function()
        ball.position.x = ball.position.x + 1
    end)
    
    return ball
end
```
