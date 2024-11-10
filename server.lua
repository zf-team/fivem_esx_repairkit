ESX = exports['es_extended']:getSharedObject()

function areBlacklistedJobsOnline()
    local players = ESX.GetPlayers()
    local blacklistJobs = Config.repairkit.blacklist_jobs

    for i = 1, #players, 1 do
        local xPlayer = ESX.GetPlayerFromId(players[i])
        for j = 1, #blacklistJobs, 1 do
            print(blacklistJobs[j])
            if xPlayer.job.name == blacklistJobs[j] then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent('checkVehicleOwnership')
AddEventHandler('checkVehicleOwnership', function(plate, vehicle, text)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        local identifier = xPlayer.getIdentifier()

        MySQL.Async.fetchScalar('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
            ['@plate'] = plate
        }, function(owner)
            local isOwner = owner == identifier

            if text == "repairkit" then
                TriggerClientEvent('checkVehicleOwnershipResponse', _source, isOwner, vehicle)
            end
        end)
    else
        TriggerClientEvent('checkVehicleOwnershipResponse', _source, false, vehicle)
    end
end)

ESX.RegisterUsableItem('repairkit', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if areBlacklistedJobsOnline() then
        TriggerClientEvent('esx:showNotification', source, 'Mechaniker sind online. Du kannst dein Fahrzeug nicht reparieren während sie online sind.')
    else
        TriggerClientEvent('repairkit:startRepair', source)
    end
end)

RegisterNetEvent('repairkit:consume')
AddEventHandler('repairkit:consume', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        xPlayer.removeInventoryItem('repairkit', 1)
    end
end)

RegisterServerEvent('syncSmoke')
AddEventHandler('syncSmoke', function(car, start)
    if start then
        TriggerClientEvent('startSmoke', -1, car)
    else
        TriggerClientEvent('stopSmoke', -1)
    end
end)