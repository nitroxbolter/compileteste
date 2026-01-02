-- Character Channel Handler
-- Sistema de informações do personagem para comunicação com o cliente
-- Usa estrutura: cmd = "character", model = "personagem", info = {dados}
-- Também gerencia atributos de itens: cmd = "items", model = "atributos"

local CharacterChannel = {}

-- Função para obter dados dos itens (será definida quando character_attributes.lua for carregado)
local getAllEquippedItemsDataForClient = nil

-- Envia dados do personagem para o cliente
function CharacterChannel.sendCharacterData(player, action)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Coleta informações básicas do personagem
    local characterInfo = {
        name = player:getName(),
        level = player:getLevel() or 0,
        experience = player:getExperience() or 0,
        magicLevel = player:getMagicLevel() or 0,
        health = player:getHealth() or 0,
        maxHealth = player:getMaxHealth() or 0,
        mana = player:getMana() or 0,
        maxMana = player:getMaxMana() or 0,
        capacity = player:getCapacity() or 0,
        freeCapacity = player:getFreeCapacity() or 0,
        soul = player:getSoul() or 0,
        stamina = player:getStamina() or 0,
        vocation = player:getVocation():getName() or "",
        vocationId = player:getVocation():getId() or 0,
        town = player:getTown():getName() or "",
        townId = player:getTown():getId() or 0,
        balance = player:getBankBalance() or 0,
        premiumDays = player:getPremiumDays() or 0,
        skills = {},
        position = {
            x = player:getPosition().x or 0,
            y = player:getPosition().y or 0,
            z = player:getPosition().z or 0
        },
        outfit = {
            lookType = player:getOutfit().lookType or 0,
            lookHead = player:getOutfit().lookHead or 0,
            lookBody = player:getOutfit().lookBody or 0,
            lookLegs = player:getOutfit().lookLegs or 0,
            lookFeet = player:getOutfit().lookFeet or 0,
            lookAddons = player:getOutfit().lookAddons or 0
        }
    }
    
    -- Coleta skills
    local skillIds = {
        SKILL_FIST,
        SKILL_CLUB,
        SKILL_SWORD,
        SKILL_AXE,
        SKILL_DISTANCE,
        SKILL_SHIELD,
        SKILL_FISHING
    }
    
    local skillNames = {
        [SKILL_FIST] = "fist",
        [SKILL_CLUB] = "club",
        [SKILL_SWORD] = "sword",
        [SKILL_AXE] = "axe",
        [SKILL_DISTANCE] = "distance",
        [SKILL_SHIELD] = "shielding",
        [SKILL_FISHING] = "fishing"
    }
    
    for _, skillId in ipairs(skillIds) do
        local skillName = skillNames[skillId]
        if skillName then
            local skillLevel = 0
            local skillPercent = 0
            
            local success, result = pcall(function()
                if player.getSkillLevel then
                    return player:getSkillLevel(skillId)
                end
                return nil
            end)
            
            if success and result then
                skillLevel = result
            end
            
            local successPercent, resultPercent = pcall(function()
                if player.getSkillLevelPercent then
                    return player:getSkillLevelPercent(skillId)
                end
                return nil
            end)
            
            if successPercent and resultPercent then
                skillPercent = resultPercent
            end
            
            characterInfo.skills[skillName] = {
                level = skillLevel,
                percent = skillPercent
            }
        end
    end
    
    -- Envia através do opcode manager usando cmd/model/info
    return OpcodeManager.sendData(
        player, 
        OpcodeManager.Config.Commands.CHARACTER, 
        OpcodeManager.Config.Models.CHARACTER, 
        characterInfo,
        action
    )
end

-- Handler para mensagens recebidas do cliente no canal de character
function CharacterChannel.handleMessage(player, data)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verifica o tipo de ação solicitada
    local action = data.action or (data.info and data.info.action)
    
    if action == "request" or action == 0 or not action then
        -- Cliente está solicitando os dados do personagem
        CharacterChannel.sendCharacterData(player, 0)
        return true
    end
    
    return false
end

-- Envia dados de atributos dos itens equipados para o cliente
function CharacterChannel.sendItemsData(player, action)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verifica se a função está disponível (carregada pelo character_attributes.lua)
    local func = getAllEquippedItemsDataForClient
    if not func and _G.getAllEquippedItemsDataForClient then
        func = _G.getAllEquippedItemsDataForClient
    end
    
    if not func then
        return false
    end
    
    -- Obter dados de todos os itens equipados
    local success, itemsData = pcall(function()
        return func(player)
    end)
    
    if not success or not itemsData then
        itemsData = {}
    end
    
    -- Preparar dados no formato info
    local itemsInfo = {
        action = "items_attributes",
        items = itemsData
    }
    
    -- Envia através do opcode manager usando cmd/model/info
    return OpcodeManager.sendData(
        player, 
        OpcodeManager.Config.Commands.ITEMS, 
        OpcodeManager.Config.Models.ITEMS, 
        itemsInfo,
        action
    )
end

-- Handler para mensagens de atributos de itens
function CharacterChannel.handleItemsMessage(player, data)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verifica o tipo de ação solicitada
    local action = data.action or (data.info and data.info.action)
    
    if action == "requestAttributes" or action == "request" or action == 0 or not action then
        -- Cliente está solicitando os dados dos itens
        CharacterChannel.sendItemsData(player, 0)
        return true
    end
    
    return false
end

-- Inicializa o canal de character
function CharacterChannel.init()
    -- Verifica se OpcodeManager está disponível
    if not OpcodeManager then
        return false
    end
    
    -- Registra handler para dados do personagem
    local cmd = OpcodeManager.Config.Commands.CHARACTER
    local model = OpcodeManager.Config.Models.CHARACTER
    local success1 = OpcodeManager.registerHandler(cmd, model, CharacterChannel.handleMessage)
    
    -- Registra handler para atributos de itens
    local itemsCmd = OpcodeManager.Config.Commands.ITEMS
    local itemsModel = OpcodeManager.Config.Models.ITEMS
    local success2 = OpcodeManager.registerHandler(itemsCmd, itemsModel, CharacterChannel.handleItemsMessage)
    
    return success1 and success2
end

-- Inicializa automaticamente quando o arquivo é carregado
CharacterChannel.init()

