function giveKey(src, plate, model)
    if Config.key == "item" then
        local metadata = {
            plate = plate,
            model = model
        }
        return framework.AddItem(src, Config.keyItem, 1, metadata)
    else
        return -- Custom key script here
    end
end

function removeKey(src, plate, model)
    if Config.key == "item" then
        local metadata = {
            plate = plate,
            model = model
        }
        return framework.RemoveItem(src, Config.keyItem, 1, metadata)
    else
        return true-- Custom key script here
    end
end

function notify(src, t, message)
    TriggerClientEvent('ox_lib:notify', src, {
        title = "Vehicle Rental",
        description = message,
        type = t,
    })
end
