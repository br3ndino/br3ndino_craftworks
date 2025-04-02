local lib = exports.ox_lib
local QBCore = exports['qb-core']:GetCoreObject()
local cows = {}
local milkHarvesting = false
local milkHarvestingEntity = nil

-- Function to spawn cows
function spawnCow(x, y, z)
    local cowModel = `a_c_cow`
    RequestModel(cowModel)
    while not HasModelLoaded(cowModel) do Wait(100) end

    local cow = CreatePed(4, cowModel, x, y, z, 0.0, true, false)
    SetEntityInvincible(cow, true)
    FreezeEntityPosition(cow, true)

    exports['qb-target']:AddTargetEntity(cow, {
        options = {
            {
                event = 'cheese:startMilkHarvest',
                icon = 'fas fa-cow',
                label = 'Harvest Milk',
                action = function(entity)
                    TriggerEvent('cheese:startMilkHarvest', cow)
                end,
            },
        },
        distance = 2.0,
    })
    table.insert(cows, cow)
    name = "milk_cow_" .. cow -- Unique ID
end

-- Spawn cows at preset locations
Citizen.CreateThread(function()
    if Config and Config.CowSpawnLocations then
        for _, point in pairs(Config.CowSpawnLocations) do
            spawnCow(point.x, point.y, point.z)
        end
    else
        print("Config.CowSpawnLocations is missing or empty!")
    end
end)

-- Function to handle harvesting loop
function MilkHarvestingLoop(cow)
    Citizen.CreateThread(function()
        while isHarvestingMilk do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local cowCoords = GetEntityCoords(cow)
            local dist = #(playerCoords - cowCoords)

            -- Stop if player moves too far
            if dist > 3.0 then
                TriggerEvent("QBCore:Notify", "You moved too far from the cow!", "error")
                isHarvestingMilk = false
                return
            end

            -- Start progress bar
            exports['progressbar']:Progress({
                name = "harvest_milk",
                duration = 5000,
                label = "Harvesting Milk...",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {disableMovement = true, disableCarMovement = true, disableMouse = true, disableCombat = true},
                animation = {dict = "amb@world_human_bum_wash@male@idle_a", clip = "idle_a"},
                onCancel = function()
                    isHarvestingMilk = false
                    TriggerEvent("QBCore:Notify", "Milk Harvesting Canceled", "error")
                end
            })

            Citizen.Wait(5000) -- Wait for progress bar duration

            -- Check if still harvesting
            if isHarvestingMilk then
                print("Milk event triggered")
                TriggerServerEvent('cheese:addMilk') -- Give milk
                Citizen.Wait(2000) -- Short delay
            end
        end
    end)
end

-- Event to start milk harvesting
RegisterNetEvent('cheese:startMilkHarvest')
AddEventHandler('cheese:startMilkHarvest', function(cow)
    if isHarvestingMilk then
        TriggerEvent("QBCore:Notify", "You are already harvesting milk!", "error")
        return
    end

    local playerPed = PlayerPedId()
    local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(cow))

    if dist > 3.0 then
        TriggerEvent("QBCore:Notify", "You are too far from the cow!", "error")
        return
    end

    isHarvestingMilk = true
    milkHarvestingEntity = cow  -- Track the cow being milked
    MilkHarvestingLoop(cow)
end)

-- Event to stop milk harvesting
RegisterNetEvent('cheese:stopMilkHarvest')
AddEventHandler('cheese:stopMilkHarvest', function()
    isHarvestingMilk = false
    milkHarvestingEntity = nil
end)



-- Crafting location (milk crafting area)
local cheeseCraftingLocation = Config.CheeseCraftLocation

-- Create the crafting location with qb-target
Citizen.CreateThread(function()
    exports['qb-target']:AddBoxZone("CheeseCrafting", cheeseCraftingLocation, 1, 1, {
        name="CheeseCraftingLocation",
        heading=0,
        debugPoly=false,
        minZ=29.0,
        maxZ=31.0
    }, {
        options = {
            {
                type = "client",
                event = "cheese:openCraftingMenu",
                icon = "fas fa-cogs",
                label = "Open Crafting Menu"
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent("cheese:openCraftingMenu", function()
    -- Get player inventory
    local playerData = QBCore.Functions.GetPlayerData()
    local inventory = playerData and playerData.items or {}

    -- Ingredient counters
    local ingredientCounts = {
        milk = 0,
        butter = 0,
        rennet = 0,
        salt = 0,
        cultures = 0,
        lemon_juice = 0
    }

    -- Loop through inventory to count each ingredient
    for _, item in pairs(inventory) do
        if ingredientCounts[item.name] then
            ingredientCounts[item.name] = item.amount or 0
        end
    end

    -- Debugging: Print ingredient counts
    print("Ingredient Counts: " .. json.encode(ingredientCounts))

    -- Build crafting menu dynamically based on available ingredients
    local options = {}

    for cheese, recipe in pairs(Config.CheeseRecipes) do
        local canCraft = true

        -- Check if player has enough of each ingredient
        for ingredient, requiredAmount in pairs(recipe.ingredients) do
            if ingredientCounts[ingredient] < requiredAmount then
                canCraft = false
                break
            end
        end

        -- Add to menu if craftable
        if canCraft then
            table.insert(options, {
                title = cheese,
                description = recipe.description,
                onSelect = function()
                    TriggerServerEvent("cheese:startCrafting", recipe.duration, cheese)
                end
            })
        end
    end

    -- If no options available, notify and exit
    if #options == 0 then
        QBCore.Functions.Notify("You don't have enough ingredients!", "error")
        return
    end

    -- Show the context menu
    exports.ox_lib:registerContext({
        id = "cheese_menu",
        title = "Cheese Crafting",
        options = options
    })
    exports.ox_lib:showContext("cheese_menu")
end)

-- Progress bar event
RegisterNetEvent("cheese:showCraftingProgress", function()
    print("Progress bar triggered")  -- Debugging
    exports['progressbar']:Progress({
        name = "crafting_cheese",
        duration = 5000,
        label = "Crafting Cheese...",
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missmechanic",
            anim = "work2_base",
        },
        prop = {},
        propTwo = {}
    }, function(cancelled)
        if cancelled then
            print("Crafting Cancelled")
        else
            print("Crafting Complete")
        end
    end)
end)

RegisterNetEvent("cheese:itemCrafted", function(itemToCraft)
    print("Item crafted: " .. itemToCraft)
    QBCore.Functions.Notify("You crafted 1 " .. itemToCraft, "success")
end)
