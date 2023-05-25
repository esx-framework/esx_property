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

function SpawnFurniture(furniture)
	for i=1,#furniture do
		ESX.Streaming.RequestModel(joaat(furniture[i].model))
		local pos = vector3(furniture[i].pos.x,furniture[i].pos.y, furniture[i].pos.z)
		local rot = vector3(furniture[i].rotation.x,furniture[i].rotation.y, furniture[i].rotation.z)
		local object = CreateObjectNoOffset(joaat(furniture[i].model), pos, false, true, false)
		if DoesEntityExist(object) then
			furniture[i].obj = object
			SpawnedFurniture[#SpawnedFurniture +1] = furniture[i]
			SetEntityRotation(object, rot)
			FreezeEntityPosition(object, true)
			SetEntityAsMissionEntity(object, true, true)
		end
		SetModelAsNoLongerNeeded(joaat(furniture[i].model))
	end
end
	
function RemoveAllFurniture()
	for i=1,#SpawnedFurniture do
		if DoesEntityExist(SpawnedFurniture[i].obj) then
			DeleteEntity(SpawnedFurniture[i].obj)
			table.remove(SpawnedFurniture, i)
		end
	end
end

RegisterNetEvent("property:UpdateFurniture", function(id, action, data)
	local selectedFurniture = SpawnedFurniture[id]
	if action == "delete" then
		local alpha = GetEntityAlpha(selectedFurniture) -- Get the entities alpha
		-- this loop 
		while alpha > 0 do
			alpha -= 1
			SetEntityAlpha(selectedFurniture, alpha, false)
			Wait(0)
		end
		DeleteEntity(selectedFurniture)
		SpawnedFurniture[id] = nil
	elseif action == "SetPostion" then
		local alpha = GetEntityAlpha(selectedFurniture)
		NetworkFadeOutEntity(selectedFurniture, true, false)
		while alpha > 0 do
			alpha = GetEntityAlpha(selectedFurniture)
			Wait(0)
		end
		SetEntityRotation(selectedFurniture, data.rotation)
		SetEntityCoords(selectedFurniture, data.pos)
		NetworkFadeInEntity(selectedFurniture, true)
	end
end)
	
RegisterNetEvent("property:CreateFurniture", SpawnFurniture)
	
RegisterCommand("furnitest", function()
	local data = {model = "v_corp_conftable2", pos = GetEntityCoords(ESX.PlayerData.ped), rotation = GetEntityRotation(ESX.PlayerData.ped)}
	ESX.TriggerServerCallback("esx_property:AddFurniture", function() end, data)
end)

RegisterCommand("furnilist", function()
	local elements = {{title = "furniture List", unselectable = true}}
	for k,v in pairs(SpawnedFurniture) do 
		elements[#elements+1] = {title = v.model, id = k, data = v}
	end
	ESX.OpenContext("right", elements, function(data, selected)
		ESX.CloseContext()
		local obj_data = exports.object_gizmo:useGizmo(selected.data.obj)
		ESX.TriggerServerCallback("esx_property:editFurniture", function() end, {id = selected.id, pos = obj_data.position, rotation = obj_data.rotation})
	end)
end)