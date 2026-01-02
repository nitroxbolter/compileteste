local ITEM_ID = 28092
local RESET_COIN_ID = 28092 -- ID da moeda de reset

local statIndexByName = {
  ["strength"] = CHARSTAT_STRENGTH,
  ["intelligence"] = CHARSTAT_INTELLIGENCE,
  ["dexterity"] = CHARSTAT_DEXTERITY,
  ["vitality"] = CHARSTAT_VITALITY,
  ["spirit"] = CHARSTAT_SPIRIT,
  ["wisdom"] = CHARSTAT_WISDOM
}

local statNameByIndex = {
  [CHARSTAT_STRENGTH] = "strength",
  [CHARSTAT_INTELLIGENCE] = "intelligence",
  [CHARSTAT_DEXTERITY] = "dexterity",
  [CHARSTAT_VITALITY] = "vitality",
  [CHARSTAT_SPIRIT] = "spirit",
  [CHARSTAT_WISDOM] = "wisdom"
}

-- this is VISUAL ONLY for the client, to change actual values, you have to edit sources
-- 5 pontos = 1% de bônus (valuePerStat = 0.2 significa que cada ponto vale 0.2%, então 5 pontos = 1%)
local valuePerStat = {
  [CHARSTAT_STRENGTH] = 0.2,
  [CHARSTAT_INTELLIGENCE] = 0.2,
  [CHARSTAT_DEXTERITY] = 0.2,
  [CHARSTAT_VITALITY] = 0.2,
  [CHARSTAT_SPIRIT] = 0.2,
  [CHARSTAT_WISDOM] = 0.2,
}

-- max points that player can add to single stat
-- Balanceado para level 1000: 1000 pontos totais / 5 stats = 200 média
-- Limite de 300 pontos (30% do total) permite especialização sem concentração total
StatsMaxValues = {
  [CHARSTAT_STRENGTH] = 300,
  [CHARSTAT_INTELLIGENCE] = 300,
  [CHARSTAT_DEXTERITY] = 300,
  [CHARSTAT_VITALITY] = 300,
  [CHARSTAT_SPIRIT] = 300,
  [CHARSTAT_WISDOM] = 0,
}

-- 1 ponto por level (a partir do level 1)
-- Não precisa mais da lista de levels, cada level dá 1 ponto

-- Função para validar e corrigir pontos baseado no nível
local function validateAndFixStatsPoints(player)
  local playerLevel = player:getLevel()
  
  -- Calcula quantos pontos o jogador deveria ter baseado no nível (1 ponto por level)
  local expectedPoints = playerLevel
  
  -- Calcula quantos pontos foram usados (soma de todos os stats)
  local usedPoints = 0
  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    usedPoints = usedPoints + player:getCharacterStat(i)
  end
  
  -- Calcula quantos pontos disponíveis o jogador tem
  local availablePoints = player:getStatsPoints()
  
  -- Total de pontos = disponíveis + usados
  local totalPoints = availablePoints + usedPoints
  
  -- Debug: Verifica se está correto
  local isCorrect = (totalPoints == expectedPoints)
  print("[Character Stats - VALIDATION] Player: " .. player:getName() .. 
        " | Level: " .. playerLevel .. 
        " | Expected Points: " .. expectedPoints .. 
        " | Available: " .. availablePoints .. 
        " | Used: " .. usedPoints .. 
        " | Total: " .. totalPoints .. 
        " | Status: " .. (isCorrect and "CORRECT" or "INCORRECT - FIXING"))
  
  -- Se o total não corresponde ao esperado, corrige
  if totalPoints ~= expectedPoints then
    -- Ajusta os pontos disponíveis para que o total seja correto
    local newAvailablePoints = expectedPoints - usedPoints
    if newAvailablePoints < 0 then
      newAvailablePoints = 0
    end
    player:setStorageValue(PlayerStorageKeys.characterStatsPoints, newAvailablePoints)
    print("[Character Stats - VALIDATION] Player: " .. player:getName() .. 
          " | Fixed! New available points: " .. newAvailablePoints)
    return true -- Indica que houve correção
  end
  
  return false -- Não houve correção necessária
end

-- Função para contar moedas de reset no inventário do jogador
local function getResetCoinCount(player)
  local count = player:getItemCount(RESET_COIN_ID)
  return count
end

local LoginEvent = CreatureEvent("CharacterStatsLogins")

function LoginEvent.onLogin(player)
  player:registerEvent("CharacterStatsAdvances")

  -- Valida e corrige pontos baseado no nível (já inclui debug)
  validateAndFixStatsPoints(player)

  -- Debug: Informações do jogador ao logar
  local coinCount = getResetCoinCount(player)
  local availablePoints = player:getStatsPoints()
  local usedPoints = 0
  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    usedPoints = usedPoints + player:getCharacterStat(i)
  end
  local playerLevel = player:getLevel()
  local expectedPoints = playerLevel
  local totalPoints = availablePoints + usedPoints
  
  print("[Character Stats - LOGIN] Player: " .. player:getName() .. 
        " | Level: " .. playerLevel .. 
        " | Coins: " .. coinCount .. 
        " | Available Points: " .. availablePoints .. 
        " | Used Points: " .. usedPoints .. 
        " | Total Points: " .. totalPoints .. 
        " | Expected: " .. expectedPoints .. 
        " | Status: " .. (totalPoints == expectedPoints and "CORRECT" or "INCORRECT"))
  
  player:updateCharacterStats()
  return true
end

local AdvanceEvent = CreatureEvent("CharacterStatsAdvances")

function AdvanceEvent.onAdvance(player, skill, oldLevel, newLevel)
  if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
    return true
  end

  -- 1 ponto por level (a partir do level 1)
  -- Calcula quantos pontos o jogador deveria ter no novo level
  local expectedPointsAtNewLevel = newLevel
  local currentTotalPoints = player:getStatsPoints()
  
  -- Calcula pontos usados
  local usedPoints = 0
  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    usedPoints = usedPoints + player:getCharacterStat(i)
  end
  
  currentTotalPoints = currentTotalPoints + usedPoints
  
  -- Se o jogador tem menos pontos do que deveria ter no novo level, adiciona a diferença
  if currentTotalPoints < expectedPointsAtNewLevel then
    local pointsToAdd = expectedPointsAtNewLevel - currentTotalPoints
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have gained " .. pointsToAdd .. " stat point(s).")
    player:addStatsPoints(pointsToAdd)
    print("[Character Stats - LEVEL UP] Player: " .. player:getName() .. 
          " | Level: " .. oldLevel .. " -> " .. newLevel .. 
          " | Added " .. pointsToAdd .. " point(s)")
  end

  return true
end

local function addStat(player, data)
  if player:getStatsPoints() <= 0 then
    return
  end
  local statId = statIndexByName[data]
  if player:getCharacterStat(statId) >= StatsMaxValues[statId] then
    return
  end
  player:addCharacterStat(statId, 1)
  player:addStatsPoints(-1, true)

  player:updateCharacterStats()
end

local function removeStat(player, data)
  local statId = statIndexByName[data]
  if player:getCharacterStat(statId) <= 0 then
    return
  end
  player:addCharacterStat(statId, -1)
  player:addStatsPoints(1, true)

  player:updateCharacterStats()
end

local function resetStats(player)
  print("[Character Stats - RESET] Player: " .. player:getName() .. " | Requested reset")
  
  if player:getItemCount(ITEM_ID) == 0 then
    print("[Character Stats - RESET] Player: " .. player:getName() .. " | ERROR: No reset coin (ID: " .. ITEM_ID .. ")")
    player:popupFYI("You need " .. ItemType(ITEM_ID):getName() .. " to reset stats")
    return
  end
  
  -- Verifica se há pontos usados (stats distribuídos)
  local usedPointsBefore = 0
  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    usedPointsBefore = usedPointsBefore + player:getCharacterStat(i)
  end
  
  -- Se não há pontos usados, não precisa resetar
  if usedPointsBefore == 0 then
    print("[Character Stats - RESET] Player: " .. player:getName() .. " | Already reset - No points used")
    player:popupFYI("Your stats are already reset. No points have been distributed.")
    return
  end
  
  local coinCountBefore = getResetCoinCount(player)
  local availablePointsBefore = player:getStatsPoints()
  
  print("[Character Stats - RESET] Player: " .. player:getName() .. 
        " | Before - Coins: " .. coinCountBefore .. 
        " | Available Points: " .. availablePointsBefore .. 
        " | Used Points: " .. usedPointsBefore)
  
  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    local points = player:getStorageValue(PlayerStorageKeys.characterStatsPoints + i + 1)
    if points > 0 then
      player:setStorageValue(PlayerStorageKeys.characterStatsPoints + i + 1, -1)
      player:addStatsPoints(points, true)
    end
  end

  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    local points = player:getCharacterStat(i)
    player:setCharacterStat(i, 0)
    player:addStatsPoints(points, true)
  end
  
  player:removeItem(ITEM_ID, 1)

  local coinCountAfter = getResetCoinCount(player)
  local availablePointsAfter = player:getStatsPoints()
  local usedPointsAfter = 0
  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    usedPointsAfter = usedPointsAfter + player:getCharacterStat(i)
  end
  
  print("[Character Stats - RESET] Player: " .. player:getName() .. 
        " | After - Coins: " .. coinCountAfter .. 
        " | Available Points: " .. availablePointsAfter .. 
        " | Used Points: " .. usedPointsAfter .. 
        " | Sending update to client...")

  player:updateCharacterStats()
end

local function saveStats(player, data)
  if not data then
    return
  end
  
  print("[Character Stats - SAVE] Player: " .. player:getName() .. " | Saving stats")
  
  -- Aplica todas as mudanças pendentes
  local statsToApply = {
    strength = data.strength or 0,
    intelligence = data.intelligence or 0,
    dexterity = data.dexterity or 0,
    vitality = data.vitality or 0,
    spirit = data.spirit or 0
  }
  
  local pointsToApply = data.points or 0
  
  -- Verifica se há mudanças para aplicar
  local hasChanges = false
  for statName, change in pairs(statsToApply) do
    if change ~= 0 then
      hasChanges = true
      break
    end
  end
  
  if not hasChanges and pointsToApply == 0 then
    print("[Character Stats - SAVE] Player: " .. player:getName() .. " | No changes to save")
    player:popupFYI("No changes to save.")
    return
  end
  
  -- Aplica mudanças em cada stat
  for statName, change in pairs(statsToApply) do
    if change ~= 0 then
      local statId = statIndexByName[statName]
      if statId then
        if change > 0 then
          -- Adiciona stats
          for i = 1, change do
            if player:getStatsPoints() > 0 and player:getCharacterStat(statId) < StatsMaxValues[statId] then
              player:addCharacterStat(statId, 1)
              player:addStatsPoints(-1, true)
            end
          end
        else
          -- Remove stats
          for i = 1, math.abs(change) do
            if player:getCharacterStat(statId) > 0 then
              player:addCharacterStat(statId, -1)
              player:addStatsPoints(1, true)
            end
          end
        end
      end
    end
  end
  
  -- Aplica mudanças nos pontos (se houver diferença)
  if pointsToApply ~= 0 then
    player:addStatsPoints(pointsToApply, true)
  end
  
  print("[Character Stats - SAVE] Player: " .. player:getName() .. " | Stats saved successfully")
  player:popupFYI("Stats saved successfully!")
  
  player:updateCharacterStats()
end

-- As funções addStat, removeStat, resetStats e saveStats são exportadas globalmente
-- para serem acessadas pelo CharStatsChannel
_G.addStat = addStat
_G.removeStat = removeStat
_G.resetStats = resetStats
_G.saveStats = saveStats

function Player:updateCharacterStats()
  -- Valida e corrige pontos antes de atualizar (verificação de segurança)
  validateAndFixStatsPoints(self)
  
  local stats = {}
  local usedPoints = 0
  for i = CHARSTAT_FIRST, CHARSTAT_SPIRIT do
    local statPoints = self:getCharacterStat(i)
    usedPoints = usedPoints + statPoints
    -- Calcula o valor: 5 pontos = 1% (valuePerStat = 0.2, então 5 * 0.2 = 1%)
    local statValue = math.floor(valuePerStat[i] * statPoints)
    stats[statNameByIndex[i]] = {
      points = statPoints,
      value = statValue
    }
  end

  -- Verificar quantidade de moedas de reset
  local coinCount = getResetCoinCount(self)
  local availablePoints = self:getStatsPoints()

  local data = {
    points = availablePoints,
    stats = stats,
    coinCount = coinCount
  }
  
  -- Debug: Informações antes de enviar
  print("[Character Stats - UPDATE] Player: " .. self:getName() .. 
        " | Coins: " .. coinCount .. 
        " | Available Points: " .. availablePoints .. 
        " | Used Points: " .. usedPoints .. 
        " | Sending to client...")

  -- Usa CharStatsChannel para enviar via opcode 66
  if CharStatsChannel then
    CharStatsChannel.sendStatsData(self, {action = "update", data = data})
  elseif OpcodeManager then
    OpcodeManager.sendData(
      self,
      OpcodeManager.Config.Commands.CHARSTATS,
      OpcodeManager.Config.Models.CHARSTATS,
      {action = "update", data = data}
    )
  else
    -- Fallback para o método antigo se OpcodeManager não estiver disponível
    self:sendExtendedOpcode(ExtendedOPCodes.CODE_CHARSTATS, json.encode({action = "update", data = data}))
  end
end

function Player:addStatsPoints(points, silent)
  local val = self:getStorageValue(PlayerStorageKeys.characterStatsPoints)
  if val == -1 then
    val = 0
  end
  local newVal = val + points
  self:setStorageValue(PlayerStorageKeys.characterStatsPoints, newVal)

  if not silent then
    self:updateCharacterStats()
  end
end


function Player:getStatsPoints()
  local val = self:getStorageValue(PlayerStorageKeys.characterStatsPoints)
  if val == -1 then
    val = 0
  end

  return val
end

LoginEvent:type("login")
LoginEvent:register()
AdvanceEvent:type("advance")
AdvanceEvent:register()

-- Registra handler no OpcodeManager para receber mensagens do cliente
-- O handler será registrado quando o arquivo for carregado (ver função handleCharStatsMessage acima)

