ESX = nil

-- DO NOT TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
if GetResourceState('es_extended') == 'started' and exports['es_extended'] and exports['es_extended']:getSharedObject() then
    ESX = exports['es_extended']:getSharedObject()
else
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

local function getXPlayer(source)
    if not ESX then
        if exports['es_extended'] and exports['es_extended'].getSharedObject then
            ESX = exports['es_extended']:getSharedObject()
        end
    end
    if ESX and ESX.GetPlayerFromId then return ESX.GetPlayerFromId(source) end
    return nil
end

RegisterNetEvent('pitcoin:server:give', function(amount)
    local src = source
    local xPlayer = getXPlayer(src)
    if not xPlayer then
        TriggerClientEvent('pitcoin:client:notify', src, Config.L('inventory_error'))
        return
    end

    amount = tonumber(amount) or 0
    if amount <= 0 then
        TriggerClientEvent('pitcoin:client:notify', src, Config.L('noResult'))
        return
    end

    local canCarry = true
    if exports.ox_inventory and exports.ox_inventory.CanCarryItem then
        local ok, carry = pcall(function() return exports.ox_inventory:CanCarryItem(src, Config.ItemName, amount) end)
        if ok and carry == false then canCarry = false end
    end

    if not canCarry then
        TriggerClientEvent('pitcoin:client:notify', src, Config.L('cannot_carry'))
        return
    end

    if exports.ox_inventory and exports.ox_inventory.AddItem then
        local ok, err = pcall(function() exports.ox_inventory:AddItem(src, Config.ItemName, amount) end)
        if not ok then
            TriggerClientEvent('pitcoin:client:notify', src, Config.L('inventory_error'))
            return
        end
    else
        TriggerClientEvent('pitcoin:client:notify', src, Config.L('inventory_error'))
        return
    end

    TriggerClientEvent('pitcoin:client:notify', src, Config.L('result', amount))

    local count = 0
    if exports.ox_inventory and exports.ox_inventory.GetItemCount then
        local ok, cnt = pcall(function() return exports.ox_inventory:GetItemCount(Config.ItemName) end)
        if ok and cnt then count = cnt end
    end
    TriggerClientEvent('pitcoin:client:updateItemCount', src, count)
end)

RegisterNetEvent('pitcoin:server:sell', function(amount)
    local src = source
    local xPlayer = getXPlayer(src)
    if not xPlayer then
        TriggerClientEvent('pitcoin:client:notify', src, Config.L('inventory_error'))
        return
    end

    local amt = tonumber(amount) or 0
    if amt <= 0 then
        TriggerClientEvent('pitcoin:client:notify', src, Config.L('invalid_amount'))
        return
    end

    if exports.ox_inventory and exports.ox_inventory.RemoveItem then
        local ok, reason = pcall(function() return exports.ox_inventory:RemoveItem(src, Config.ItemName, amt) end)

        local success = false
        if ok then
            if reason == true or (type(reason) == "number" and reason >= 0) or reason == nil then
                success = true
            end
        end

        if not success then
            TriggerClientEvent('pitcoin:client:notify', src, "Fehler beim Entfernen der Bitcoin.")
            return
        end
    else
        TriggerClientEvent('pitcoin:client:notify', src, Config.L('inventory_error'))
        return
    end

    local price = tonumber(Config.Sell.PricePerBitcoin) or 0
    local payout = price * amt

    if xPlayer and xPlayer.addMoney then
        xPlayer.addMoney(payout)
    elseif xPlayer and xPlayer.addAccountMoney then
        xPlayer.addAccountMoney('money', payout)
    else
        TriggerClientEvent('pitcoin:client:notify', src,
            ("Du hast $%s erhalten. (Konnte Geldserverseit nicht korrekt setzen)"):format(tostring(payout)))
        return
    end

    TriggerClientEvent('pitcoin:client:notify', src, Config.L('sell_complete', amt, payout))

    local count = 0
    if exports.ox_inventory and exports.ox_inventory.GetItemCount then
        local ok, cnt = pcall(function() return exports.ox_inventory:GetItemCount(Config.ItemName) end)
        if ok and cnt then count = cnt end
    end
    TriggerClientEvent('pitcoin:client:updateItemCount', src, count)
end)

if ESX and ESX.RegisterCommand then
    ESX.RegisterCommand('bitcoin', 'user', function(xPlayer, args, showError)
        local src = xPlayer.source
        local count = 0
        if exports.ox_inventory and exports.ox_inventory.GetItemCount then
            local ok, cnt = pcall(function() return exports.ox_inventory:GetItemCount(Config.ItemName) end)
            if ok and cnt then count = cnt end
        end
        TriggerClientEvent('pitcoin:client:notify', src, ("Du hast %s Bitcoin."):format(count))
    end, true, { help = "Zeigt deine Bitcoin-Anzahl an" })
else
    RegisterCommand('bitcoin', function(source)
        local count = 0
        if exports.ox_inventory and exports.ox_inventory.GetItemCount then
            local ok, cnt = pcall(function() return exports.ox_inventory:GetItemCount(Config.ItemName) end)
            if ok and cnt then count = cnt end
        end
        TriggerClientEvent('pitcoin:client:notify', source, ("Du hast %s Bitcoin."):format(count))
    end)
end