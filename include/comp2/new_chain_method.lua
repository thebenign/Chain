local collider = {}

local mtl1 = {
    with = function(self, w)
        self.collides_with[w] = true
        return({
                f = self.collides_with,
                w = w,
                does = function(self, func)
                    self.f[w] = func
                end
            }
        )
    end
}
mtl1.__index = mtl1

function collider:give()
    return setmetatable(
        {
            cells = {},
            dynamic = true,
            collides_with = {}
        }
        , mtl1)
end

local box = {}
box.collides = collider.give()


box.collides
    :with("box")
    :does(function()
        print("The box hit another box")
    end
)


box.collides.collides_with["box"]()