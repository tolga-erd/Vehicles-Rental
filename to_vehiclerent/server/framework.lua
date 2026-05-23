framework = {}
CreateThread(function()
    if Config.Framework == "esx" then
        ESX = exports["es_extended"]:getSharedObject()
    elseif Config.Framework == "qb" then
        QBCore = exports["qb-core"]:GetCoreObject()
    end
end)

function framework.getPlayer(src)
    if Config.Framework == "esx" then
        return ESX.GetPlayerFromId(src)
    elseif Config.Framework == "qb" then
        return QBCore.Functions.GetPlayer(src)
    end
end

function framework.getIdentifier(src)
    local xPlayer = framework.getPlayer(src)
    if Config.Framework == "esx" then
        return xPlayer.getIdentifier()
    elseif Config.Framework == "qb" then
        return xPlayer.PlayerData.citizenid
    end
end

function framework.money(src)
    local xPlayer = framework.getPlayer(src)
    if Config.Framework == "esx" then
        return xPlayer.getAccount('bank').money
    elseif Config.Framework == "qb" then
        return xPlayer.Functions.GetMoney('bank')
    end
end

function framework.AddMoney(src, amount)
    local xPlayer = framework.getPlayer(src)
    if Config.Framework == "esx" then
        xPlayer.addAccountMoney("bank", amount)
        return true
    elseif Config.Framework == "qb" then
        return xPlayer.Functions.AddMoney("bank", amount)
    end
end

function framework.RemoveMoney(src, account, amount)
    local xPlayer = framework.getPlayer(src)
    if Config.Framework == "esx" then
        xPlayer.removeAccountMoney(account, amount)
        return true
    elseif Config.Framework == "qb" then
        return xPlayer.Functions.RemoveMoney(account, amount)
    end
end

function framework.AddItem(src, item, count, metadata)
    local xPlayer = framework.getPlayer(src)

    if Config.Framework == "esx" then
        return xPlayer.addInventoryItem(item, count, metadata)
    elseif Config.Framework == "qb" then
        xPlayer.Functions.AddItem(item, count, false, metadata)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[item], "add")
        return true
    end
end


function framework.RemoveItem(src, item, count, metadata)
    local xPlayer = framework.getPlayer(src)
    if Config.Framework == "esx" then
        return xPlayer.removeInventoryItem(item, count, metadata)
    elseif Config.Framework == "qb" then
        local items = xPlayer.Functions.GetItemsByName(item)
        if not items then return false end
        
        for slot, v in pairs(items) do
            if metadata then
                if v.count >= count then
                    local removed = xPlayer.Functions.RemoveItem(item, count, v.info, v.slot)
                    if removed then
                        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[item], "remove")
                        return true
                    end
                end
            end
        end
        return false
    end
end
