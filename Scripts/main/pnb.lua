itemid = 5640
delay_place = 50
far =8
--[[ZAXPLOIT]]--
function place(x,y) 
    pkt = {} 
    pkt.pos_x = x * 32
    pkt.pos_y = y * 32
    pkt.int_x = x
    pkt.int_y = y
    pkt.type = 3
    pkt.int_data = itemid
    SendPacketRaw(pkt) 
    Sleep(delay_place) 
end
function hit(x,y) 
    local me = GetLocal()
    pkt = {} 
    pkt.pos_x = x * 32
    pkt.pos_y = y * 32
    pkt.int_x = x
    pkt.int_y = y
    pkt.flags = me.facing_left and 16 or 32
    pkt.type = 3
    pkt.int_data = 18
    SendPacketRaw(pkt) 
    Sleep(delay_place) 
end

function pnb()
    local me = GetLocal()
    if not me then return end
    if not me.facing_left then
        for i = 1, far do
            place(math.floor(me.pos_x / 32) + i, math.floor(me.pos_y / 32))
        end
        hit(me.pos_x / 32 + 1, me.pos_y / 32)
        Sleep(100)
    else
        for i = 1, far do
            place(math.floor(me.pos_x / 32) - i, math.floor(me.pos_y / 32))
        end
        hit(me.pos_x / 32 - 1, me.pos_y / 32)
        Sleep(100)
    end
end

while true do
pnb()
end