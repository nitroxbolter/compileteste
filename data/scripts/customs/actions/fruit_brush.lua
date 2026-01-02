local fruitBushSystem = Action()

local fruitBushes = {
    -- [ID da árvore com fruta] = {itemid da fruta, quantidade mínima, quantidade máxima, ID da árvore seca}
    [2785] = {fruit_id = 2677, min = 2, max = 5, decayTo = 2786}, -- Blueberry bush
    [5391] = {fruit_id = 2673, min = 2, max = 4, decayTo = 5390}, -- pera
    [4393] = {fruit_id = 2674, min = 2, max = 3, decayTo = 2702}, -- Apple tree
    [4006] = {fruit_id = 2675, min = 1, max = 4, decayTo = 4008}, -- laranja
    [5095] = {fruit_id = 2676, min = 2, max = 3, decayTo = 5092}, -- Banana tree
    [5096] = {fruit_id = 2678, min = 1, max = 2, decayTo = 2726}, -- coco
    [4392] = {fruit_id = 2679, min = 3, max = 5, decayTo = 4391}, -- cherry
    [5157] = {fruit_id = 5097, min = 1, max = 2, decayTo = 5156}, -- manga 
}
function fruitBushSystem.onUse(player, item, fromPosition, target, toPosition)
    local config = fruitBushes[item.itemid]
    if not config then
        player:sendCancelMessage("Esta planta não possui frutos no momento.")
        return true
    end

    -- Determina quantidade de frutas
    local count = math.random(config.min, config.max)
    player:addItem(config.fruit_id, count)

    -- Get the fruit name based on the fruit_id
    local fruitName = getItemName(config.fruit_id) -- Assuming a function to get the item name
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Você colheu " .. count .. " " .. fruitName .. "(s).")

    -- Efeitos visuais e decay
    fromPosition:sendMagicEffect(CONST_ME_MAGIC_GREEN)
    item:transform(config.decayTo)
    item:decay()
    return true
end

-- Registrar todas as árvores com fruta
for bushId, _ in pairs(fruitBushes) do
    fruitBushSystem:id(bushId)
end

fruitBushSystem:register()