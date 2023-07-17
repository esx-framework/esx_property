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

local properties = {}

CreateThread(function()
	local properties = MySQL.query.await("SELECT * From `properties`")
	for _,v in pairs(properties) do
		properties[v.HouseID] = PropertyClass:CreateProperty(v.HouseID, v.owner,v.price, v.furniture, v.cctv, v.garage, v.data)
		Wait(100)
		properties[v.HouseID]:syncProperty()
	end
	startDBSync()
	print(("successfully Loaded ^5%s^7 properties"):format(ESX.Table.SizeOf(properties)))
end)

AddEventHandler("esx:playerLoaded", function(src)
	for _,property in pairs(properties) do
		property:syncPropertyToPlayer(src)
		Wait(0)
	end
end)

ESX.RegisterServerCallback("esx_property:createProperty", function(src, cb, class)
	local info = {
		interior = class.interior,
		entrance = class.entrance
	}
	local furniture = json.encode({enabled = class.furniture, objects = {}})
	local CCTV = json.encode(class.cctv)
	local garage = json.encode(class.garage)
	local data = json.encode(info)
	local output = MySQL.execute.await("INSERT INTO `properties` (furniture, price, cctv, garage, data) VALUES (?, ?, ?, ?, ?)", 
	{furniture, class.price, CCTV, garage, data})
	local houseId = output.insertId
	properties[houseId] = PropertyClass:CreateProperty(houseId, nil, class.price, furniture, CCTV, garage, data)
	properties[houseId]:syncProperty()
end)

ESX.RegisterServerCallback("esx_property:attemptEnter", function(src, cb, id)
	local property = properties[tonumber(id)]
	if not property then 
		return cb(false)
	end
	property:enter(src)
	cb(true, property.furniture.enabled and property.furniture.objects or {})
end)

ESX.RegisterServerCallback("esx_property:attemptLeave", function(src, cb)
	local property = getPropertyPlayerIsIn(src)
	if not property then
		return cb(false)
	end
	property:leave(src)
	cb(true)
end)

ESX.RegisterServerCallback("esx_property:addFurniture", function(src, cb, data)
	local property = getPropertyPlayerIsIn(src)
	if not property then
		return cb(false)
	end
	property:addFurniture(data.model, data.pos, data.rotation)
	cb(true)
end)

ESX.RegisterServerCallback("esx_property:editFurniture", function(src, cb, data)
	local property = getPropertyPlayerIsIn(src)
	if not property then
		return cb(false)
	end
	property:editFurniture(data.id, data.pos, data.rotation)
	cb(true)
end)

RegisterNetEvent('esx_property:clearCurrentProperty', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.clearMeta('currentProperty')
end)

--  Simple function to retrieve a property, from its id.
--- @param id (number) Id of the property
--- @return properties class
exports("getPropertyFromId", function(id)
	return properties[tonumber(id)]
end)

--  Simple function to retrieve the Class of the property a player is inside
--- @param player (number) ServerId of the player
--- @return properties class
function getPropertyPlayerIsIn(player)
	local current = ESX.GetPlayerFromId(player).metadata.currentProperty
	if current then
		return properties[tonumber(current)]
	end
	return false
end

-- Export the function to allow outside scripts to use it :)
exports("getPropertyPlayerIsIn", getPropertyPlayerIsIn)

-- Property Saving
function saveAllProperties(cb)
	local count = ESX.Table.SizeOf(properties)
	if count > 0 then
		local parameters = {}
		local time = os.time()
		for k,v in pairs(properties) do
			parameters[#parameters + 1] = {v.Owner, json.encode(v.furniture), v.Price, json.encode(v.CCTV), json.encode(v.garage), json.encode(v.data), v.HouseID}
		end
		MySQL.prepare(
			'UPDATE `properties` SET `owner` = ?, `furniture` = ?, `price` = ?, `cctv` = ?, `garage` = ?, `data` = ? WHERE `HouseID` = ?',
			parameters, function(results)
			if results then
				if type(cb) == 'function' then
					cb()
				else
					print(('[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms'):format(count, count > 1 and 'properties' or 'Property', ESX.Math.Round((os.time() - time) / 1000000, 2)))
				end
			end
		end)
	end
end

-- Triggered when using a txAdmin scheduled Restart
AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
	if eventData.secondsRemaining == 60 then
		CreateThread(function()
			Wait(40000)
			saveAllProperties()
		end)
	end
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
	saveAllProperties()
end)

-- function for Intervaled saving
function startDBSync()
	CreateThread(function()
		while true do
			Wait(Config.SaveInterval * 100000)
			saveAllProperties()
		end
	end)
end

-- debug command
RegisterCommand("property:forcesave", function()
	saveAllProperties()
end)