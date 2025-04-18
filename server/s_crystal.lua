local QBCore = exports['qb-core']:GetCoreObject()

-- Server-side event to add cotton
RegisterNetEvent('textile:addCotton')
AddEventHandler('textile:addCotton', function()
    print("Add cotton triggered.")
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem("cotton", 1) 
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["cotton"], "add")
        TriggerClientEvent("QBCore:Notify", src, "You harvested 1 cotton!", "success")
    end
end)


RegisterNetEvent("textile:startCrafting")
AddEventHandler("textile:startCrafting", function(cottonRequired, itemToCraft)
    local player = QBCore.Functions.GetPlayer(source)

    -- Debugging: Check if the event is running
    print("Event triggered for player: ", source)

    if not player then
        print("Error: Player not found!")
        return
    end

    -- Check if the player has enough cotton
    local cottonItem = player.Functions.GetItemByName("cotton")
    local cottonCount = cottonItem and cottonItem.amount or 0

    -- Debugging: Check inventory item retrieval
    print("Cotton item data:", json.encode(cottonItem))
    print("Cotton count: ", cottonCount)

    -- Check if the player has enough cotton to craft
    if cottonCount >= cottonRequired then
        -- Trigger the crafting progress bar on client
        TriggerClientEvent("textile:showCraftingProgress", source)

        -- Wait for the duration of the crafting process
        Citizen.Wait(15000)  -- Adjust the wait time to match the progress bar duration

        -- Remove the required amount of cotton and add the crafted item
        player.Functions.RemoveItem("cotton", cottonRequired)
        player.Functions.AddItem(itemToCraft, 1)

        -- Notify the player that the item has been crafted
        TriggerClientEvent("textile:itemCrafted", source, itemToCraft)

        -- Debugging: Confirm that the item was crafted
        print("Crafted item added: " .. itemToCraft)
    else
        TriggerClientEvent("QBCore:Notify", source, "Not enough cotton to craft " .. itemToCraft, "error")
    end
end)
