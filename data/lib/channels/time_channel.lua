-- Time Channel Handler
-- Sistema de tempo para comunicação com o cliente
-- Usa estrutura: cmd = "time", model = "tempo", info = {dados}

local TimeChannel = {}

-- Configuração do sistema de tempo
local Config = {
    -- Intervalo de atualização do tempo (em segundos)
    UPDATE_INTERVAL = 1,
    
    -- Formato de tempo (server, local, utc)
    TIME_FORMAT = "server"
}

-- Armazena os timers de atualização por player
local playerTimers = {}

-- Envia dados de tempo para o cliente
function TimeChannel.sendTimeData(player, action)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Obtém o tempo do servidor
    local serverTime = os.time()
    local serverDate = os.date("*t", serverTime)
    
    -- Obtém o tempo do Tibia (formato HH:MM)
    local tibiaMinutes = getWorldTime() -- Obtém o tempo do mundo em minutos desde 00:00
    local tibiaHours = math.floor(tibiaMinutes / 60) -- Converte minutos para horas
    local tibiaMins = tibiaMinutes % 60 -- Obtém os minutos restantes
    local tibiaTime = string.format("%02d:%02d", tibiaHours, tibiaMins) -- Formata para "HH:MM"
    
    -- Monta os dados de tempo no formato info
    local timeInfo = {
        serverTime = serverTime,
        serverDate = {
            year = serverDate.year,
            month = serverDate.month,
            day = serverDate.day,
            hour = serverDate.hour,
            min = serverDate.min,
            sec = serverDate.sec,
            wday = serverDate.wday,
            yday = serverDate.yday
        },
        tibiaTime = tibiaTime, -- Horário do Tibia formatado (HH:MM)
        tibiaMinutes = tibiaMinutes, -- Minutos totais do Tibia
        timestamp = serverTime,
        timezone = os.date("%z", serverTime)
    }
    
    -- Envia através do opcode manager usando cmd/model/info
    return OpcodeManager.sendData(
        player, 
        OpcodeManager.Config.Commands.TIME, 
        OpcodeManager.Config.Models.TIME, 
        timeInfo,
        action
    )
end

-- Inicia o sistema de atualização de tempo para um player
function TimeChannel.startTimeUpdates(player)
    if not player or not player:isPlayer() then
        return false
    end
    
    local playerId = player:getId()
    
    -- Remove timer anterior se existir
    if playerTimers[playerId] then
        stopEvent(playerTimers[playerId])
        playerTimers[playerId] = nil
    end
    
    -- Envia o tempo inicial
    TimeChannel.sendTimeData(player, 0) -- action 0 = resposta inicial
    
    -- Cria um timer recursivo para atualizar periodicamente
    local function updateTime()
        local currentPlayer = Player(playerId)
        if not currentPlayer or not currentPlayer:isPlayer() then
            -- Player desconectou, remove o timer
            if playerTimers[playerId] then
                playerTimers[playerId] = nil
            end
            return false
        end
        
        TimeChannel.sendTimeData(currentPlayer, 1) -- action 1 = update periódico
        
        -- Agenda a próxima atualização
        playerTimers[playerId] = addEvent(updateTime, Config.UPDATE_INTERVAL * 1000)
        return true
    end
    
    -- Cria o timer de atualização
    playerTimers[playerId] = addEvent(updateTime, Config.UPDATE_INTERVAL * 1000)
    
    return true
end

-- Para as atualizações de tempo para um player
function TimeChannel.stopTimeUpdates(player)
    if not player or not player:isPlayer() then
        return false
    end
    
    local playerId = player:getId()
    
    if playerTimers[playerId] then
        stopEvent(playerTimers[playerId])
        playerTimers[playerId] = nil
        return true
    end
    
    return false
end

-- Handler para mensagens recebidas do cliente no canal de tempo
function TimeChannel.handleMessage(player, data)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verifica o tipo de ação solicitada (pode vir em action ou info.action)
    local action = data.action or (data.info and data.info.action)
    
    if action == "request" or action == 0 then
        -- Cliente está solicitando o tempo atual
        TimeChannel.sendTimeData(player, 0)
        return true
    elseif action == "start" or action == 1 then
        -- Cliente quer iniciar atualizações periódicas
        TimeChannel.startTimeUpdates(player)
        return true
    elseif action == "stop" or action == 2 then
        -- Cliente quer parar atualizações periódicas
        TimeChannel.stopTimeUpdates(player)
        return true
    else
        -- Se não tem action, assume request
        TimeChannel.sendTimeData(player, 0)
        return true
    end
end

-- Limpa timers quando o player desconecta
function TimeChannel.onLogout(player)
    if player and player:isPlayer() then
        TimeChannel.stopTimeUpdates(player)
    end
end

-- Inicializa o canal de tempo
function TimeChannel.init()
    -- Verifica se OpcodeManager está disponível
    if not OpcodeManager then
        print("[SERVER DEBUG] ERRO: OpcodeManager não está disponível!")
        return false
    end
    
    -- Obtém os valores de cmd e model
    local cmd = OpcodeManager.Config.Commands.TIME
    local model = OpcodeManager.Config.Models.TIME
    
    -- Registra o handler no opcode manager usando cmd/model
    local success = OpcodeManager.registerHandler(cmd, model, TimeChannel.handleMessage)
    
    if not success then
        print("[SERVER DEBUG] ERRO: Falha ao registrar handler de tempo!")
    end
    
    return success
end

-- Inicializa automaticamente quando o arquivo é carregado
TimeChannel.init()

