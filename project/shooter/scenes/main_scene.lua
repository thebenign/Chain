
chain.new("ship")
local block = {}
for i = 1, 8 do
    block[i] = chain.new("block")
    block[i].position:set(200+(i*64), 200)
end
