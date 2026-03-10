local retrieve = false
-- Teleport to tile
function tp(x, y)
    SendPacketRaw({
        type = 0,
        pos_x = x * 32,
        pos_y = y * 32
    })
end

-- Wrench a tile
function wrench(x, y)
    local packet = {
        type = 3,
        int_data = 32,
        int_x = x,
        int_y = y,
        pos_x = x * 32,
        pos_y = y * 32
    }
    SendPacketRaw(packet)
    Sleep(100)
end

function retrieveMag(x,y)
    wrench(x,y)

    local packet1 = "action|dialog_return\n" ..
                "dialog_name|itemsucker_block\n" ..
                "tilex|" .. x .. "|\n" ..
                "tiley|" .. y .. "|\n" ..
                "buttonClicked|retrieveitem\n"

    local packet2 = "action|dialog_return\n" ..
                "dialog_name|itemremovedfromsucker\n" ..
                "tilex|" .. x .. "|\n" ..
                "tiley|" .. y .. "|\n" ..
                "itemtoremove|200\n"

    SendPacket(2, packet1)
    SendPacket(2, packet2)
    Sleep(130)
end

function addMag(x,y,count)
    wrench(x,y)
    
    local packet1 = "action|dialog_return\n" ..
                   "dialog_name|itemsucker\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n" ..
                   "buttonClicked|additem\n"

    local packet2 = "action|dialog_return\n" ..
                   "dialog_name|itemaddedtosucker\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n" ..
                   "itemtoadd|".. count .."\n"
    SendPacket(2, packet1)
    SendPacket(2, packet2)
    Sleep(130)
end

-- Wrench self
function wrenchSelf()
    local packet = "action|wrench\n" ..
                   "|netid|1\n"
    SendPacket(2, packet)
    Sleep(100)
end

-- Open inventory
function openInventory()
    local packet = "action|dialog_return\n" ..
                   "dialog_name|popup\n" ..
                   "netID|-1|\n" ..
                   "buttonClicked|extra_inventory\n"
    SendPacket(2, packet)
    Sleep(100)
end


-- Retrieve item from extra inventory (batched packets)
function retrieveItem(itemID, amount, pos)
    local packet1 = "action|dialog_return\n" ..
                    "dialog_name|extra_inventory_player\n" ..
                    "buttonClicked|searchableItemListButton_".. itemID .."_".. amount .."_".. pos .."\n"

    local packet2 = "action|dialog_return\n" ..
                    "dialog_name|extra_inventory_player\n" ..
                    "item_id|".. itemID .."|\n" ..
                    "pos|".. pos .."|\n" ..
                    "amount_remove|".. amount .."\n"

    SendPacket(2, packet1)
    SendPacket(2, packet2)
    Sleep(100)
end

function drop(itemID)
    local s = getIDamount(itemID)
    if s == 0 then return end

    local packet = "action|dialog_return\n" ..
                   "dialog_name|drop_item\n" ..
                   "itemID|" .. itemID .. "\n" ..
                   "count|" .. s .. "\n"
    SendPacket(2, packet)
end

-- Store item into extra inventory (batched packets)
function storeItem(itemID)
     local packet = "action|dialog_return\n" ..
                    "dialog_name|extra_inventory_player\n" ..
                    "item_id|".. itemID .."|\n" ..
                    "amount_add|".. getIDamount(itemID) .."\n"
     SendPacket(2, packet)
     Sleep(100)
end

-- Check if item is in inventory
function hasInventoryItem(targetId)
    local inventory = GetInventory()
    if not inventory then return false end
    for _, item in pairs(inventory) do
        if item.id == targetId then
            return true
        end
    end
    return false
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

local functions = {
    ["magTobp"] = function (itemID)
        if not (getIDamount(itemID) == 0) then storeItem(itemID) end
        retrieveMag(48,25)
    end,

    ["bpRetDrop"] = function (itemID)
        drop(itemID)

        retrieve = true
        callBack(itemID)
        openInventory()
        retrieve = false
    end,
    ["bpTomag"] = function (itemID)
        retrieve = true
            callBack(itemID)
            openInventory()
        retrieve = false

        addMag(48,25,getIDamount(itemID))
    end,
    ["growchMode"] = function (axe,coupon)
        if getIDamount(coupon) >= 180 then  
            storeItem(coupon)
        end
        if getIDamount(axe) == 0 then 
            retrieve = true
            callBack(axe)
            openInventory()
            retrieve = false
        end
    end
}
-- Main logic for one item
function scanAndHit(range)
    local me = GetLocal()
    if not me then return end

    local px = math.floor(me.pos_x / 32)
    local py = math.floor(me.pos_y / 32)

    for dx = -range, range do
            local tx = px + dx
            local tile = GetTile(tx, py)

            if tile and tile.fg == 3200 then
                log("Found target tile 3202 at (" .. tx .. "," .. py .. ")")

                -- Punch packet
                local pkt = {}
                pkt.type = 3
                pkt.int_data = 18 -- punch action
                pkt.pos_x = tx * 32
                pkt.pos_y = py * 32
                pkt.int_x = tx
                pkt.int_y = py
                pkt.flags = me.facing_left and 16 or 32

                SendPacketRaw(pkt)
                Sleep(200) -- delay between hits
        end
    end
end

-- Usage: scan 2 tiles around player

function callBack(itemID)
    if not retrieve then return end
    local handled = false

    AddCallback("block", "OnVarlist", function(varlist)
        if handled then return end
        if varlist[0] ~= "OnDialogRequest" then return end

        local dialog = varlist[1]
        local line = dialog:match("add_searchable_item_list|(.-)|listType")
        if not line then return end

        local pos = 0
        for id, amount in line:gmatch("(%d+),(%d+)") do
            id, amount = tonumber(id), tonumber(amount)

            if id == itemID then
                retrieveItem(id, amount, pos)
                break
            end
            pos = pos + 1
        end

        handled = true -- don’t reset this
    end)
end

local targetId = 3206 -- axe 3206, coupon 17068

--functions["magTobp"](targetId)
--functions["bpRetDrop"](targetId)
--functions["bpTomag"](targetId)
functions["growchMode"](3206,17068)
scanAndHit(2)
