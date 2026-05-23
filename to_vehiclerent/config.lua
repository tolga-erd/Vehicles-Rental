Config = {}

Config.Framework = "qb" -- esx, qb
Config.key = "item" -- item, custom || shared/functions.lua giveKey and removeKey functions
Config.keyItem = "vehicle_key" -- if it is Config.key, it is available
Config.randomPlate = true -- The plates can be arranged randomly or in a sequence. 
Config.returnRent = 30 -- the money that will be given back after the vehicles are returned (in percentage terms)

Config.discordWebhook = nil

Config.Vehicles = {
    ["car"] = {
        ["blista"] = {
            label = "Blista",
            price = 300 -- Rent Price
        },
        ["zentorno"] = {
            label = "Pegassi Zentorno",
            price = 1000 -- Rent Price
        },
    },
    ["boats"] = {
        ["dinghy4"] = {
            label = "Dinghy",
            price = 300 -- Rent Price
        },
        ["seashark"] = {
            label = "Seashark",
            price = 1000 -- Rent Price
        },

    }
    
}


Config.renterPed = {
    { 
        pedloc = vec4(-1038.94, -2730.76, 19.19, 246.61), 
        model = "a_m_m_business_01",
        vehSpawnLoc = vec4(-1036.77, -2728.90, 20.04, 238.11),
        category = "car",
    },
    { 
        pedloc = vec4(-751.9070, -1510.6294, 4.0057, 8.4326), 
        model = "a_m_m_business_01",
        vehSpawnLoc = vec4(-795.4572, -1503.3235, -0.4748, 85.1763),
        category = "boats",
    },
}
