local Keys = {["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167,
    ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163,
    ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182, ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26,["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,  ["HOME"] = 213,  ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27,
    ["DOWN"] = 173, ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107,  ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local Notification = nil
isInInventory = false
local open = false
ESX = nil
local currentMenu = 'item'


local fastWeapons = {
	[1] = nil,
	[2] = nil,
	[3] = nil
}

function notif(msg)
    if Notification then 
      RemoveNotification(Notification)
    end 
    SetNotificationTextEntry("STRING") 
    AddTextComponentSubstringPlayerName(msg)
    Notification = DrawNotification(true, true)
end



Citizen.CreateThread(function() while ESX == nil do TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end) Citizen.Wait(0) end end)

RegisterCommand('invbug', function()
    SetNuiFocus(true, true)
end, false)

function openInventory()
    loadPlayerInventory(currentMenu)
    isInInventory = true
    open = true
    SendNUIMessage({action = "display", type = "normal"})
    SetNuiFocus(true, true)
    SetKeepInputMode(true)
    TriggerScreenblurFadeIn(0)
end

function closeInventory()
    isInInventory = false
    open = false
    DisplayRadar(true)
    SendNUIMessage({action = "hide"})
    SetNuiFocus(false, false)
    SetKeepInputMode(false)
    TriggerScreenblurFadeOut(0)
end

RegisterNUICallback('escape', function(data, cb)
    closeInventory()
    SetKeepInputMode(false)
end)

RegisterNUICallback("NUIFocusOff",function()
    closeInventory()
    SetKeepInputMode(false)
end)

RegisterNUICallback("GetNearPlayers", function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayers = false
    local elements = {}

    for i = 1, #players, 1 do
        if players[i] ~= PlayerId() then
            foundPlayers = true

            table.insert(
                elements,
                {
                    label = GetPlayerName(players[i]),
                    player = GetPlayerServerId(players[i])
                }
            )
        end
    end

    if not foundPlayers then
        ESX.ShowNotification('~b~Conseil~s~\nRapprochez vous de quelqu\'un.')
    else
        SendNUIMessage({action = "nearPlayers", foundAny = foundPlayers, players = elements, item = data.item})
    end

    cb("ok")
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLength)
	AddTextEntry("FMMC_KEY_TIP1", TextEntry)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

RegisterNUICallback("dsqds", function(data, cb)
    if currentMenu ~= data.type then 
        currentMenu = data.type
        loadPlayerInventory(data.type)
    end
end)

RegisterNUICallback("RanameItem", function(data, cb)
    if data.item.type ~= "item_weapon" then 
        closeInventory()
        local result = KeyboardInput('', data.item.label, 30)
        if result ~= nil then 
            if data.item.type ~= "item_standard" and data.item.type ~= "item_weapon" then 
                TriggerServerEvent('user_p:changenom', data.item.id, result)
            elseif data.item.type == "item_standard" then 
                TriggerServerEvent('user_p:changenom', data.item.name, result)
            end
            ESX.ShowNotification('Vous avez changer le nom ~o~'..data.item.label..'~s~ en ~b~'..result..'~s~')
        end 
    else
        closeInventory()
        local result = KeyboardInput('', data.item.label, 30)
        if result ~= nil then 
            for k, v in pairs(ESX.GetPlayerData().loadout) do 
                if data.item.name == v.name then
                    print(v.name)
                end 
            end 
        end 
    end
end)

RegisterNUICallback("InformationItem", function(data, cb)
    if data.item.id ~= nil then 
        ESX.ShowNotification('~b~TYPE~s~ '..data.item.type..'\n~b~Count~s~ '..data.item.count..'\n~b~NAME~s~ '..data.item.label..'\n~b~ID~s~ '..data.item.id..'')
    else
        ESX.ShowNotification('~b~TYPE~s~ '..data.item.type..'\n~b~Count~s~ '..data.item.count..'\n~b~NAME~s~ '..data.item.label..'')
    end
end)




RegisterNUICallback("UseItem", function(data, cb)
  
    if data.item.type == "item_standard" then 
        TriggerServerEvent("esx:useItem", data.item.name)
    elseif data.item.type == "item_tenue" then 
        TriggerEvent('skinchanger:getSkin', function(skin)
            if tenue then 
                TriggerEvent('skinchanger:getSkin', function(skin)
                    if skin.sex == 0 then
                        TriggerEvent('skinchanger:loadSkin', {
                            sex      = 0,
                            tshirt_1 = 15,
                            tshirt_2 = 0,
                            arms     = 15,
                            torso_1  = 91,
                            torso_2  = 0,
                            pants_1  = 14,
                            pants_2  = 0
                        })
                    else
                        TriggerEvent('skinchanger:loadSkin', {
                            sex      = 1,
                            tshirt_1 = 34,
                            tshirt_2 = 0,
                            arms     = 15,
                            torso_1  = 101,
                            torso_2  = 1,
                            pants_1  = 16,
                            pants_2  = 0
                        })
                    end
                end)
            else
                TriggerEvent('skinchanger:loadClothes', skin, { 
                    ["pants_1"] = data.item.skins["pants_1"], 
                    ["tshirt_2"] = data.item.skins["tshirt_2"], 
                    ["tshirt_1"] = data.item.skins["tshirt_1"], 
                    ["torso_1"] = data.item.skins["torso_1"], 
                    ["torso_2"] = data.item.skins["torso_2"],
                    ["arms"] = data.item.skins["arms"],
                    ["arms_2"] = data.item.skins["arms_2"],
                    ["decals_1"] = data.item.skins["decals_1"],
                    ["decals_2"] = data.item.skins["decals_2"],
                    ["shoes_1"] = data.item.skins["shoes_1"],
                    ["shoes_2"] = data.item.skins["shoes_2"]})
            end
            tenue = not tenue
            save()
            end)
        elseif data.item.type == "item_chaussures" or data.item.type == "item_torse" or data.item.type == "item_calque" or data.item.type == "item_chaine" or data.item.type == "item_masque" or data.item.type == "item_pantalon" or data.item.type == "item_chapeau" or data.item.type == "item_sac" then 
            local info = data.item.skins
            local type  = info[data.item.info] 
            local var = info[data.item.info2] 
            print('ok')
            TriggerEvent('skinchanger:getSkin', function(skin)
                if used then 
                    if data.item.decals ~= nil then 
                        TriggerEvent('skinchanger:loadClothes', skin, {[data.item.info] = data.item.decals, [data.item.info2] = 0})
                    else
                        TriggerEvent('skinchanger:loadClothes', skin, {[data.item.info] = 0, [data.item.info2] = 0})
                    end
                else
                    notif("Vous venez d'equipé le ~b~"..data.item.label)
                    TriggerEvent('skinchanger:loadClothes', skin, {[data.item.info] = type, [data.item.info2] = var})
                end  
                save()
                used = not used
            end)
    end 
    if shouldCloseInventory(data.item.name) then
        closeInventory()
    else
        Citizen.Wait(250)
        if data.item.type == "item_chaussures" or data.item.type == "item_torse" or data.item.type == "item_calque" or data.item.type == "item_chaine" or data.item.type == "item_masque" or data.item.type == "item_pantalon" or data.item.type == "item_chapeau" or data.item.type == "item_sac" then 
            loadPlayerInventory()
        end
    end
    cb("ok")
end)

RegisterNUICallback("DropItem", function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if currentMenu ~= 'clothe' then 
        if type(data.number) == "number" and math.floor(data.number) == data.number then
            TriggerServerEvent("esx:removeInventoryItem", data.item.type, data.item.name, data.number)
        end
    else
        TriggerServerEvent('user_p:deleteitem', data.item.id) 
    end

    Wait(250)
    loadPlayerInventory(currentMenu)

    cb("ok")
end)



RegisterNUICallback("fdsqfqs", function(data, cb)
    print(data.caac)
end)

RegisterNUICallback("GiveItem", function(data, cb)
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayer = false
    for i = 1, #players, 1 do
        if players[i] ~= PlayerId() then
            if GetPlayerServerId(players[i]) == data.player then
                foundPlayer = true
            end
        end
    end
 
    if foundPlayer then
        
        local count = tonumber(data.number)

        if data.item.type == "item_weapon" then
            count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
        end

        if data.item.type == "item_tenue" or data.item.type == "item_torse" or data.item.type == "item_chaussures" or data.item.type == "item_calque" or data.item.type == "item_chaine" or data.item.type == "item_masque" or data.item.type == "item_pantalon" or data.item.type == "item_chapeau" or data.item.type == "item_sac" then
            print(data.item.id, data.player)
            TriggerServerEvent('user_p:giveitem', data.item.id, data.player)
            Wait(250)
            loadPlayerInventory(currentMenu)
            ESX.ShowNotification('Vous venez de donner votre ~b~'..data.item.label)
        else
            TriggerServerEvent("esx:giveInventoryItem", data.player, data.item.type, data.item.name, count)
            Wait(250)
            loadPlayerInventory(currentMenu)
        end
    else
        ESX.ShowNotification('~b~Conseil~s~\nRapprochez vous de quelqu\'un.')
    end
    cb("ok")
end)

function shouldCloseInventory(itemName)
    for index, value in ipairs(Config.CloseUiItems) do
        if value == itemName then
            return true
        end
    end

    return false
end

function shouldSkipAccount(accountName)
    for index, value in ipairs(Config.ExcludeAccountsList) do
        if value == accountName then
            return true
        end
    end

    return false
end
function save()
	TriggerEvent('skinchanger:getSkin', function(skin)
		TriggerServerEvent('esx_skin:save', skin)
	end)
end


local tenue,chaussures,masque,torse,pantalon,tshirt,lunettes,modifitems,chapeau,sac,chaine,calque = {},{},{},{},{},{},{},{},{},{},{},{}

function loadPlayerInventory(result)
  
    
 
    if result == 'item' then 
        ESX.TriggerServerCallback("esx_inventoryhud:getPlayerInventory", function(data)
            items = {}
            fastItems = {}
            inventory = data.inventory
            accounts = data.accounts
            money = data.money
            weapons = data.weapons

            if Config.IncludeCash and money ~= nil and money > 0 then
                moneyData = {
                    label = _U("cash"),
                    name = "money",
                    type = "item_money",
                    count = money,
                    usable = false,
                    rename = false,
                    rare = false,
                    information = true, 
                    weight = -1,
                    canRemove = true
                }

                table.insert(items, moneyData)
            end
            
            if Config.IncludeAccounts and accounts ~= nil then
                for key, value in pairs(accounts) do
                    if not shouldSkipAccount(accounts[key].name) then
                        local canDrop = accounts[key].name ~= "bank"

                        if accounts[key].money > 0 then
                            accountData = {
                                label = accounts[key].label,
                                count = accounts[key].money,
                                type = "item_account",
                                name = accounts[key].name,
                                usable = false,
                                rare = false,
                                information = true, 
                                rename = false,
                                weight = -1,
                                canRemove = canDrop
                            }
                            table.insert(items, accountData)
                        end
                    end
                end
            end

            
            
        

            if inventory ~= nil then
                for key, value in pairs(inventory) do
                    if inventory[key].count <= 0 then
                        inventory[key] = nil
                    else
                        for k, v in pairs(modifitems) do
                            if v.item == inventory[key].name then 
                                if v.name ~= nil then 
                                    inventory[key].label = v.name
                                end
                            end 
                        end
                        inventory[key].type = "item_standard"
                        information = true
                        table.insert(items, inventory[key])
                    end
                end
            end

         
        SendNUIMessage({ action = "setItems", itemList = items, fastItems = fastItems, text = texts, crMenu = currentMenu})
        end, GetPlayerServerId(PlayerId()))
    elseif result == 'weapon' then 
        ESX.TriggerServerCallback("esx_inventoryhud:getPlayerInventory", function(data)
            items = {}
            fastItems = {}
            inventory = data.inventory
            accounts = data.accounts
            money = data.money
            weapons = data.weapons
            if Config.IncludeWeapons and weapons ~= nil then
                for key, value in pairs(weapons) do
                    local weaponHash = GetHashKey(weapons[key].name)
                    local playerPed = PlayerPedId()
                    if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= "WEAPON_UNARMED" then
                            local found = false
                            for slot, weapon in pairs(fastWeapons) do
                                if weapon == weapons[key].name then
                                    local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
                                    table.insert(
                                        fastItems,
                                        {
                                            label = weapons[key].label,
                                            count = ammo,
                                            limit = -1,
                                            type = "item_weapon",
                                            name = weapons[key].name,
                                            usable = false,
                                            rare = false,
                                            information = false, 
                                            rename = false,
                                            canRemove = true,
                                            slot = slot
                                        }
                                    )
                                    found = true
                                    break
                                end
                            end
                            if found == false then
                                local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
                                table.insert(
                                    items,
                                    {
                                        label = weapons[key].label,
                                        count = ammo,
                                        limit = -1,
                                        type = "item_weapon",
                                        name = weapons[key].name,
                                        usable = false,
                                        rare = false,
                                        information = true, 
                                        rename = false,
                                        canRemove = true
                                    }
                                )
                            end
                    end
                end
            end
        SendNUIMessage({ action = "setItems", itemList = items, fastItems = fastItems, text = texts, crMenu = currentMenu})
        end, GetPlayerServerId(PlayerId()))
    elseif result == 'clothe' then 
        items = {}

        ESX.TriggerServerCallback('user_p:getblackomask', function(Vetement)
            tenue, chaussures, masque, pantalon, torse, tshirt, lunettes, chapeau, sac,chaine,calque = {}, {}, {}, {}, {}, {}, {}, {}, {},{},{}
            for k, v in pairs(Vetement) do  
                if v.type == "blackotenue" then 
                    table.insert(tenue, {name = v.nom, skins = json.decode(v.clothe), id = v.id})
                end
                if v.type == "blackochaussures" then 
                    table.insert(chaussures, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "shoes_1", data2 = "shoes_2", decals = 34})
                end 
                if v.type == "blackomasque" then 
                    table.insert(masque, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "mask_1", data2 = "mask_2"})
                end 
                if v.type == "blackopantalon" then 
                    table.insert(pantalon, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "pants_1", data2 = "pants_2", decals = 14})
                end 
                if v.type == "blackotshirt" then 
                    table.insert(tshirt, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "tshirt_1", data2 = "tshirt_2"})
                end 
                if v.type == "blackogant" then 
                    table.insert(lunettes, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "arms", data2 = "arms_2"})
                end 
                if v.type == "blackolunettes" then 
                    table.insert(lunettes, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "glasses_1", data2 = "glasses_2"})
                end 
                if v.type == "blackochapeau" then 
                    table.insert(chapeau, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "helmet_1", data2 = "helmet_2"})
                end 
                if v.type == "blackosac" then 
                    table.insert(sac, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "bags_1", data2 = "bags_1"})
                end 
                if v.type == "blackochaine" then 
                    table.insert(chaine, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "chain_1", data2 = "chain_2"})
                end 
                if v.type == "blackoCalques" then 
                    table.insert(calque, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "decals_1", data2 = "decals_2"})
                end 
                if v.type == "blackotorse" then 
                    table.insert(torse, {name = v.nom, skins = json.decode(v.clothe), id = v.id, data = "torso_1", data2 = "torso_2"})
                end 
            end 
    

        Wait(50)

            for k, v in pairs(tenue) do
                tenueData = {
                    label = v.name,
                    name = "tenue",
                    type = "item_tenue",
                    skins = v.skins,
                    count = "",
                    usable = true,
                    rename = true,
                    rare = false,
                    information = true, 
                    id = v.id, 
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, tenueData)
            end

            for k, v in pairs(chaussures) do
                chaussuresData = {
                    label = v.name,
                    name = "shoes",
                    type = "item_chaussures",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    count = "",
                    usable = true,
                    information = true, 
                    id = v.id, 
                    decals = v.decals,
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, chaussuresData)
            end

            for k, v in pairs(masque) do
                masqueData = {
                    label = v.name,
                    name = "mask",
                    type = "item_chaussures",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    count = "",
                    information = true, 
                    usable = true,
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, masqueData)
            end

            for k, v in pairs(pantalon) do
                pantalonData = {
                    label = v.name,
                    name = "jean",
                    type = "item_chaussures",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    decals = v.decals,
                    id = v.id, 
                    count = "",
                    information = true, 
                    usable = true,
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, pantalonData)
            end

            for k, v in pairs(tshirt) do
                tshirtData = {
                    label = v.name,
                    name = "shirt",
                    type = "item_chaussures",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    count = "",
                    information = true, 
                    usable = true,
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, tshirtData)
            end

            for k, v in pairs(torse) do
                torseData = {
                    label = v.name,
                    name = "shirt",
                    type = "item_torse",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    count = "",
                    information = true, 
                    usable = true,
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, torseData)
            end

            for k, v in pairs(lunettes) do
                lunettesData = {
                    label = v.name,
                    name = "tie",
                    type = "item_chaussures",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    count = "",
                    usable = true,
                    information = true, 
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, lunettesData)
            end

            for k, v in pairs(chapeau) do
                chapeauData = {
                    label = v.name,
                    name = "hat",
                    type = "item_chapeau",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    decals = 11,
                    count = "",
                    usable = true,
                    information = true, 
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, chapeauData)
            end
            
            for k, v in pairs(sac) do
                sacData = {
                    label = v.name,
                    name = "bag",
                    type = "item_sac",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    count = "",
                    usable = true,
                    information = true, 
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, sacData)
            end
    
                
            for k, v in pairs(chaine) do
                chaineData = {
                    label = v.name,
                    name = "tie",
                    type = "item_chaine",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    count = "",
                    usable = true,
                    information = true, 
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, chaineData)
            end
    
            for k, v in pairs(calque) do
                calqueData = {
                    label = v.name,
                    name = "tie",
                    type = "item_calque",
                    skins = v.skins,
                    info = v.data,
                    info2 = v.data2,
                    id = v.id, 
                    count = "",
                    usable = true,
                    information = true, 
                    rename = true,
                    rare = false,
                    weight = -1,
                    canRemove = true
                }
                table.insert(items, calqueData)
            end

        SendNUIMessage({ action = "setItems", itemList = items, fastItems = fastItems, text = texts, crMenu = currentMenu})
        Wait(250)
    end)
    end
end



Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        Citizen.Wait(750)
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        BlockWeaponWheelThisFrame()
        SetPedCanSwitchWeapon(PlayerPedId(), false)
    end
end)

--FAST ITEMS
RegisterNUICallback("PutIntoFast", function(data, cb)
	if data.item.slot ~= nil then
		fastWeapons[data.item.slot] = nil
	end
	fastWeapons[data.slot] = data.item.name
	TriggerServerEvent("esx_inventoryhud:changeFastItem",data.slot,data.item.name)
	loadPlayerInventory(currentMenu)
	cb("ok")
end)

RegisterNUICallback("TakeFromFast", function(data, cb)
	fastWeapons[data.item.slot] = nil
	TriggerServerEvent("esx_inventoryhud:changeFastItem",0,data.item.name)
	loadPlayerInventory(currentMenu)
	cb("ok")
end)


RegisterKeyMapping('ouvririnventaire', 'Ouverture inventaire', 'keyboard', 'TAB')
RegisterKeyMapping('keybind1', 'Slot d\'arme 1', 'keyboard', '1')
RegisterKeyMapping('keybind2', 'Slot d\'arme 2', 'keyboard', '2')
RegisterKeyMapping('keybind3', 'Slot d\'arme 3', 'keyboard', '3')


RegisterCommand('ouvririnventaire', function()
    if open then 
        openInventory()
        DisplayRadar(false)
    else
        closeInventory()
        DisplayRadar(true)
    end
    open = not open
end)

RegisterCommand('keybind1', function()
    if fastWeapons[1] ~= nil then
        if GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey(fastWeapons[1]) then
            SetCurrentPedWeapon(GetPlayerPed(-1), "WEAPON_UNARMED",true)
        else
            SetCurrentPedWeapon(GetPlayerPed(-1), fastWeapons[1],true)
            notif('Vous avez équipé votre ~g~'..ESX.GetWeaponLabel(fastWeapons[1])..'')
        end
    end
end)

RegisterCommand('keybind2', function()
    if fastWeapons[2] ~= nil then
        if GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey(fastWeapons[2]) then
            SetCurrentPedWeapon(GetPlayerPed(-1), "WEAPON_UNARMED",true)
        else
            SetCurrentPedWeapon(GetPlayerPed(-1), fastWeapons[2],true)
            notif('Vous avez équipé votre ~g~'..ESX.GetWeaponLabel(fastWeapons[2])..'')
        end
    end
end)

RegisterCommand('keybind3', function()
    if fastWeapons[3] ~= nil then
        if GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey(fastWeapons[3]) then
            SetCurrentPedWeapon(GetPlayerPed(-1), "WEAPON_UNARMED",true)
        else
            SetCurrentPedWeapon(GetPlayerPed(-1), fastWeapons[3],true)
            notif('Vous avez équipé votre ~g~'..ESX.GetWeaponLabel(fastWeapons[3])..'')
        end
    end
end)




KEEP_FOCUS = false
local threadCreated = false
local controlDisabled = {1, 2, 3, 4, 5, 6, 18, 24, 25, 37, 69, 70, 111, 117, 118, 182, 199, 200, 257}

function SetKeepInputMode(bool)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(bool)
    end

    KEEP_FOCUS = bool

    if not threadCreated and bool then
        threadCreated = true

        Citizen.CreateThread(function()
            while KEEP_FOCUS do
                Wait(0)

                for _,v in pairs(controlDisabled) do
                    DisableControlAction(0, v, true)
                end
            end

            threadCreated = false
        end)
    end
end