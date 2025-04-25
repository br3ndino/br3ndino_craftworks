QBCore = exports['qb-core']:GetCoreObject()

-- Handle the milk harvesting event
RegisterNetEvent('cheese:harvestMilk')
AddEventHandler('cheese:harvestMilk', function(cowCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- You can check if the player already has milk or any other conditions here
    -- Add milk to the player's inventory
    Player.Functions.AddItem('milk', 1)

    -- Notify the player
    TriggerClientEvent('QBCore:Notify', src, 'You harvested some milk!', 'success')

    -- Optionally, you can add more logic here for removing the cow or other actions after harvesting
end)

-- Server-side event to add milk
RegisterNetEvent('cheese:addMilk')
AddEventHandler('cheese:addMilk', function()
    print("Add milk triggered.")
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem("milk", 1) -- Make sure "milk" is a valid item in your database
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["milk"], "add")
        TriggerClientEvent("QBCore:Notify", src, "You received 1 milk!", "success")
    end
end)


-- Crafting logic (using milk and other ingredients)
RegisterNetEvent('cheese:craftCheese')
AddEventHandler('cheese:craftCheese', function()
    local player = QBCore.Functions.GetPlayer(source)
    local milkItem = "milk"
    local rennetItem = "rennet"
    local butterItem = "butter"
    local saltItem = "salt"
    local culturesItem = "cultures"
    local lemonJuiceItem = "lemon_juice"

    -- Check if player has required ingredients
    if player.Functions.GetItemByName(milkItem) and player.Functions.GetItemByName(rennetItem) and
        player.Functions.GetItemByName(butterItem) and player.Functions.GetItemByName(saltItem) and
        player.Functions.GetItemByName(culturesItem) and player.Functions.GetItemByName(lemonJuiceItem) then
        
        -- Deduct ingredients
        player.Functions.RemoveItem(milkItem, 1)
        player.Functions.RemoveItem(rennetItem, 1)
        player.Functions.RemoveItem(butterItem, 1)
        player.Functions.RemoveItem(saltItem, 1)
        player.Functions.RemoveItem(culturesItem, 1)
        player.Functions.RemoveItem(lemonJuiceItem, 1)

        -- Add the crafted cheese to the player's inventory
        player.Functions.AddItem("cheese", 1)  -- "cheese" is the crafted item

        -- Notify player
        TriggerClientEvent('QBCore:Notify', source, 'You have crafted cheese!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'You are missing ingredients!', 'error')
    end
end)

RegisterNetEvent("cheese:startCrafting")
AddEventHandler("cheese:startCrafting", function(ingredients, itemToCraft)
    local player = QBCore.Functions.GetPlayer(source)

    if not player then
        print("Error: Player not found!")
        return
    end

    -- Check if player has all required ingredients
    for ingredient, requiredAmount in pairs(ingredients) do
        local item = player.Functions.GetItemByName(ingredient)
        local amount = item and item.amount or 0
        if amount < requiredAmount then
            TriggerClientEvent("QBCore:Notify", source, "Not enough " .. ingredient .. " to craft " .. itemToCraft, "error")
            return
        end
    end

    -- Show client-side progress
    TriggerClientEvent("cheese:showCraftingProgress", source)
    Wait(5000) -- Or use ingredients.duration if needed in future

    -- Remove ingredients and add the crafted item
    for ingredient, requiredAmount in pairs(ingredients) do
        player.Functions.RemoveItem(ingredient, requiredAmount)
    end
    player.Functions.AddItem(itemToCraft, 1)
    TriggerClientEvent("cheese:itemCrafted", source, itemToCraft)
end)

