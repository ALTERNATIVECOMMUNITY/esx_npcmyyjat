ESX = nil
local npct = {}
local database = {}
local juttelee = false
local pedi
--created by karpo#1943

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(10)
	end
    TriggerServerEvent('velho_npcmyyjat:serverista')
    TriggerServerEvent('velho_npcmyyjat:dbsta')
    Wait(5600) --venataan että saaadaaan sql info
    while true do
    local wait = 2500 --atm looppaa vaan joka 2,5 sec ettei mee liian raskaaks
    local coords = GetEntityCoords(PlayerPedId())
        for i=1, #database do
            for i=1, #npct do
            if Vdist(database[i].x, database[i].y, database[i].z, coords.x, coords.y, coords.z) < 3.0 then
                wait = 5  --nyt joka 5 tick/frame mikä vittu koska pitää renderöidä teksti
                if not npct[i].pylly then
                    if not juttelee and not npct[i].ryostetaan then
                        teksti(database[i].x, database[i].y, database[i].z, tostring("~w~Paina ~g~E ~w~jutellaksesi!"))
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent('velho_npcmyyjat:dbsta')
                            Wait(500)--venataa et saadaan sqllst infot perille ennenku avataan menu
                            menu(i)
                            npct[i].juttelee = true
                        end
                    else
                    if not npct[i].ryostetaan then
                        teksti(database[i].x, database[i].y, database[i].z, tostring("~w~Mitä sais olla?"))
                    else
                        teksti(database[i].x, database[i].y, database[i].z, tostring("~r~Ryöstetään!"))
                    end
                end
            end
            else
                if npct[i].juttelee then
                    npct[i].juttelee = false
                    ESX.UI.Menu.CloseAll()
                end
            end
            for i=1, #npct do --loopataan kaikki pedit jotka saadaan sql ja luodaan ne 
                if not npct[i].check22 then
                    npct[i].check22 = true
                    luo(i)
                end
            end
        end
    end
    Wait(wait) --ooämgee
    end
end)

function menu(npc) --works
    local elements = {}
    local itemi = database[npc].tavara
    table.insert(elements, {label = 'Myyn: ' ..database[npc].label.. ' hintaan: $' ..database[npc].hinta, value = 1})
    table.insert(elements, {label = 'Minulla on vielä: ' ..database[npc].jaljella.. 'kpl jäljellä!', value = 2})
    if IsPedArmed(PlayerPedId(), 7) then --jos pelaajalla ase (lol?)
        table.insert(elements, {label = 'Ryöstä myyjä!', value = 3})
    end
    ESX.UI.Menu.Open(
	    'default', GetCurrentResourceName(), 'npc',
	    {
	        title    = 'Myyjä',
	        align    = 'bottom',
	        elements = elements, 
	    },
		function(data, menu)
            if data.current.value == 1 or data.current.value == 2 then
                if database[npc].tyyppi == 'ITEMI' then
                menu.close()
                ESX.UI.Menu.Open(
			    		'dialog', GetCurrentResourceName(), 'määrä',
			    		{
			    			title = "Montas laitetaan?"
			    		},
			     	function(data2, menu2)
                        local maara = tonumber(data2.value)
                        juttelee = false
                        menu2.close()
			            TriggerServerEvent('velho_npcmyyjat:osta', npc, database[npc].hinta, itemi, database[npc].label, database[npc].tyyppi, maara, database[npc].jaljella)
                end, function(data2, menu2)
                    menu2.close()
                    juttelee = false
                end)
            else
                menu.close()
                juttelee = false
                TriggerServerEvent('velho_npcmyyjat:osta', npc, database[npc].hinta, itemi, database[npc].label, database[npc].tyyppi, maara, database[npc].jaljella)
            end
        end
        if data.current.value == 3 then
            ryosto(npc)
        end
	end,
	function(data, menu)  
		menu.close()
        juttelee = false
	end
)
end


RegisterNetEvent('velho_npcmyyjat:poistaclient')
AddEventHandler('velho_npcmyyjat:poistaclient', function(npc)
    vaihdapaikkaa(npc) 
end)

function luo(npc)
    npct[npc].luotu = false
    CreateThread(function()  
        while true do --loopataan vain koska tarvitaan pelaajan kordinaatteja.
            local wait2 = 2000 --looppaa joka 2sec ettei mee liian raskaaks (ei tarvi joka frame sillä ei renderöidä muuteskaa mitään lol)
            local coords = GetEntityCoords(PlayerPedId())
            if Vdist(database[npc].x, database[npc].y, database[npc].z, coords.x, coords.y, coords.z) < 150.0 then --jos pelaaja on lähel npct (siks koska fivem pedit poistuu jne iha vitu bugiset)
                if database[npc].kaytossa == 1 then
                    if not npct[npc].luotu then --jos npctä ei ole jo luotu
                        RequestModel(GetHashKey(npct[npc].npcmodel))
                        while not HasModelLoaded(GetHashKey(npct[npc].npcmodel)) do
                            Citizen.Wait(1)
                        end
                        RequestAnimDict(npct[npc].anim)
                        while not HasAnimDictLoaded(npct[npc].anim) do
                            Citizen.Wait(1)
                        end
                        Wait(100)	
                        pedi = CreatePed(4, GetHashKey(npct[npc].npcmodel), database[npc].x, database[npc].y, database[npc].z, database[npc].h, false, true)
                        SetEntityHeading(pedi, database[npc].h+0.0)
                        SetPedCanRagdollFromPlayerImpact(pedi, false)
                        SetPedCanEvasiveDive(pedi, false)
                        SetPedCanBeTargetted(pedi, false)
                        SetEntityInvincible(pedi, true)
                        SetBlockingOfNonTemporaryEvents(pedi, true)
                        TaskPlayAnim(pedi, npct[npc].anim, npct[npc].anim2,1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
                        Wait(700)
                        FreezeEntityPosition(pedi, true)
                        npct[npc].luotu = true
                        break --breakataan looppi koska ei oo tarvetta enää omg
                    end
                end
            end
            Wait(wait2)
        end
    end)
end


function vaihdapaikkaa(npc)
    npct[npc].pylly = true
    SetEntityInvincible(pedi, false)
    SetBlockingOfNonTemporaryEvents(pedi, false)
    TaskWanderStandard(ped, 10, 10)
    SetPedAsNoLongerNeeded(pedi)
    Wait(5000)
    npct[npc].luotu = false
end

function ryosto(npc)
    npct[npc].ryostetaan = true
    local dict = "missminuteman_1ig_2"
    ClearPedTasksImmediately(pedi)
    Wait(500)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(1)
    end
    TaskPlayAnim(pedi,dict,"handsup_enter",8.0, 8.0, -1, 50, 0, false, false, false)
    CreateThread(function()
        while true do
            Wait(5)
            local coords = GetEntityCoords(PlayerPedId())
            if npct[npc].ryostetaan then
                if Vdist(database[npc].x, database[npc].y, database[npc].z, coords.x, coords.y, coords.z) > 5.0 then --npc luonti
                    npct[npc].ryostetaan = false
                    TriggerServerEvent('velho_npcmyyjat:poistaped', npc)
                    ESX.ShowNotification('Liikuit liian kauaksi!')
                    SetEntityInvincible(pedi, false)
                    SetBlockingOfNonTemporaryEvents(pedi, false)
                    TaskSmartFleePed(pedi, PlayerPedId(), 1000.0, -1, true, true)
                    SetPedAsNoLongerNeeded(pedi)
                end
                Wait(Config.ryostoaika*1000)
                Wait(1000)
                npct[npc].pylly = true
                TriggerServerEvent('velho_npcmyyjat:poistaped', npc)
                Wait(500)
                TriggerServerEvent('velho_npcmyyjat:ryosto', npc)
                SetEntityInvincible(pedi, false)
                SetBlockingOfNonTemporaryEvents(pedi, false)
                TaskSmartFleePed(pedi, PlayerPedId(), 1000.0, -1, true, true)
                SetPedAsNoLongerNeeded(pedi)
                npct[npc].ryostetaan = false 
            end
        end
    end)

end


RegisterNetEvent('velho_npcmyyjat:clienttiin')
AddEventHandler('velho_npcmyyjat:clienttiin', function(infot, infot2)
    npct = infot
end)

RegisterNetEvent('velho_npcmyyjat:clienttiin2')
AddEventHandler('velho_npcmyyjat:clienttiin2', function(infot2)
    database = infot2
end)

function teksti(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z+0.30)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*1
    local fov = (1/GetGameplayCamFov())*100
    local scale = 1.0
   
    if onScreen then
        SetTextScale(0.0*scale, 0.25*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(0, 0, 0, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    	DrawRect(_x,_y+0.0125, 0.013+ factor, 0.03, 0, 0, 0, 68)
    end
end
