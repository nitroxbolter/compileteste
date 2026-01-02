-- Craft Channel Handler
-- Sistema de craft para comunicação com o cliente
-- Usa estrutura: cmd = "craft", model = "craft", info = {dados}
-- Integrado com 1crafting_mod.lua

local CraftChannel = {}

-- Handler para mensagens recebidas do cliente no canal de craft
function CraftChannel.handleMessage(player, data)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verifica o tipo de ação solicitada
    local action = data.action or (data.info and data.info.action)
    
    if action == "fetch" then
        -- Cliente está solicitando lista de crafts
        local category = data.info and data.info.category or (data.data and data.data.category)
        local page = data.info and data.info.page or (data.data and data.data.page) or 1
        
        if category and Crafting and Crafting[category] then
            Crafting:sendCrafts(player, category, page)
            return true
        end
    elseif action == "show" then
        -- Cliente está solicitando abertura da janela
        local category = data.info and data.info.category or (data.data and data.data.category)
        if category and Crafting and Crafting[category] then
            player:showCrafting(category)
            return true
        end
    elseif action == "craft" then
        -- Cliente está tentando fazer craft
        local category = data.info and data.info.category or (data.data and data.data.category)
        local craftId = data.info and data.info.craftId or (data.data and data.data.craftId)
        
        if category and craftId and Crafting and Crafting[category] then
            Crafting:craft(player, category, craftId)
            return true
        end
    end
    
    return false
end

-- Função auxiliar para enviar dados de craft usando OpcodeManager
function CraftChannel.sendCraftData(player, action, craftData)
    if not player or not player:isPlayer() then
        return false
    end
    
    local success = OpcodeManager.sendData(
        player,
        OpcodeManager.Config.Commands.CRAFT,
        OpcodeManager.Config.Models.CRAFT,
        craftData,
        action
    )
    
    return success
end

-- Inicializa o canal de craft
function CraftChannel.init()
    -- Verifica se OpcodeManager está disponível
    if not OpcodeManager then
        return false
    end
    
    -- Registra handler para dados de craft
    local cmd = OpcodeManager.Config.Commands.CRAFT
    local model = OpcodeManager.Config.Models.CRAFT
    local success = OpcodeManager.registerHandler(cmd, model, CraftChannel.handleMessage)
    
    return success
end

-- Inicializa automaticamente quando o arquivo é carregado
CraftChannel.init()

return CraftChannel

