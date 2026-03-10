local seedid = 3207      -- 2029- brown, 2013,grey
local delay_action = 80
local hits_per_tile = 2
local delay_per_tile = 20

-- teleport helper
function tp(x, y)
    SendPacketRaw({
        type = 0,
        pos_x = x * 32,
        pos_y = y * 32
    })
end

-- punch helper
function hit(x, y)
    local me = GetLocal()
    if not me then return end

    local face = me.facing_left and 48 or 32
    local hitflag = me.facing_left and 2608 or 2592

    -- move packet
    SendPacketRaw({
        type = 0,
        flags = face,
        pos_x = x * 32,
        pos_y = y * 32,
        int_x = x,
        int_y = y
    })

    -- action packet (hand = item 18)
    SendPacketRaw({
        type = 3,
        flags = hitflag,
        pos_x = x * 32,
        pos_y = y * 32,
        int_x = x,
        int_y = y,
        int_data = 18
    })

    Sleep(delay_action)
end

-- check if tile is harvestable
function canHarvest(x, y)
    local t = GetTile(x, y)
    return t and t.fg == seedid
end

-- harvest a single tile safely
function harvestTile(x, y)
    if canHarvest(x, y) then
        for i = 1, hits_per_tile do
            hit(x, y)
        end
        Sleep(delay_per_tile)
    end
end

-- harvest step: standing + immediate right tile
function harvestStep(x, y)
    tp(x, y)
    harvestTile(x, y)       -- standing tile
    harvestTile(x + 1, y)   -- adjacent tile (right side only)
end

-- harvest a full row
function harvestRow(y)
    for x = 0, 99 do
        harvestStep(x, y)
    end
    log("[HARVEST] Row " .. y .. " cleared.")
end

-- main harvesting loop
function runHarvesting()
    log("[HARVEST] Started.")
    for y = 0, 58, 2 do
        harvestRow(y)
    end
    log("[HARVEST] Finished.")
end

-- run it
runHarvesting()
