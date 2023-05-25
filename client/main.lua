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

local Properties = {} -- Define Properties Locally
SpawnedFurniture = {} -- define furniture globally

RegisterNetEvent("esx_property:syncProperty", function(ID, Data) -- event for syncing data
	Properties[ID] = Data
end)

RegisterNetEvent("esx_property:syncPropertyInterally", function(ID, Data) -- sync for players while inside property
	Properties[ID] = Data
	RemoveAllFurniture()
	SpawnFurniture(Data.furniture)
end)

-- debug command - Remove in future
RegisterCommand("create", function()
	local CreationMenu = CreationMenuClass() -- create the creation menu
	CreationMenu.MainMenu() -- show the main menu
end)

-- Main loop
local DrawingUI = {showing = false, text = ""} -- create table for showing TextUI

CreateThread(function()
	while true do --continuous loop
		local Sleep = 1000 -- sleep while inactive
		local PlayerCoords = GetEntityCoords(ESX.PlayerData.ped) -- get current coords
		local InProperty = LocalPlayer.state.CurrentProperty -- grab the state bag (set by the server-side) to see if they are inside a properly
		local Near = false -- set Near to point to false
		if not InProperty then -- if the player is not inside a property
		for k,v in pairs(Properties) do -- loop over known properties
			local dist = #(v.entrance - PlayerCoords) -- Check distance to entrance
			if dist <= 10.0 then -- if player is semi-close
			Sleep = 0 -- set the sleep to every tick
			-- draw the marker on the ground so that the player can see where the door is
			DrawMarker(27, v.entrance - vector3(0,0,0.9), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 200, 200, false, false, 2, true, nil, nil, false)
			if dist <= 2.0 then -- if player is very close (within marker)
				Near = true -- set near point to true
				-- Draw TextUI
				if not DrawingUI.showing or DrawingUI.text ~= "[E] Enter Property" then
				DrawingUI.showing = true 
				DrawingUI.text = "[E] Enter Property"
				ESX.TextUI(DrawingUI.text, "info")
				end
				-- If Player interacts with the door
				if IsControlJustPressed(0, 38) then
				-- debug code, will be moved
				DoScreenFadeOut(500)
				Wait(700)
				ESX.TriggerServerCallback("esx_property:AttemptEnter", function(Enter, furniture)
					if Enter then 
					SpawnFurniture(furniture)
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
		else -- Player is Inside a property
		local Current_Property = Properties[InProperty] -- get the stroed details of the property they are inside
		-- everything under here is debug code and will either be moved or refactored
		local dist = #(Current_Property.interior.pos - PlayerCoords) 
		if dist <= 5.0 then
			Sleep = 0
			DrawMarker(27, Current_Property.interior.pos - vector3(0,0,0.9), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 200, 200, false, false, 2, true, nil, nil, false)
			if dist <= 2.0 then
			Near = true
			if not DrawingUI.showing or DrawingUI.text ~= "[E] Exit Property" then
				DrawingUI.showing = true 
				DrawingUI.text = "[E] Exit Property"
				ESX.TextUI(DrawingUI.text, "info")
			end
			if IsControlJustPressed(0, 38) then
				DoScreenFadeOut(500)
				Wait(500)
				ESX.TriggerServerCallback("esx_property:AttemptLeave", function(Leave, Data)
				if Leave then 
					RemoveAllFurniture()
					LocalPlayer.state:set("CurrentProperty", false)
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
		if not Near and DrawingUI.showing then 
		DrawingUI.showing = false 
		ESX.HideUI()
		end
		Wait(Sleep)
	end
end)

-- Interior Viewer
local PreviewedInt = {}
function CreateInterior(interior)
	if PreviewedInt.obj then -- if saved shell object
		DeleteObject(PreviewedInt.obj) -- delete object
		PreviewedInt.obj = nil -- nilify the object reference
	end
	PreviewedInt.previewing = true
	if interior.type == "ipl" then 
		SetEntityCoords(ESX.PlayerData.ped, interior.pos) -- teleport player to the coords
	elseif interior.type == "shell" then
		PreviewedInt.type = "shell" -- set type
		local Coords = GetEntityCoords(PlayerPedId()) -- grab current coords
		ESX.Streaming.RequestModel(joaat(interior.value)) -- request shell model
		local obj = CreateObject(joaat(interior.value), Coords.x,Coords.y, 2000, false, true, false) -- spawn shell 2000 units in the air
		FreezeEntityPosition(obj, true) -- freeze shell
		SetEntityCoords(ESX.PlayerData.ped, Coords.x,Coords.y, 2001) -- teleport player into shell
		PreviewedInt.obj = obj -- save the object reference
		PreviewedInt.Coords = Coords 
	end
end

function ViewInteriors()
  	local elements = {{title = "Interior Viewer", unselectable = true, description = "select an interior to view"}} -- set menu title
  	if PreviewedInt.obj then -- if saved object
		elements[#elements +1] = {title = "Delete Shell Interior", delete = true} -- allow deleting the object
  	end
  	for i=1, #Config.Interiors do -- loop the interiors
		elements[#elements +1] = {title = Config.Interiors[i].label,description = "Type: " ..Config.Interiors[i].type, value = i}
  	end
  	ESX.OpenContext("right", elements, function(_, element) -- open menu
		ESX.CloseContext() -- close menu
		if element.delete then -- shell Deletation
	  		if PreviewedInt.obj then -- saved object
				DeleteObject(PreviewedInt.obj) -- delete object
				PreviewedInt.obj = nil -- nil the object
				SetEntityCoords(ESX.PlayerData.ped, PreviewedInt.Coords) -- set player onto the ground
	  		end
		else
	  		CreateInterior(Config.Interiors[element.value]) -- create the selected interior
		end
  	end)
end

RegisterCommand("ViewInteriors", ViewInteriors)

AddEventHandler("onResourceStop", function(name)
	if name ~= GetCurrentResourceName() then return end
	LocalPlayer.state.CurrentProperty = nil
end)