--- Refresh Properties From Database
function Core:RefreshProperties()
    local properties = MySQL.query.await('SELECT * FROM properties')
    self.Properties = {}
    for i = 1, #properties do
        local property = properties[i]
        self.Properties[property.name] = property
    end
end

MySQL.ready(Core.RefreshProperties)