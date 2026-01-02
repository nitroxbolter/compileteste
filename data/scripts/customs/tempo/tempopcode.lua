dofile('data/lib/core/json.lua')
dofile('data/lib/opcode_manager.lua')

local CODE_JSON_TEST = OpcodeManager.getMainOpcode() -- Usa o opcode 66 da lib 

local ExtendedEvent = CreatureEvent("JsonTestExtended")

function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == CODE_JSON_TEST then
    local status, json_data = pcall(function()
      return json.decode(buffer)
    end)

    if not status then
      return false
    end
    
    -- Se a mensagem está no formato novo (cmd/model), não processa aqui
    -- Deixa o evento OpcodeManager processar
    if json_data and json_data.cmd and json_data.model then
      return false -- Retorna false para que outros eventos (OpcodeManager) possam processar
    end
    
    -- Compatibilidade com formato antigo (request = "time")
    if json_data and json_data.request == "time" then
      local tibiaTime = getTibiaServerTime()
      local timeData = {
        status = "time_update",
        message = tibiaTime
      }
      player:sendExtendedOpcode(CODE_JSON_TEST, json.encode(timeData))
      return true
    end
    
    return false
  end
  return false
end
ExtendedEvent:type("extendedopcode")
ExtendedEvent:register()

local LoginEvent = CreatureEvent("JsonTestLogin")

function LoginEvent.onLogin(player)
  player:registerEvent("JsonTestExtended")
  return true
end
LoginEvent:type("login")
LoginEvent:register()

-- Função para converter o tempo do Tibia (TFS) para HH:MM
function getTibiaServerTime()
  local minutes = getWorldTime() -- Obtém o tempo do mundo em minutos desde 00:00
  local hours = math.floor(minutes / 60) -- Converte minutos para horas
  local mins = minutes % 60 -- Obtém os minutos restantes
  return string.format("%02d:%02d", hours, mins) -- Formata para "HH:MM"
end

-- Função para enviar o horário do Tibia para todos os jogadores a cada minuto
function sendTibiaTimeToClients()
  local tibiaTime = getTibiaServerTime()
  local timeData = {
    status = "time_update",
    message = tibiaTime
  }
  local timeDataJson = json.encode(timeData)
  
  for _, player in pairs(Game.getPlayers()) do
    if player and not player:isRemoved() then
      player:sendExtendedOpcode(CODE_JSON_TEST, timeDataJson)
    end
  end

  addEvent(sendTibiaTimeToClients, 60 * 1000) -- Chama novamente após 60 segundos
end

-- Inicia o envio do horário ao carregar o script
sendTibiaTimeToClients()
