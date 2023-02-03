ESX = nil

TriggerEvent(cl_cfg.esxInit, function(obj) ESX = obj end)

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
                print('Ustawiono range Uzytkownikowi ' .. name)
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
    if source == nil then return end;
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
    if source == nil then return end;
    if amount > cfg.maxCoinsGive then TriggerClientEvent('esx:showNotification', source, 'Probujesz dac za duzo coinsow na raz.') return end;
    MySQL.Async.execute('UPDATE users SET coins = coins + @amount WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['amount'] = amount
    }, function(result)

    end)
end

exports('addUserCoins', addUserCoins)

function setUserCoins(source,identifier,amount)
    if source == nil then return end;
    MySQL.Async.execute('UPDATE users SET coins = @amount WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['amount'] = amount
    }, function(result)
        print(source .. ' ustawil coinsy uzytkownikowi ' .. identifier)
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
		print('[INFO] # Usunieto range Uzytkownikowi ' .. identifier .. '!')
	end)
end)

function checkTime()
	MySQL.Async.fetchAll('SELECT identifier, rank, rankexpire as timestamp FROM users', 
		{
			
		}, 
		function(result)
			local time_now = os.time()
			local i = 1
            while i <= #result do -- NANOSECOND OPTIMIZATION ON TOP
                local dostepTime = result[i].timestamp
                if result[i].rank ~= 'Gracz' and dostepTime <= time_now then
                    TriggerEvent('zykem_coinsystem:expired', result[i].identifier)
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

ESX.RegisterServerCallback('zykem_coins:addCoins', function(source,cb,id,amount)

    if amount == nil or id == nil then return end;
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(id)
    local targetID = xTarget.getIdentifier()
    if amount > cfg.maxCoinsGive then
        xPlayer.showNotification('Nie mozesz dac wiecej niz ' .. cfg.maxCoinsGive);
        return
    end
    xPlayer.showNotification('Dodales ' .. amount .. ' Coinsow Graczowi ' .. id)
    if getUserCoins(targetID) < 0 then
        setUserCoins(source, xTarget.source,targetID, amount) 
    else
        addUserCoins(xTarget.source,targetID, amount)
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
    local rankFound = false

    for k, v in ipairs(cfg.ranks) do
        if v == rank then rankFound = true break end; -- NANOSECOND OPTIMIZATION ON TOP
    end
    
    if not rankFound then return false end;
    if getUserCoins(identifier) < price then prompt(source, 'money') return false end;

    removeUserCoins(source,identifier, price)
    updateRank(identifier, GetPlayerName(source), 0, rank, duration)
    
    xPlayer.showNotification('Zakupiles Range ' .. string.upper(rank) .. ' za ' .. price .. 'x Coinsow!');

end)

ESX.RegisterServerCallback('zykem_ranks:buyItem', function(source,cb,item,price)
    local xPlayer = ESX.GetPlayerFromId(source);
    local identifier = xPlayer.getIdentifier();

    for k,v in pairs(cl_cfg.shopItems) do
        if(string.find(v.value, item)) then
            found = true -- NANOSECOND OPTIMIZATION ON TOP
            break
        end
    end

    if not found then return end;   -- callback argument item does not exist in config, probably cheater tried to resp item!
    if getUserCoins(identifier) < price then prompt(source, 'money') return false end;

    xPlayer.addInventoryItem(item, 1)
    removeUserCoins(source,identifier, price)
    xPlayer.showNotification('Zakupiles Item ' .. string.upper(item) .. ' za ' .. price .. 'x Coinsow!');

end)

ESX.RegisterServerCallback('zykem_coins:hasPerms', function(source,cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()
    local found = false

    for k,v in pairs(cfg.perms) do
        if(string.match(v, group)) then found = true break end;
    end

    cb(found)

end)
