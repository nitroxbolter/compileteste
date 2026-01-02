-- Sistema de títulos de guilda (visual acima dos jogadores)
-- Agora usa opcode 66 através do OpcodeManager

dofile('data/lib/opcode_manager.lua')

-- Tabela de nomes especiais com título e cor
local customTitles = {
    ["Eduardo"] = { title = "[Game Master]", color = "#f07807" },
    ["João"]    = { title = "João",          color = "#f5c367" },
    ["Maria"]   = { title = "Maria",         color = "#f5c367" }
}

-- Handler para mensagens de título de guilda via opcode 66
local function handleGuildTitleMessage(player, data)
    if not player or not player:isPlayer() then
        return false
    end
    
    local creatureID = data.info and data.info.creature
    if not creatureID then
        return false
    end
    
    local creature = Creature(creatureID)
    if not creature or not creature:isPlayer() then
        return false
    end
    
    local title = ""
    local color = "#c5f0c5" -- cor padrão
    local vipColor = "#5a85d6" -- cor exclusiva para "VIP"

    -- calcula VIP
    local expiration = creature:getAccountStorageValue(30017)
    local currentTime = os.time()
    local vipDays = 0
    
    if expiration > currentTime then
        local remainingSeconds = expiration - currentTime
        vipDays = math.floor(remainingSeconds / (24 * 60 * 60))
    end

    -- verifica se o nome está na tabela de títulos especiais
    local custom = customTitles[creature:getName()]
    if custom then
        title = custom.title
        color = custom.color
    else
        local vocation = creature:getVocation()
        if vocation then
            title = vocation:getName()
        else
            title = "Sem Vocation"
        end
    end

    -- adiciona "VIP" somente se não for customTitle
    local vipText = ""
    if vipDays > 0 and not custom then
        vipText = "VIP"
    end

    local responseData = {
        response = "SetTitle",
        creatureId = creatureID,
        title = title,
        color = color,
        vipText = vipText,
        vipColor = vipColor
    }

    -- Envia através do opcode manager usando cmd/model/info
    return OpcodeManager.sendData(
        player, 
        "guildTitle", 
        "titulo", 
        responseData
    )
end

-- Registra o handler quando o arquivo é carregado
if OpcodeManager then
    OpcodeManager.registerHandler("guildTitle", "titulo", handleGuildTitleMessage)
end
