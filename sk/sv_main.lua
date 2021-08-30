ESX = nil
local homo = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local npct = {
    [1] = {
        npcmodel = "g_m_importexport_01",
        anim = 'anim@heists@prison_heistig_2_p1_exit_bus',  --animaatio dict https://wiki.gtanet.work/index.php?title=Animations
        anim2 = 'loop_a_guard_a',
        luotu = false,
        pylly = false,
        juttelee = false,
        ryostetaan = false,
        check22 = false,
        paikat  = { --random posit, johon npc vaihtaa aina kun varasto loppuu/npc ryöstetään.
            [1] = {coords=vector3(135.99, -57.11, 67.67), h=67},
            [2] = {coords=vector3(134.77, -60.71, 67.67), h=67},
            [3] = {coords=vector3(133.62, -64.13, 67.67), h=67},
            [4] = {coords=vector3(132.59, -67.46, 67.672), h=67}
        }
    },
    [2] = {
        npcmodel = "g_m_importexport_01",
        anim = 'anim@heists@prison_heistig_2_p1_exit_bus',  --animaatio dict https://wiki.gtanet.work/index.php?title=Animations
        anim2 = 'loop_a_guard_a',
        luotu = false,
        pylly = false,
        juttelee = false,
        ryostetaan = false,
        check22 = false,
        paikat  = {
            [1] = {coords=vector3(135.99, -57.11, 67.67), h=67},
            [2] = {coords=vector3(134.77, -60.71, 67.67), h=67},
            [3] = {coords=vector3(133.62, -64.13, 67.67), h=67},
            [4] = {coords=vector3(132.59, -67.46, 67.672), h=67}
        }
    }
}


function math.percent(percent,maxvalue) --otettu jostain netistä prosenttilaskuri
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end


RegisterNetEvent('velho_npcmyyjat:osta')
AddEventHandler('velho_npcmyyjat:osta', function(npc, hinta, itemi, label, tyyppi, maara, jaljella)
    local xPlayer = ESX.GetPlayerFromId(source)
    local massit = xPlayer.getMoney()
    if homo[npc].jaljella > 0 then
        if massit >= hinta then
            if tyyppi == 'ASE' then
                TriggerClientEvent('esx:showNotification', source, "Ostit: "..label.. " hintaan: ~g~$" ..hinta)
                xPlayer.addWeapon(itemi, 0)
                xPlayer.removeMoney(hinta)
            else
                TriggerClientEvent('esx:showNotification', source, "Ostit: " ..maara.. "x "..label.. " hintaan: ~g~$" ..hinta)
                xPlayer.addInventoryItem(itemi, maara)
                xPlayer.removeMoney(hinta)
            end
            local lol = homo[npc].jaljella-1
            MySQL.Async.execute("UPDATE velhomyyjat SET `jaljella` = @uusvalue WHERE npc = @npc",{["@npc"] = npc, ["@uusvalue"] = lol})
            local prosentti = math.percent(Config.prosenttiosuus, hinta)
            local tuotot = homo[npc].tuotot + prosentti
            MySQL.Async.execute("UPDATE velhomyyjat SET `tuotot` = @tuotot WHERE npc = @npc",{["@npc"] = npc, ["@tuotot"] = tuotot}) --jos on niin value laitetaan 0
            if lol == 0 then
                if Config.vaihdapaikkaa then
                    local source = source
                    local lisaa = Config.paljonlisaa
                    MySQL.Async.execute("UPDATE velhomyyjat SET `jaljella`= @jaljella WHERE npc = @npc",{["@npc"] = npc, ["@jaljella"] = lisaa}) 
                    TriggerEvent('velho_npcmyyjat:poistaped', source, npc)
                    Wait(150)
                    MySQL.Async.fetchAll('SELECT * FROM velhomyyjat', {}, function(result)
                        homo = result
                    end)
                    Wait(150)
                    TriggerClientEvent('velho_npcmyyjat:clienttiin2', source, homo)
                    TriggerClientEvent('velho_npcmyyjat:poistaclient', source, npc)
                end
            end
        end
    else
        TriggerClientEvent('esx:showNotification', source, "Ei mulla ole mitään :D?")
    end
end)

RegisterNetEvent('velho_npcmyyjat:poistaped')
AddEventHandler('velho_npcmyyjat:poistaped', function(npc)
    local source = source
    local paska = math.random(1,#npct[npc].paikat)
    local lol = npct[npc].paikat[paska].coords
    local heading = npct[npc].paikat[paska].h
    local x,y,z = table.unpack(lol)
    Wait(150)
    MySQL.Async.execute("UPDATE velhomyyjat SET `x`= @x WHERE npc = @npc",{["@npc"] = npc, ["@x"] = x}) 
    MySQL.Async.execute("UPDATE velhomyyjat SET `y`= @y WHERE npc = @npc",{["@npc"] = npc, ["@y"] = y}) 
    MySQL.Async.execute("UPDATE velhomyyjat SET `z`= @z WHERE npc = @npc",{["@npc"] = npc, ["@z"] = z})
    MySQL.Async.execute("UPDATE velhomyyjat SET `h`= @h WHERE npc = @npc",{["@npc"] = npc, ["@h"] = heading})
    Wait(150)
    MySQL.Async.fetchAll('SELECT * FROM velhomyyjat', {}, function(result)
            homo = result
    end)
    Wait(150)
    TriggerClientEvent('velho_npcmyyjat:clienttiin2', source, homo)
    TriggerClientEvent('velho_npcmyyjat:poistaclient', source, npc)
end)


RegisterNetEvent('velho_npcmyyjat:ryosto')
AddEventHandler('velho_npcmyyjat:ryosto', function(npc)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM velhomyyjat', {}, function(result)
        TriggerClientEvent('velho_npcmyyjat:clienttiin2', source, result)
        if result[npc].tuotot > 0 then
            xPlayer.addMoney(result[npc].tuotot)
            TriggerClientEvent('esx:showNotification', source, "Myyjällä oli taskussaan: ~g~$" ..result[npc].tuotot)
            MySQL.Async.execute("UPDATE velhomyyjat SET `tuotot` = @kakka WHERE npc = @npc",{["@npc"] = npc, ["@kakka"] = 0}) --jos on niin value laitetaan 0
        else
            TriggerClientEvent('esx:showNotification', source, "Myyjällä oli tyhjät taskut!")
        end
        homo = result
    end)
end)


RegisterNetEvent('velho_npcmyyjat:dbsta')
AddEventHandler('velho_npcmyyjat:dbsta', function()
    local source = source
    MySQL.Async.fetchAll('SELECT * FROM velhomyyjat', {}, function(result)
        TriggerClientEvent('velho_npcmyyjat:clienttiin2', source, result)
        homo = result
    end)
end)

RegisterNetEvent('velho_npcmyyjat:serverista')
AddEventHandler('velho_npcmyyjat:serverista', function()
    local source = source
    TriggerClientEvent('velho_npcmyyjat:clienttiin', source, npct)
end)

AddEventHandler('onResourceStart', function(resourceName) --öö äläkoske tää on codenz
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    for i=1, #npct do
        MySQL.Async.execute("UPDATE velhomyyjat SET `kaytossa` = @kakka WHERE npc = @npc",{["@npc"] = i, ["@kakka"] = 1}) --jos on niin value laitetaan 0
    end
end)
  
  
