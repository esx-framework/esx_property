-- @class
-- Property Class
PropertyClass = {
    __index = PropertyClass
}


function PropertyClass:CreateProperty(houseId, owner, price, furniture, cctv, garage, data)
    local property = setmetatable({}, PropertyClass)

    property.houseId = houseId
    property.price = price
    property.owner = owner or nil
    property.data = json.decode(data)
    property.interior = GetInteriorValues(property.data.interior)
    property.furniture = json.decode(furniture)
    property.garage = json.decode(garage)
    property.garage.pos = vector3(property.garage.pos.x, property.garage.pos.y, property.garage.pos.z)
    property.cctv = json.decode(cctv)
    property.entrance = vector3(property.data.entrance.x,property.data.entrance.y, property.data.entrance.z)
    property.playersInside = {}

    ---sync property to all clients
    function property:syncProperty()
        TriggerClientEvent("esx_property:syncProperty",-1, self.houseId, {
            id = self.houseId,
            entrance = self.entrance,
            garage = self.garage.pos,
        })
    end

    ---sync property to a player
    ---@param playerId integer
    function property:syncPropertyToPlayer(playerId)
        TriggerClientEvent("esx_property:syncProperty", playerId, self.houseId, {
            id = self.houseId,
            entrance = self.entrance,
            garage = self.garage.pos,
        })
    end

    ---sync property to players inside the property
    function property:syncPropertyToInsidePlayers()
        for i=1, #self.playersInside do
            TriggerClientEvent("esx_property:syncPropertyInterally", self.playersInside[i].id, self.houseId, {
                id = self.houseId,
                entrance = self.entrance,
                garage = self.garage.pos,
                interior = self.interior,
                furniture = self.furniture.enabled and self.furniture.objects or {}
            })
        end
    end

    ---sync property to a specific player inside it
    ---@param playerId integer
    function property:syncPropertyToInsidePlayer(playerId)
        TriggerClientEvent("esx_property:syncPropertyInterally", playerId, self.houseId, {
            id = self.houseId,
            entrance = self.entrance,
            garage = self.garage.pos,
            interior = self.interior,
            furniture = self.furniture.enabled and self.furniture.objects or {}
        })
    end


    ---allow scripts to change any value of the property
    function property:set(key, value) 
        if key == "houseId" then return end
        self[key] = value
    end

    ---allow scripts save extra data (metadata) about a property
    function property:setMetadata(key, value) 
        self.data[key] = value
    end

    --- furniture code, will be refactored in the future
    function property:syncFurnitureItem(id)
        for i=1, #self.playersInside do
            TriggerClientEvent("esx_property:UpdateFurniture", self.playersInside[i].id, id,"SetPosition", self.furniture.objects[id])
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

    ---Registers a player as being inside the property
    function property:enter(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        self.playersInside[#self.playersInside + 1] = {id = playerId, name = xPlayer.name}
        property:syncPropertyToInsidePlayer(playerId)
        SetPlayerRoutingBucket(playerId, self.houseId)
        xPlayer.setMeta('currentProperty', self.houseId)
        local ped = GetPlayerPed(playerId)
        SetEntityCoords(ped, self.interior.pos)
    end

    ---get a specific player from inside the property
    function property:getPlayerInside(playerId)
        for i=1,#(self.playersInside) do
            if self.playersInside[i].id == playerId then 
                return i
            end
        end
        return false
    end

    ---un register the player from being inisde
    function property:leave(playerId)
        local isInside = self:getPlayerInside(playerId)
        if isInside then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            table.remove(self.playersInside, isInside)
            SetPlayerRoutingBucket(playerId, 0)
            xPlayer.setMeta('currentProperty', self.houseId)
            local ped = GetPlayerPed(playerId)
            SetEntityCoords(ped, self.entrance)
            self:syncPropertyToPlayer(playerId)
        end
    end

    ---function to buy the property, optional removal of money
    function property:buy(playerId, removeMoney)
        local xPlayer = ESX.GetPlayerFromId(player)
        if not xPlayer then
            return false
        end 
        if removeMoney then
            xPlayer.removeAccountMoney(Config.Account, self.price)
        end 
        self.owner = xPlayer.identifier
        return true
    end

    --- Property Saving 
    function property:save()
        local furniture = json.encode(self.furniture)
        local cctv = json.encode(self.cctv)
        local garage = json.encode(self.garage)
        local data = json.encode(self.data)

        MySQL.update('UPDATE properties SET owner = ?, furniture = ?, price = ?, cctv = ?, garage = ?, data = ? WHERE houseId = ?', {self.owner, furniture, self.price, cctv, garage, data, self.houseId}, function(affectedRows)
            if affectedRows then
                print(("[INFO] Sucessfully Saved Property - %s"):format(self.houseId))
            end
        end)
    end

    return property
end