ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('clearmenu:getGroup',function(source, cb)
    local allowed = false
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() ~= 'user' then
        allowed = true
    end

    cb(allowed)
end)