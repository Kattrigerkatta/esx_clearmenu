include = false
_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Clear Menu", "Menu to clear all entitys in the area")
_menuPool:Add(mainMenu)

ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterCommand('+OpenMenu', function()
    ESX.TriggerServerCallback('clearmenu:getGroup', function(allowed)
        if allowed then
            mainMenu:Visible(not mainMenu:Visible())
        end
    end)
end)

function AddMenu(menu)
    local includeSelf = NativeUI.CreateCheckboxItem('Include yourself?', include, 'Do you also want to delete your vehicle?')
    menu:AddItem(includeSelf)
    menu.OnCheckboxChange = function(sender, item, checked_)
        if item == includeSelf then
            include = checked_
        end
    end
    local pedItem = NativeUI.CreateItem('Peds', 'Delete all peds in the area')
    local vehItem = NativeUI.CreateItem('Vehicles', 'Delete all vehicles in the area')
    local objItem = NativeUI.CreateItem('Objects', 'Delete all objects(props) in the area')
    local pickItem = NativeUI.CreateItem('Pickups', 'Delete all pickups in the area')

    pedItem.Activated = function(sender, index)
        local peds = GetGamePool('CPed')

        for k, v in ipairs(peds) do
            if not IsPedAPlayer(v) then
                if DoesEntityExist(v) then
                    NetworkRegisterEntityAsNetworked(v)
                    NetworkRequestControlOfEntity(v)
                    SetEntityAsMissionEntity(v, true, true)
                    DeleteEntity(v)
                end
            end
        end

        ShowNotification(#peds .. ' ped(s) were deleted')
    end

    vehItem.Activated = function(sender, index)
        local vehs = GetGamePool('CVehicle')

        for k, v in ipairs(vehs) do
            if GetVehiclePedIsIn(PlayerPedId(), false) ~= v then
                if DoesEntityExist(v) then
                    NetworkRegisterEntityAsNetworked(v)
                    NetworkRequestControlOfEntity(v)
                    SetEntityAsMissionEntity(v, true, true)
                    DeleteEntity(v)
                end
            else
                if include then
                    if DoesEntityExist(v) then
                        NetworkRegisterEntityAsNetworked(v)
                        NetworkRequestControlOfEntity(v)
                        SetEntityAsMissionEntity(v, true, true)
                        DeleteEntity(v)
                    end
                end
            end
        end

        ShowNotification(#vehs .. ' vehicle(s) were deleted')
    end

    objItem.Activated = function(sender, index)
        local obj = GetGamePool('CObject')

        for k, v in ipairs(obj) do
            if DoesEntityExist(v) then
                NetworkRegisterEntityAsNetworked(v)
                NetworkRequestControlOfEntity(v)
                SetEntityAsMissionEntity(v, true, true)
                DeleteEntity(v)
            end
        end

        ShowNotification(#obj .. ' object(s) were deleted')
    end

    pickItem.Activated = function(sender, index)
        local obj = GetGamePool('CPickup')

        for k, v in ipairs(obj) do
            if DoesEntityExist(v) then
                NetworkRegisterEntityAsNetworked(v)
                NetworkRequestControlOfEntity(v)
                SetEntityAsMissionEntity(v, true, true)
                DeleteEntity(v)
            end
        end

        ShowNotification(#obj .. ' object(s) were deleted')
    end

    menu:AddItem(pedItem)
    menu:AddItem(vehItem)
    menu:AddItem(objItem)
    menu:AddItem(pickItem)
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end


AddMenu(mainMenu)
_menuPool:RefreshIndex()
_menuPool:MouseEdgeEnabled(false)
_menuPool:MouseControlsEnabled(false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)

RegisterKeyMapping('+OpenMenu', 'Open clearmenu', 'keyboard', 'k')