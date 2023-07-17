--[[
Copyright ©️ 2022 Kasey Fitton, ESX-Framework
All rights reserved. 

use of this source, with or without modification, are permitted provided that the following conditions are met: 

   Even if 'All rights reserved' is very clear :

  You shall not use any piece of this software in a commercial product / service
  You shall not resell this software
  You shall not provide any facility to install this particular software in a commercial product / service
  This copyright should appear in every part of the project code
]] 

local properties = {}
SpawnedFurniture = {}

RegisterNetEvent("esx_property:syncProperty", function(id, data)
	properties[id] = data
end)

RegisterNetEvent("esx_property:syncPropertyInterally", function(id, data)
	properties[id] = data
	removeAllFurniture()
	spawnFurniture(data.furniture)
end)

-- debug command
RegisterCommand("create", function()
	local creationMenu = creationMenuClass()
	creationMenu.mainMenu()
end)

CreateThread(function()
	local drawingUI = {showing = false, text = ""}
	while true do
		local sleep = 1500
		local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
		local inProperty = ESX.PlayerData.metadata.currentProperty
		local near = false
		if not inProperty then
			for k,v in pairs(properties) do
				local dist = #(v.entrance - playerCoords)
				if dist <= 10.0 then
					sleep = 0
					DrawMarker(27, v.entrance - vector3(0,0,0.9), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 200, 200, false, false, 2, true, nil, nil, false)
					if dist <= 2.0 then
						near = true

						if not drawingUI.showing or drawingUI.text ~= "[E] Enter Property" then
							drawingUI.showing = true 
							drawingUI.text = "[E] Enter Property"
							ESX.TextUI(drawingUI.text, "info")
						end

						if IsControlJustPressed(0, 38) then
							DoScreenFadeOut(500)
							Wait(700)
							ESX.TriggerServerCallback("esx_property:attemptEnter", function(Enter, furniture)
								if Enter then 
									spawnFurniture(furniture)
									ESX.ShowNotification("~b~Entering~s~ Property!", "success")
								else
									ESX.ShowNotification("~r~Cannot Enter~s~ Property", "error")
								end
								Wait(600)
								DoScreenFadeIn(500)
							end, v.id)
						end
					end
				end
			end
		else
			local currentProperty = properties[inProperty]
			local dist = #(currentProperty.interior.pos - playerCoords)
			if dist <= 5.0 then
				sleep = 0
				DrawMarker(27, currentProperty.interior.pos - vector3(0,0,0.9), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 200, 200, false, false, 2, true, nil, nil, false)
				if dist <= 2.0 then
					near = true
					if not drawingUI.showing or drawingUI.text ~= "[E] Exit Property" then
						drawingUI.showing = true
						drawingUI.text = "[E] Exit Property"
						ESX.TextUI(drawingUI.text, "info")
					end
					if IsControlJustPressed(0, 38) then
						DoScreenFadeOut(500)
						Wait(500)
						ESX.TriggerServerCallback("esx_property:attemptLeave", function(Leave, data)
							if Leave then
								removeAllFurniture()
								ESX.ShowNotification("~b~Leaving~s~ Property!", "success")
							else
								ESX.ShowNotification("~r~Cannot Leave~s~ Property", "error")
							end
							Wait(1000)
							DoScreenFadeIn(500)
							Wait(500)
						end)
					end
				end
			end
		end
		if not near and drawingUI.showing then
			drawingUI.showing = false
			ESX.HideUI()
		end
		Wait(sleep)
	end
end)

local PreviewedInt = {}
local function createInterior(interior)
	if previewedInt.obj then
		DeleteObject(previewedInt.obj)
		previewedInt.obj = nil 
	end
	previewedInt.previewing = true
	if interior.type == "ipl" then
		SetEntityCoords(ESX.PlayerData.ped, interior.pos)
	elseif interior.type == "shell" then
		previewedInt.type = "shell"
		local Coords = GetEntityCoords(PlayerPedId())
		ESX.Streaming.RequestModel(joaat(interior.value), function()
			local obj = CreateObject(joaat(interior.value), Coords.x,Coords.y, 2000, false, true, false)
			FreezeEntityPosition(obj, true) -- freeze shell
			SetEntityCoords(ESX.PlayerData.ped, Coords.x,Coords.y, 2001)
			previewedInt.obj = obj
			previewedInt.Coords = Coords
		end)
	end
end

local function viewInteriors()
  	local elements = {{title = "Interior Viewer", unselectable = true, description = "select an interior to view"}}
  	if previewedInt.obj then
		elements[#elements +1] = {title = "Delete Shell Interior", delete = true}
  	end
  	for i=1, #Config.Interiors do
		elements[#elements +1] = {title = Config.Interiors[i].label,description = "Type: " ..Config.Interiors[i].type, value = i}
  	end
  	ESX.OpenContext("right", elements, function(_, element)
		ESX.CloseContext()
		if element.delete then
	  		if previewedInt.obj then
				DeleteObject(previewedInt.obj)
				previewedInt.obj = nil
				SetEntityCoords(ESX.PlayerData.ped, previewedInt.Coords)
	  		end
		else
	  		createInterior(Config.Interiors[element.value])
		end
  	end)
end

RegisterCommand("viewInteriors", viewInteriors, false)

AddEventHandler("onResourceStop", function(name)
	if name ~= GetCurrentResourceName() then return end
	TriggerServerEvent('esx_property:clearCurrentProperty')
end)