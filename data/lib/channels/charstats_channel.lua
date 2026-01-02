-- CharStats Channel Handler
-- Sistema de stats do personagem para comunicação com o cliente
-- Usa estrutura: cmd = "charstats", model = "stats", info = {dados}
-- Integrado com character_stats.lua

local CharStatsChannel = {}

-- Handler para mensagens recebidas do cliente no canal de charstats
function CharStatsChannel.handleMessage(player, data)
    if not player or not player:isPlayer() then
        return false
    end
    
    -- Verifica o tipo de ação solicitada
    local info = data.info or {}
    local action = info.action
    
    if action == "add" then
        -- Cliente está tentando adicionar um stat
        if player.addCharacterStat and player.getStatsPoints then
            -- Chama função do character_stats.lua
            if _G.addStat then
                _G.addStat(player, info.data)
                return true
            end
        end
    elseif action == "remove" then
        -- Cliente está tentando remover um stat
        if player.addCharacterStat then
            -- Chama função do character_stats.lua
            if _G.removeStat then
                _G.removeStat(player, info.data)
                return true
            end
        end
    elseif action == "reset" then
        -- Cliente está tentando resetar os stats
        print("[CharStats Channel] Player: " .. player:getName() .. " | Action: RESET requested")
        if _G.resetStats then
            _G.resetStats(player)
            return true
        else
            print("[CharStats Channel] ERROR: _G.resetStats not found!")
        end
    elseif action == "save" then
        -- Cliente está tentando salvar os stats pendentes
        print("[CharStats Channel] Player: " .. player:getName() .. " | Action: SAVE requested")
        if _G.saveStats then
            _G.saveStats(player, info.data)
            return true
        else
            print("[CharStats Channel] ERROR: _G.saveStats not found!")
        end
    elseif action == "request" or action == "update" then
        -- Cliente está solicitando atualização dos stats
        print("[CharStats Channel] Player: " .. player:getName() .. " | Action: REQUEST/UPDATE - Sending stats data")
        if player.updateCharacterStats then
            player:updateCharacterStats()
            return true
        else
            print("[CharStats Channel] ERROR: player.updateCharacterStats not found!")
        end
    end
    
    return false
end

-- Função auxiliar para enviar dados de stats usando OpcodeManager
function CharStatsChannel.sendStatsData(player, statsData)
    if not player or not player:isPlayer() then
        return false
    end
    
    local success = OpcodeManager.sendData(
        player,
        OpcodeManager.Config.Commands.CHARSTATS,
        OpcodeManager.Config.Models.CHARSTATS,
        statsData
    )
    
    return success
end

-- Inicializa o canal de charstats
function CharStatsChannel.init()
    print("[CharStats Channel] Initializing...")
    
    -- Verifica se OpcodeManager está disponível
    if not OpcodeManager then
        print("[CharStats Channel] ERROR: OpcodeManager not available!")
        return false
    end
    
    -- Registra handler para dados de charstats
    local cmd = OpcodeManager.Config.Commands.CHARSTATS
    local model = OpcodeManager.Config.Models.CHARSTATS
    
    print("[CharStats Channel] Registering handler | cmd: " .. tostring(cmd) .. " | model: " .. tostring(model))
    
    local success = OpcodeManager.registerHandler(cmd, model, CharStatsChannel.handleMessage)
    
    if success then
        print("[CharStats Channel] Handler registered successfully!")
    else
        print("[CharStats Channel] ERROR: Failed to register handler!")
    end
    
    return success
end

-- Inicializa automaticamente quando o arquivo é carregado
print("[CharStats Channel] File loaded, calling init...")
CharStatsChannel.init()

return CharStatsChannel

