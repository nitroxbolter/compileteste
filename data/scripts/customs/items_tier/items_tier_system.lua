-- Sistema de Tier para Todos os Itens
-- Envia tier de itens em containers via Extended Opcode quando solicitado pelo cliente

dofile('data/lib/core/tier_ability_config.lua')

-- Opcode para comunicação de tier de itens (usando o mesmo do character para simplificar)
local OPCODE_ITEMS_TIER = 151

-- Função para obter tier de um item
local function getItemTierData(item)
  if not item then
    return nil
  end
  
  local tier = TierSystem.getItemTier(item)
  if tier and tier > 0 then
    return {
      id = item:getId(),
      tier = tier
    }
  end
  
  return nil
end

-- Função para coletar tier de todos os itens de um container
local function getContainerItemsTier(container)
  if not container then
    return {}
  end
  
  local itemsTier = {}
  
  for i = 0, container:getSize() - 1 do
    local item = container:getItem(i)
    if item then
      local tierData = getItemTierData(item)
      if tierData then
        -- Usar slot como chave
        itemsTier[tostring(i)] = tierData
      end
    end
  end
  
  return itemsTier
end

-- Handler de Extended Opcode para responder solicitações de tier de containers
local ItemsTierExtended = CreatureEvent("ItemsTierExtended")

function ItemsTierExtended.onExtendedOpcode(player, opcode, buffer)
  -- Só processar se for o opcode correto
  if opcode ~= OPCODE_ITEMS_TIER then
    return true
  end
  
  -- Tentar decodificar JSON
  local success, data = pcall(function() return json.decode(buffer) end)
  
  if not success or not data then
    return true
  end
  
  -- Verificar se é uma solicitação de tier de container
  if data.action == "requestContainerTier" and data.containerId then
    local containerId = tonumber(data.containerId)
    if containerId then
      local container = player:getContainerByID(containerId)
      if container then
        local itemsTier = getContainerItemsTier(container)
        
        local response = {
          action = "container_items_tier",
          containerId = containerId,
          items = itemsTier
        }
        
        local encodeSuccess, jsonString = pcall(function() return json.encode(response) end)
        if encodeSuccess then
          player:sendExtendedOpcode(OPCODE_ITEMS_TIER, jsonString)
        end
      end
    end
  end
  
  return true
end

ItemsTierExtended:type("extendedopcode")
ItemsTierExtended:register()

-- Evento de login para registrar o extended opcode
local ItemsTierLoginEvent = CreatureEvent("ItemsTierLoginEvent")

function ItemsTierLoginEvent.onLogin(player)
  player:registerEvent("ItemsTierExtended")
  return true
end

ItemsTierLoginEvent:type("login")
ItemsTierLoginEvent:register()

print(">> Items Tier System Loaded")

