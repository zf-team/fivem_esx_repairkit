local percentage = Config.repairkit.engine_destroy_percent
local repairtimer = Config.repairkit.repair_timer * 1000
local repair_car_visual = Config.repairkit.repair_car_visual

local progress_bar_color = Config.progressbar.progress_bar_color
local bar_color = Config.progressbar.bar_color
local show_bar = Config.progressbar.show_bar
local bar_x = Config.progressbar.bar_x
local bar_y = Config.progressbar.bar_y
local bar_width = Config.progressbar.bar_width
local bar_height = Config.progressbar.bar_height

local text_color = Config.text.text_color
local show_text = Config.text.show_text
local text_x = Config.text.text_x
local text_y = Config.text.text_y
local text_scale = Config.text.text_scale

local particleEffect = nil
local particle_dict = Config.engine_check.particle_dict
local particle_effect = Config.engine_check.particle_effect
local particle_size = Config.engine_check.particle_size
local activeParticles = {}

RegisterNetEvent('startSmoke')
AddEventHandler('startSmoke', function(car)
    for i = 0, 10 do
        UseParticleFxAssetNextCall(particle_dict)
        particleEffect = StartParticleFxLoopedOnEntityBone(
            particle_effect, 
            car, 
            0, 0, 0, 
            0, 0, 0, 
            GetEntityBoneIndexByName(car, "engine"), 
            particle_size, 
            0, 0, 0
        )
        table.insert(activeParticles, particleEffect)
    end
end)

RegisterNetEvent('stopSmoke')
AddEventHandler('stopSmoke', function()
    for _, particleEffect in ipairs(activeParticles) do
        if particleEffect ~= nil then
            RemoveParticleFx(particleEffect, false)
        end
    end
    activeParticles = {}
end)

function drawText(text, x, y, scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(text_color[1], text_color[2], text_color[3], text_color[4])
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)

    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function isPlayerInFrontOfVehicleEngine(playerPed, vehicle)
    local playerPos = GetEntityCoords(playerPed)

    local enginePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "engine"))

    if enginePos == vector3(0.0, 0.0, 0.0) then
        enginePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "bonnet"))

        if enginePos == vector3(0.0, 0.0, 0.0) then
            enginePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "boot"))
        end
    end

    if enginePos == vector3(0.0, 0.0, 0.0) then
        enginePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 3.0, 0.0)
    end

    local distance = #(playerPos - enginePos)

    return distance < 1.5
end

function drawProgressBar(progress, x, y, width, height)
    DrawRect(x, y, width, height, bar_color[1], bar_color[2], bar_color[3], bar_color[4])

    local progressWidth = (progress / 100) * width

    DrawRect(x - width / 2 + progressWidth / 2, y, progressWidth, height, progress_bar_color[1], progress_bar_color[2], progress_bar_color[3], progress_bar_color[4])
end

function randomEngineDestroy(percentage)
    return math.random(0, 100) <= percentage
end

function playRepairAnimation(vehicle)
    local playerPed = PlayerPedId()

    if isPlayerInFrontOfVehicleEngine(playerPed, vehicle) then

        SetVehicleDoorOpen(vehicle, 4, false, false)

        if not HasAnimDictLoaded("mini@repair") then
            RequestAnimDict("mini@repair")
            while not HasAnimDictLoaded("mini@repair") do
                Citizen.Wait(100)
            end
        end

        TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 49 + 16, 0, false, false, false)

        local progress = 0
        local totalDuration = repairtimer 
        local incrementTime = 100 
        local progressIncrement = 100 / (totalDuration / incrementTime)

        local startTime = GetGameTimer()
        
        Citizen.CreateThread(function()
            while progress < 100 do 
                Citizen.Wait(0) 

                if not IsEntityPlayingAnim(playerPed, "mini@repair", "fixing_a_ped", 3) then
                    TriggerEvent('esx:showNotification', 'Reparatur abgebrochen.')
                    ClearPedTasks(playerPed)
                    return
                end

                if show_text then
                    drawText("Reparatur läuft...", text_x, text_y, text_scale)
                end

                if show_bar then
                    drawProgressBar(progress, bar_x, bar_y, bar_width, bar_height)
                end

                if GetGameTimer() - startTime >= incrementTime then
                    progress = progress + progressIncrement
                    startTime = GetGameTimer()
                end
            end

            Citizen.Wait(500)

            ClearPedTasks(playerPed) 

            if repair_car_visual then
                SetVehicleBodyHealth(vehicle, 1000.0)
            end

            SetVehicleEngineHealth(vehicle, 1000.0)

            SetVehicleDoorShut(vehicle, 4, false, false)

            TriggerEvent('esx:showNotification', 'Dein Fahrzeug wurde repariert.')

            TriggerServerEvent('repairkit:consume')

        end)
    else
        TriggerEvent('esx:showNotification', 'Du musst vor dem Motor deines Fahrzeuges stehen, um es reparieren zu können.')
    end
end

RegisterNetEvent('repairkit:startRepair')
AddEventHandler('repairkit:startRepair', function()
    local playerPed = PlayerPedId()
    local vehicleInFront = GetClosestVehicle(GetEntityCoords(playerPed), 3.0, 0, 70)

    if vehicleInFront then
        local plate = GetVehicleNumberPlateText(vehicleInFront)
        local enginehealth = GetVehicleEngineHealth(vehicleInFront)
        local bodyhealth = GetVehicleBodyHealth(vehicleInFront)


        if enginehealth == 0.0 then
            TriggerEvent('esx:showNotification', 'Dein Fahrzeug ist kaputt, rufe einen Mechaniker um es wieder zu reparieren.')
        elseif enginehealth == 1000.0 then
            TriggerEvent('esx:showNotification', 'Dein Fahrzeug muss nicht repariert werden.')
        else
            if randomEngineDestroy(percentage) then
                TriggerEvent('esx:showNotification', 'Du hast ein Fehler bei der Reperatur deines Fahrzeuges geamcht, der Motor ist kaputt gegangen.')
                SetVehicleEngineHealth(vehicleInFront, 0.0)
            else
                playRepairAnimation(vehicleInFront)
            end
        end
    else
        TriggerEvent('esx:showNotification', 'Kein Fahrzeug in der Nähe.')
    end

end)

Citizen.CreateThread(function()
    local lastVehicle = nil
    local lastEngineCheck = nil

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 71)

        if IsPedInAnyVehicle(ped, false) then
            vehicle = GetVehiclePedIsIn(ped, false)
        end

        if vehicle and vehicle ~= 0 then
            local engine_check = GetVehicleEngineHealth(vehicle)
            local smoke_start = Config.engine_check.smoke_start
            local speed_reduce_start = Config.engine_check.speed_reduce_start
            local speed_reduce = Config.engine_check.speed_reduce
            local damage_modifier = Config.engine_check.damage_modifier

            local max_speed = GetVehicleModelEstimatedMaxSpeed(GetEntityModel(vehicle))
            local new_maxSpeed = max_speed / speed_reduce

            SetVehicleDamageModifier(vehicle, damage_modifier)

            if engine_check <= smoke_start then
                TriggerServerEvent('syncSmoke', vehicle, true)
            elseif engine_check > smoke_start then
                TriggerServerEvent('syncSmoke', vehicle, false)
            end

            if engine_check <= speed_reduce_start then
                SetVehicleMaxSpeed(vehicle, new_maxSpeed)
            end
        else
            lastVehicle = nil
            lastEngineCheck = nil
        end

        Citizen.Wait(1000)
    end
end)