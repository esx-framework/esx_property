function Core.RefreshProperties()
    local properties = MySQL.query.await('SELECT * FROM properties')
    Core.Properties = {}
    for i = 1, #properties do
        local property = properties[i]
        Core.Properties[property.name] = property
    end
end

MySQL.ready(Core.RefreshProperties)