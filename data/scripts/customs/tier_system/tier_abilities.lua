-- Tier Abilities System
-- Sistema de habilidades baseado em tier usando Custom Attributes
-- Adaptado do sistema OTG para usar getCustomAttribute/setCustomAttribute

dofile('data/lib/core/tier_ability_config.lua')

-- Função auxiliar para obter tier de um item (usando Custom Attribute)
local function getItemTier(item)
	if not item then
		return 0
	end
	
	local tierAttr = item:getCustomAttribute("tier")
	if not tierAttr then
		return 0
	end
	
	-- Tenta converter para número
	if type(tierAttr) == "number" then
		return tierAttr
	else
		return tonumber(tierAttr) or 0
	end
end

-- Função auxiliar para calcular chance total considerando Amplification
local function calculateTotalChance(player, baseChance, abilityType)
	if abilityType == "amplification" then
		return baseChance
	end
	
	-- Verifica se tem botas com tier para amplificar
	local boots = player:getSlotItem(CONST_SLOT_FEET)
	if boots then
		local bootsTier = getItemTier(boots)
		if bootsTier > 0 then
			local amplificationChance = TierSystem.getActivationChance("amplification", bootsTier)
			-- Amplification aumenta a chance em 50% do seu valor
			local amplificationBonus = (amplificationChance * 0.5) / 100
			baseChance = baseChance * (1 + amplificationBonus)
		end
	end
	
	return baseChance
end

-- Atualiza storage de dodge baseado no tier da armadura
local function updateDodgeStorage(playerId)
	local player = Player(playerId)
	if not player then
		return
	end
	
	local storageValue = 0
	local slotItem = player:getSlotItem(CONST_SLOT_ARMOR)
	
	if slotItem then
		local tier = getItemTier(slotItem)
		if tier > 0 then
			local activationChance = TierSystem.abilityConfig["armor"].activationChances[tier] or 0
			storageValue = math.floor(activationChance * 100)
		end
	end
	
	player:setStorageValue(TierSystem.storageIds.dodgeStorage, storageValue)
end

-- Remove condições de bônus quando item é desequipado
local function updateStatBonus(playerId)
	local player = Player(playerId)
	if not player then
		return
	end
	
	if player:getCondition(CONDITION_ATTRIBUTES, TierSystem.storageIds.conditionSubId) then
		player:removeCondition(CONDITION_ATTRIBUTES, TierSystem.storageIds.conditionSubId)
	end
	if player:getCondition(CONDITION_HASTE, TierSystem.storageIds.conditionSubId) then
		player:removeCondition(CONDITION_HASTE, TierSystem.storageIds.conditionSubId)
	end
end

-- ========================================
-- HABILIDADES DE COMBATE
-- ========================================

-- Onslaught (Hand) - Aumenta dano crítico em 60%
local function processOnslaught(player, target, damage)
	local weapon = player:getSlotItem(CONST_SLOT_RIGHT) or player:getSlotItem(CONST_SLOT_LEFT)
	if not weapon then
		return damage
	end
	
	local tier = getItemTier(weapon)
	if tier == 0 then
		return damage
	end
	
	local activationChance = TierSystem.getActivationChance("onslaught", tier)
	local totalChance = calculateTotalChance(player, activationChance, "onslaught")
	
	if math.random(10000) <= (totalChance * 100) then
		-- Aumenta dano crítico em 60%
		if damage.primary.value < 0 then
			damage.primary.value = math.floor(damage.primary.value * 1.6)
		end
		if damage.secondary.value < 0 then
			damage.secondary.value = math.floor(damage.secondary.value * 1.6)
		end
		
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		player:say("Onslaught!", TALKTYPE_MONSTER_SAY)
	end
	
	return damage
end

-- Ruse (Armor) - Sistema de Dodge
local function processRuse(player, damage)
	local armor = player:getSlotItem(CONST_SLOT_ARMOR)
	if not armor then
		return damage
	end
	
	local tier = getItemTier(armor)
	if tier == 0 then
		return damage
	end
	
	local activationChance = TierSystem.getActivationChance("ruse", tier)
	local totalChance = calculateTotalChance(player, activationChance, "ruse")
	
	if math.random(10000) <= (totalChance * 100) then
		-- Dodge completo - reduz dano para 0
		damage.primary.value = 0
		damage.secondary.value = 0
		
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:say("Ruse!", TALKTYPE_MONSTER_SAY)
	end
	
	return damage
end

-- Transcendence (Legs) - Avatar automático
local function processTranscendence(player)
	local legs = player:getSlotItem(CONST_SLOT_LEGS)
	if not legs then
		return false
	end
	
	local tier = getItemTier(legs)
	if tier < 3 then
		return false
	end
	
	-- Só funciona fora de PZ
	if getTilePzInfo(player:getPosition()) then
		return false
	end
	
	-- Verifica se já tem outfit condition
	if player:getCondition(CONDITION_OUTFIT) then
		return false
	end
	
	local activationChance = TierSystem.getActivationChance("transcendence", tier)
	local totalChance = calculateTotalChance(player, activationChance, "transcendence")
	
	if math.random(10000) <= (totalChance * 100) then
		local vocation = player:getVocation():getName():lower()
		local outfit = TierSystem.avatarOutfits[vocation] or TierSystem.avatarOutfits["knight"]
		local duration = TierSystem.avatarDuration
		
		-- Aplica outfit de avatar
		local conditionOutfit = Condition(CONDITION_OUTFIT)
		conditionOutfit:setOutfit(outfit)
		conditionOutfit:setParameter(CONDITION_PARAM_TICKS, duration)
		player:addCondition(conditionOutfit)
		
		-- Aplica buffs de avatar
		local conditionBuffs = Condition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT)
		conditionBuffs:setParameter(CONDITION_PARAM_TICKS, duration)
		conditionBuffs:setParameter(CONDITION_PARAM_STAT_PERCENTDAMAGE, 85)
		conditionBuffs:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITPERCENT, 100)
		conditionBuffs:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 1500)
		player:addCondition(conditionBuffs)
		
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		player:say("Transcendence!", TALKTYPE_MONSTER_SAY)
		
		return true
	end
	
	return false
end

-- Momentum (Head) - Redução de cooldown (simplificado - apenas efeito visual)
local function processMomentum(player)
	local helmet = player:getSlotItem(CONST_SLOT_HEAD)
	if not helmet then
		return false
	end
	
	local tier = getItemTier(helmet)
	if tier == 0 then
		return false
	end
	
	-- Não funciona em PZ
	if getTilePzInfo(player:getPosition()) then
		return false
	end
	
	local activationChance = TierSystem.getActivationChance("momentum", tier)
	local totalChance = calculateTotalChance(player, activationChance, "momentum")
	
	if math.random(10000) <= (totalChance * 100) then
		-- Aplica efeito visual de momentum
		-- Nota: Redução de cooldown real precisa ser implementada na src
		player:getPosition():sendMagicEffect(232) -- Efeito momentum
		player:say("Momentum!", TALKTYPE_MONSTER_SAY)
		return true
	end
	
	return false
end

-- Amplification (Feet) - Amplifica outras habilidades
local function processAmplification(player)
	local boots = player:getSlotItem(CONST_SLOT_FEET)
	if not boots then
		return false
	end
	
	local tier = getItemTier(boots)
	if tier == 0 then
		return false
	end
	
	local activationChance = TierSystem.getActivationChance("amplification", tier)
	
	if math.random(10000) <= (activationChance * 100) then
		-- Aplica bônus de critical hit
		local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT)
		condition:setParameter(CONDITION_PARAM_TICKS, 10000)
		condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 25)
		condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 500)
		player:addCondition(condition)
		
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		player:say("Amplification!", TALKTYPE_MONSTER_SAY)
		return true
	end
	
	return false
end

-- ========================================
-- EVENT HANDLERS
-- ========================================

-- Evento unificado de Health Change (ataque e defesa)
local creatureEvent = CreatureEvent("tier_onHealthChange")
function creatureEvent.onHealthChange(target, source, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	-- Processa habilidades de ataque (quando source é player)
	if source and source:isPlayer() then
		-- Onslaught (hand) - aumenta dano
		local damage = {
			primary = {value = primaryDamage, type = primaryType},
			secondary = {value = secondaryDamage, type = secondaryType}
		}
		
		damage = processOnslaught(source, target, damage)
		
		primaryDamage = damage.primary.value
		secondaryDamage = damage.secondary.value
		
		-- Momentum (head) - redução de cooldown
		processMomentum(source)
		
		-- Amplification (feet) - bônus de critical
		processAmplification(source)
		
		-- Transcendence (legs) - avatar
		processTranscendence(source)
	end
	
	-- Processa habilidades de defesa (quando target é player)
	if target and target:isPlayer() then
		-- Ruse (armor) - dodge
		local damage = {
			primary = {value = primaryDamage, type = primaryType},
			secondary = {value = secondaryDamage, type = secondaryType}
		}
		
		damage = processRuse(target, damage)
		
		primaryDamage = damage.primary.value
		secondaryDamage = damage.secondary.value
	end
	
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end
creatureEvent:register()

-- Evento para registrar Health Change quando ataca
local ec = EventCallback
function ec.onTargetCombat(creature, target)
	if creature and target and creature:isPlayer() then
		target:registerEvent("tier_onHealthChange")
	end
	return RETURNVALUE_NOERROR
end
ec:register(8) -- Prioridade 8 (depois do rarity que é 7)

-- ========================================
-- LUCKY DROP (Necklace)
-- ========================================

local ecDropLoot = EventCallback
ecDropLoot.onDropLoot = function(self, corpse)
	local mType = self:getType()
	if configManager.getNumber(configKeys.RATE_LOOT) == 0 then
		return
	end
	
	local player = Player(corpse:getCorpseOwner())
	if not player then
		return
	end
	
	-- Só funciona com stamina > 840
	if player:getStamina() > 840 then
		local necklace = player:getSlotItem(CONST_SLOT_NECKLACE)
		if necklace then
			local tier = getItemTier(necklace)
			if tier > 0 then
				local dropBoost = TierSystem.getDropBoost(tier)
				if dropBoost > 0 then
					player:sendTextMessage(MESSAGE_STATUS_DEFAULT, 
						string.format("[Lucky Necklace] You have a tier %d necklace with +%d%% Drop Boost!", 
						tier, dropBoost))
					
					corpse:getPosition():sendMagicEffect(CONST_ME_TUTORIALARROW)
					corpse:getPosition():sendMagicEffect(CONST_ME_TUTORIALSQUARE)
					
					local rate = dropBoost / 10 * configManager.getNumber(configKeys.RATE_LOOT)
					local monsterLoot = mType:getLoot()
					
					for i = 1, #monsterLoot do
						local item = monsterLoot[i]
						if math.random(100) <= rate then
							local count = item.maxCount > 1 and math.random(item.maxCount) or 1
							corpse:addItem(item.itemId, count)
						end
					end
				end
			end
		end
	end
end
ecDropLoot:register()

-- ========================================
-- EQUIP/UNEQUIP HANDLERS (via onMoveItem)
-- ========================================

-- ========================================
-- LOGIN HANDLER
-- ========================================

local loginEvent = CreatureEvent("tier_onLogin")
function loginEvent.onLogin(player)
	player:registerEvent("tier_onHealthChange")
	
	-- Atualiza dodge storage ao logar
	addEvent(updateDodgeStorage, 100, player:getId())
	addEvent(updateStatBonus, 100, player:getId())
	return true
end
loginEvent:register()

-- ========================================
-- MOVE ITEM HANDLER (detecta equip/desequip)
-- ========================================

local ecMove = EventCallback
ecMove.onMoveItem = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if not self:isPlayer() then
		return RETURNVALUE_NOERROR
	end
	
	-- Verifica se item foi movido para/do equipamento (slots 1-10)
	local wasEquipped = toPosition.x == CONTAINER_POSITION and toPosition.y >= 1 and toPosition.y <= 10
	local wasUnequipped = fromPosition.x == CONTAINER_POSITION and fromPosition.y >= 1 and fromPosition.y <= 10
	
	if wasEquipped or wasUnequipped then
		-- Atualiza dodge storage quando armadura é equipada/desequipada
		if wasEquipped and toPosition.y == CONST_SLOT_ARMOR then
			addEvent(updateDodgeStorage, 100, self:getId())
		elseif wasUnequipped and fromPosition.y == CONST_SLOT_ARMOR then
			-- Remove dodge quando armadura é desequipada
			local tier = getItemTier(item)
			if tier > 0 then
				local activationChance = TierSystem.abilityConfig["armor"].activationChances[tier] or 0
				local currentValue = self:getStorageValue(TierSystem.storageIds.dodgeStorage) or 0
				local newValue = math.max(0, currentValue - math.floor(activationChance * 100))
				self:setStorageValue(TierSystem.storageIds.dodgeStorage, newValue)
			end
		end
		
		-- Atualiza condições de bônus
		addEvent(updateStatBonus, 100, self:getId())
	end
	
	return RETURNVALUE_NOERROR
end
ecMove:register()

print(">> Tier Abilities System Loaded")

