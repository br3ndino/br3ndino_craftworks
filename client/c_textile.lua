local lib = exports.ox_lib
local QBCore = exports['qb-core']:GetCoreObject()

local cottonPlants = {}
local cottonHarvesting = false
local cottonHarvestingEntity = nil -- To track the entity being harvested

-- Function to spawn cotton plants
function spawnCottonPlant(x, y, z)
    local cottonModel = `prop_plant_fern_02a` -- Change to an appropriate cotton plant model
    RequestModel(cottonModel)
    while not HasModelLoaded(cottonModel) do Wait(100) end

    local cottonPlant = CreateObject(cottonModel, x, y, z, true, true, false)
    SetEntityInvincible(cottonPlant, true)
    FreezeEntityPosition(cottonPlant, true)

    exports['qb-target']:AddTargetEntity(cottonPlant, {
        options = {
            {
                icon = 'fas fa-hand-paper',
                label = 'Harvest Cotton',
                action = function(entity)
                    TriggerEvent('textile:startCottonHarvest', cottonPlant)
                end,
            },
        },
        distance = 2.0,
        name = "cotton_plant_" .. cottonPlant -- Unique ID
    })

    table.insert(cottonPlants, cottonPlant)
end

-- Spawn cotton plants from Config
Citizen.CreateThread(function()
    if Config and Config.CottonSpawnLocations then
        for _, point in pairs(Config.CottonSpawnLocations) do
            spawnCottonPlant(point.x, point.y, point.z)
        end
    else
        print("Config.CottonSpawnLocations is missing or empty!")
    end
end)

-- Function to handle harvesting loop
function CottonHarvestingLoop(cottonPlant)
    Citizen.CreateThread(function()
        while isHarvestingCotton do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local plantCoords = GetEntityCoords(cottonPlant)
            local dist = #(playerCoords - plantCoords)

            -- Stop if player moves too far
            if dist > 3.0 then
                TriggerEvent("QBCore:Notify", "You moved too far from the cotton plant!", "error")
                isHarvestingCotton = false
                return
            end

            -- Start progress bar
            exports['progressbar']:Progress({
                name = "harvest_cotton",
                duration = 5000,
                label = "Harvesting Cotton...",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {disableMovement = true, disableCarMovement = true, disableMouse = true, disableCombat = true},
                animation = {animDict = "amb@world_human_gardener_plant@male@idle_a", anim = "idle_a"},
                onCancel = function()
                    isHarvestingCotton = false
                    TriggerEvent("QBCore:Notify", "Cotton Harvesting Canceled", "error")
                end
            })

            Citizen.Wait(5000) -- Wait for progress bar duration

            -- Check if still harvesting
            if isHarvestingCotton then
                print("Cotton event triggered")
                TriggerServerEvent('textile:addCotton') -- Give cotton
                Citizen.Wait(2000) -- Short delay
            end
        end
    end)
end

-- Event to start harvesting
RegisterNetEvent('textile:startCottonHarvest')
AddEventHandler('textile:startCottonHarvest', function(cottonPlant)
    if isHarvestingCotton then
        TriggerEvent("QBCore:Notify", "You are already harvesting cotton!", "error")
        return
    end

    local playerPed = PlayerPedId()
    local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(cottonPlant))

    if dist > 3.0 then
        TriggerEvent("QBCore:Notify", "You are too far from the cotton plant!", "error")
        return
    end

    isHarvestingCotton = true
    cottonHarvestingEntity = cottonPlant  -- Track the cotton plant being harvested
    CottonHarvestingLoop(cottonPlant)
end)

RegisterNetEvent('textile:stopCottonHarvest')
AddEventHandler('textile:stopCottonHarvest', function()
    isHarvestingCotton = false
    cottonHarvestingEntity = nil
end)

-- Crafting location (textile crafting area)
local cottonCraftingLocation = Config.TextileCraftLocation

-- Create the crafting location with qb-target
Citizen.CreateThread(function()
    exports['qb-target']:AddBoxZone("CottonCrafting", cottonCraftingLocation, 1, 1, {
        name="CottonCrafting",
        heading=0,
        debugPoly=false,
        minZ=29.0,
        maxZ=31.0
    }, {
        options = {
            {
                type = "client",
                event = "textile:openCraftingMenu",
                icon = "fas fa-cogs",
                label = "Open Crafting Menu"
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent("textile:openCraftingMenu", function()
    local cottonCount = 0

    -- Access player data
    local playerData = QBCore.Functions.GetPlayerData()

    -- Debug: Print out the entire inventory data
    print("Player Data: " .. json.encode(playerData))

    -- Check if cotton item exists in inventory
    if playerData and playerData.items then
        -- Loop through the items to find cotton
        for _, item in pairs(playerData.items) do
            if item.name == "cotton" then
                cottonCount = item.amount or 0
                break
            end
        end
    end

    -- Debug: Log the cotton count
    print("Cotton Count: " .. cottonCount)

    -- Check if the player has enough cotton to craft
    if cottonCount >= 3 then
        -- Define the crafting options for the context menu
        local options = {
            {
                title = "🧦 Socks",
                description = "Requires 5 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 5, "sock")
                end
            },
            {
                title = "👕 Shirt",
                description = "Requires 10 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 10, "shirt")
                end
            },
            {
                title = "👖 Pants",
                description = "Requires 15 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 15, "pants")
                end
            },
            {
                title = "👜 Purse",
                description = "Requires 20 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 20, "purse")
                end
            },
            {
                title = "👚 Fake Designer Shirt",
                description = "Requires 25 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 25, "fake_shirt")
                end
            },
            {
                title = "👖 Fake Designer Pants",
                description = "Requires 30 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 30, "fake_pants")
                end
            },
            {
                title = "👛 Fake Designer Purse",
                description = "Requires 35 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 35, "fake_purse")
                end
            },
            {
                title = "👮 Fake Police Uniform",
                description = "Requires 40 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 40, "fake_police")
                end
            },
            {
                title = "🩹 Bandaid",
                description = "Requires 50 Cotton",
                onSelect = function()
                    TriggerServerEvent("textile:startCrafting", 50, "bandage")
                end
            },
        }

        -- Show the context menu with ox_lib:registerContext
        exports.ox_lib:registerContext({
            id = "textile_menu",
            title = "Textile Crafting",
            options = options
        })

        -- Open the context menu
        exports.ox_lib:showContext("textile_menu")
    else
        QBCore.Functions.Notify("You don't have enough cotton!", "error")
    end
end)

-- Show progress bar on crafting
RegisterNetEvent("textile:showCraftingProgress", function()
    print("Progress bar triggered")  -- Debugging line to check if the event is fired
    exports['progressbar']:Progress({
        name = "Sewing Cotton",
        duration = 5000,
        label = "Sewing Cotton",
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
        if not cancelled then
            print("Not cancelled")
        else
            print("Cancelled")
        end
    end)
end)


RegisterNetEvent("textile:itemCrafted", function(itemToCraft)
    print("Item crafted: " .. itemToCraft)  -- Debugging line to ensure the item is crafted
    -- Notify the player and update inventory
    QBCore.Functions.Notify("You crafted 1 " .. itemToCraft, "success")
end)
