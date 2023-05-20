--- Save properties in database
--- @param cb function|false
--- @return boolean
function Core:SaveProperties(cb)
    local parameters = {}

    local promise = not cb and promise.new()

    for propertyName, propertyData in pairs(self.Properties) do
        parameters[#parameters + 1] = {
            propertyName,
            propertyData.label,
            propertyData.owner,
            propertyData.positions,
            -- todo: other stuff
            propertyName
        }
    end

    MySQL.prepare('UPDATE properties SET name = ?, label = ?, owner = ?, positions = ? WHERE name = ?', parameters, function(results)
        if promise then promise:resolve(true) end
        if not results then return false end
        print(('[^1ESX_PROPERTIES^7] Saved ^5%s^7 %s'):format(#parameters, #parameters > 1 and 'properties' or 'property'))
    end)

    if cb then
        cb()
    end

    if promise then
        return Citizen.Await(promise)
    end
end