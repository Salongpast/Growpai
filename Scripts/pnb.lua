local itemid = 5640
local delay_place = 45   -- tuned delay for placement
local delay_hit = 0     -- slightly longer delay before breaking
local far = 10

-- place block
function place(x,y) 
    local pkt = {
        pos_x = x * 32,
        pos_y = y * 32,
        int_x = x,
        int_y = y,
        type = 3,
        int_data = itemid
    }
    SendPacketRaw(pkt) 
    Sleep(delay_place) 
end

-- punch block
function hit(x,y) 
    local me = GetLocal()
    if not me then return end
    local pkt = {
        pos_x = x * 32,
        pos_y = y * 32,
        int_x = x,
        int_y = y,
        flags = me.facing_left and 16 or 32,
        type = 3,
        int_data = 18
    }
    SendPacketRaw(pkt) 
    Sleep(delay_hit) 
end

-- place and break routine
function pnb()
    local me = GetLocal()
    if not me then return end
    local px, py = math.floor(me.pos_x / 32), math.floor(me.pos_y / 32)

    if not me.facing_left then
        for i = 1, far do
            place(px + i, py)
        end
        hit(px + 1, py)
    else
        for i = 1, far do
            place(px - i, py)
        end
        hit(px - 1, py)
    end
    Sleep(80) -- short cooldown before next cycle
end

-- main loop
while true do
    local me = GetLocal()
    if not me then
        log("Player left game, script stopped.")
        break
    end
    pnb()
end
