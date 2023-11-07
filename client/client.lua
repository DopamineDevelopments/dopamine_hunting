local isHunting = false
local DPMN = DPMN.Hunting
local boar = DPMN.AnimalModel
local spawnedBoar = {}
local spawnedBoarCounter = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('dopamine_grindings:notify')
AddEventHandler('dopamine_grindings:notify', function(title, msg, msgType, duration)
  lib.notify({
    title = title,
    description = msg,
    position = 'center-right',
    type = msgType,
    duration = duration,
  })
end)

CreateThread(function()
  local DPMN = DPMN.Ped
  local modelHash = GetHashKey(DPMN.model)
  RequestModel(modelHash) 
  while ( not HasModelLoaded(modelHash) ) do
      Wait(1)
  end
  local ped = CreatePed(1, modelHash, DPMN.coords, false, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true) 
  TaskStartScenarioInPlace(ped, DPMN.scenario, -1, true) 
  FreezeEntityPosition(ped, true)
end)

CreateThread(function()
  for k,v in pairs(DPMN.Target) do
    exports.ox_target:addBoxZone({
      coords = v.Coords,
      size = v.Size,
      rotation = v.Heading,
      drawSprite = false,
      options = {
        {
          label = 'Start/Stop Hunting Job',
          name = 'starthuntingjob',
          icon = 'fa fa-person-rifle',
          distance = 2,
          onSelect = function()
            if not isHunting then
              startHunting()
            else
              endHunting()
            end
          end
        },
        {
          label = 'Sell Carcass?',
          name = 'starthuntingjob',
          icon = 'fa fa-sack-dollar',
          distance = 2,
          onSelect = function()
            ESX.TriggerServerCallback('dopamine_grindings:getItemAmount', function(itemCount)
              if itemCount == 0 then
                TriggerEvent('dopamine_grindings:notify', 'Hunting Job', 'You don\'t have any carcass!', 'inform', 5000)
              else
                local input = lib.inputDialog('Sell Carcass?', {
                  {type = 'number', label = 'Quantity', icon = 'hashtag', min = 1, max = itemCount},
                })
                if input[1] == '' then return end
                if not input then return end
                ESX.TriggerServerCallback('dopamine_grindings:getPassword', function(password)
                  TriggerServerEvent('dopamine_grindings:addItem', 'money', tonumber(input[1])*2000, password)
                  TriggerServerEvent('dopamine_grindings:removeItem', 'carcass', tonumber(input[1]))
                end)
              end
            end, 'carcass')
          end
        },
      }
    })
  end
end)

createTextUI = function()
  lib.showTextUI('Hunting Job [ACTIVE]', {
    position = "right-center",
    icon = 'person-rifle',
    style = {
        borderRadius = 5,
        backgroundColor = '#ff0c0c',
        color = 'white'
    }
  })
end

startHunting = function()
  isHunting = true
  lib.requestModel(boar)
  SetNewWaypoint(4597.1548, -4881.4048)
  createBlip()
  --createTextUI()
  if DPMN.AllowJob then
    TriggerServerEvent('dopamine_grindings:setJob', 'hunting', 0)
  end
  TriggerEvent('dopamine_grindings:notify', 'Hunting Job', 'Go to the waypoint to hunt!', 'inform', 5000)
  for k, v in pairs(DPMN.SpawnLocations) do
    spawnedBoar[k] = CreatePed(1, boar, v.x, v.y, v.z, v.w, true, true)
    spawnedBoarCounter[k] = false
    TaskWanderStandard(spawnedBoar[k], 20, 10.0)
  end
  spawnAnimals()
end

endHunting = function()
  if DPMN.AllowJob then
  TriggerServerEvent('dopamine_grindings:setLastJob')
  end
  isHunting = false
  removeBlip()
  for k, v in pairs(spawnedBoar) do
    DeleteEntity(spawnedBoar[k])
  end
  --lib.hideTextUI()
end 

createBlip = function()
  CreateThread(function()
    blip = AddBlipForCoord(4597.1548, -4881.4048) -- Example coordinates (replace with your desired coordinates)
    
    SetBlipSprite(blip, 177) -- Blip icon (1 is the standard white dot, replace with the desired sprite ID)
    SetBlipDisplay(blip, 4) -- Blip display type (4 is the map and minimap, 2 is minimap only)
    SetBlipScale(blip, 0.8) -- Blip size
    
    SetBlipColour(blip, 59) -- Blip color (2 is green, replace with the desired color ID)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Hunting Area") -- Text displayed when hovering over the blip
    EndTextCommandSetBlipName(blip)
  end)
end

removeBlip = function()
  RemoveBlip(blip)
end

spawnAnimals = function()
  while isHunting do
    for k, v in pairs(spawnedBoar) do
      if GetEntityHealth(spawnedBoar[k]) == 0 and not spawnedBoarCounter[k] then
        spawnedBoarCounter[k] = true
        local newCoords = DPMN.SpawnLocations[k]
        local currentPed = NetworkGetNetworkIdFromEntity(spawnedBoar[k])
        local options = {
          {
            label = 'Get Carcass',
            name = 'Hunting Get Carcass',
            icon = 'fa fa-drumstick-bite',
            distance = 2,
            onSelect = function()
              local weaponHash = GetHashKey("WEAPON_UNARMED")
              SetCurrentPedWeapon(PlayerPedId(), weaponHash, true)
              if lib.progressBar({
                duration = 7000,
                label = 'Getting Carcass',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
                anim = {
                    dict = 'melee@large_wpn@streamed_core',
                    clip = 'ground_attack_on_spot'
                },
                prop = {
                  bone = 57005,
                  model = `prop_tool_fireaxe`,
                  pos = vec3(0.016000, -0.314000, -0.086000),
                  rot = vec3(-97.145500, 165.074905, 13.911400)
                },
              }) then
                if DPMN.AllowJob then
                  if ESX.PlayerData.job and ESX.PlayerData.job.name == DPMN.JobName then
                    ESX.TriggerServerCallback('dopamine_grindings:getPassword', function(password)
                      ESX.TriggerServerCallback('dopamine_grindings:canCarryItem', function(canCarryItem)
                        if canCarryItem then
                          TriggerServerEvent('dopamine_grindings:addItem', 'carcass', 1, password)
                        else
                          TriggerEvent('dopamine_grindings:notify', 'Notification', 'You can\'t carry more carcass!', 'error', 5000)
                        end
                      end, {item = 'carcass', amount = 1})
                    end)
                    DeleteEntity(spawnedBoar[k])
                    Wait(10000)
                    spawnedBoar[k] = CreatePed(1, boar, newCoords.x, newCoords.y, newCoords.z, newCoords.w, true, true)
                    TaskWanderStandard(spawnedBoar[k], 20, 10.0)
                    spawnedBoarCounter[k] = false
                  else
                    TriggerEvent('dopamine_grindings:notify', 'Hunting', 'You are not on the correct job for this type of work!', 'error', 5000)
                  end
                else
                  ESX.TriggerServerCallback('dopamine_grindings:getPassword', function(password)
                    ESX.TriggerServerCallback('dopamine_grindings:canCarryItem', function(canCarryItem)
                      if canCarryItem then
                        TriggerServerEvent('dopamine_grindings:addItem', 'carcass', 1, password)
                      else
                        TriggerEvent('dopamine_grindings:notify', 'Notification', 'You can\'t carry more carcass!', 'error', 5000)
                      end
                    end, {item = 'carcass', amount = 1})
                  end)
                  DeleteEntity(spawnedBoar[k])
                  Wait(10000)
                  spawnedBoar[k] = CreatePed(1, boar, newCoords.x, newCoords.y, newCoords.z, newCoords.w, true, true)
                  TaskWanderStandard(spawnedBoar[k], 20, 10.0)
                  spawnedBoarCounter[k] = false
                end
              end
            end
          }
        }
        exports.ox_target:addEntity(currentPed, options)
      end
    end
    Wait(5000)
  end
end