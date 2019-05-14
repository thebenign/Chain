-- debuging core
-- Provides a channel to access/modify the global game-state, 
-- view engine errors, warnings, and info

local chain_debug = {
    message = {
        error = {n = 0},
        warning = {n = 0},
        info = {n = 0}
    }
}

function chain_debug.newMessage(msg_type, string)
    local field = chain_debug.message[msg_type]
    if field then
        local info = debug.getinfo(2, "n")
        field[field.n] = "["..msg_type:upper().."] In function: "..info.name.."()".." > "..string
        print(field[field.n])
    end
end

return chain_debug