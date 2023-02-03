ESX = nil
CreateThread(function()
	while ESX == nil do
		TriggerEvent('hypex:getTwojStarySharedTwojaStaraObject', function(obj)
			ESX = obj
		end)
		Citizen.Wait(250)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterCommand('sklep', function()

	OpenCoinsMainMenu()

end)


function OpenCoinsMainMenu()

	ESX.UI.Menu.CloseAll()
	local elements = {}
	ESX.TriggerServerCallback('zykem_coinsystem:getUserData', function(cb)
		
		elements = {

			{label = "# Stan Konta - " .. cb.coins .. ' #', value = nil},
			{label = "# Aktualna Ranga - " .. cb.rank .. ' #', value = nil},
			{label = "Sklep", value = 'shop'},
			{label = "[ADMIN] Menu", value = 'adminmenu'}

		}
	
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_menu',
		{
			title    = 'Menu Glowne',
			align    = 'center',
			elements = elements
		}, function(data, menu)	

			if data.current.value == 'admintmenu' then OpenAdminMenu() end;	
			if data.current.value == 'shop' then OpenShopMenu() end;

		end, function(data, menu)
			menu.close()
		end)

	end)

end

function OpenAdminMenu()
	ESX.UI.Menu.CloseAll()
	
	ESX.TriggerServerCallback('zykem_coins:hasPerms', function(res)

		if not res then return end;
			local elements = {
				{label = "Daj Coinsy", value = 'addcoins'},
				{label = "Usun Coinsy", value = 'removecoins'}
			}

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_menu',
					{
						title    = 'Admin Menu',
						align    = 'center',
						elements = elements
					}, function(data, menu)	
						if data.current.value == 'addcoins' then

							ESX.UI.Menu.CloseAll();
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'zykem_economy', {
								title = ('Podaj ID gracza')
							}, function(data2, menu2)
								ESX.UI.Menu.CloseAll()
								if data2.value == nil then return end;

								ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'zykem_economy', {
									title = ('Podaj Ilosc Coinsow')
								}, function(data3, menu3)
									ESX.UI.Menu.CloseAll()
									if data3.value == nil then return end;
									ESX.TriggerServerCallback('zykem_coins:addCoins', function(cb)
								
									
								
									end, data2.value, data3.value)
								end, function(data3, menu3)
									menu2.close()
								end)
								
							end, function(data2, menu2)
								menu2.close()
							end)

						elseif data.current.value == 'removecoins' then

							ESX.UI.Menu.CloseAll();
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'zykem_economy', {
								title = ('Podaj ID gracza')
							}, function(data2, menu2)
								ESX.UI.Menu.CloseAll()
								if data2.value == nil then return end;

								ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'zykem_economy', {
									title = ('Podaj Ilosc Coinsow')
								}, function(data3, menu3)
									ESX.UI.Menu.CloseAll()
									if data3.value == nil then return end;
									ESX.TriggerServerCallback('zykem_coins:removeCoins', function(cb)
								
									
								
									end, data2.value, data3.value)
								end, function(data3, menu3)
									menu2.close()
								end)
								
							end, function(data2, menu2)
								menu2.close()
							end)

						end
					end, function(data, menu)
						menu.close()
					end)
	end)

end

function OpenShopMenu()

	ESX.UI.Menu.CloseAll()
	local elements = {}
		
	for k,v in pairs(cl_cfg.shopItems) do

		table.insert(elements, {label = v.itemdesc, value = v.value, type = v.type, price = v.price})

	end
	
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_menu',
		{
			title    = 'Sklep',
			align    = 'center',
			elements = elements
		}, function(data, menu)		
			if data.current.value == nil then return end;
			
			if data.current.type == 'rank' then
				OpenRankMenu(data.current.value)
			elseif data.current.type == 'item' then
			ESX.TriggerServerCallback('zykem_ranks:buyItem', function(cb)

			
			
			end, data.current.value, data.current.price)	

			end
		end, function(data, menu)
			menu.close()
		end)

end

function OpenRankMenu(rank)
	ESX.UI.Menu.CloseAll()
	local elements = {}
	for k,v in pairs(cl_cfg.shopItems[rank].elements) do

		table.insert(elements, {label = v.itemdesc, value = v.rank, duration = v.duration, price = v.price, shoptype = v.shoptype})

	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_menu',
	{
		title    = 'Sklep # Rangi',
		align    = 'center',
		elements = elements
	}, function(data, menu)	


			ESX.TriggerServerCallback('zykem_ranks:buyRank', function(cb)
			
			
			
			end, data.current.value, data.current.duration, data.current.price)
		
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('zykem_misc:notify', function(msg)

	notify(msg)

end)

function notify(msg)
	SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true, false)
end

RegisterNetEvent('zykem_misc:announcement', function(msg)

	TriggerEvent('chatMessage', msg, {255, 152, 247})

end)