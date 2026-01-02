-- Sistema Simplificado de Upgrade de Tier
-- Agora apenas adiciona o atributo custom "tier" ao item, sem transformar o itemId
-- As estrelas visuais são gerenciadas pelo cliente baseado no atributo tier

local upgradeAction = Action()

-- Função auxiliar para obter tier de um item
local function getItemTier(item)
	local tierAttr = item:getCustomAttribute("tier")
	if not tierAttr then
		return 0
	end
	
	-- Tenta converter para número de diferentes formas
	if type(tierAttr) == "number" then
		return tierAttr
	else
		return tonumber(tierAttr) or 0
	end
end

-- Função auxiliar para definir tier de um item
local function setItemTier(item, tier)
	item:setCustomAttribute("tier", tier)
end

-- Função para atualizar a descrição do item com o tier
local function updateItemDescription(item)
	local tier = getItemTier(item)
	local baseDescription = ItemType(item:getId()):getDescription()
	
	-- Remove qualquer descrição de tier anterior
	local currentDesc = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION) or ""
	if currentDesc:find("Tier:") then
		currentDesc = currentDesc:gsub("\nTier: %d+", "")
		currentDesc = currentDesc:gsub("Tier: %d+", "")
	end
	
	-- Adiciona o tier na descrição se for maior que 0
	if tier > 0 then
		local newDescription = baseDescription
		if currentDesc ~= "" and currentDesc ~= baseDescription then
			newDescription = currentDesc
		end
		newDescription = newDescription .. "\nTier: " .. tier
		item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, newDescription)
	else
		-- Se tier for 0, remove a descrição customizada (volta para a base)
		if currentDesc == baseDescription or currentDesc == "" then
			item:removeAttribute(ITEM_ATTRIBUTE_DESCRIPTION)
		else
			-- Mantém outras descrições customizadas, apenas remove o tier
			local cleanedDesc = currentDesc:gsub("\nTier: %d+", "")
			cleanedDesc = cleanedDesc:gsub("Tier: %d+", "")
			if cleanedDesc == baseDescription or cleanedDesc == "" then
				item:removeAttribute(ITEM_ATTRIBUTE_DESCRIPTION)
			else
				item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, cleanedDesc)
			end
		end
	end
end

-- Configuração de tier por item de upgrade
-- Cada item de upgrade adiciona +1 tier ao item alvo
local tierUpgradeItems = {
    -- Common Tier (1-3)
    [27134] = {tierAdd = 1, tierName = "Common"},
    [27135] = {tierAdd = 1, tierName = "Common"},
    [27136] = {tierAdd = 1, tierName = "Common"},
    
    -- Rare Tier (4-6)
    [27137] = {tierAdd = 1, tierName = "Rare"},
    [27138] = {tierAdd = 1, tierName = "Rare"},
    [27139] = {tierAdd = 1, tierName = "Rare"},
    
    -- Very Rare Tier (7-9)
    [27140] = {tierAdd = 1, tierName = "Very Rare"},
    [27141] = {tierAdd = 1, tierName = "Very Rare"},
    [27142] = {tierAdd = 1, tierName = "Very Rare"},
    
    -- Epic Tier (10-12)
    [27143] = {tierAdd = 1, tierName = "Epic"},
    [27144] = {tierAdd = 1, tierName = "Epic"},
    [27145] = {tierAdd = 1, tierName = "Epic"},
    
    -- Legendary Tier (13-15)
    [27146] = {tierAdd = 1, tierName = "Legendary"},
    [27147] = {tierAdd = 1, tierName = "Legendary"},
    [27148] = {tierAdd = 1, tierName = "Legendary"},
}

-- Verifica se o item pode receber tier
local function canItemReceiveTier(item)
    if not item or not item:isItem() then
        return false
    end
    
    -- Verifica se é um item equipável (armas, armaduras, etc)
    local itemType = ItemType(item:getId())
    if not itemType then
        return false
    end
    
    local slotPosition = itemType:getSlotPosition()
    -- Permite itens que ocupam slots de equipamento
    if slotPosition == SLOTP_HEAD or 
       slotPosition == SLOTP_ARMOR or 
       slotPosition == SLOTP_LEGS or 
       slotPosition == SLOTP_FEET or 
       slotPosition == SLOTP_LEFT or 
       slotPosition == SLOTP_RIGHT or
       slotPosition == SLOTP_AMULET then
        return true
    end
    
    -- Também permite armas e armaduras mesmo sem slot específico
    if itemType:getWeaponType() ~= WEAPON_NONE or 
       itemType:getArmor() > 0 or 
       itemType:getDefense() > 0 then
        return true
    end
    
    return false
end

function upgradeAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- DEBUG: Início do processo
    print(string.format("[TIER DEBUG] Player %s tentando usar item %d em target", player:getName(), item:getId()))
    
    if not target:isItem() then
        player:sendCancelMessage('You must select an item.')
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        print("[TIER DEBUG] Falha: Target não é um item")
        return true
    end

    local itemId = item.itemid
    local targetId = target.itemid
    local upgradeConfig = tierUpgradeItems[itemId]
    
    -- DEBUG: Informações do item de upgrade
    print(string.format("[TIER DEBUG] Item de upgrade ID: %d", itemId))
    if upgradeConfig then
        print(string.format("[TIER DEBUG] Config encontrada: tierAdd=%d, tierName=%s", upgradeConfig.tierAdd, upgradeConfig.tierName))
    else
        print("[TIER DEBUG] ERRO: Item de upgrade não encontrado na configuração!")
    end
    
    -- Verifica se o item de upgrade é válido
    if not upgradeConfig then
        player:sendCancelMessage('This upgrade item is not configured.')
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end
    
    -- Verifica se o item alvo pode receber tier
    if not canItemReceiveTier(target) then
        player:sendCancelMessage('This item cannot receive tier upgrades.')
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        print(string.format("[TIER DEBUG] Falha: Item %d não pode receber tier", targetId))
        return true
    end
    
    -- Obtém o tier atual do item
    local currentTier = getItemTier(target)
    local maxTier = 10 -- Tier máximo configurado no sistema
    
    -- DEBUG: Tier atual
    print(string.format("[TIER DEBUG] Item alvo: %s (ID: %d)", target:getName(), targetId))
    print(string.format("[TIER DEBUG] Tier atual: %d", currentTier))
    
    -- Verifica se já está no tier máximo
    if currentTier >= maxTier then
        player:sendCancelMessage(string.format('This item is already at maximum tier (%d).', maxTier))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        print(string.format("[TIER DEBUG] Falha: Item já está no tier máximo (%d)", maxTier))
        return true
    end
    
    -- Calcula o novo tier
    local newTier = math.min(currentTier + upgradeConfig.tierAdd, maxTier)
    
    -- DEBUG: Novo tier calculado
    print(string.format("[TIER DEBUG] Novo tier calculado: %d (atual: %d + add: %d)", newTier, currentTier, upgradeConfig.tierAdd))
    
    -- Aplica o tier ao item
    local success, errorMsg = pcall(function()
        setItemTier(target, newTier)
    end)
    
    if not success then
        player:sendCancelMessage('Failed to apply tier upgrade. Error: ' .. tostring(errorMsg))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        print(string.format("[TIER DEBUG] ERRO ao aplicar tier: %s", tostring(errorMsg)))
        return true
    end
    
    -- Verifica se o tier foi aplicado corretamente
    local verifiedTier = getItemTier(target)
    
    -- DEBUG: Verificação final
    print(string.format("[TIER DEBUG] Tier após aplicar: %d", verifiedTier))
    print(string.format("[TIER DEBUG] Tier esperado: %d", newTier))
    
    if verifiedTier == newTier then
        -- Atualiza a descrição do item com o tier
        updateItemDescription(target)
        
        -- Sucesso
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Successfully upgraded %s to tier %d!", target:getName(), newTier))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
        item:remove(1)
        playSound(player, "success.ogg")
        print(string.format("[TIER DEBUG] SUCESSO: Tier %d aplicado ao item %s (ID: %d)", newTier, target:getName(), targetId))
    else
        -- Falha na verificação
        player:sendCancelMessage(string.format('Tier upgrade failed verification. Expected: %d, Got: %d', newTier, verifiedTier))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        print(string.format("[TIER DEBUG] ERRO: Verificação falhou! Esperado: %d, Obtido: %d", newTier, verifiedTier))
    end

    return true
end

-- Registra todos os itens de upgrade de tier
-- Lista direta para evitar problemas com unpack
upgradeAction:id(
    27134, 27135, 27136, -- Common
    27137, 27138, 27139, -- Rare
    27140, 27141, 27142, -- Very Rare
    27143, 27144, 27145, -- Epic
    27146, 27147, 27148  -- Legendary
)
upgradeAction:register()

print(">> Tier Upgrade System Loaded - 15 upgrade items registered")
