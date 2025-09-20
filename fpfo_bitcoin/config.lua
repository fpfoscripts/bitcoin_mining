Config = {}

-- Locale: 'de' or 'en'
Config.Locale = 'de'

-- Use ox_lib features if available
Config.UseOxLibIfAvailable = true

-- Mining fallback duration (wenn kein skillcheck verfügbar)
Config.MiningDurationMin = 8
Config.MiningDurationMax = 15

-- Low/High tier distribution for normal nodes
Config.LowTierChance = 0.70
Config.LowTierMin = 1
Config.LowTierMax = 6
Config.HighTierMin = 7
Config.HighTierMax = 10

-- Cooldown mode:
-- If RequireDifferentSpot = true, player must move to a different node to mine again (cooldown is ignored).
-- If RequireDifferentSpot = false, classical per-node cooldown applies (UseCooldownSeconds).
Config.RequireDifferentSpot = true
Config.UseCooldown = false
Config.UseCooldownSeconds = 5

-- Texts per locale
Config.Locales = {
    de = {
        help = "Drücke ~INPUT_CONTEXT~ um Pitcoins zu minen",
        startMining = "Pitcoin-Mining läuft...",
        result = "Du hast %s Pitcoin erhalten.",
        noResult = "Du hast nichts erhalten.",
        alreadyMining = "Du minest bereits.",
        cooldown = "Warte %s Sekunden bevor du hier erneut minen kannst.",
        cancel = "Vorgang abgebrochen.",
        skillFail = "Skillcheck fehlgeschlagen.",
        switch_node = "Wechsle zu einem anderen Node, um weiterzuminen.",
        sell_prompt = "Drücke ~INPUT_CONTEXT~ um Pitcoins zu verkaufen",
        no_bitcoin = "Du hast keine Pitcoin zum Verkaufen.",
        sell_too_big = "Verkauf zu groß. Reduziere die Menge.",
        sell_cancelled = "Verkauf abgebrochen.",
        sell_complete = "Du hast %s Pitcoin verkauft und $%s erhalten.",
        cannot_carry = "Du kannst nicht so viele Pitcoin tragen.",
        inventory_error = "Fehler: ox_inventory nicht verfügbar.",
        sell_too_far = "Du bist zu weit entfernt, Verkauf abgebrochen.",
        invalid_amount = "Ungültige Menge."
    },
    en = {
        help = "Press ~INPUT_CONTEXT~ to mine Pitcoins",
        startMining = "Starting Pitcoin mining...",
        result = "You received %s Pitcoin.",
        noResult = "You didn't receive anything.",
        alreadyMining = "You are already mining.",
        cooldown = "Wait %s seconds before mining here again.",
        cancel = "Action cancelled.",
        skillFail = "Skill check failed.",
        switch_node = "Move to another node to continue mining.",
        sell_prompt = "Press ~INPUT_CONTEXT~ to sell Pitcoins",
        no_bitcoin = "You have no Pitcoin to sell.",
        sell_too_big = "Sale too large. Reduce the amount.",
        sell_cancelled = "Sale cancelled.",
        sell_complete = "You sold %s Pitcoin and received $%s.",
        cannot_carry = "You cannot carry that many Pitcoins.",
        inventory_error = "Error: ox_inventory not available.",
        sell_too_far = "You are too far away, sale cancelled.",
        invalid_amount = "Invalid amount."
    }
}

-- DO NOT TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
function Config.L(key, ...)
    local loc = Config.Locales[Config.Locale] or Config.Locales.de
    local txt = loc[key] or ("<missing:"..tostring(key)..">")
    if ... and select('#', ...) > 0 then
        return string.format(txt, ...)
    end
    return txt
end


Config.SkillCheckSequence = {'easy', 'easy', 'medium', 'easy', 'easy', 'medium', 'medium', 'easy', 'medium'} -- default sequence for normal nodes
Config.SkillCheckInputs = {'e'}


Config.Locations = {
    { coords = vector3(2198.2664, 2920.7944, -84.7193), rare = false },
    { coords = vector3(2201.8022, 2921.0679, -84.7193), rare = true, skill = {'hard', 'hard', 'hard', 'easy'}, rareMin = 7, rareMax = 20 },
    { coords = vector3(2203.6912, 2930.3174, -84.7193), rare = false },
    { coords = vector3(2200.2605, 2929.7971, -84.7193), rare = false },
    { coords = vector3(2197.4683, 2938.5388, -84.7243), rare = false },
    { coords = vector3(2203.7673, 2911.8682, -84.7244), rare = true, skill = {'hard', 'hard', 'hard', 'easy'}, rareMin = 7, rareMax = 20 },
    { coords = vector3(2200.3171, 2911.7627, -84.7243), rare = false },
    { coords = vector3(2202.5930, 2902.3184, -84.7193), rare = false },
    { coords = vector3(2199.1772, 2902.5139, -84.7193), rare = true, skill = {'hard', 'hard', 'hard', 'easy'}, rareMin = 7, rareMax = 20 },
    { coords = vector3(2200.7732, 2939.4634, -84.7244), rare = false },
    { coords = vector3(2213.9778, 2941.4915, -84.7193), rare = false },
    { coords = vector3(2217.1863, 2942.3689, -84.7193), rare = false },
    { coords = vector3(2227.8110, 2921.0793, -84.7243), rare = false },
    { coords = vector3(2224.3694, 2920.7517, -84.7243), rare = true, skill = {'hard', 'hard', 'hard', 'easy'}, rareMin = 7, rareMax = 20 },
    { coords = vector3(2217.3621, 2899.6812, -84.7243), rare = false },
    { coords = vector3(2213.6987, 2899.9631, -84.7243), rare = false },
    { coords = vector3(2230.1179, 2944.3918, -84.7243), rare = false },
    { coords = vector3(2233.4890, 2945.3904, -84.7243), rare = false },
    { coords = vector3(2242.4343, 2937.2693, -84.7193), rare = true, skill = {'hard', 'hard', 'hard', 'easy'}, rareMin = 7, rareMax = 20 },
    { coords = vector3(2246.0320, 2937.5923, -84.7193), rare = false },
    { coords = vector3(2243.9370, 2929.4822, -84.7243), rare = false },
    { coords = vector3(2240.2703, 2929.2668, -84.7243), rare = false },
    { coords = vector3(2241.5151, 2912.3188, -84.7193), rare = true, skill = {'hard', 'hard', 'hard', 'easy'}, rareMin = 7, rareMax = 20 },
    { coords = vector3(2245.3735, 2912.5452, -84.7193), rare = false },
    { coords = vector3(2244.7590, 2904.4924, -84.7243), rare = false },
    { coords = vector3(2240.8958, 2904.2729, -84.7243), rare = false },
    { coords = vector3(2229.8362, 2897.0583, -84.7193), rare = false },
    { coords = vector3(2233.9932, 2896.6597, -84.7193), rare = false },
}

Config.InteractDistance = 1.0

-- Map blip config
Config.ShowMapBlips = true
Config.BlipSprite = 431
Config.BlipColor = 5
Config.BlipScale = 0.6
Config.BlipText = "Pitcoin Node"

-- Item name in ox_inventory
Config.ItemName = "bitcoin"

-- Sell config
Config.Sell = {}
Config.Sell.Enabled = true
Config.Sell.Locations = { vector3(707.3120, -966.9720, 30.4128) }
Config.Sell.Blip = true
Config.Sell.BlipSprite = 408
Config.Sell.BlipColor = 2
Config.Sell.BlipScale = 0.7
Config.Sell.BlipText = "Pitcoin Verkauf"
Config.Sell.PricePerBitcoin = 100
Config.Sell.BaseDuration = 2
Config.Sell.DurationPerBitcoin = 0.5
Config.Sell.MaxPerAction = nil
Config.Sell.MaxSellDurationSeconds = 120
Config.Sell.Emote = "type"
Config.Sell.UseScenario = true

-- Marker visuals
Config.Marker = {}
Config.Marker.Type = 2
Config.Marker.Scale = vector3(0.20, 0.20, 0.08)
Config.Marker.Color = { r = 0, g = 255, b = 50, a = 120 }
Config.Marker.RareColor = { r = 255, g = 200, b = 0, a = 160 }
Config.MarkerRotationSpeed = 60.0

Config.Debug = false

-- DO NOT TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
function Config.GeneratePitcoins(isRare, node)
    if isRare then
        local min = 7
        local max = 20
        if node and node.rareMin then min = node.rareMin end
        if node and node.rareMax then max = node.rareMax end
        return math.random(min, max)
    end

    local r = math.random()
    if r <= Config.LowTierChance then
        return math.random(Config.LowTierMin, Config.LowTierMax)
    else
        return math.random(Config.HighTierMin, Config.HighTierMax)
    end
end