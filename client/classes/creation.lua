-- Create Properties
-- For this approach, we are going to use a class to have a completely dynamic creation menu
-- This Should Also Allow easier Readablity
function CreationMenuClass() -- Create a Class 
    self = {} -- define self
  
    -- Define Default Values
    self.HouseID = 0 
    self.Price = 0
    self.interior = "apa_v_mp_h_01_a"
    self.furniture = true
    self.garage = {
      enabled = false,
      pos = vector3(0,0,0),
      heading = 0,
    }
    self.CCTV = {
      enabled = false,
      center = 0,
      left = 0,
      right = 0,
    }
  
    self.entrance = vector3(0,0,0)
    
    -- Start API
  
    --  allow any value to be changed
    --- @param key (string) Takes the index to be set.
    --- @param value (any) Takes the value to set the index to.
    --- @return void
    function self.SetValue(key, value) 
      	self[key] = value
    end
  
    -- Garage
  
    --  Opens the Garage Settings Menu
    --- @return void
    function self.GarageMenu()
		local elements = {
			{title = "Garage Settings", unselectable = true, description = "Status: " .. (self.garage.enabled and "Enabled" or "Disabled")},
			{title = self.garage.enabled and "Disable" or "Enable", value = "toggle"},
			{title = "Set Posititon", value = "setPos",disabled =not self.garage.enabled, description = ("%s, %s, %s"):format(ESX.Round(self.garage.pos.x, 2), ESX.Round(self.garage.pos.y, 2), ESX.Round(self.garage.pos.z, 2))},
			{title = "Finish", value = "finish"},
		}
		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == "toggle" then 
			self.garage.enabled = not self.garage.enabled -- toggle Enabled
			self.GarageMenu() -- refresh menu
			elseif element.value == "setPos" then 
			ESX.TextUI("[E] -> Set Postition", "info") -- show text on screen
			ESX.CloseContext()
			while true do -- create loop
				Wait(0)
				if IsControlJustPressed(0, 38) then -- if player presses E
				local PlayerPos = GetEntityCoords(ESX.PlayerData.ped) -- Get Player Pos
				self.garage.pos = PlayerPos
				self.garage.heading = GetEntityHeading(ESX.PlayerData.ped) -- Get Heading to spawn vehicles with
				ESX.HideUI() -- Hide Text
				self.GarageMenu() -- Refresh Menu
				break -- Break Loop
				end
			end
			else
			self.MainMenu() -- re-open main menu upon finish
			end
		end)
    end
  
    -- CCTV 
  
    --  Opens the CCTV Settings Menu
    --- @return void
    function self.CCTVMenu()
		local elements = {
			{title = "CCTV Settings", unselectable = true, description = "Status: " .. (self.CCTV.enabled and "Enabled" or "Disabled")},
			{title = self.CCTV.enabled and "Disable" or "Enable", value = "toggle"},
			{title = "Set Center", value = "center",disabled =not self.CCTV.enabled, description = ("Current: %s"):format(ESX.Round(self.CCTV.center, 2))},
			{title = "Set Max Left", value = "left",disabled =not self.CCTV.enabled,  description = ("Current: %s"):format(ESX.Round(self.CCTV.left, 2))},
			{title = "Set Max Right", value = "right",disabled =not self.CCTV.enabled, description = ("Current: %s"):format(ESX.Round(self.CCTV.right, 2))},
			{title = "Finish", value = "finish", description = "Apply Current Settings"},
		}
		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == "toggle" then 
			self.CCTV.enabled = not self.CCTV.enabled -- toggle Enabled
			self.CCTVMenu() -- refresh menu
			elseif element.value == "finish" then 
			self.MainMenu() -- re-open main menu upon finish
			else
			ESX.TextUI("[E] -> Set Posititon", "info") -- show text on screen
			ESX.CloseContext()
			while true do -- create loop
				Wait(0)
				if IsControlJustPressed(0, 38) then -- if player presses E
				local PlayerHeading = GetEntityHeading(ESX.PlayerData.ped) -- Get Heading of Player's Ped
				self.CCTV[element.value] = PlayerHeading -- set value to current heading
				ESX.HideUI() -- Hide Text
				self.CCTVMenu()
				break -- Break Loop
				end
			end
			end
		end)
    end
  
    --  Opens the Price Menu
    --- @param pos (string) Posititon to show the menu ("right", "left", "center")
    --- @param cb (function) Called when input is finished
    --- @return int
    function self.PriceMenu(pos, cb) -- Create a Menu to set price
		local elements = {
			{title = "Set Price", unselectable = true},
			{
					icon="",
					title="Price",
					input=true,
					inputType="number",
					inputPlaceholder="0",
					inputValue= self.Price, -- set default price to stored price
					inputMin=0,
					inputMax= 900000000,
					name="price",
				},
			{title = "Submit", value = "submit"}
		}
		ESX.OpenContext(pos, elements, function(menu, element)
			if element.value == "submit" then
				if menu.eles[2].inputValue then -- make sure price is valid
					cb(menu.eles[2].inputValue) -- callback the price
				else 
					ESX.ShowNotification("Invalid Input", "error") -- let user know the price is invalid
				end
			end
		end)
    end
  
    function self.MainMenu() -- For Normal Creation use
		local elements = {
			{title = "Property Creation", unselectable = true},
			{title = "Set Price", value = "price", description = "Current: $" .. self.Price},
			{title = "Garage Settings", value = "garage", description = "Status: " .. (self.garage.enabled and "Enabled" or "Disabled")},
			{title = "CCTV Settings", value = "cctv", description = "Status: " .. (self.CCTV.enabled and "Enabled" or "Disabled")},
			{title = "Allow Furniture", value = "furniture", description = "Status: " .. (self.furniture and "Allowed" or "Not Allowed")},
			{title = "SetEntance", value = "entrance", description = "Status: " .. (self.entrance ~= vector3(0,0,0) and "Set" or "Not Set")},
			{title = "Create", value = "create"},
		}
		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == "garage" then 
			self.GarageMenu() -- open Garage settings
			elseif element.value == "cctv" then 
			self.CCTVMenu() -- open CCTV Settings
			elseif element.value == "furniture" then 
			self.furniture = not self.furniture
			self.MainMenu() -- reopen menu
			elseif element.value == "price" then
			self.PriceMenu("right", function(price)
				self.Price = price
				self.MainMenu() -- reopen menu
			end)
			elseif element.value == "entrance" then 
			ESX.TextUI("[E] -> Set Posititon", "info") -- show text on screen
			ESX.CloseContext()
			while true do -- create loop
				Wait(0)
				if IsControlJustPressed(0, 38) then -- if player presses E
				local PlayerPos = GetEntityCoords(ESX.PlayerData.ped) -- Get Player Pos
				self.entrance = PlayerPos
				ESX.HideUI() -- Hide Text
				self.MainMenu() -- reopen menu
				break -- Break Loop
				end
			end
			else
			ESX.TriggerServerCallback("esx_property:CreateProperty", function(Created)
				ESX.ShowNotification(Created and "Created Property!" or "Failed To Create Property", Created and "success" or "error")
			end, self)
			end
		end)
    end
  
    return self
end