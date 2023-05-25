-- @class
-- Player Class
PropertyClass = {
    __index = PropertyClass
}


function PropertyClass:CreateProperty(HouseID, Owner,Price, furniture, CCTV,garage, data)
    local property = setmetatable({}, PropertyClass)
  
    -- Define Default Values
    property.HouseID = HouseID
    property.Price = Price
    property.Owner = Owner or nil -- set to nil if no owner
    property.data = json.decode(data)
    property.interior = GetInteriorValues(property.data.interior) -- grab the interior settings from the cnfig
    property.furniture = json.decode(furniture)
    property.garage = json.decode(garage)
    property.garage.pos = vector3(property.garage.pos.x, property.garage.pos.y, property.garage.pos.z) -- convert to vector
    property.CCTV = json.decode(CCTV)
    property.entrance = vector3(property.data.entrance.x,property.data.entrance.y, property.data.entrance.z) -- convert to vector
    property.PlayersInside = {}

    -- This function Syncs basic info the all online clients
    function property:syncProperty()
        TriggerClientEvent("esx_property:syncProperty",-1, self.HouseID, {
            id = self.HouseID,
            entrance = self.entrance,
            garage = self.garage.pos,
        })
    end

    -- syncs a property to a specific player (for example, when loading into the server)
    function property:syncPropertyToPlayer(Player)
        TriggerClientEvent("esx_property:syncProperty", Player, self.HouseID, {
            id = self.HouseID,
            entrance = self.entrance,
            garage = self.garage.pos,
        })
    end

    -- sync property to players inside the property, whom will have more info than those outside.
    function property:syncPropertyToInsidePlayers()
        for i=1, #self.PlayersInside do
            TriggerClientEvent("esx_property:syncPropertyInterally", self.PlayersInside[i].id, self.HouseID, {
                id = self.HouseID,
                entrance = self.entrance,
                garage = self.garage.pos,
                interior = self.interior,
                furniture = self.furniture.enabled and self.furniture.objects or {}
            })
        end
    end

     -- sync property to a single player inside the property, whom will have more info than those outside.
    function property:syncPropertyToInsidePlayer(ply)
        TriggerClientEvent("esx_property:syncPropertyInterally", ply, self.HouseID, {
             id = self.HouseID,
                entrance = self.entrance,
                garage = self.garage.pos,
                interior = self.interior,
                furniture = self.furniture.enabled and self.furniture.objects or {}
        })
    end


    -- allow scripts to change any value of the property
    function property:SetValue(key, value) 
        if key == "HouseID" then return end -- dont allow houseID to be changed, otherwise big database errors
        self[key] = value
    end

    -- allow scripts save extra data (metadata) about a property
    function property:SetMetadata(key, value) 
        self.data[key] = value
    end

    -- furniture code, will be refactored in the future

    function property:syncFurnitureItem(id)
        for i=1, #self.PlayersInside do
            TriggerClientEvent("esx_property:UpdateFurniture", self.PlayersInside[i].id, id,"SetPosition", self.furniture.objects[id])
        end
    end

    function property:addFurniture(model, position, rotation)
        if not self.furniture.enabled then return end
        self.furniture.objects[#self.furniture.objects + 1] = {model = model, pos = position, rotation = rotation}
        self:syncPropertyToInsidePlayers()
    end

    function property:editFurniture(id, position, rotation)
        if not self.furniture.enabled then return end
        self.furniture.objects[id].pos = position
        self.furniture.objects[id].rotation = rotation
        self:syncFurnitureItem(id)
    end

    -- Registers a player as being inside the property
    function property:enter(player)
        local xPlayer = ESX.GetPlayerFromId(player)
        self.PlayersInside[#self.PlayersInside +1] = {id = player, name = xPlayer.getName()} -- store the players id and name
        property:syncPropertyToInsidePlayer(player)
        SetPlayerRoutingBucket(player, self.HouseID)
        Player(player).state:set("CurrentProperty", HouseID, true) -- store the house id as a state bag
        local Ped = GetPlayerPed(player)
        SetEntityCoords(Ped, self.interior.pos) -- teleport them into the interior
    end

    -- get a specific player from inside the property
    function property:GetPlayerInside(player)
        for i=1,#(self.PlayersInside) do
            if self.PlayersInside[i].id == player then 
                return i
            end
        end
        return false
    end

    -- un register the player from being inisde
    function property:leave(player)
        local isInside = self:GetPlayerInside(player)
        if isInside then 
            table.remove(self.PlayersInside, isInside)
            local xPlayer = ESX.GetPlayerFromId(player)
            SetPlayerRoutingBucket(player, 0)
            Player(player).state:set("CurrentProperty", false, true)
            local Ped = GetPlayerPed(player)
            SetEntityCoords(Ped, self.entrance)
            self:syncPropertyToPlayer(player)
        end
    end

    -- function to buy the property, optional removal of money
    function property:buy(player, removeMoney)
        local xPlayer = ESX.GetPlayerFromId(player) -- get xPlayer
        if not xPlayer then -- check if player is online
            return false 
        end 
        if removeMoney then
            xPlayer.removeAccountMoney(Config.Account, self.Price)
        end 
        self.Owner = xPlayer.identifier -- set the owner to the player
        return true
    end

    -- Property Saving 
   
    function property:save()
         -------- JSON encoding so it can be stored in the database ------------
        local furniture = json.encode(self.furniture)
        local CCTV = json.encode(self.CCTV)
        local garage = json.encode(self.garage)
        local data = json.encode(self.data)
        -------------------------------------------------------------------------
        MySQL.update('UPDATE properties SET owner = ?, furniture = ?, price = ?, cctv = ?, garage = ?, data = ? WHERE HouseID = ?', {self.Owner, furniture, self.Price, CCTV, garage, data, self.HouseID}, function(affectedRows)
            if affectedRows then
                print(("[INFO] Sucessfully Saved Property - %s"):format(self.HouseID))
            end
        end)
    end
    return property
end