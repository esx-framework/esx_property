Core = {}

--- Check does a player have the permission to do an action
--- @param target integer
--- @param action string
--- @return boolean
function Core:HasPermission(target, action)
    local xPlayer = ESX.GetPlayerFromId(target)

    if Config.AdminGroups[xPlayer.group] then
        return true
    end

    if Config.PlayerManagement and action then
        if xPlayer.job.name == Config.PlayerManagement.job and xPlayer.job.grade >= Config.PlayerManagement.Permissions[action] then
            return true
        end
    end
    
    return false
end