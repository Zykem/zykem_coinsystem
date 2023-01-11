ESX = nil

TriggerEvent('hypex:getTwojStarySharedTwojaStaraObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('zykem_coinsystem:getUserData', function(source,cb)
    local data = {coins = 0, rank = nil}
    local identifier = ESX.GetPlayerFromId(source).identifier

    if identifier == nil then return end;

    MySQL.Async.fetchAll('SELECT coins,rank FROM users WHERE identifier=@identifier', {
        ['@identifier'] = identifier
    
    }, function(result)
            
        if result == nil then cb(false) return end;
        data = {
            coins = result[1].coins,
            rank = result[1].rank
        }
        cb(data)
            
    end)


end)
function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
  end


local ranks = {

    deleteYoutuber = function(identifier)
        MySQL.Async.execute("UPDATE users SET rank = @rank WHERE identifier = @identifier AND rank = @ranga",{
            ['@identifier'] = identifier,
            ['@rank'] = 'Gracz',
            ['@ranga'] = 'youtuber'
        }, function(result)
            
            print('Usunieto wszystkie usuniete/niepubliczne Filmy.')
        
        end)
    end,

}

function getRank(identifier)
    local rank
    MySQL.Async.fetchAll('SELECT rank FROM users WHERE identifier = @identifier', {

        ['@identifier'] = identifier

    }, function(result)
        
        rank = result[1].rank
    
    end)
    while rank == nil do Wait(50) end;
    return rank;
end
exports('getRank', getRank)
function updateRank(identifier,name,videoid,rank, duration)
    if rank == 'youtuber' then
        MySQL.Async.execute("UPDATE users SET rank = @rank,videoid=@videoid WHERE identifier = @identifier",{
            ['@identifier'] = identifier,
            ['@rank'] = rank,
            ['@videoid'] = videoid
        }, function(result)
            
            TriggerClientEvent('zykem_misc:announcement', -1, '[ZYKEMRP] # Gracz ' .. name .. ' odebral range ' .. rank .. '!')
        
        end)
    else
        if duration == '24h' then
            local insertData = {
                rok = round(os.date('%Y'),0),
                miesiac = round(os.date('%m'),0),
                dzien = round(os.date('%d'),0),
                godzina = round(os.date('%H') + 24,0),
                minuta = round(os.date('%M'),0),
                sekunda = round(os.date('%S') + 3,0)
                
            }
            local formatted_Date = {year = insertData.rok, month = insertData.miesiac, day = insertData.dzien, hour = insertData.godzina, min = insertData.minuta, sec = insertData.sekunda}
            local finalDate = os.time(formatted_Date)

            MySQL.Async.execute("UPDATE users SET rank = @rank,rankexpire=@duration  WHERE identifier = @identifier",{
                ['@identifier'] = identifier,
                ['@rank'] = rank,
                ['@duration'] = finalDate
            }, function(result)            
                TriggerClientEvent('zykem_misc:announcement', -1, '[ZYKEMRP] # Gracz zykem  zakupil range ' .. string.upper(rank) .. ' na ' .. duration .. '!')
            end)

        elseif duration == '1w' then
            local insertData = {
                rok = round(os.date('%Y'),0),
                miesiac = round(os.date('%m'),0),
                dzien = round(os.date('%d') + 7,0),
                godzina = round(os.date('%H'),0),
                minuta = round(os.date('%M'),0),
                sekunda = round(os.date('%S'),0)
                
            }
            local formatted_Date = {year = insertData.rok, month = insertData.miesiac, day = insertData.dzien, hour = insertData.godzina, min = insertData.minuta, sec = insertData.sekunda}
            local finalDate = os.time(formatted_Date)

            MySQL.Async.execute("UPDATE users SET rank = @rank, rankexpire = @duration  WHERE identifier = @identifier",{
                ['@identifier'] = identifier,
                ['@rank'] = rank,
                ['@duration'] = finalDate
            }, function(result)
                
                TriggerClientEvent('zykem_misc:announcement', -1, '[ZYKEMRP] # Gracz ' .. name .. ' zakupil range ' .. string.upper(rank) .. '!')
            
            end)
        end
    end
end
exports('updateRank', updateRank)

function getUserCoins(identifier)
    local coins = nil
    MySQL.Async.fetchAll('SELECT coins FROM users WHERE identifier=@identifier', {
        ['@identifier'] = identifier
    }, function(result)

        if result[1] == nil then return end;
        coins = result[1].coins
    
    end)
    while coins == nil do Wait(50) end;
    return coins
end
exports('getUserCoins', getUserCoins)
function removeUserCoins(source,identifier, amount)
    if amount > cfg.maxCoinsRemove then TriggerClientEvent('esx:showNotification', source, 'Probujesz zabrac za duzo coinsow na raz.') return end;
    MySQL.Async.execute('UPDATE users SET coins = coins - @amount WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['amount'] = amount
    }, function(result)
        
        if source ~= nil then
            TriggerClientEvent('esx:showNotification', source, 'Nowy stan Konta: ' .. getUserCoins(identifier))
        end
    
    end)
end

exports('removeUserCoins', removeUserCoins)

function addUserCoins(source,identifier,amount)
    print(amount)
    if amount > cfg.maxCoinsGive then TriggerClientEvent('esx:showNotification', source, 'Probujesz dac za duzo coinsow na raz.') return end;
    MySQL.Async.execute('UPDATE users SET coins = coins + @amount WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['amount'] = amount
    }, function(result)

    end)
end

exports('addUserCoins', addUserCoins)

function setUserCoins(source,identifier,amount)
    MySQL.Async.execute('UPDATE users SET coins = @amount WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['amount'] = amount
    }, function(result)

    
    end)
end

exports('setUserCoins', setUserCoins)

RegisterServerEvent('zykem_coinsystem:expired')
AddEventHandler('zykem_coinsystem:expired', function(identifier)
	MySQL.Async.execute('UPDATE users SET rank = @rank, rankexpire = -1 WHERE identifier = @identifier', 
	{
		['@identifier'] = identifier,
        ['@rank'] = 'Gracz'
	}, function(rowsChanged)
		print("[INFO] # Usunieto " .. identifier .. ' z cooldownu Kitu!')
	end)
end)

function checkTime(d, h, m)
	print("[INFO] # Sprawdzam Czas")

	MySQL.Async.fetchAll('SELECT identifier, rank, rankexpire as timestamp FROM users', 
		{
			
		}, 
		function(result)
			local time_now = os.time()
			for i=1, #result, 1 do
				local dostepTime = result[i].timestamp

                if result[i].rank ~= 'Gracz' then
                    if dostepTime <= time_now then
                        TriggerEvent('zykem_coinsystem:expired', result[i].identifier)
                    end
                end
			end
		end
	)
end
CreateThread(function()
    while true do

        checkTime()
        Wait(1000 * 60 * 10)
    end

end)

function prompt(source, type)

    if type == 'money' then TriggerClientEvent('esx:showNotification', source, 'Nie posiadasz wystarczajaco Pieniedzy!') return end;

end

ESX.RegisterServerCallback('zykem_coins:changePlate', function(source,cb,plate,newplate)

    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()

    MySQL.Async.execute('UPDATE owned_vehicles SET plate = @newplate WHERE owner = @identifier AND plate = @plate', {

        ['@newplate'] = newplate,
        ['@identifier'] = identifier,
        ['@plate'] = plate

    }, function(result)
        
        TriggerClientEvent('zykem_misc:notify', source, 'Zmieniono rejestracje na ' .. newplate)
    
    end)

end)

ESX.RegisterServerCallback('zykem_coins:addCoins', function(source,cb,id,amount)

    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(id)
    local targetID = xTarget.getIdentifier()
    addUserCoins(xTarget.source,targetID, amount)
    if amount > cfg.maxCoinsGive then
        xPlayer.showNotification('Nie mozesz dac wiecej niz ' .. cfg.maxCoinsGive);
        return
    end
    xPlayer.showNotification('Dodales ' .. amount .. ' Coinsow Graczowi ' .. id)
    if getUserCoins(targetID) < 0 then
        setUserCoins(source, xTarget.source,targetID, amount) 
    end


end)

ESX.RegisterServerCallback('zykem_coins:removeCoins', function(source,cb,id, amount)

    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(id)
    local targetID = xTarget.getIdentifier()
    if amount > cfg.maxCoinsRemove then
        xPlayer.showNotification('Nie mozesz zabrac wiecej niz ' .. cfg.maxCoinsGive);
        return
    end
    xPlayer.showNotification('Zabrales ' .. amount .. ' Coinsow Graczowi ' .. id)
    
    removeUserCoins(xTarget.source,targetID, amount)
    if getUserCoins(targetID) < 0 then
        setUserCoins(xTarget.source,targetID, amount) 
    end

end)

ESX.RegisterServerCallback('zykem_ranks:buyRank', function(source,cb,rank,duration,price)
    local xPlayer = ESX.GetPlayerFromId(source);
    local identifier = xPlayer.getIdentifier();

    if rank ~= 'vip' and rank ~= 'svip' and rank ~= 'legend' then return false end;
    if getUserCoins(identifier) < price then prompt(source, 'money') return false end;

    removeUserCoins(source,identifier, price)
    updateRank(identifier, GetPlayerName(source), 0, rank, duration)
    
    xPlayer.showNotification('Zakupiles Range ' .. string.upper(rank) .. ' za ' .. price .. 'x Coinsow!');

end)

ESX.RegisterServerCallback('zykem_ranks:buyItem', function(source,cb,item,price)
    local xPlayer = ESX.GetPlayerFromId(source);
    local identifier = xPlayer.getIdentifier();
    local items = {}
    if getUserCoins(identifier) < price then prompt(source, 'money') return false end;
    for k,v in pairs(cl_cfg.shopItems) do
        if(string.find(v.value, item)) then
            xPlayer.addInventoryItem(item, 1)
            removeUserCoins(source,identifier, price)
            xPlayer.showNotification('Zakupiles Item ' .. string.upper(item) .. ' za ' .. price .. 'x Coinsow!');
        else
            --banplr
        end
    end

end)

ESX.RegisterServerCallback('zykem_coins:hasPerms', function(source,cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()

    for k,v in pairs(cfg.perms) do
        if(string.match(v, group)) then cb(true) return end;
        cb(false);
    end

end)
