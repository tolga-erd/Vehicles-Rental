Citizen.CreateThread(function()
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `tolib_rentvehicles` (
            `rentId` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` text DEFAULT NULL,
            `model` text DEFAULT NULL,
            `plate` text NOT NULL,
            PRIMARY KEY (`rentId`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]], {}, function(result)
    end)
end)

Citizen.CreateThread(function()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    local versionUrl = "https://raw.githubusercontent.com/tolib-fivem/vehiclerental/main/version.txt"

    PerformHttpRequest(versionUrl, function(errorCode, resultData, resultHeaders)
        if errorCode == 200 then
            local latestVersion = resultData:gsub("%s+", "")
            if latestVersion ~= currentVersion then
                Wait(2000)
                print("^1[WARNING]^2 " .. GetCurrentResourceName() .. " Latest Version: " .. latestVersion .. " | Your Version: " .. currentVersion .. "^0")
            end
        end
    end, 'GET')
end)

local hook = Config.discordWebhook
local rawServerName = GetConvar("sv_projectName", "FiveM Server")
local cleanServerName = rawServerName:gsub("%^%d", "")

function SendDiscordLog(name, message, color)
    local connect = {
        {
            ["color"] = color,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = cleanServerName.." • " .. os.date("%x %X"),
            },
        }
    }
    
    if not hook then return print("Webhook not defined!") end
    PerformHttpRequest(hook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
end

local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

function GenerateRandomPlate()
    local plate = ""
    for i = 1, 7 do
        if i == 4 then plate = plate .. " " end
        local rand = math.random(1, #charset)
        plate = plate .. string.sub(charset, rand, rand)
    end
    return string.upper(plate)
end

lib.callback.register("to_lib:rentVehicleKey", function(src, model, category)
    local money = framework.money(src)

    price = Config.Vehicles[category][model].price

    if money >= price then
        if not framework.RemoveMoney(src, "bank", price) then return notify(src, "error", "An unexpected error occurred") end
        local plate = "RENT"
        local result = MySQL.Sync.fetchAll('SELECT plate FROM tolib_rentvehicles')

        local x = 0
        
        while true do
            x += 1
            for i, n in ipairs(result) do
                if not Config.randomPlate then
                    if plate .. x == n.plate then
                        goto continue
                    end
                else
                    plate = GenerateRandomPlate()
                    if plate == n.plate then
                        goto continue
                    end
                end
            end
            if not Config.randomPlate then plate = plate .. x end
            break
            ::continue::
        end

        local identifier = framework.getIdentifier(src)
        SendDiscordLog("Vehicle Rental", 
        GetPlayerName(src) .. " - (".. src ..") player car rental successful.\n\nPlate: ".. plate .."\nPrice:".. price .."\nModel: ".. model, 
        65280)
        MySQL.Async.execute('INSERT INTO tolib_rentvehicles(identifier, plate, model) VALUES(@identifier, @plate, @model)', {
            ["identifier"] = identifier,
            ["plate"] = plate,
            ["model"] = model
        })

        giveKey(src, plate, model)
        notify(src, "success", "Vehicle rent success")
        return true, plate
    else
        notify(src, "error", "Your account balance is insufficient")
        return false, nil
    end
end)

lib.callback.register("to_lib:returnVehicleList", function(src) 
    local identifier = framework.getIdentifier(src)

    local result = MySQL.Sync.fetchAll('SELECT plate, model FROM tolib_rentvehicles WHERE identifier = @identifier', {
        ["identifier"] = identifier
    })

    return result
end)

lib.callback.register("to_lib:returnVehicles", function(src, plate, model, category) 
    local result = removeKey(src, plate, model)

    if plate and result then
        local rows = MySQL.Sync.fetchAll('SELECT * FROM tolib_rentvehicles WHERE plate = @plate', {
            ["@plate"] = plate
        })

        if #rows > 0 then
            MySQL.Sync.execute('DELETE FROM tolib_rentvehicles WHERE plate = @plate', {
                ["@plate"] = plate
            })
            local pay = (Config.Vehicles[category][model].price / 100) * Config.returnRent
            SendDiscordLog("Vehicle Rental", 
            GetPlayerName(src) .. " - (".. src ..") player car rental successful.\n\nPlate: ".. plate .."\nAmount refunded:".. pay .."\nModel: ".. model, 
            255)
            notify(src, "success", "Vehicle returned success")
            return framework.AddMoney(src, pay) 
        else
            notify(src, "error", "Vehicle not found")
            return false
        end
    else
        notify(src, "error", "You don't have vehicle keys!")
        return false
    end
end)