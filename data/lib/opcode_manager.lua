-- Opcode Manager Library
-- Sistema unificado para gerenciar comunicação JSON com o cliente usando um único opcode
-- Estrutura: cmd (comando) -> model (sistema) -> info (dados)

-- Configuração
local Config = {
    -- Opcode principal para comunicação JSON
    OPCODE_MAIN = 66,
    
    -- Comandos disponíveis
    Commands = {
        ATTRIBUTE = "atribute",
        CHAT_NPC = "chatNPC",
        TIME = "time",
        CHARACTER = "character",
        ITEMS = "items",
        TITLE = "title",
        GUILD_TITLE = "guildTitle",
        CRAFT = "craft",
        CHARSTATS = "charstats",
        -- Outros comandos serão adicionados aqui no futuro
    },
    
    -- Models disponíveis para cada comando
    Models = {
        TIME = "tempo",
        CRAFT = "craft",
        TIER = "tier",
        CHARACTER = "personagem",
        ITEMS = "atributos",
        TITLE = "titulo",
        CHARSTATS = "stats",
        -- Outros models serão adicionados aqui no futuro
    }
}

-- Tabela de handlers: [cmd][model] = handler
-- Usa variável global para persistir entre carregamentos
if not _G.CommandHandlers then
    _G.CommandHandlers = {}
end
local CommandHandlers = _G.CommandHandlers

-- Registra um handler para um comando e model específicos
function registerHandler(cmd, model, handler)
    if not cmd or not model or not handler then
        print("[OpcodeManager] Erro: cmd, model ou handler inválido")
        return false
    end
    
    if not CommandHandlers[cmd] then
        CommandHandlers[cmd] = {}
    end
    
    CommandHandlers[cmd][model] = handler
    return true
end

-- Remove um handler
function unregisterHandler(cmd, model)
    if CommandHandlers[cmd] and CommandHandlers[cmd][model] then
        CommandHandlers[cmd][model] = nil
        return true
    end
    return false
end

-- Envia dados JSON para o cliente
-- cmd: tipo de comando (atribute, chatNPC, time, etc)
-- model: subcategoria (tempo, craft, tier, etc)
-- info: tabela com os dados específicos
-- action: ação opcional (para compatibilidade)
function sendData(player, cmd, model, info, action)
    if not player or not player:isPlayer() then
        print("[OpcodeManager] Erro: Player inválido")
        return false
    end
    
    if not cmd then
        print("[OpcodeManager] Erro: cmd não especificado")
        return false
    end
    
    -- Monta o payload seguindo o padrão: cmd, model, info, action
    local payload = {
        cmd = cmd,
        model = model,
        info = info or {},
    }
    
    -- Adiciona action se fornecida
    if action then
        payload.action = action
    end
    
    -- Converte para JSON
    local status, jsonData = pcall(json.encode, payload)
    if not status then
        print("[OpcodeManager] Erro ao codificar JSON: " .. tostring(jsonData))
        return false
    end
    
    -- Envia o opcode
    player:sendExtendedOpcode(Config.OPCODE_MAIN, jsonData)
    return true
end

-- Processa mensagens recebidas do cliente
function processMessage(player, buffer)
    if not player or not player:isPlayer() then
        print("[OpcodeManager] ERROR: Invalid player")
        return false
    end
    
    -- Tenta decodificar o JSON
    local status, payload = pcall(json.decode, buffer)
    if not status or not payload then
        print("[OpcodeManager] Erro ao decodificar JSON do cliente: " .. tostring(buffer))
        return false
    end
    
    -- Debug: Mostra o payload recebido
    print("[OpcodeManager] Player: " .. player:getName() .. " | Received payload | cmd: " .. tostring(payload.cmd) .. " | model: " .. tostring(payload.model) .. " | action: " .. tostring(payload.info and payload.info.action))
    
    -- Verifica se tem cmd especificado
    local cmd = payload.cmd
    if not cmd then
        print("[OpcodeManager] Erro: cmd n�o especificado na mensagem")
        return false
    end
    
    -- Verifica se tem model especificado
    local model = payload.model
    if not model then
        print("[OpcodeManager] Erro: model n�o especificado na mensagem")
        return false
    end
    
    -- Verifica se existe handler para este cmd/model
    if not CommandHandlers[cmd] or not CommandHandlers[cmd][model] then
        print("[OpcodeManager] ERROR: No handler found for cmd: " .. tostring(cmd) .. ", model: " .. tostring(model))
        print("[OpcodeManager] Available handlers:")
        for c, models in pairs(CommandHandlers) do
            for m, _ in pairs(models) do
                print("[OpcodeManager]   - cmd: " .. tostring(c) .. ", model: " .. tostring(m))
            end
        end
        return false
    end
    
    local handler = CommandHandlers[cmd][model]
    
    -- Prepara os dados para o handler
    local handlerData = {
        info = payload.info or {},
        action = payload.action,
        data = payload.data or payload.info or {} -- compatibilidade com estrutura antiga
    }
    
    -- Chama o handler
    local success, result = pcall(handler, player, handlerData)
    if not success then
        print("[OpcodeManager] Erro no handler cmd: " .. tostring(cmd) .. ", model: " .. tostring(model) .. ": " .. tostring(result))
        return false
    end
    
    return true
end

-- Retorna o opcode principal (útil para registro de eventos)
function getMainOpcode()
    return Config.OPCODE_MAIN
end

-- Retorna os comandos disponíveis
function getAvailableCommands()
    return Config.Commands
end

-- Retorna os models disponíveis
function getAvailableModels()
    return Config.Models
end

-- Função de compatibilidade (mantém suporte à estrutura antiga)
function sendChannelData(player, channel, data)
    -- Mapeia channel antigo para cmd/model novo
    if channel == "time" then
        return sendData(player, Config.Commands.TIME, Config.Models.TIME, data)
    end
    print("[OpcodeManager] Aviso: sendChannelData está obsoleto, use sendData com cmd/model")
    return false
end

-- Função de compatibilidade (mantém suporte à estrutura antiga)
function processChannelMessage(player, buffer)
    return processMessage(player, buffer)
end

-- Exporta funções principais
OpcodeManager = {
    registerHandler = registerHandler,
    unregisterHandler = unregisterHandler,
    sendData = sendData,
    processMessage = processMessage,
    getMainOpcode = getMainOpcode,
    getAvailableCommands = getAvailableCommands,
    getAvailableModels = getAvailableModels,
    -- Funções de compatibilidade
    sendChannelData = sendChannelData,
    processChannelMessage = processChannelMessage,
    Config = Config
}

-- Debug removido - apenas inicializa silenciosamente

