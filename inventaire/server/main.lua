ESX = nil

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

ESX.RegisterServerCallback("esx_inventoryhud:getPlayerInventory", function(source, cb, target)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if targetXPlayer ~= nil then
		cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), accounts = targetXPlayer.accounts, weapons = targetXPlayer.loadout})
	else
		cb(nil)
	end
end)

RegisterServerEvent('user_p:deleteitem')
AddEventHandler('user_p:deleteitem', function(supprimer)
    MySQL.Async.execute('DELETE FROM user_p_clothe WHERE id = @id', { 
            ['@id'] = supprimer 
    }) 
end)

RegisterServerEvent('user_p:changenom')
AddEventHandler('user_p:changenom', function(id, Actif)   
	MySQL.Sync.execute('UPDATE user_p_clothe SET nom = @nom WHERE id = @id', {
		['@id'] = id,   
		['@nom'] = Actif        
	})
end) 


ESX.RegisterServerCallback('user_p:getalmodifiitems', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items = {}
	MySQL.Async.fetchAll('SELECT * FROM user_inventory WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
	}, function(result) 
		for i = 1, #result, 1 do  
			table.insert(items, {gdfsg = result[i].Nommodif, item = result[i].item})
		end  
		cb(items) 
	end)  
end)    

RegisterServerEvent("user_p:changenom")
AddEventHandler("user_p:changenom", function(item, result)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE user_inventory SET Nommodif = @Nommodif WHERE identifier = @identifier AND item = @item', {
		['@identifier'] = xPlayer.identifier,
		['@item'] = item,
		["@Nommodif"] = result
	})	
end)

RegisterServerEvent("esx_inventoryhud:tradePlayerItem")
AddEventHandler("esx_inventoryhud:tradePlayerItem",	function(from, target, type, itemName, itemCount)
	local _source = from

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if type == "item_standard" then
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and sourceItem.count >= itemCount then
			--if targetXPlayer.canCarryItem(itemName, itemCount) then

				sourceXPlayer.removeInventoryItem(itemName, itemCount)
				targetXPlayer.addInventoryItem(itemName, itemCount)
			--else
			--	
			--end
		end
	elseif type == "item_money" then
		if itemCount > 0 and sourceXPlayer.getMoney() >= itemCount then
			sourceXPlayer.removeMoney(itemCount)
			targetXPlayer.addMoney(itemCount)
		end
	elseif type == "item_account" then
		if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then
			sourceXPlayer.removeAccountMoney(itemName, itemCount)
			targetXPlayer.addAccountMoney(itemName, itemCount)
		end
	elseif type == "item_weapon" then
		if not targetXPlayer.hasWeapon(itemName) then
			sourceXPlayer.removeWeapon(itemName)
			targetXPlayer.addWeapon(itemName, itemCount)
		end
	end
end)

RegisterCommand("openinventory", function(source, args, rawCommand)
	local target = tonumber(args[1])
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if targetXPlayer ~= nil then
		TriggerClientEvent("esx_inventoryhud:openPlayerInventory", source, target, targetXPlayer.name)
	else
		TriggerClientEvent("chatMessage", source, "^1" .. _U("no_player"))
	end
end)

-- ESX.RegisterServerCallback('user_p:getblackomask', function(source, cb)
-- 	local xPlayer = ESX.GetPlayerFromId(source)
-- 	local masque = {}
-- 	MySQL.Async.fetchAll('SELECT * FROM user_p_clothe WHERE identifier = @identifier', {
-- 		['@identifier'] = xPlayer.identifier
-- 	}, function(result) 
-- 		for i = 1, #result, 1 do  
-- 			table.insert(masque, {      
--                 type      = result[i].type, 
-- 				clothe      = result[i].clothe,
-- 				id      = result[i].id,
-- 				nom      = result[i].nom,

-- 			})
-- 		end  
-- 		cb(masque) 
-- 	end)  
-- end)    