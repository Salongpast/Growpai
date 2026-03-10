local taskType = "ht" -- "ht - harvest" or "pt - planting"

-- =========================
-- HARVESTING CONFIG
-- =========================
local harvest_seedid = 2013 -- dGrey 2013 -- dBrown -2029 -- axe -- 3207
local harvest_delay_action  = 85
local harvest_hits_per_tile = 3
local harvest_delay_per_tile = 20

-- =========================
-- PLANTING CONFIG
-- =========================
local plant_itemid   = 5640
local plant_delay    = 50
local spliceOn       = false
local magOn          = true

-- teleport helper (shared)
function tp(x, y)
    SendPacketRaw({
        type = 0,
        pos_x = x * 32,
        pos_y = y * 32
    })
end

-- =========================
-- HARVESTING FUNCTIONS
-- =========================
function harvestHit(x, y)
    local me = GetLocal()
    if not me then return end
    local face    = me.facing_left and 48 or 32
    local hitflag = me.facing_left and 2608 or 2592

    SendPacketRaw({ type = 0, flags = face, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y })
    SendPacketRaw({ type = 3, flags = hitflag, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y, int_data = 18 })
    Sleep(harvest_delay_action)
end

function canHarvest(x, y)
    local t = GetTile(x, y)
    return t and t.fg == harvest_seedid
end

function harvestTile(x, y)
    if canHarvest(x, y) then
        for i = 1, harvest_hits_per_tile do
            harvestHit(x, y)
        end
        Sleep(harvest_delay_per_tile)
    end
end

function harvestStep(x, y)
    tp(x, y)
    harvestTile(x, y)
    harvestTile(x + 1, y)
end

function harvestRow(y)
    for x = 0, 99 do
        harvestStep(x, y)
    end
end

function runHarvesting()
    for y = 0, 58, 2 do
          if not leaveGuard() then return end
          harvestRow(y)
    end
end

-- =========================
-- PLANTING FUNCTIONS
-- =========================
function plantHit(x, y, item)
    local me = GetLocal()
    if not me then return end
    local face    = me.facing_left and 48 or 32
    local hitflag = me.facing_left and 2608 or 2592

    SendPacketRaw({ type = 0, flags = face, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y })
    SendPacketRaw({ type = 3, flags = hitflag, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y, int_data = item })
    Sleep(plant_delay)
end

function getSeedID(x, y)
    local t = GetTile(x, y)
    if not t then return 0 end
    return t.fg
end

function scanAndPlace(x, y)
    local id = getSeedID(x, y)
    local below = GetTile(x, y + 1)

    if id == 0 then
        if below and below.fg ~= 0 then
            plantHit(x, y, plant_itemid)
        end
        return
    elseif id == 3207 then
        return
    end

    if spliceOn and magOn then
        plantHit(x, y, plant_itemid)
    end
end

function plant(x, y)
    tp(x, y)
    scanAndPlace(x, y - 2)
    scanAndPlace(x, y)
    scanAndPlace(x, y + 2)
end

function plantColumn()
     for y = 2, 56, 6 do
          for x = 0, 99 do
               if not leaveGuard() then return end
               plant(x, y)
          end
     end
end

function runPlanting()
    plantColumn()
    plantColumn()
end

function leaveGuard()
    local me = GetLocal()
    if not me then
        log("Player left game, script stopped.")
        return false
    end
    return true
end

-- =========================
-- MAIN TASK SWITCH
-- =========================
if taskType == "pt" then
    runPlanting()
elseif taskType == "ht" then
    runHarvesting()
end

-- =========================
local plant_itemid   = 5640
local plant_delay    = 80
local spliceOn       = false
local magOn          = true

-- teleport helper (shared)
function tp(x, y)
    SendPacketRaw({
        type = 0,
        pos_x = x * 32,
        pos_y = y * 32
    })
end

-- =========================
-- HARVESTING FUNCTIONS
-- =========================
function harvestHit(x, y)
    local me = GetLocal()
    if not me then return end
    local face    = me.facing_left and 48 or 32
    local hitflag = me.facing_left and 2608 or 2592

    SendPacketRaw({ type = 0, flags = face, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y })
    SendPacketRaw({ type = 3, flags = hitflag, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y, int_data = 18 })
    Sleep(harvest_delay_action)
end

function canHarvest(x, y)
    local t = GetTile(x, y)
    return t and t.fg == harvest_seedid
end

function harvestTile(x, y)
    if canHarvest(x, y) then
            harvestHit(x, y)
    end
end

function harvestStep(x, y)
    tp(x, y)
    harvestTile(x, y)
    harvestTile(x + 1, y)
end

function harvestRow(y)
    for x = 0, 99 do
        harvestStep(x, y)
    end
end

function runHarvesting()
    for y = 0, 58, 2 do
          if not leaveGuard() then return end
          harvestRow(y)
    end
end

-- =========================
-- PLANTING FUNCTIONS
-- =========================
function plantHit(x, y, item)
    local me = GetLocal()
    if not me then return end
    local face    = me.facing_left and 48 or 32
    local hitflag = me.facing_left and 2608 or 2592

    SendPacketRaw({ type = 0, flags = face, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y })
    SendPacketRaw({ type = 3, flags = hitflag, pos_x = x*32, pos_y = y*32, int_x = x, int_y = y, int_data = item })
    Sleep(plant_delay)
end

function getSeedID(x, y)
    local t = GetTile(x, y)
    if not t then return 0 end
    return t.fg
end

function scanAndPlace(x, y)
    local id = getSeedID(x, y)
    local below = GetTile(x, y + 1)

    if id == 0 then
        if below and below.fg ~= 0 then
            plantHit(x, y, plant_itemid)
        end
        return
    elseif id == 3207 then
        return
    end

    if spliceOn and magOn then
        plantHit(x, y, plant_itemid)
    end
end

function plant(x, y)
    tp(x, y)
    scanAndPlace(x, y - 2)
    scanAndPlace(x, y)
    scanAndPlace(x, y + 2)
end

function plantColumn()
     for y = 2, 56, 6 do
          for x = 0, 99 do
               if not leaveGuard() then return end
               plant(x, y)
          end
     end
end

function runPlanting()
    plantColumn()
    plantColumn()
end

function leaveGuard()
    local me = GetLocal()
    if not me then
        log("Player left game, script stopped.")
        return false
    end
    return true
end

-- =========================
-- MAIN TASK SWITCH
-- =========================
if taskType == "pt" then
    runPlanting()
elseif taskType == "ht" then
    runHarvesting()
end