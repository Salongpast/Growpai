local function Place(id, x, y)
    local player = GetLocal()
    local packet = {
        type = 3,
        int_data = id,
        pos_x = player.pos_x,
        pos_y = player.pos_y,
        int_x = x,
        int_y = y,
    }
    SendPacketRaw(packet)
end

local function lowheat(x, y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|oven\n" ..
                   "tilex|" .. x .. "\n" ..
                   "tiley|" .. y .. "\n" ..
                   "cookthis|4562\n" ..
                   "buttonClicked|low\n" ..
                   "display_timer|1\n"
    SendPacket(2, packet)
    log("Triggered oven at (" .. x .. "," .. y .. ")")
    Sleep(130)
end

function cook1(x, y, timesToRun)
    local Recipe1 = 4562 -- Flour
    local Recipe2 = 874  -- Egg
    local Recipe3 = 868  -- Milk
    local Recipe4 = 196  -- Blueberry
    local Recipe5 = 4572 -- Sugar

    local packet1 = {
        type = 3,
        int_data = 18,
        pos_x = GetLocal().pos_x,
        pos_y = GetLocal().pos_y,
        int_x = x - 1,
        int_y = y,
    }
    local packet2 = {
        type = 3,
        int_data = 18,
        pos_x = GetLocal().pos_x,
        pos_y = GetLocal().pos_y,
        int_x = x + 2,
        int_y = y,
    }
    
    RunThread(function()
        local count = 0
        while true do
            count = count + 1
            if timesToRun > 0 and count > timesToRun then
                log("Finished all cycles.")
                break
            end

            -- Flour + Oven prep
            Place(Recipe1, x - 1, y)
            Sleep(100)
            lowheat(x - 1, y)

            Place(Recipe1, x + 2, y)
            Sleep(100)
            lowheat(x + 2, y)

            -- Sugar (3x)
            for i = 1, 3 do
                Place(Recipe5, x - 1, y)
                Sleep(100)
                Place(Recipe5, x + 2, y)
                Sleep(100)
                log("Placed Sugar cycle " .. i)
            end

            -- Egg (Timer start at 0s)
            Place(Recipe2, x - 1, y)
            Sleep(100)
            Place(Recipe2, x + 2, y)
            log("Placed Egg (Timer Start)")

            -- Wait until 26s → Milk (adjusted)
            Sleep(25000)
            Place(Recipe3, x - 1, y)
            Sleep(100)
            Place(Recipe3, x + 2, y)
            log("Placed Milk at 26s")

            -- Wait until 40s → Blueberry (adjusted)
            Sleep(13500)
            Place(Recipe4, x - 1, y)
            Sleep(100)
            Place(Recipe4, x + 2, y)
            log("Placed Blueberry at 40s")

            -- Wait until 60s → Punch (adjusted)
            Sleep(20896)
            SendPacketRaw(packet1)
            Sleep(275)
            SendPacketRaw(packet2)
            log("Punched at Perfection (60s)")
        end
    end)
end

local x = GetLocal().pos_x / 32
local y = GetLocal().pos_y / 32

cook1(x, y, 20)

