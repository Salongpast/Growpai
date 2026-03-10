-- CONFIG
local mag = { x = 48, y = 25 }
local itemID = 3206
--
function tp(x, y)
    SendPacketRaw({
        type = 0,
        pos_x = x * 32,
        pos_y = y * 32
    })
end

function closeDialog(dialogName, x, y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|" .. dialogName .. "\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n"
    SendPacket(2, packet)
    Sleep(130)
end

function wrench(x, y)
    local packet = {
        type = 3,          -- packet type for wrench
        int_data = 32,     -- wrench action
        int_x = x,         -- tile coordinate
        int_y = y,         -- tile coordinate
        pos_x = x * 32,    -- pixel coordinate
        pos_y = y * 32     -- pixel coordinate
    }
    SendPacketRaw(packet)
    Sleep(130)
end

function ret1(x, y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|itemsucker_block\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n" ..
                   "buttonClicked|retrieveitem\n"
    SendPacket(2, packet)
    Sleep(130)
end
function ret2(x, y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|itemremovedfromsucker\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n" ..
                   "itemtoremove|200\n"
    SendPacket(2, packet)
    Sleep(130)
end

function add1(x, y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|itemsucker\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n" ..
                   "buttonClicked|additem\n"
    SendPacket(2, packet)
    Sleep(130)
end
function add2(x, y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|itemaddedtosucker\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n" ..
                   "itemtoadd|200\n"
    SendPacket(2, packet)
    Sleep(130)
end

function drop(itemID, count)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|drop_item\n" ..
                   "itemID|" .. itemID .. "\n" ..
                   "count|" .. count .. "\n"
    SendPacket(2, packet)
end

function retri(x,y)
        wrench(x,y)
        ret1(x,y)
        ret2(x,y)
        drop(3206,200)
end

function add(x,y)
        wrench(x,y)
        add1(x,y)
        add2(x,y)
end

function addStock()
    local me = GetLocal()
    -- wrench at the tile where the player is standing
    wrench(me.tile_x, me.tile_y)

    local packet = "action|dialog_return\n" ..
                   "dialog_name|vending\n" ..
                   "tilex|" .. me.tile_x .. "|\n" ..
                   "tiley|" .. me.tile_y .. "|\n" ..
                   "buttonClicked|addstock\n"
    SendPacket(2, packet)
    Sleep(130)
end
-- main routine: retrieve items from magplant, then add to vending
function main()
    local mag = { x = 48, y = 25 }   -- magplant coordinates
    local me = GetLocal()            -- player position for vending

    -- Step 1: retrieve items from magplant
    wrench(mag.x, mag.y)
    ret1(mag.x, mag.y)
    ret2(mag.x, mag.y)

    -- Step 2: add items into vending machine
    wrench(me.tile_x, me.tile_y)
    addStock()
end

function tpthenadd(x,y)
	tp(x,y)
    local packet = "action|dialog_return\n" ..
                   "dialog_name|vending\n" ..
                   "tilex|" .. x .. "|\n" ..
                   "tiley|" .. y .. "|\n" ..
                   "buttonClicked|addstock\n"
    SendPacket(2, packet)
    Sleep(130)
end
--main()

tpthenadd(50,24)

