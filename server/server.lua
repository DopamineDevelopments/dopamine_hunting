local password = math.random(1000,3000)
local lastJob = {}
RegisterNetEvent('dopamine_grindings:addItem')
AddEventHandler('dopamine_grindings:addItem', function(item, amount, passcode)
  local xPlayer = ESX.GetPlayerFromId(source)
  if passcode == password then
    xPlayer.addInventoryItem(item, amount)
  else
    print('trigger')
    --DropPlayer(source, 'You have been kicked for triggering using a lua executor'
  end
end)

RegisterNetEvent('dopamine_grindings:removeItem')
AddEventHandler('dopamine_grindings:removeItem', function(item, amount)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeInventoryItem(item, amount)
end)

RegisterNetEvent('dopamine_grindings:setJob')
AddEventHandler('dopamine_grindings:setJob', function(jobName, jobGrade)
  local xPlayer = ESX.GetPlayerFromId(source)
  lastJob[source] = xPlayer.getJob()
  print(ESX.DoesJobExist(jobName, jobGrade))
  if ESX.DoesJobExist(jobName, jobGrade) then -- make sure the Job and Grade are both defined in the database
    xPlayer.setJob(jobName, jobGrade)
  end
end)

RegisterNetEvent('dopamine_grindings:setLastJob')
AddEventHandler('dopamine_grindings:setLastJob', function()
  local xPlayer = ESX.GetPlayerFromId(source)
  if lastJob[source] then
    if ESX.DoesJobExist(lastJob[source].name,  lastJob[source].grade) then -- make sure the Job and Grade are both defined in the database
      xPlayer.setJob(lastJob[source].name, lastJob[source].grade)
    end
  end
end)

ESX.RegisterServerCallback('dopamine_grindings:getPassword', function(source, cb) 
  password = password
  cb(password)
end)

ESX.RegisterServerCallback('dopamine_grindings:canCarryItem', function(source, cb, data) 
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer.canCarryItem(data.item, data.amount) then
    cb(true)
  else
    cb(false)
  end
end)

ESX.RegisterServerCallback('dopamine_grindings:getItemAmount', function(source, cb, item) 
  local xPlayer = ESX.GetPlayerFromId(source)
  local count = xPlayer.getInventoryItem(item).count
  cb(count)
end)

