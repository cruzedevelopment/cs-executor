Framework = {}

CreateThread(function()
    if GetResourceState("qb-core") == "started" then
        Framework.Name = "qbcore"
        Framework.Functions = exports["qb-core"]:GetCoreObject()
    elseif GetResourceState("es_extended") == "started" then
        Framework.Name = "esx"
        Framework.Functions = exports["es_extended"]:getSharedObject()
    elseif GetResourceState("ox_core") == "started" then
        Framework.Name = "ox_core"
    else
        Framework.Name = "standalone"
    end

    print(("[INFO] Detected Framework: %s"):format(Framework.Name))
end)

local function hasAdminRole(player)
    if Framework.Name == "qbcore" then
        local Player = Framework.Functions.Functions.GetPlayer(player)
        if not Player then return false end

        local groups = Player.PlayerData.groups
        for _, role in pairs(Config.AllowedRoles) do
            if groups and groups[role] then
                return true
            end
        end

    elseif Framework.Name == "esx" then
        local xPlayer = Framework.Functions.GetPlayerFromId(player)
        if not xPlayer then return false end

        local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
        for _, role in pairs(Config.AllowedRoles) do
            if group == role then
                return true
            end
        end

    elseif Framework.Name == "ox_core" then
        local Player = exports.ox_core:GetPlayer(player)
        if not Player then return false end

        local groups = Player.getGroups()
        for _, role in pairs(Config.AllowedRoles) do
            if groups and groups[role] then
                return true
            end
        end
    else
        print(("[INFO] Standalone mode: Assuming player %s is not an admin."):format(player))
        return false
    end

    return false
end

lib.callback.register("cs-executor:server:isAdmin", function(source)
    return hasAdminRole(source)
end)