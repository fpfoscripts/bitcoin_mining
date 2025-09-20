ESX = nil
local playerMining = false
local lastUsed = {}
local lastMinedIndex = nil
local myItemCount = 0

local LOCS = Config.Locations
local LOCS_COUNT = #LOCS

-- DO NOT TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
Citizen.CreateThread(function()
    while ESX == nil do
        if GetResourceState('es_extended') == 'started' and exports['es_extended'] and exports['es_extended']:getSharedObject() then
            ESX = exports['es_extended']:getSharedObject()
        else
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
        Citizen.Wait(200)
    end
end)

-- Blips
Citizen.CreateThread(function()
    if Config.ShowMapBlips then
        for i = 1, LOCS_COUNT do
            local v = LOCS[i]
            local coords = (type(v) == "table" and v.coords) and v.coords or v
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipColour(blip, Config.BlipColor)
            SetBlipScale(blip, Config.BlipScale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.BlipText)
            EndTextCommandSetBlipName(blip)
        end
    end

    if Config.Sell and Config.Sell.Enabled and Config.Sell.Blip then
        for _, v in ipairs(Config.Sell.Locations) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(blip, Config.Sell.BlipSprite)
            SetBlipColour(blip, Config.Sell.BlipColor)
            SetBlipScale(blip, Config.Sell.BlipScale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Sell.BlipText)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- DO NOT TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
local function L(key, ...)
    return Config.L(key, ...)
end

-- Notify wrapper (ox_lib -> ESX fallback)
local function Notify(text)
    if Config.UseOxLibIfAvailable and lib and lib.notify then
        lib.notify({ description = text })
        return
    end
    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(text)
        return
    end
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

RegisterNetEvent('pitcoin:client:notify', function(text)
    Notify(text)
end)

RegisterNetEvent('pitcoin:client:updateItemCount', function(count)
    myItemCount = tonumber(count) or 0
end)

local function getRotation()
    local t = GetGameTimer() / 1000.0
    return (t * Config.MarkerRotationSpeed) % 360
end

-- DO NOT TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
local function getNode(i)
    local v = LOCS[i]
    if not v then return nil end
    if type(v) == "table" and v.coords then return v end
    return { coords = v, rare = false }
end

-- Main loop
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)

        -- quick distance check: only iterate nodes if within 80m of any (fast early-exit)
        for i = 1, LOCS_COUNT do
            local node = getNode(i)
            local loc = node.coords
            local dist = #(pcoords - loc)
            if dist <= 80.0 then
                sleep = 0
            end

            if dist <= 20.0 then
                local rot = getRotation()
                local color = node.rare and Config.Marker.RareColor or Config.Marker.Color
                DrawMarker(
                    Config.Marker.Type,
                    loc.x, loc.y, loc.z + 0.05,
                    0.0, 0.0, rot,
                    0.0, 0.0, 0.0,
                    Config.Marker.Scale.x, Config.Marker.Scale.y, Config.Marker.Scale.z,
                    color.r, color.g, color.b, color.a,
                    false, false, 2, true, nil, nil, false
                )
            end

            if dist <= Config.InteractDistance then
                if ESX and ESX.ShowHelpNotification then
                    ESX.ShowHelpNotification(L('help'))
                else
                    SetTextComponentFormat("STRING")
                    AddTextComponentString(L('help'))
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                end

                if IsControlJustReleased(0, 38) then -- E
                    local now = GetGameTimer()
                    local last = lastUsed[i] or 0

                    -- Mode handling: if RequireDifferentSpot true -> require different, ignore cooldown
                    if Config.RequireDifferentSpot then
                        if lastMinedIndex == i then
                            Notify(L('switch_node'))
                        else
                            if not playerMining then
                                playerMining = true
                                lastUsed[i] = now
                                StartMining(i)
                            else
                                Notify(L('alreadyMining'))
                            end
                        end
                    else
                        -- normal cooldown mode
                        if Config.UseCooldown and (now - last) < (Config.UseCooldownSeconds * 1000) then
                            local waitSec = math.ceil((Config.UseCooldownSeconds * 1000 - (now - last)) / 1000)
                            Notify(L('cooldown', waitSec))
                        else
                            if not playerMining then
                                playerMining = true
                                lastUsed[i] = now
                                StartMining(i)
                            else
                                Notify(L('alreadyMining'))
                            end
                        end
                    end
                end
            end
        end

        -- Sell spots
        if Config.Sell and Config.Sell.Enabled then
            for _, loc in ipairs(Config.Sell.Locations) do
                local dist = #(pcoords - loc)
                if dist <= 80.0 then sleep = 0 end

                if dist <= 20.0 then
                    local rot = getRotation()
                    DrawMarker(Config.Marker.Type, loc.x, loc.y, loc.z + 0.05, 0.0, 0.0, rot, 0.0, 0.0, rot,
                        Config.Marker.Scale.x, Config.Marker.Scale.y, Config.Marker.Scale.z, 200, 180, 20, 140, false,
                        false, 2, nil, nil, false)
                end

                if dist <= Config.InteractDistance then
                    if ESX and ESX.ShowHelpNotification then
                        ESX.ShowHelpNotification(L('sell_prompt'))
                    else
                        SetTextComponentFormat("STRING")
                        AddTextComponentString(L('sell_prompt'))
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                    end

                    if IsControlJustReleased(0, 38) then
                        if not playerMining then
                            StartSelling(loc)
                        else
                            Notify(L('alreadyMining'))
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

local function DoSkillCheckWithAnim(node)
    local ped = PlayerPedId()

    if Config.UseScenario then
        TaskStartScenarioInPlace(ped, Config.ScenarioName, 0, true)
    else
        RequestAnimDict(Config.AnimDict)

        Citizen.CreateThread(function()
            local timeout = GetGameTimer() + 1000
            while not HasAnimDictLoaded(Config.AnimDict) and GetGameTimer() < timeout do
                Citizen.Wait(10)
            end
            if HasAnimDictLoaded(Config.AnimDict) then
                TaskPlayAnim(ped, Config.AnimDict, Config.AnimName, 8.0, -8.0, -1, 1, 0, false, false, false)
            end
        end)
    end

    local success = true
    if Config.UseOxLibIfAvailable and lib and lib.skillCheck then
        local seq = (node and node.skill) or Config.SkillCheckSequence
        local inputs = Config.SkillCheckInputs or { 'e' }
        success = lib.skillCheck(seq, inputs)
    else
        -- Fallback progress (only used if no lib.skillCheck). This is shorter/faster to avoid user-perceived delay.
        local duration = math.random(Config.MiningDurationMin, Config.MiningDurationMax) * 1000
        if Config.UseOxLibIfAvailable and lib and lib.progressCircle then
            lib.progressCircle({
                duration = duration,
                position = 'bottom',
                label = L('startMining'),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                },
            })
        else
            local start = GetGameTimer()
            while GetGameTimer() - start < duration do
                Citizen.Wait(50)
                if IsEntityDead(ped) then
                    success = false
                    break
                end
            end
        end
    end

    ClearPedTasks(ped)

    return success
end

function StartMining(index)
    local node = getNode(index)
    local ped = PlayerPedId()

    local ok = DoSkillCheckWithAnim(node)

    if not ok then
        Notify(L('skillFail'))
        lastMinedIndex = index
        playerMining = false
        return
    end

    local amount = Config.GeneratePitcoins(node.rare, node)
    TriggerServerEvent('pitcoin:server:give', amount)

    lastMinedIndex = index
    playerMining = false
end

function StartSelling(sellLocation)
    local ped = PlayerPedId()

    local count = 0
    if exports.ox_inventory and exports.ox_inventory.GetItemCount then
        count = exports.ox_inventory:GetItemCount(Config.ItemName) or 0
    end
    if count <= 0 then
        Notify(L('no_bitcoin'))
        return
    end

    local sellAmount = count
    if Config.UseOxLibIfAvailable and lib and lib.inputDialog then
        local ok, response = pcall(lib.inputDialog, "Bitcoin verkaufen",
            { { type = "input", label = "Menge", name = "amount", value = tostring(count) } })
        if ok and response and response[1] and tonumber(response[1]) then
            sellAmount = math.floor(tonumber(response[1]))
            if sellAmount < 1 then
                Notify(L('invalid_amount'))
                return
            end
            if sellAmount > count then sellAmount = count end
        else
            -- fallback sell all
            sellAmount = count
        end
    else
        sellAmount = count
    end

    -- apply MaxPerAction cap
    if Config.Sell.MaxPerAction and Config.Sell.MaxPerAction > 0 then
        sellAmount = math.min(sellAmount, Config.Sell.MaxPerAction)
    end

    local desiredDurationSec = Config.Sell.BaseDuration + (sellAmount * Config.Sell.DurationPerBitcoin)
    local usedDurationSec = desiredDurationSec

    if Config.Sell.MaxSellDurationSeconds and Config.Sell.MaxSellDurationSeconds > 0 then
        if desiredDurationSec > Config.Sell.MaxSellDurationSeconds then
            usedDurationSec = Config.Sell.MaxSellDurationSeconds
        end
    end

    local durationMs = math.floor(usedDurationSec * 1000)
    local startPos = GetEntityCoords(ped)

    if Config.Sell.Emote and Config.Sell.Emote ~= "" then
        ExecuteCommand("e " .. Config.Sell.Emote)
    elseif Config.Sell.UseScenario then
        TaskStartScenarioInPlace(ped, Config.Sell.ScenarioName or "PROP_HUMAN_SEAT_COMPUTER", 0, true)
    end

    local cancelled = false
    local tStart = GetGameTimer()
    if Config.UseOxLibIfAvailable and lib and lib.progressCircle then
        local finished = lib.progressCircle({
            duration = durationMs,
            position = 'bottom',
            label = ("Verkaufe %s Bitcoin"):format(sellAmount),
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true
            },
        })
        if not finished then cancelled = true end
    else
        while GetGameTimer() - tStart < durationMs do
            Citizen.Wait(200)
            if IsEntityDead(ped) then
                cancelled = true; break
            end
            local curr = GetEntityCoords(ped)
            if #(curr - sellLocation) > (Config.InteractDistance + 1.0) then
                cancelled = true; break
            end
        end
    end

    ExecuteCommand("e c")
    ClearPedTasks(ped)

    if cancelled then
        Notify(L('sell_cancelled'))
        return
    end

    local finalPos = GetEntityCoords(ped)
    if #(finalPos - sellLocation) > (Config.InteractDistance + 1.0) then
        Notify(L('sell_too_far'))
        return
    end

    TriggerServerEvent('pitcoin:server:sell', sellAmount)
end