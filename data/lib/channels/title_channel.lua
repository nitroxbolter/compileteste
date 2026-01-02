-- Title Channel Handler
-- Sistema de títulos para comunicação com o cliente
-- Usa estrutura: cmd = "title", model = "titulo", info = {dados}
-- Integrado com systemTitle.lua

local TitleChannel = {}

-- Tabela de nomes especiais com título e cor (mesma do systemTitle.lua)
local customTitles = {
    ["Eduardo"] = { title = "[Game Master]", color = "#f07807" },
    ["João"]    = { title = "João",          color = "#f5c367" },
    ["Maria"]   = { title = "Maria",         color = "#f5c367" }
}

-- Função auxiliar para calcular VIP
local function getVipDays(player)
    local expiration = player:getAccountStorageValue(30017)
    local currentTime = os.time()
    local vipDays = 0
    
    if expiration > currentTime then
        local remainingSeconds = expiration - currentTime
        vipDays = math.floor(remainingSeconds / (24 * 60 * 60))
    end
    
    return vipDays
end

-- Função auxiliar para obter título do jogador
local function getPlayerTitle(player)
    local title = ""
    local color = "#c5f0c5" -- cor padrão
    local vipColor = "#5a85d6" -- cor exclusiva para "VIP"
    
    -- Calcula VIP
    local vipDays = getVipDays(player)
    
    -- Verifica se o nome está na tabela de títulos especiais
    local custom = customTitles[player:getName()]
    if custom then
        title = custom.title
        color = custom.color
    else
        local vocation = player:getVocation()
        if vocation then
            title = vocation:getName()
        else
            title = "Sem Vocation"
        end
    end
    
    -- Adiciona "VIP" somente se não for customTitle
    local vipText = ""
    if vipDays > 0 and not custom then
        vipText = "VIP"
    end
    
    return {
        title = title,
        color = color,
        vipText = vipText,
        vipColor = vipColor,
        vipDays = vipDays,
        isCustom = custom ~= nil
    }
end

-- Envia dados de título para o cliente
function TitleChannel.sendTitleData(player, action)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Obtém informações do título usando a mesma lógica do systemTitle.lua
    local titleData = getPlayerTitle(player)
    
    -- Coleta informações do título do personagem
    local titleInfo = {
        currentTitle = titleData.title,
        titleColor = titleData.color,
        vipText = titleData.vipText,
        vipColor = titleData.vipColor,
        vipDays = titleData.vipDays,
        isCustom = titleData.isCustom,
        availableTitles = {}, -- Lista de títulos disponíveis (pode ser expandida)
        titleId = 0 -- ID do título atual (pode ser usado para seleção de títulos)
    }
    
    -- Exemplo de títulos disponíveis (ajuste conforme necessário)
    -- Você pode buscar isso de um banco de dados ou storage
    titleInfo.availableTitles = {
        {id = 1, name = "Novato", description = "Título para iniciantes", color = "#c5f0c5"},
        {id = 2, name = "Veterano", description = "Título para jogadores experientes", color = "#f5c367"},
        {id = 3, name = "Lendário", description = "Título para grandes conquistas", color = "#f07807"}
    }
    
    -- Envia através do opcode manager usando cmd/model/info
    local success = OpcodeManager.sendData(
        player, 
        OpcodeManager.Config.Commands.TITLE, 
        OpcodeManager.Config.Models.TITLE, 
        titleInfo,
        action
    )
    
    return success
end

-- Handler para mensagens recebidas do cliente no canal de título
function TitleChannel.handleMessage(player, data)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verifica o tipo de ação solicitada
    local action = data.action or (data.info and data.info.action)
    
    if action == "request" or action == 0 or not action then
        -- Cliente está solicitando os dados do título
        TitleChannel.sendTitleData(player, 0)
        return true
    elseif action == "set" or action == "change" then
        -- Cliente está tentando alterar o título
        local titleId = data.info and data.info.titleId
        if titleId then
            -- Storage para título: 50000 (ajuste conforme necessário)
            local STORAGE_TITLE_ID = 50000
            local STORAGE_TITLE_NAME = 50001
            
            -- Lista de títulos disponíveis (mesma do sendTitleData)
            local availableTitles = {
                {id = 1, name = "Novato", description = "Título para iniciantes"},
                {id = 2, name = "Veterano", description = "Título para jogadores experientes"},
                {id = 3, name = "Lendário", description = "Título para grandes conquistas"}
            }
            
            -- Aqui você pode validar se o jogador tem acesso a este título
            -- Por enquanto, apenas aplica o título
            player:setStorageValue(STORAGE_TITLE_ID, titleId)
            
            -- Busca o nome do título na lista de títulos disponíveis
            local titleName = ""
            for _, title in ipairs(availableTitles) do
                if title.id == titleId then
                    titleName = title.name
                    break
                end
            end
            
            if titleName ~= "" then
                player:setStorageValue(STORAGE_TITLE_NAME, titleName)
            end
            
            -- Depois envia os dados atualizados
            TitleChannel.sendTitleData(player, 0)
            return true
        end
    end
    
    return false
end

-- Inicializa o canal de título
function TitleChannel.init()
    -- Verifica se OpcodeManager está disponível
    if not OpcodeManager then
        return false
    end
    
    -- Registra handler para dados de título
    local cmd = OpcodeManager.Config.Commands.TITLE
    local model = OpcodeManager.Config.Models.TITLE
    local success = OpcodeManager.registerHandler(cmd, model, TitleChannel.handleMessage)
    
    return success
end

-- Inicializa automaticamente quando o arquivo é carregado
TitleChannel.init()

