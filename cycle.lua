-- =========================
-- STATUS TRACKER
-- =========================
local currentStatus = "idle"
local CurrentSeed = "DarkGrey"  -- start with Grey

-- =========================
-- MAGPLANT HELPERS
-- =========================
function wrench(x, y)
    local packet = { type = 3, int_data = 32, int_x = x, int_y = y, pos_x = x*32, pos_y = y*32 }
    SendPacketRaw(packet)
    Sleep(130)
end

function getRemote(x, y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|itemsucker\n" ..
                   "tilex|"..x.."|\n" ..
                   "tiley|"..y.."|\n" ..
                   "buttonClicked|getplantationdevice\n"
    SendPacket(2, packet)
    Sleep(130)
end

function trashMag()
    local packet = "action|trash\n|itemID|5640\n"
    SendPacket(2, packet)
    Sleep(130)
    local packet2 = "action|dialog_return\n" ..
                    "dialog_name|trash_dialog\n" ..
                    "itemID|5640|\n" ..
                    "count|01\n"
    SendPacket(2, packet2)
    Sleep(130)
end

-- =========================
-- MAGPLANT COORDINATES
-- =========================
local mag = {
    DarkGrey = {Seed = {45,33}, Block = {45,31}, id = 2013},
    DarkBrown = {Seed = {45,29}, Block = {45,27}, id = 2029}
}

-- =========================
-- HARVESTING CONFIG
-- =========================
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

-- teleport helper
function tp(x, y)
    SendPacketRaw({ type = 0, pos_x = x*32, pos_y = y*32 })
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

function canHarvest(x, y, seedID)
    local t = GetTile(x, y)
    return t and t.fg == seedID
end

function harvestTile(x, y, seedID)
    if canHarvest(x, y, seedID) then
        for i = 1, harvest_hits_per_tile do harvestHit(x, y) end
        Sleep(harvest_delay_per_tile)
    end
end

function harvestStep(x, y, seedID)
    tp(x, y)
    harvestTile(x, y, seedID)
    harvestTile(x+1, y, seedID)
end

function harvestRow(y, seedID)
    for x = 0, 99 do harvestStep(x, y, seedID) end
end

function runHarvesting(coords, seedID)
    currentStatus = "harvesting"
    trashMag()
    wrench(coords[1], coords[2])
    getRemote(coords[1], coords[2])
    for i = 1, 5 do
        log("Harvest iteration "..i)
        for y = 0, 58, 2 do
            if not leaveGuard() then return end
            harvestRow(y, seedID)
        end
    end
    currentStatus = "idle"
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
    return t and t.fg or 0
end

function scanAndPlace(x, y)
    local id = getSeedID(x, y)
    local below = GetTile(x, y+1)
    if id == 0 then
        if below and below.fg ~= 0 then plantHit(x, y, plant_itemid) end
        return
    elseif id == 3207 then return end
    if spliceOn and magOn then plantHit(x, y, plant_itemid) end
end

function plant(x, y)
    tp(x, y)
    scanAndPlace(x, y-2)
    scanAndPlace(x, y)
    scanAndPlace(x, y+2)
end

function plantColumn()
    for y = 2, 56, 6 do
        for x = 0, 99 do
            if not leaveGuard() then return end
            plant(x, y)
        end
    end
end

function runPlanting(coords)
    currentStatus = "planting"
    trashMag()
    wrench(coords[1], coords[2])
    getRemote(coords[1], coords[2])
    for i = 1, 5 do
        log("Plant iteration "..i)
        plantColumn()
    end
    currentStatus = "idle"
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
-- PNB ROUTINE
-- =========================
local pnb_itemid = 5640
local delay_place = 45
local delay_hit = 0
local far = 10

function place(x,y)
    local pkt = { pos_x = x*32, pos_y = y*32, int_x = x, int_y = y, type = 3, int_data = pnb_itemid }
    SendPacketRaw(pkt)
    Sleep(delay_place)
end

function hit(x,y)
    local me = GetLocal()
    if not me then return end
    local pkt = { pos_x = x*32, pos_y = y*32, int_x = x, int_y = y, flags = me.facing_left and 16 or 32, type = 3, int_data = 18 }
    SendPacketRaw(pkt)
    Sleep(delay_hit)
end

function pnb()
    local me = GetLocal()
    if not me then return end
    local px, py = math.floor(me.pos_x/32), math.floor(me.pos_y/32)
    if not me.facing_left then
        for i = 1, far do place(px+i, py) end
        hit(px+1, py)
    else
        for i = 1, far do place(px-i, py) end
        hit(px-1, py)
    end
    Sleep(80)
end

function runPNBForGrowth(coords)
    currentStatus = "pnb"
    trashMag()
    wrench(coords[1], coords[2])
    getRemote(coords[1], coords[2])
    local growth_time_ms = (13*60 + 51) * 1000
    local start = os.clock()
    while (os.clock() - start)*1000 < growth_time_ms do
        if not leaveGuard() then return end
        pnb()
    end
    currentStatus = "idle"
end

-- =========================
-- SEED SWITCHING HELPERS
-- =========================
function getSeedData()
    return mag[CurrentSeed]
end

function switchSeed()
    if CurrentSeed == "DarkGrey" then
        CurrentSeed = "DarkBrown"
    else
        CurrentSeed = "DarkGrey"
    end
end
-- =========================
-- UWS HELPER
-- =========================
function useUWS()
    local packet = "action|dialog_return\n" ..
                   "dialog_name|uw_spray\n"
    SendPacket(2, packet)
    Sleep(500)
end

function getIDamount(targetId)
     local inventory = GetInventory()
    if not inventory then return 0 end
    for _, item in pairs(inventory) do
        if item.id == targetId then
            return item.count
        end
    end
    return 0
end

-- =========================
-- SPLICE LOOP
-- =========================
-- =========================
-- SPLICE LOOP
-- =========================
function spliceLoop()
    while true do
        -- Plant first seed (DarkGrey)
        CurrentSeed = "DarkGrey"
        local s1 = getSeedData()
        log("Planting first seed: "..CurrentSeed)
        runPlanting(s1.Seed)   -- ✅ always Seed coords

        -- Plant second seed (DarkBrown) on top to splice
        CurrentSeed = "DarkBrown"
        local s2 = getSeedData()
        log("Planting second seed for splicing: "..CurrentSeed)
        spliceOn = true
        runPlanting(s2.Seed)   -- ✅ always Seed coords
        spliceOn = false

        -- Use UWS to speed up growth
        tp(4, 59)
        log("Using UWS...")
        if getIDamount(12600) == 0 then
            log("Restock your UWS")
            break
        end
        useUWS()
        Sleep(1000)

        -- Harvest the spliced result
        log("Harvesting spliced tiles...")
        runHarvesting(s1.Seed, 3207)  -- 3207 = spliced item ID
        Sleep(5000)

        log("Splice cycle complete, restarting...")
    end
end


-- =========================
-- MAIN LOOP
-- =========================
function mainLoop()
    while true do
        local s = getSeedData()

        log("Starting planting phase for "..CurrentSeed)
        runPlanting(s.Seed)

        tp(4,59)
        log("Growth phase with continuous PNB for "..CurrentSeed)
        runPNBForGrowth(s.Block)

        log("Starting harvesting phase for "..CurrentSeed)
        runHarvesting(s.Seed, s.id)
        Sleep(5000)

        switchSeed()
        log("Cycle complete for "..CurrentSeed..", switching seed...")
    end
end

mainLoop()

