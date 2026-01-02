-- Script para exibir automaticamente atributos de itens equipados
-- Exibe quando o jogador loga e quando itens são equipados

dofile('data/lib/opcode_manager.lua')

-- Mapeamento de tipos de combate para nomes legíveis
local combatTypeNames = {
  [COMBAT_PHYSICALDAMAGE] = "Physical",
  [COMBAT_ENERGYDAMAGE] = "Energy",
  [COMBAT_EARTHDAMAGE] = "Earth",
  [COMBAT_FIREDAMAGE] = "Fire",
  [COMBAT_ICEDAMAGE] = "Ice",
  [COMBAT_HOLYDAMAGE] = "Holy",
  [COMBAT_DEATHDAMAGE] = "Death",
  [COMBAT_WATERDAMAGE] = "Water",
  [COMBAT_ARCANEDAMAGE] = "Arcane",
  [COMBAT_DROWNDAMAGE] = "Drown",
  [COMBAT_LIFEDRAIN] = "Life Drain",
  [COMBAT_MANADRAIN] = "Mana Drain",
}

-- Mapeamento de skills para nomes legíveis
local skillNames = {
  [SKILL_FIST] = "Fist Fighting",
  [SKILL_CLUB] = "Club Fighting",
  [SKILL_SWORD] = "Sword Fighting",
  [SKILL_AXE] = "Axe Fighting",
  [SKILL_DISTANCE] = "Distance Fighting",
  [SKILL_SHIELD] = "Shielding",
  [SKILL_FISHING] = "Fishing",
  [SKILL_CRAFTING] = "Crafting",
  [SKILL_MINING] = "Mining",
  [SKILL_WOODCUTTING] = "Woodcutting",
  [SKILL_HERBALIST] = "Herbalist",
  [SKILL_ARMORSMITH] = "Armorsmith",
  [SKILL_WEAPONSMITH] = "Weaponsmith",
  [SKILL_JEWELSMITH] = "Jewelsmith",
}

-- Função auxiliar para obter nome do tipo de combate pelo índice
local function getCombatNameByIndex(index)
  -- Mapeamento de índices para tipos de combate
  local combatTypes = {
    COMBAT_PHYSICALDAMAGE,
    COMBAT_ENERGYDAMAGE,
    COMBAT_EARTHDAMAGE,
    COMBAT_FIREDAMAGE,
    COMBAT_UNDEFINEDDAMAGE,
    COMBAT_LIFEDRAIN,
    COMBAT_MANADRAIN,
    COMBAT_HEALING,
    COMBAT_DROWNDAMAGE,
    COMBAT_ICEDAMAGE,
    COMBAT_HOLYDAMAGE,
    COMBAT_DEATHDAMAGE,
    COMBAT_WATERDAMAGE,
    COMBAT_ARCANEDAMAGE,
  }
  
  if combatTypes[index + 1] then
    return combatTypeNames[combatTypes[index + 1]] or "Unknown"
  end
  return "Unknown"
end

-- Função para exibir atributos de um item (simplificada)
local function displayItemAttributes(item, slotName)
  if not item then
    return
  end
  
  local itemId = item:getId()
  local itemName = item:getName()
  
  -- Print removido para evitar spam no console
end

-- Função para exibir todos os itens equipados
local function displayAllEquippedItems(player)
  if not player then
    return
  end
  
  local slotNames = {
    [CONST_SLOT_HEAD] = "Head",
    [CONST_SLOT_NECKLACE] = "Necklace",
    [CONST_SLOT_BACKPACK] = "Backpack",
    [CONST_SLOT_ARMOR] = "Armor",
    [CONST_SLOT_RIGHT] = "Right Hand",
    [CONST_SLOT_LEFT] = "Left Hand",
    [CONST_SLOT_LEGS] = "Legs",
    [CONST_SLOT_FEET] = "Feet",
    [CONST_SLOT_RING] = "Ring",
    [CONST_SLOT_AMMO] = "Ammo",
    [CONST_SLOT_DECK] = "Deck",
    [CONST_SLOT_BADGE] = "Badge",
    [CONST_SLOT_SHIP] = "Ship",
    [CONST_SLOT_BELT] = "Belt",
    [CONST_SLOT_GLOVES] = "Gloves",
  }
  
  for slot, slotName in pairs(slotNames) do
    local item = player:getSlotItem(slot)
    if item then
      displayItemAttributes(item, slotName)
    end
  end
end

-- Função para limpar tabela de valores nil e garantir compatibilidade com JSON
local function cleanTableForJSON(tbl)
  if type(tbl) ~= "table" then
    return tbl
  end
  
  local cleaned = {}
  local hasStringKeys = false
  local hasNumericKeys = false
  local maxNumericIndex = 0
  local numericKeyCount = 0
  
  -- Verificar tipos de chaves
  for k, v in pairs(tbl) do
    if type(k) == "string" then
      hasStringKeys = true
    elseif type(k) == "number" then
      hasNumericKeys = true
      numericKeyCount = numericKeyCount + 1
      if k > maxNumericIndex then
        maxNumericIndex = k
      end
    end
  end
  
  -- Se tem chaves string OU chaves numéricas não-sequenciais, é um objeto
  local isArray = hasNumericKeys and not hasStringKeys and maxNumericIndex == numericKeyCount and maxNumericIndex > 0
  
  if isArray then
    -- É um array, manter como array
    for i = 1, maxNumericIndex do
      if tbl[i] ~= nil then
        if type(tbl[i]) == "table" then
          cleaned[i] = cleanTableForJSON(tbl[i])
        else
          cleaned[i] = tbl[i]
        end
      end
    end
  else
    -- É um objeto, processar todas as chaves
    for k, v in pairs(tbl) do
      if v ~= nil then
        if type(v) == "table" then
          cleaned[k] = cleanTableForJSON(v)
        else
          cleaned[k] = v
        end
      end
    end
  end
  
  return cleaned
end

-- Função para coletar atributos de um item e retornar como tabela
local function getItemAttributesData(item, slotName)
  if not item then
    return nil
  end
  
  local itemData = {
    slot = slotName,
    id = item:getId(),
    name = item:getName(),
    attributes = {},
    rarityAttributes = {}
  }
  
  local itemType = item:getType()
  if not itemType then
    return itemData
  end
  
  -- Tier (Custom Attribute)
  local tierAttr = item:getCustomAttribute("tier")
  if tierAttr then
    local tier = 0
    if type(tierAttr) == "number" then
      tier = tierAttr
    else
      tier = tonumber(tierAttr) or 0
    end
    if tier > 0 then
      itemData.tier = tier
    end
  end
  
  -- Atributos básicos
  local attack = itemType:getAttack()
  if attack and attack > 0 then
    table.insert(itemData.attributes, {type = "attack", value = attack})
  end
  
  local defense = itemType:getDefense()
  if defense and defense > 0 then
    table.insert(itemData.attributes, {type = "defense", value = defense})
  end
  
  local extraDefense = itemType:getExtraDefense()
  if extraDefense and extraDefense > 0 then
    table.insert(itemData.attributes, {type = "extraDefense", value = extraDefense})
  end
  
  local armor = itemType:getArmor()
  if armor and armor > 0 then
    table.insert(itemData.attributes, {type = "armor", value = armor})
  end
  
  -- Raridade
  local success, rarity = pcall(function() return item:getRarity() end)
  if success and rarity and rarity > 0 then
    itemData.rarity = rarity
    
    -- Obter atributos de raridade
    local successAttrs, rarityAttrs = pcall(function() 
      if item.getRarityAttributes then
        return item:getRarityAttributes()
      end
      return nil
    end)
    
    if successAttrs and rarityAttrs and type(rarityAttrs) == "table" then
      for _, attr in ipairs(rarityAttrs) do
        local attrId = attr.id
        local value = attr.value
        local types = attr.types
        
        if value and value ~= 0 then
          local attrData = {
            id = attrId,
            value = value
          }
          
          if types and #types > 0 then
            attrData.types = {}
            for _, typeValue in ipairs(types) do
              table.insert(attrData.types, typeValue)
            end
          end
          
          table.insert(itemData.rarityAttributes, attrData)
        end
      end
    end
  end
  
  return itemData
end

-- Função para converter atributos de raridade para o formato esperado pelo cliente
local function convertRarityAttributesToClientFormat(rarityAttributes)
  if not rarityAttributes or #rarityAttributes == 0 then
    return {}
  end
  
  local converted = {}
  
  for _, attr in ipairs(rarityAttributes) do
    local attrId = attr.id
    local value = attr.value
    local types = attr.types
    
    if attrId and value and value ~= 0 then
      -- Usar string como chave para evitar problemas com JSON encoder
      -- O cliente converte de volta para número
      local attrIdStr = tostring(attrId)
      
      -- Inicializar array para este attrId se não existir
      if not converted[attrIdStr] then
        converted[attrIdStr] = {}
      end
      
      -- Se tem tipos (resistências, skills, stats), criar uma entrada para cada tipo
      if types and #types > 0 then
        for _, typeValue in ipairs(types) do
          local attrEntry = {
            id = attrId,
            value = value,
            type = typeValue
            }
          table.insert(converted[attrIdStr], attrEntry)
        end
      else
        -- Atributo sem tipo específico - não incluir type se for nil
        local attrEntry = {
          id = attrId,
          value = value
        }
        table.insert(converted[attrIdStr], attrEntry)
      end
    end
  end
  
  return converted
end

-- Função para coletar atributos de todos os itens equipados no formato esperado pelo cliente
-- Torna global para ser acessível pelo CharacterChannel
function getAllEquippedItemsDataForClient(player)
  if not player then
    return {}
  end
  
  local itemsData = {}
  local slotNames = {
    [CONST_SLOT_HEAD] = "Head",
    [CONST_SLOT_NECKLACE] = "Necklace",
    [CONST_SLOT_BACKPACK] = "Backpack",
    [CONST_SLOT_ARMOR] = "Armor",
    [CONST_SLOT_RIGHT] = "Right Hand",
    [CONST_SLOT_LEFT] = "Left Hand",
    [CONST_SLOT_LEGS] = "Legs",
    [CONST_SLOT_FEET] = "Feet",
    [CONST_SLOT_RING] = "Ring",
    [CONST_SLOT_AMMO] = "Ammo",
    [CONST_SLOT_DECK] = "Deck",
    [CONST_SLOT_BADGE] = "Badge",
    [CONST_SLOT_SHIP] = "Ship",
    [CONST_SLOT_BELT] = "Belt",
    [CONST_SLOT_GLOVES] = "Gloves",
  }
  
  for slot, slotName in pairs(slotNames) do
    local item = player:getSlotItem(slot)
    if item then
      local rawItemData = getItemAttributesData(item, slotName)
      if rawItemData then
        -- Converter para formato esperado pelo cliente
        local itemData = {
          id = rawItemData.id,
          name = rawItemData.name,
          attributes = convertRarityAttributesToClientFormat(rawItemData.rarityAttributes)
        }
        
        -- Adicionar tier se existir
        if rawItemData.tier and rawItemData.tier > 0 then
          itemData.tier = rawItemData.tier
        end
        
        -- Adicionar atributos básicos se existirem
        if rawItemData.attributes and #rawItemData.attributes > 0 then
          -- Mapear atributos básicos para IDs de tooltip
          for _, attr in ipairs(rawItemData.attributes) do
            local attrId = nil
            if attr.type == "attack" then
              attrId = TOOLTIP_ATTRIBUTE_ATTACK
            elseif attr.type == "defense" then
              attrId = TOOLTIP_ATTRIBUTE_DEFENSE
            elseif attr.type == "extraDefense" then
              attrId = TOOLTIP_ATTRIBUTE_EXTRADEFENSE
            elseif attr.type == "armor" then
              attrId = TOOLTIP_ATTRIBUTE_ARMOR
            end
            
            if attrId then
              -- Usar string como chave para evitar problemas com JSON encoder
              local attrIdStr = tostring(attrId)
              if not itemData.attributes[attrIdStr] then
                itemData.attributes[attrIdStr] = {}
              end
              -- Não incluir type se for nil
              local attrEntry = {
                id = attrId,
                value = attr.value
              }
              table.insert(itemData.attributes[attrIdStr], attrEntry)
            end
          end
        end
        
        -- Usar slot como chave (string)
        itemsData[tostring(slot)] = itemData
      end
    end
  end
  
  return itemsData
end


-- Função para enviar atributos atualizados para o cliente
local function sendUpdatedAttributesToClient(player)
  if not player or not player:isPlayer() then
    return
  end
  
  -- Usa o CharacterChannel para enviar os dados dos itens
  if CharacterChannel and CharacterChannel.sendItemsData then
    CharacterChannel.sendItemsData(player, 0)
  end
end

-- Evento para detectar quando item é equipado ou desequipado e enviar dados atualizados
local ec = EventCallback

ec.onMoveItem = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
  local player = self
  local wasEquipped = false
  local wasUnequipped = false
  
  -- Verificar se o item foi movido PARA um slot de equipamento
  if toPosition.x == CONTAINER_POSITION and bit.band(toPosition.y, 0x40) == 0 then
    local slot = toPosition.y
    local slotNames = {
      [CONST_SLOT_HEAD] = "Head",
      [CONST_SLOT_NECKLACE] = "Necklace",
      [CONST_SLOT_BACKPACK] = "Backpack",
      [CONST_SLOT_ARMOR] = "Armor",
      [CONST_SLOT_RIGHT] = "Right Hand",
      [CONST_SLOT_LEFT] = "Left Hand",
      [CONST_SLOT_LEGS] = "Legs",
      [CONST_SLOT_FEET] = "Feet",
      [CONST_SLOT_RING] = "Ring",
      [CONST_SLOT_AMMO] = "Ammo",
      [CONST_SLOT_DECK] = "Deck",
      [CONST_SLOT_BADGE] = "Badge",
      [CONST_SLOT_SHIP] = "Ship",
      [CONST_SLOT_BELT] = "Belt",
      [CONST_SLOT_GLOVES] = "Gloves",
    }
    
    if slotNames[slot] then
      wasEquipped = true
      -- Debug removido para evitar spam no console
    end
  end
  
  -- Verificar se o item foi movido DE um slot de equipamento (desequipado)
  if fromPosition.x == CONTAINER_POSITION and bit.band(fromPosition.y, 0x40) == 0 then
    local slot = fromPosition.y
    local slotNames = {
      [CONST_SLOT_HEAD] = "Head",
      [CONST_SLOT_NECKLACE] = "Necklace",
      [CONST_SLOT_BACKPACK] = "Backpack",
      [CONST_SLOT_ARMOR] = "Armor",
      [CONST_SLOT_RIGHT] = "Right Hand",
      [CONST_SLOT_LEFT] = "Left Hand",
      [CONST_SLOT_LEGS] = "Legs",
      [CONST_SLOT_FEET] = "Feet",
      [CONST_SLOT_RING] = "Ring",
      [CONST_SLOT_AMMO] = "Ammo",
      [CONST_SLOT_DECK] = "Deck",
      [CONST_SLOT_BADGE] = "Badge",
      [CONST_SLOT_SHIP] = "Ship",
      [CONST_SLOT_BELT] = "Belt",
      [CONST_SLOT_GLOVES] = "Gloves",
    }
    
    if slotNames[slot] then
      wasUnequipped = true
      -- Debug removido para evitar spam no console
    end
  end
  
  -- Se houve equipar ou desequipar, enviar dados atualizados
  if wasEquipped or wasUnequipped then
      addEvent(function()
        if player and player:isPlayer() then
          sendUpdatedAttributesToClient(player)
        end
    end, 200) -- Aguardar um pouco para garantir que o item foi movido
  end
  
  return RETURNVALUE_NOERROR
end

ec:register(10) -- Prioridade 10

-- Função para coletar atributos de todos os itens equipados (formato antigo, mantido para compatibilidade)
local function getAllEquippedItemsData(player)
  if not player then
    return {}
  end
  
  local itemsData = {}
  local slotNames = {
    [CONST_SLOT_HEAD] = "Head",
    [CONST_SLOT_NECKLACE] = "Necklace",
    [CONST_SLOT_BACKPACK] = "Backpack",
    [CONST_SLOT_ARMOR] = "Armor",
    [CONST_SLOT_RIGHT] = "Right Hand",
    [CONST_SLOT_LEFT] = "Left Hand",
    [CONST_SLOT_LEGS] = "Legs",
    [CONST_SLOT_FEET] = "Feet",
    [CONST_SLOT_RING] = "Ring",
    [CONST_SLOT_AMMO] = "Ammo",
    [CONST_SLOT_DECK] = "Deck",
    [CONST_SLOT_BADGE] = "Badge",
    [CONST_SLOT_SHIP] = "Ship",
    [CONST_SLOT_BELT] = "Belt",
    [CONST_SLOT_GLOVES] = "Gloves",
  }
  
  for slot, slotName in pairs(slotNames) do
    local item = player:getSlotItem(slot)
    if item then
      local itemData = getItemAttributesData(item, slotName)
      if itemData then
        table.insert(itemsData, itemData)
      end
    end
  end
  
  return itemsData
end

-- Handler removido - agora usa ItemsChannel através do OpcodeManager
-- O sistema de atributos de itens é gerenciado pelo ItemsChannel em data/lib/channels/items_channel.lua

-- Evento de login para exibir todos os itens equipados
local CharacterAttributesLogin = CreatureEvent("CharacterAttributesLogin")

function CharacterAttributesLogin.onLogin(player)
  -- Registrar o evento de extended opcode
  player:registerEvent("CharacterAttributesExtended")
  
  -- Debug removido para evitar spam no console
  -- displayAllEquippedItems removido para evitar spam
  
  return true
end

CharacterAttributesLogin:type("login")
CharacterAttributesLogin:register()
