local itemID = 17068
local price = 9
local count = 1
local retrieve = false
local handled = false

function buy(itemID, price, count)
    local me = GetLocal()
    local x = math.floor(me.pos_x / 32)
    local y = math.floor(me.pos_y / 32)
    wrench(x,y)

    local packet = "action|dialog_return\n" ..
                   "dialog_name|vending\n" ..
                   "tilex|".. x .."|\n" ..
                   "tiley|".. y .."|\n" ..
                   "expectprice|".. price .."|\n" ..
                   "expectitem|".. itemID .."|\n" ..
                   "buycount|".. count .."|\n"
    SendPacket(2, packet)
    Sleep(130)

    local packet = "action|dialog_return\n" ..
                   "dialog_name|vending\n" ..
                   "tilex|".. x .."|\n" ..
                   "tiley|".. y .."|\n" ..
                   "verify|1|\n" ..
                   "buycount|".. count .."|\n" ..
                   "expectitem|".. itemID .."|\n"
    SendPacket(2, packet)
    Sleep(130)
end

function wrench(x,y)
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
function openInventory()
    local packet1 = "action|dialog_return\n" ..
                "dialog_name|popup\n" ..
                "netID|-1|\n" ..
                "buttonClicked|extra_inventory\n"

    SendPacket(2,packet1)

    handled = false
end

function store(itemID)
     local packet = "action|dialog_return\n" ..
                    "dialog_name|extra_inventory_player\n" ..
                    "item_id|".. itemID .."|\n" ..
                    "amount_add|".. getIDamount(itemID) .."\n"
     SendPacket(2, packet)
     Sleep(100)
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
function callBack()
    if retrieve == false then return end
    AddCallback("block", "OnVarlist", function(varlist)
        if varlist[0] == "OnDialogRequest" and not handled then
            local dialog = varlist[1]
            local line = dialog:match("add_searchable_item_list|(.-)|listType")
            if not line then return end

            local numbers, items = {}, {}
            for num in line:gmatch("%d+") do table.insert(numbers, tonumber(num)) end

            local pos = 0
            for i = 1, #numbers, 2 do
                table.insert(items, {id = numbers[i], amount = numbers[i+1], pos = pos})
                pos = pos + 1
            end

            for _, entry in ipairs(items) do
                if entry.id == itemID then
                    retrieveItem(entry.id, entry.amount, entry.pos)
                    break -- stop after first match
                end
            end
            handled = true
        end
    end)    
end


callBack()
buy(itemID,price,count)
if getIDamount(itemID) > 150 then store(itemID) end
openInventory()




