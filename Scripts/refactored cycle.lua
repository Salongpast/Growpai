local plant_itemid = 5640
local plant_delay  = 30
local spliceOn = false
local magOn = true


function getSeedID(x, y)
    local t = GetTile(x, y)
    return t and t.fg or 0
end


function plant(x, y, item)
    local me = GetLocal()
    local hitflag = me.facing_left and 2608 or 2592
    SendPacketRaw({
    type = 3,
    flags = hitflag,
    pos_x = x * 32,
    pos_y = y * 32,
    int_x = x,
    int_y = y,
    int_data = item})

    Sleep(plant_delay)
end

function scanPlant(x, y)
    local id = getSeedID(x, y)
    local below = GetTile(x, y+1)
    if id == 0 then
        if below and below.fg ~= 0 then 
            plant(x, y-2, plant_itemid) 
            plant(x, y, plant_itemid)
            plant(x, y+2, plant_itemid) 
            end
        return
    end
end

for y = 2, 58, 2 do
    for x = 0, 99, 1 do
        scanPlant(x,y,plant_itemid)
    end
end

