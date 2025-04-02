Config = {}

-- TEXTILE CONFIG
Config.TextileCraftLocation = vector3(718.6765, -963.7034, 30.4178)
Config.CottonSpawnLocations = {
    vector3(2344.9458, 5114.4438, 47.1410),
    vector3(2341.1426, 5118.0347, 47.0773),
    vector3(2335.1033, 5123.6792, 47.3318),
    vector3(2337.4644, 5121.5483, 47.1493),
    vector3(2332.5808, 5126.3750, 47.5618),
    vector3(2329.4734, 5129.2456, 47.8489),
}

--CHEESEMAKING CONFIG
Config.CowSpawnLoctions = {
    vector3(2386.3560, 5054.5181, 45.4446),
    vector3(2382.2139, 5049.9624, 45.4350),
    vector3(2374.6006, 5048.5874, 45.4446),
    vector3(2372.4551, 5055.9966, 45.4428),
}
Config.CheeseRecipes = {
    ["Mozzarella"] = {
        description = "A soft and stretchy cheese",
        duration = 5000,
        ingredients = { milk = 5, rennet = 2, salt = 1, cultures = 1, lemon_juice = 2 }
    },
    ["Cheddar"] = {
        description = "A sharp, flavorful cheese",
        duration = 5000,
        ingredients = { milk = 4, butter = 2, rennet = 1, salt = 3, cultures = 2 }
    },
    ["Brie"] = {
        description = "A soft and creamy cheese",
        duration = 5000,
        ingredients = { milk = 5, butter = 1, rennet = 2, salt = 1, cultures = 3 }
    },
    ["Gouda"] = {
        description = "A mild and nutty cheese",
        duration = 5000,
        ingredients = { milk = 5, butter = 2, rennet = 2, salt = 2, cultures = 1 }
    },
    ["Ricotta"] = {
        description = "A light and fluffy cheese",
        duration = 5000,
        ingredients = { milk = 4, butter = 1, salt = 2, lemon_juice = 3 }
    },
    ["Parmesan"] = {
        description = "A hard, aged cheese",
        duration = 5000,
        ingredients = { milk = 5, butter = 2, rennet = 1, salt = 3, cultures = 2 }
    }
}
