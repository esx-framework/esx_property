---Create Properties
function creationMenuClass()
    local self = {
		houseId = 0,
		price = 0,
		interior = "apa_v_mp_h_01_a",
		furniture = true,
		garage = {
			enabled = true,
			pos = vec3(0,0,0),
			heading = 0
		},
		cctv = {
			enabled = false,
			center = 0,
			left = 0,
			right = 0
		},
		entrance = vec3(0,0,0)
	}

    ---Opens the Garage Settings Menu
    function self.garageMenu()
		local elements = {
			{title = "Garage Settings", unselectable = true, description = "Status: " .. (self.garage.enabled and "Enabled" or "Disabled")},
			{title = self.garage.enabled and "Disable" or "Enable", value = "toggle"},
			{title = "Set Posititon", value = "setPos",disabled =not self.garage.enabled, description = ("%s, %s, %s"):format(ESX.Round(self.garage.pos.x, 2), ESX.Round(self.garage.pos.y, 2), ESX.Round(self.garage.pos.z, 2))},
			{title = "Finish", value = "finish"},
		}
		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == "toggle" then
				self.garage.enabled = not self.garage.enabled
				self.garageMenu()
			elseif element.value == "setPos" then
				ESX.TextUI("[E] -> Set Postition", "info")
				ESX.CloseContext()
				while true do
					Wait(0)
					if IsControlJustPressed(0, 38) then
						local playerPos = GetEntityCoords(ESX.PlayerData.ped)
						self.garage.pos = playerPos
						self.garage.heading = GetEntityHeading(ESX.PlayerData.ped)
						ESX.HideUI()
						self.garageMenu()
						break
					end
				end
			else
				self.mainMenu()
			end
		end)
    end

    ---Opens the CCTV Settings Menu
    function self.cctvMenu()
		local elements = {
			{title = "CCTV Settings", unselectable = true, description = "Status: " .. (self.CCTV.enabled and "Enabled" or "Disabled")},
			{title = self.cctv.enabled and "Disable" or "Enable", value = "toggle"},
			{title = "Set Center", value = "center",disabled =not self.cctv.enabled, description = ("Current: %s"):format(ESX.Round(self.cctv.center, 2))},
			{title = "Set Max Left", value = "left",disabled =not self.cctv.enabled,  description = ("Current: %s"):format(ESX.Round(self.cctv.left, 2))},
			{title = "Set Max Right", value = "right",disabled =not self.cctv.enabled, description = ("Current: %s"):format(ESX.Round(self.cctv.right, 2))},
			{title = "Finish", value = "finish", description = "Apply Current Settings"},
		}
		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == "toggle" then
				self.cctv.enabled = not self.cctv.enabled
				self.cctvMenu()
			elseif element.value == "finish" then
				self.mainMenu()
			else
				ESX.TextUI("[E] -> Set Posititon", "info")
				ESX.CloseContext()
				while true do
					Wait(0)
					if IsControlJustPressed(0, 38) then
						local playerHeading = GetEntityHeading(ESX.PlayerData.ped)
						self.cctv[element.value] = playerHeading
						ESX.HideUI()
						self.cctvMenu()
						break
					end
				end
			end
		end)
    end

    ---Opens the Price Menu
    ---@param pos (string) Posititon to show the menu ("right", "left", "center")
    ---@param cb (function) Called when input is finished
    ---@return int
    function self.priceMenu(pos, cb)
		local elements = {
			{title = "Set Price", unselectable = true},
			{
					icon = "",
					title = "Price",
					input = true,
					inputType = "number",
					inputPlaceholder = "0",
					inputValue = self.price,
					inputMin = 0,
					inputMax = 900000000,
					name = "price",
			},
			{title = "Submit", value = "submit"}
		}
		ESX.OpenContext(pos, elements, function(menu, element)
			if element.value == "submit" then
				if menu.eles[2].inputValue then
					cb(menu.eles[2].inputValue)
				else
					ESX.ShowNotification("Invalid Input", "error")
				end
			end
		end)
    end

	---Main menu
    function self.mainMenu()
		local elements = {
			{title = "Property Creation", unselectable = true},
			{title = "Set Price", value = "price", description = "Current: $" .. self.price},
			{title = "Garage Settings", value = "garage", description = "Status: " .. (self.garage.enabled and "Enabled" or "Disabled")},
			{title = "CCTV Settings", value = "cctv", description = "Status: " .. (self.cctv.enabled and "Enabled" or "Disabled")},
			{title = "Allow Furniture", value = "furniture", description = "Status: " .. (self.furniture and "Allowed" or "Not Allowed")},
			{title = "SetEntance", value = "entrance", description = "Status: " .. (self.entrance ~= vector3(0,0,0) and "Set" or "Not Set")},
			{title = "Create", value = "create"},
		}
		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == "garage" then
				self.garageMenu()
			elseif element.value == "cctv" then
				self.cctvMenu()
			elseif element.value == "furniture" then
				self.furniture = not self.furniture
				self.mainMenu()
			elseif element.value == "price" then
				self.priceMenu("right", function(price)
					self.price = price
					self.mainMenu()
				end)
			elseif element.value == "entrance" then
				ESX.TextUI("[E] -> Set Posititon", "info")
				ESX.CloseContext()
				while true do
					Wait(0)
					if IsControlJustPressed(0, 38) then
						local playerPos = GetEntityCoords(ESX.PlayerData.ped)
						self.entrance = playerPos
						ESX.HideUI()
						self.mainMenu()
						break
					end
				end
			else
				ESX.TriggerServerCallback("esx_property:createProperty", function(Created)
					ESX.ShowNotification(Created and "Created Property!" or "Failed To Create Property", Created and "success" or "error")
				end, self)
			end
		end)
    end

    return self
end