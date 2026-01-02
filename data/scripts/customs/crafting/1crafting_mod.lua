--- File is called 1crafting_mod.lua , because it needs to be the first file of the folder, if not, then you get errors of nil value about categorys crafting (armorsmith, etc)

Crafting = {}

-- Sistema de craft agora usa OpcodeManager (opcode 66) através de craft_channel.lua
local fetchLimit = 10
local CHUNK_SIZE = 512
local categories = {"herbalist", "woodcutting", "mining", "generalcrafting", "armorsmith", "weaponsmith", "jewelsmith"}
-- Função para calcular a chance de falha baseada na diferença entre level do item e skill do personagem
local function calculateFailChance(player, skillType, craftLevel)
  local playerSkill = player:getEffectiveSkillLevel(skillType)
  
  -- Se o skill for 0 ou negativo, usar chance máxima
  if playerSkill <= 0 then
    return 50
  end
  
  -- Calcular a diferença: level requerido - skill do personagem
  local difference = craftLevel - playerSkill
  
  -- Se o skill for menor ou igual ao level requerido
  if difference >= 0 then
    -- Chance base de 50% quando skill = level
    -- Mantém 50% como máximo mesmo se skill for muito menor
    return 50
  else
    -- Se o skill for maior que o level requerido, reduzir a chance
    -- A redução é baseada na diferença negativa (quanto maior o skill acima do requerido)
    local skillAbove = math.abs(difference) -- Quantos pontos acima do requerido
    
    -- Calcular redução progressiva baseada no level do item
    -- A progressão é proporcional: precisa de aproximadamente 1.2x o level requerido em skill acima
    -- para chegar ao mínimo de 5% (redução de 45%)
    -- Exemplo: item level 120 precisa de ~144 skill acima para chegar a 5%
    -- Exemplo: item level 50 precisa de ~60 skill acima para chegar a 5%
    
    -- Fórmula: redução = (skill acima / (level requerido * 1.2)) * 45
    local reductionPercent = (skillAbove / (craftLevel * 1.2)) * 45
    
    -- Limitar a redução máxima a 45% (para chegar ao mínimo de 5%)
    reductionPercent = math.min(reductionPercent, 45)
    
    -- Chance final: 50% - redução (mínimo 5%)
    local finalChance = math.max(50 - reductionPercent, 5)
    
    return math.floor(finalChance)
  end
end


-- Tabela de ganho de experiência baseado no nível do item craftado
local craftLevelStages = {
  { minlevel = 1, maxlevel = 10, tries = 1 },
  { minlevel = 11, maxlevel = 25, tries = 2 },
  { minlevel = 26, maxlevel = 50, tries = 3 },
  { minlevel = 51, maxlevel = 100, tries = 4 },
  { minlevel = 101, maxlevel = 200, tries = 5 },
  { minlevel = 201, tries = 6 }
}

for _, category in ipairs(categories) do
  local filePath = string.format("data/scripts/customs/crafting/%s.lua", category)
  local status, err = pcall(dofile, filePath)
  -- if not status then
  --   print(string.format("[Crafting] Error loading file for category '%s': %s", category, err))
  -- else
  --   print(string.format("[Crafting] Successfully loaded category '%s'", category))
  -- end
end

local categoryAIDs = {
  herbalist = 38820,
  woodcutting = 38821,
  mining = 38822,
  generalcrafting = 38823,
  armorsmith = 38825,
  weaponsmith = 38826,
  jewelsmith = 38824
}

for category, aid in pairs(categoryAIDs) do
  local actionEvent = Action()

  function actionEvent.onUse(player)
    player:showCrafting(category)
    return true
  end

  actionEvent:aid(aid)
  actionEvent:register()
end

local rarities = {
  { id = 1, name = "Common", chance = 40.0 },
  { id = 2, name = "Rare", chance = 20.0 },
  { id = 3, name = "Epic", chance = 20.0 },
  { id = 4, name = "Legendary", chance = 10.0 },
  { id = 5, name = "Brutal", chance = 10.0 }
  
}

local function rollRarity(player)
    local skillArmorsmith = player:getSkillLevel(SKILL_ARMORSMITH) or 0
    local skillWeaponsmith = player:getSkillLevel(SKILL_WEAPONSMITH) or 0
    local skillJewelsmith = player:getSkillLevel(SKILL_JEWELSMITH) or 0
    local skillCrafting = player:getSkillLevel(SKILL_CRAFTING) or 0

    -- Calcular a média das habilidades
    local mediaSkill = (skillArmorsmith + skillWeaponsmith + skillJewelsmith + skillCrafting) / 4
    local bonusPercent = mediaSkill * 0.1  -- Usar apenas o bonusPercent
    local rolledChance = math.random() * 100  -- Definido para um máximo de 100%

    -- Ajustar as chances de raridade usando apenas bonusPercent
    local rarityChances = {
        {id = 1, name = "Common", chance = 40.0 - bonusPercent},       -- penaliza comum
        {id = 2, name = "Rare", chance = 20.0 + bonusPercent / 4},     -- recompensa Rare
        {id = 3, name = "Epic", chance = 20.0 + bonusPercent / 3},     -- recompensa Epic
        {id = 4, name = "Legendary", chance = 10.0 + bonusPercent / 2},  -- recompensa mais
        {id = 5, name = "Brutal", chance = 10.0 + bonusPercent / 2},     -- idem
    }

    -- Imprimir as chances ajustadas
    for _, rarity in ipairs(rarityChances) do
        -- print(string.format("Raridade: %s, Chance ajustada: %.2f", rarity.name, rarity.chance))
    end

    -- Corrigir possíveis negativos (caso a Common fique < 0)
    for _, rarity in ipairs(rarityChances) do
        if rarity.chance < 0 then rarity.chance = 0 end
    end

    -- Calcular total e sortear
    local totalChance = 0
    for _, rarity in ipairs(rarityChances) do
        totalChance = totalChance + rarity.chance
    end

    -- print(string.format("Total de chances ajustadas: %.2f", totalChance))  -- Print do total de chances

    local roll = math.random() * totalChance
    -- print(string.format("Valor do roll: %.2f", roll))  -- Print do valor do roll
      -- print(string.format("=========================================================")) 
    local accumulated = 0
    for _, rarity in ipairs(rarityChances) do
        accumulated = accumulated + rarity.chance
        if roll <= accumulated then
            return rarity.id, rarity.name
        end
    end

    -- fallback de segurança
    return 0, "None"
end

-- Sistema de craft agora usa OpcodeManager (opcode 66) através de craft_channel.lua
-- O handler está registrado em craft_channel.lua que chama as funções abaixo

function Crafting:sendCrafts(player, category, page)
  if not Crafting[category] then
    return
  end

  -- Definir skill type baseado na categoria
  local skillType
  if category == "herbalist" then
    skillType = SKILL_HERBALIST
  elseif category == "woodcutting" then
    skillType = SKILL_WOODCUTTING
  elseif category == "mining" then
    skillType = SKILL_MINING
  elseif category == "generalcrafting" then
    skillType = SKILL_CRAFTING
  elseif category == "armorsmith" then
    skillType = SKILL_ARMORSMITH
  elseif category == "weaponsmith" then
    skillType = SKILL_WEAPONSMITH
  elseif category == "jewelsmith" then
    skillType = SKILL_JEWELSMITH
  end

  local startIndex = (page - 1) * fetchLimit + 1
  local endIndex = math.min(startIndex + fetchLimit - 1, #Crafting[category])
  local craftsData = {}
  for i = startIndex, endIndex do
    local craft = Crafting[category][i]
    if craft then
      local itemType = ItemType(craft.id)
      local mainClient = itemType and itemType:getClientId() or 0
      local playerStorage = craft.storage and player:getStorageValue(craft.storage) or -1

      -- Calcular chance de falha baseada no skill do jogador
      local failChance = calculateFailChance(player, skillType, craft.level)
      
      local craftEntry = {
        index = i,
        name = craft.name,
        id = craft.id,
        clientId = mainClient,
        level = craft.level,
        cost = craft.cost,
        count = craft.count,
        storage = craft.storage or 0,
        playerStorage = playerStorage,
        storageText = craft.storageText or "",
        failChance = failChance,
        materials = {}
      }
      if craft.materials then
        for _, mat in ipairs(craft.materials) do
          local matType = ItemType(mat.id)
          local matClient = matType and matType:getClientId() or 0
          table.insert(craftEntry.materials, {
            id = mat.id,
            clientId = matClient,
            count = mat.count,
            player = player:getItemCount(mat.id)
          })
        end
      end

      table.insert(craftsData, craftEntry)
    end
  end

  local bigTable = {
    action = "fetch",
    data = {
      category = category,
      crafts = craftsData,
      page = page,
      totalPages = math.ceil(#Crafting[category] / fetchLimit)
    }
  }

  local bigJson = json.encode(bigTable)
  local msgID = string.format("fetch-%s-page%d", category, page)
  local totalLen = #bigJson
  local offset = 1
  local chunks = {}
  local totalBytes = 0

  while offset <= totalLen do
    local chunkStr = string.sub(bigJson, offset, offset + CHUNK_SIZE - 1)
    offset = offset + CHUNK_SIZE
    table.insert(chunks, chunkStr)
    totalBytes = totalBytes + #chunkStr
  end

  for i, chunkData in ipairs(chunks) do
    local chunkInfo = {
      action = "chunkedFetch",
      chunkData = {
        msgID = msgID,
        index = i,
        count = #chunks,
        payload = chunkData
      }
    }
    -- Usa OpcodeManager para enviar chunks
    OpcodeManager.sendData(
      player,
      OpcodeManager.Config.Commands.CRAFT,
      OpcodeManager.Config.Models.CRAFT,
      chunkInfo,
      "chunkedFetch"
    )
  end
end

local SKILL_HERBALIST = 10
local SKILL_WOODCUTTING = 8
local SKILL_MINING = 9
local SKILL_CRAFTING = 7
local SKILL_ARMORSMITH = 11
local SKILL_WEAPONSMITH = 12
local SKILL_JEWELSMITH = 13

local skillNames = {
  [SKILL_HERBALIST] = "Herbalist",
  [SKILL_WOODCUTTING] = "Woodcutting",
  [SKILL_MINING] = "Mining",
  [SKILL_CRAFTING] = "Crafting",
  [SKILL_ARMORSMITH] = "Armorsmith",
  [SKILL_WEAPONSMITH] = "Weaponsmith",
  [SKILL_JEWELSMITH] = "Jewelsmith"
}

function Crafting:craft(player, category, craftId)
  if not Crafting[category] then
    return
  end

  local crafts = Crafting[category]
  local craft = crafts[craftId]

  if not craft then
    return
  end

  local skillType
  if category == "herbalist" then
    skillType = SKILL_HERBALIST
  elseif category == "woodcutting" then
    skillType = SKILL_WOODCUTTING
  elseif category == "mining" then
    skillType = SKILL_MINING
  elseif category == "generalcrafting" then
    skillType = SKILL_CRAFTING
  elseif category == "armorsmith" then
    skillType = SKILL_ARMORSMITH
  elseif category == "weaponsmith" then
    skillType = SKILL_WEAPONSMITH
  elseif category == "jewelsmith" then
    skillType = SKILL_JEWELSMITH
  end

  local playerSkill = player:getEffectiveSkillLevel(skillType)
  local money = player:getMoney()


  if craft.storage and craft.storage > 0 then
    local playerStorage = player:getStorageValue(craft.storage)
    if playerStorage ~= 1 then
      local message = "Você precisa desbloquear a receita."
      if craft.storageText and craft.storageText ~= "" then
        message = message .. "\n" .. craft.storageText
      end
      player:popupFYI(message)
      return
    end
  end

  if money < craft.cost then
    player:popupFYI(string.format("Você não tem gold Suficiente: %d.", craft.cost)) 
    return
  end

  if playerSkill < craft.level then
    player:popupFYI(string.format("Você não tem skill requeridos %s skill: %d. Your skill is: %d.", skillNames[skillType], craft.level, playerSkill))
    return
  end

  if craft.materials then
    for _, mat in ipairs(craft.materials) do
      if player:getItemCount(mat.id) < mat.count then
        player:popupFYI(string.format(
          "You don't have enough %s (need %d).",
          ItemType(mat.id):getName(),
          mat.count
        ))
        return
      end
    end
  end

  addEvent(function()
    -- Verifica se o jogador tem uma mochila equipada e espaço disponível
    local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
    if not backpack or not backpack:isContainer() or backpack:getEmptySlots() <= 0 then
        player:popupFYI("Sua mochila está cheia, ou você não está usando uma mochila.")
        return
    end

    -- Calcular chance de falha baseada no skill atual
    local currentFailChance = calculateFailChance(player, skillType, craft.level)
    
    -- Verifica se o crafting falhou
    if math.random(100) <= currentFailChance then
        player:removeMoney(craft.cost)
        if craft.materials then
            for _, material in ipairs(craft.materials) do
                player:removeItem(material.id, material.count)
            end
        end

        player:popupFYI("O item falhou!!.")
        
        -- Enviar mensagem de falha para o cliente usando OpcodeManager
        OpcodeManager.sendData(
          player,
          OpcodeManager.Config.Commands.CRAFT,
          OpcodeManager.Config.Models.CRAFT,
          {success = false},
          "craft"
        )
        return
    end

    -- Criar o item
    local item = Game.createItem(craft.id, craft.count)

    -- Rolar a raridade do item (usa média de todos os skills de craft)
    local rarityId, rarityName = rollRarity(player)

    -- Aplicar a raridade ao item
    if rarityId > 0 then
        item:setRarityLevel(rarityId)  -- Chame a função para definir a raridade
        player:popupFYI(string.format("Voce criou um %s %s", item:getName(), rarityName))
    else
        player:popupFYI(string.format("Item Criado com Sucesso: %s", ItemType(craft.id):getName()))
    end

    -- Se tiver espaço suficiente, adicionamos o item à mochila
    if player:addItemEx(item) then
        player:removeMoney(craft.cost)
        if craft.materials then
            for _, material in ipairs(craft.materials) do
                player:removeItem(material.id, material.count)
            end
        end

        -- Calcula ganho de experiência baseado no nível do item craftado
        local skillTries = 1 -- padrão
        if craftLevelStages then
            for _, stage in ipairs(craftLevelStages) do
                if craft.level >= stage.minlevel then
                    if not stage.maxlevel or craft.level <= stage.maxlevel then
                        skillTries = stage.tries
                        break
                    end
                end
            end
        end

        player:addSkillTries(skillType, skillTries)
        Crafting:sendMoney(player)

        local page = math.ceil(craftId / fetchLimit)
        Crafting:sendCrafts(player, category, page)
        playSound(player, "crafting.ogg")

        -- Envia a confirmação de sucesso depois que o item for realmente criado e adicionado usando OpcodeManager
        OpcodeManager.sendData(
          player,
          OpcodeManager.Config.Commands.CRAFT,
          OpcodeManager.Config.Models.CRAFT,
          {success = true},
          "craft"
        )
    else
        player:popupFYI("Você não tem espaço suficiente para receber o item criado.")
    end
end, 860)
end


function Crafting:sendMaterials(player, category, craftId)
  if not Crafting[category] then
    return
  end

  if not craftId or not Crafting[category][craftId] then
    return
  end

  local craft = Crafting[category][craftId]
  if not craft then
    return
  end

  local updatedMaterials = {}
  if craft.materials then
    for _, material in ipairs(craft.materials) do
      local playerCount = player:getItemCount(material.id)
      table.insert(updatedMaterials, {
        id = material.id,
        count = material.count,
        player = playerCount
      })
    end
  end

  -- Envia dados de materiais usando OpcodeManager
  OpcodeManager.sendData(
    player,
    OpcodeManager.Config.Commands.CRAFT,
    OpcodeManager.Config.Models.CRAFT,
    {
      category = category,
      recipeIndex = craftId,
      materials = updatedMaterials
    },
    "materials"
  )
end

function Crafting:sendMoney(player)
  -- Envia dados de dinheiro usando OpcodeManager
  OpcodeManager.sendData(
    player,
    OpcodeManager.Config.Commands.CRAFT,
    OpcodeManager.Config.Models.CRAFT,
    {money = player:getMoney()},
    "money"
  )
end

function Player:showCrafting(category)
  local selectedCategory = category

  if not Crafting[selectedCategory] then
    return
  end

  Crafting:sendMoney(self)
  Crafting:sendMaterials(self, selectedCategory)
  -- Envia comando para mostrar janela usando OpcodeManager
  OpcodeManager.sendData(
    self,
    OpcodeManager.Config.Commands.CRAFT,
    OpcodeManager.Config.Models.CRAFT,
    {category = selectedCategory},
    "show"
  )
end

local function craftRoll(player, craft)
    local roll = math.random(0, 90)  -- Gera um número aleatório entre 0 e 100
    print("====================================================")
    print(string.format("[Crafting] Craft Roll Value: %d", roll))  -- Mensagem unificada

    -- Verifica se o crafting falhou
    if roll < 15 then  -- Se o roll for menor que 15
        player:removeMoney(craft.cost)
        if craft.materials then
            for _, material in ipairs(craft.materials) do
                player:removeItem(material.id, material.count)
            end
        end
        return nil, "Common"  -- Retorna nil para indicar falha
    else
        print("[Crafting] Craft Roll: >= 15, Avança para Raridade.")
        -- Rolar a raridade do item
        local rarityRoll = math.random(1, 90)  -- Gera um número aleatório entre 1 e 100
        print(string.format("[Crafting] Rarity Roll Value: %d", rarityRoll))  -- Debug: Valor do roll de raridade

        -- Comparar o rarityRoll com a tabela de raridades
        local cumulativeChance = 0
        for _, rarity in ipairs(rarities) do
            cumulativeChance = cumulativeChance + rarity.chance
            if rarityRoll <= cumulativeChance then
                local item = Game.createItem(craft.id, craft.count)  -- Cria o item
                print(string.format("[Crafting] Item criado: %s, Raridade: %s", item:getName(), rarity.name))  -- Print do item e sua raridade
                print("====================================================")
                return item, rarity.name  -- Retorna o item e a raridade
            end
        end

        print("[Crafting] Error: No rarity matched, defaulting to Common.")
        return Game.createItem(craft.id, craft.count), "Common"  -- Retorna Comum por padrão
    end
end

local function getCraftingRarity(mediaSkill)
    -- 1. Definir o bônus com base na média de skill
    local bonusPercent = mediaSkill * 0.1
    print(string.format("Bônus calculado: %.2f", bonusPercent))  -- Print do valor do bônus

    -- 2. Configurar as chances com ajustes
    local rarityChances = {
        {id = 1, name = "Common", chance = 70.0 - bonusPercent},       -- penaliza comum
        {id = 2, name = "Rare", chance = 20.0 + bonusPercent / 4},     -- recompensa Rare
        {id = 3, name = "Epic", chance = 10.0 + bonusPercent / 3},     -- recompensa Epic
        {id = 4, name = "Legendary", chance = 2.0 + bonusPercent / 2},  -- recompensa mais
        {id = 5, name = "Brutal", chance = 1.5 + bonusPercent / 2},     -- idem
    }

    -- 3. Corrigir possíveis negativos (caso a Common fique < 0)
    for _, rarity in ipairs(rarityChances) do
        if rarity.chance < 0 then rarity.chance = 0 end
    end

    -- 4. Calcular total e sortear
    local totalChance = 0
    for _, rarity in ipairs(rarityChances) do
        totalChance = totalChance + rarity.chance
    end

    local roll = math.random() * totalChance
    print(string.format("Valor do roll: %.2f", roll))  -- Print do valor do roll
    print("====================================================")

    local accumulated = 0
    for _, rarity in ipairs(rarityChances) do
        accumulated = accumulated + rarity.chance
        if roll <= accumulated then
            return rarity.name, roll
        end
    end

    -- fallback de segurança
    return "Common", roll
end
