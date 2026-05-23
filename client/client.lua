local vehSpawnLoc = nil
local fo = true
local Category = ""
function rentVehicle(model)
    local vehicleHash = GetHashKey(model)

    local loadModel = 0
    RequestModel(vehicleHash)

    while not HasModelLoaded(vehicleHash) do
        Wait(100)
        loadModel += 1
        if loadModel >= 100 then
            return notification("error", "Vehicle not found")
        end
    end
    
    local success, plate =  lib.callback('to_lib:rentVehicleKey', 2000, nil, model, Category)
    if not success then return end
    fo = true
    
    local veh = CreateVehicle(vehicleHash, vehSpawnLoc.x, vehSpawnLoc.y, vehSpawnLoc.z, vehSpawnLoc.w, true, true)
    SetVehicleNumberPlateText(veh, plate)
    SetEntityAsMissionEntity(veh, true, true)
end

function returnVehicles(plate, model)
    lib.callback('to_lib:returnVehicles', 2000, function(success)
        if success then
            local vehicles = GetGamePool("CVehicle")
            fo = true

            for _, vehicle in ipairs(vehicles) do
                local plt = GetVehicleNumberPlateText(vehicle)
                if plt:match("^%s*(.-)%s*$") == plate:match("^%s*(.-)%s*$") then
                    DeleteEntity(vehicle)
                end
            end
        end
    end, plate, model, Category)    
end



function openRentMenu()
    if fo then
        local rawOwnVeh = lib.callback.await('to_lib:returnVehicleList', 2000)
        local ownVeh = {}
        local c = 1
        
        if rawOwnVeh then
            for i,n in pairs(rawOwnVeh) do
                local model = Config.Vehicles[Category][n.model]

                print(json.encode(n))
                if model then 
                    ownVeh[c] = {
                        label = Config.Vehicles[Category][n.model]?.label,
                        model = n.model,
                        plate = n.plate
                    }
                    c = c + 1
                end
            end
        end 
        
        SendNUIMessage({
            type = "vehiclesData",
            returnRent = Config.returnRent,
            data = Config.Vehicles[Category],
            ownVeh = ownVeh
        })
        fo = false
    end
    
    SendNUIMessage({
        type = "showUI"
    })
    SetNuiFocus(true, true)

end

RegisterNUICallback("closeUI", function(data, cb)
    if data.vehicleName and data.plate == "" then
        rentVehicle(data.vehicleName)
    elseif data.vehicleName and data.plate ~= "" then
        returnVehicles(data.plate, data.vehicleName)
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

Citizen.CreateThread(function()
    for i,n in pairs(Config.renterPed) do
        local model = GetHashKey(n.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(500)
        end

        local ped = CreatePed(1, model, n.pedloc.x, n.pedloc.y, n.pedloc.z, n.pedloc.w, false, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", -1, true)
        FreezeEntityPosition(ped, true)

        local option = {
            label = "Araç Kirala",
            icon = "fa-solid fa-car-side",
            onSelect = function() 
                print(Category, n.category)
                if Category ~= n.category then 
                    fo = true
                    Category = n.category
                end
                
                openRentMenu()
                vehSpawnLoc = n.vehSpawnLoc
            end
        }

        exports.ox_target:addLocalEntity(ped, option)
    end
end)
