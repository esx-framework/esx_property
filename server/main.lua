--[[
Copyright ©️ 2022 Kasey Fitton, ESX-Framework
All rights reserved. 

Redistribution and use of this source, with or without 
modification, are permitted provided that the following conditions are met: 

   Even if 'All rights reserved' is very clear :

  You shall not use any piece of this software in a commercial product / service
  You shall not resell this software
  You shall not provide any facility to install this particular software in a commercial product / service
  This copyright should appear in every part of the project code
]]

local Properties = {} -- define local table to store property classes

CreateThread(function()
  local properties = MySQL.query.await("SELECT * From `properties`") -- Get all saved properties
  for _,v in pairs(properties) do -- loop through the returned rows
    Properties[v.HouseID] = PropertyClass:CreateProperty(v.HouseID, v.owner,v.price, v.furniture, v.cctv, v.garage, v.data) -- Create and save property class
    Wait(100) -- Allow a 100ms for it to create
    Properties[v.HouseID]:syncProperty() -- Sync the property to players who are online, to allow resource to be restarted in-game
  end
  StartDBSync()
  print(("successfully Loaded ^5%s^7 Properties"):format(ESX.Table.SizeOf(properties)))
end)

AddEventHandler("esx:playerLoaded", function(src) -- Listen for when a player has loaded into the server
  for _,property in pairs(Properties) do -- loop through all existing properties
    property:syncPropertyToPlayer(src) -- sync basic data to the player, so they can see markers, etc
    Wait(0) -- wait a tick, to make sure the load isnt too heavy on the player
  end
end)

ESX.RegisterServerCallback("esx_property:CreateProperty", function(src, cb, Class) -- when an admin creates a property
  local info = { -- create basic table to store extra info
    interior = Class.interior,
    entrance = Class.entrance
  }
  -------- JSON encoding so it can be stored in the database ------------
  local furniture = json.encode({enabled = Class.furniture, objects = {}})
  local CCTV = json.encode(Class.CCTV)
  local garage = json.encode(Class.garage)
  local data = json.encode(info)
  -------------------------------------------------------------------------
  local output = MySQL.execute.await("INSERT INTO `properties` (furniture, price, cctv, garage, data) VALUES (?, ?, ?, ?, ?)", 
  {furniture, Class.Price, CCTV, garage, data}) -- Insert the data into the database and await the result
  local HouseID = output.insertId -- output.insertId returns the primary key of the input, which in this case, will be the ID
  Properties[HouseID] = PropertyClass:CreateProperty(HouseID, nil, Class.Price,furniture, CCTV,garage, data) -- create property Class
  Properties[HouseID]:syncProperty() -- sync new property to online players.
end)

ESX.RegisterServerCallback("esx_property:AttemptEnter", function(src, cb, id) -- called when a player tries to enter a property
  local Property = Properties[tonumber(id)] -- grab the property they are trying to enter
  if Property then -- check the property exists
    cb(true, Property.furniture.enabled and Property.furniture.objects or {}) -- send back, to the cient so say they can enter and send all known property furniture to the client
    Property:enter(src) -- trigger the enter function, to send them into the property
  else 
    cb(false) -- send back that they cannot enter the property
  end
end)

ESX.RegisterServerCallback("esx_property:AttemptLeave", function(src, cb) -- called when a player tries to leave a property
  local Property = getPropertyPlayerIsIn(src) -- Grab the property the player is in
  if Property then -- check this is a valid property
    cb(true) -- callback that they can leave
    Property:leave(src) -- trigger the leave function to unregister them from the property
  else
    cb(false) -- callback that they cannot leave
  end
end)

ESX.RegisterServerCallback("esx_property:AddFurniture", function(src, cb, data) -- called when a player tries to add furniture
  local Property = getPropertyPlayerIsIn(src) -- Grab the property the player is in
  if Property then -- check this is a valid property
    cb(true) -- callback that they can leave
    Property:addFurniture(data.model, data.pos, data.rotation) -- trigger the AddFurniture function
  else
    cb(false) -- callback that they cannot leave
  end
end)

ESX.RegisterServerCallback("esx_property:editFurniture", function(src, cb, data) -- called when a player tries to add furniture
  local Property = getPropertyPlayerIsIn(src) -- Grab the property the player is in
  if Property then -- check this is a valid property
    cb(true) -- callback that they can leave
    Property:editFurniture(data.id, data.pos, data.rotation) -- trigger the AddFurniture function
  else
    cb(false) -- callback that they cannot leave
  end
end)

--  Simple function to retrieve a property, from its id.
--- @param id (number) Id of the property
--- @return Property class
exports("getPropertyFromId", function(id)
  return Properties[tonumber(id)]
end)

--  Simple function to retrieve the Class of the property a player is inside
--- @param player (number) ServerId of the player
--- @return Properties
function getPropertyPlayerIsIn(player)
  local Current = Player(player).state.CurrentProperty
  if Current then
    return Properties[tonumber(Current)]
  end
  return false
end

-- Export the function to allow outside scripts to use it :)
exports("getPropertyPlayerIsIn", getPropertyPlayerIsIn)

-- Property Saving

function SaveAllProperties(cb)
  local count = ESX.Table.SizeOf(Properties) -- Get how many properties are stored
  if count > 0 then -- check if there is any stored (no point in saving if there is no properties)
    local parameters = {} -- define table for SQL Statement
    local time = os.time() -- define a start time
    for k,v in pairs(Properties) do-- loop over all properties, (k,v in pairs since some numbers may be missing)
      parameters[#parameters + 1] = {v.Owner, json.encode(v.furniture), v.Price, json.encode(v.CCTV), json.encode(v.garage), json.encode(v.data), v.HouseID}
    end
    MySQL.prepare(
      'UPDATE `properties` SET `owner` = ?, `furniture` = ?, `price` = ?, `cctv` = ?, `garage` = ?, `data` = ? WHERE `HouseID` = ?',
      parameters, function(results)
        if results then
          if type(cb) == 'function' then
            cb()
          else
            -- Print that the save was successful
            print(('[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms'):format(count, count > 1 and 'Properties' or 'Property', ESX.Math.Round((os.time() - time) / 1000000, 2)))
          end
        end
      end)
  end
end

-- Triggered when using a txAdmin scheduled Restart
AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
  if eventData.secondsRemaining == 60 then
    CreateThread(function()
      Wait(40000) -- Wait 40 seconds
      SaveAllProperties()
    end)
  end
end)

-- Triggered when restarting the server with txAdmin
AddEventHandler('txAdmin:events:serverShuttingDown', function()
  SaveAllProperties()
end)

-- function for Intervaled saving
function StartDBSync()
  CreateThread(function()
    while true do
      Wait(Config.SaveInterval * 100000) -- Wait Config.SaveInterval in minutes
      SaveAllProperties()
    end
  end)
end

RegisterCommand("property:forcesave", function()
  SaveAllProperties()
end)