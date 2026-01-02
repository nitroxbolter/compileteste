function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local item = nil
	
	-- Primeiro tenta pegar o item na mão
	item = player:getSlotItem(CONST_SLOT_LEFT)
	if not item then
		item = player:getSlotItem(CONST_SLOT_RIGHT)
	end
	
	-- Se não tem na mão, tenta pegar o item na frente
	if not item then
		local position = player:getPosition()
		position:getNextPosition(player:getDirection())
		local tile = Tile(position)
		
		if tile then
			local thing = tile:getTopVisibleThing(player)
			if thing and thing:isItem() then
				item = thing
			end
		end
	end
	
	if not item then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa segurar um item na mão ou ter um item na sua frente.")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Nenhum item encontrado na mão ou na frente.")
		print(string.format("[TIER DEBUG] /tier - Player %s não tem item na mão ou na frente", player:getName()))
		return false
	end
	
	print(string.format("[TIER DEBUG] /tier - Item encontrado: %s (ID: %d)", item:getName(), item:getId()))
	
	-- Se não tem parâmetro, mostra o tier atual
	if param == "" or not param then
		-- DEBUG: Informações básicas do item
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Item encontrado: " .. item:getName())
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Item ID: " .. item:getId())
		
		-- Proteção para getUniqueId
		local success, uid = pcall(function() return item:getUniqueId() end)
		if success then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Item UID: " .. tostring(uid))
		else
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Item UID: (não disponível)")
		end
		
		-- DEBUG: Verificar atributos críticos ANTES de aplicar tier
		local critChance = 0
		local critAmount = 0
		local success, rarityAttrs = pcall(function() 
			if item.getRarityAttributes then
				return item:getRarityAttributes()
			end
			return nil
		end)
		
		-- TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE = 26, TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT = 27
		local CRITICAL_HIT_CHANCE_ID = 26
		local CRITICAL_HIT_AMOUNT_ID = 27
		
		if success and rarityAttrs and type(rarityAttrs) == "table" then
			for _, attr in ipairs(rarityAttrs) do
				if attr.id == CRITICAL_HIT_CHANCE_ID then
					critChance = attr.value or 0
				elseif attr.id == CRITICAL_HIT_AMOUNT_ID then
					critAmount = attr.value or 0
				end
			end
		end
		
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[DEBUG] Critical Chance: %d | Critical Amount: %d", critChance, critAmount))
		print(string.format("[TIER DEBUG] Item %s (ID: %d) - Critical Chance: %d | Critical Amount: %d", item:getName(), item:getId(), critChance, critAmount))
		
		-- Obtém o tier usando custom attribute
		local tierAttr = item:getCustomAttribute("tier")
		local tier = 0
		if tierAttr then
			if type(tierAttr) == "number" then
				tier = tierAttr
			else
				tier = tonumber(tierAttr) or 0
			end
		end
		
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] getCustomAttribute('tier') = " .. tostring(tierAttr))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Tier extraído: " .. tostring(tier))
		local classification = item:getAttribute(ITEM_ATTRIBUTE_CLASSIFICATION) or 0
		
		local classificationName = "Nenhuma"
		if classification == 1 then
			classificationName = "Improved"
		elseif classification == 2 then
			classificationName = "Exalted"
		end
		
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("=== Informações do Item: %s ===", item:getName()))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Item ID: %d", item:getId()))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Tier: %d %s", tier, tier > 0 and "(Aplicado)" or "(Sem tier)"))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("Classification: %s (%d)", classificationName, classification))
		return false
	end

	-- Se tem parâmetro, define o tier
	local tierValue = tonumber(param)
	if not tierValue or tierValue < 0 or tierValue > 10 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Uso: /tier [valor] - Valor deve ser entre 0 e 10")
		return false
	end

	-- Define o tier
	local itemName = item:getName()
	local itemId = item:getId()
	
	-- Obtém tier atual
	local tierAttr = item:getCustomAttribute("tier")
	local tierBefore = 0
	if tierAttr then
		if type(tierAttr) == "number" then
			tierBefore = tierAttr
		else
			tierBefore = tonumber(tierAttr) or 0
		end
	end
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "========================================")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] === APLICANDO TIER ===")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Item: " .. itemName)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Item ID: " .. itemId)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Tier ANTES: " .. tierBefore)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Tier A APLICAR: " .. tierValue)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "========================================")
	
	if tierValue == 0 then
		print(string.format("[TIER DEBUG] /tier 0 - Removendo tier do item %s (ID: %d)", itemName, itemId))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Removendo tier do item...")
		item:removeCustomAttribute("tier")
		
		-- Remove o tier da descrição
		local baseDescription = ItemType(item:getId()):getDescription()
		local currentDesc = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION) or ""
		if currentDesc:find("Tier:") then
			local cleanedDesc = currentDesc:gsub("\nTier: %d+", "")
			cleanedDesc = cleanedDesc:gsub("Tier: %d+", "")
			if cleanedDesc == baseDescription or cleanedDesc == "" then
				item:removeAttribute(ITEM_ATTRIBUTE_DESCRIPTION)
			else
				item:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, cleanedDesc)
			end
		end
		local verifiedTierAttr = item:getCustomAttribute("tier")
		local verifiedTier = 0
		if verifiedTierAttr then
			if type(verifiedTierAttr) == "number" then
				verifiedTier = verifiedTierAttr
			else
				verifiedTier = tonumber(verifiedTierAttr) or 0
			end
		end
		print(string.format("[TIER DEBUG] Tier após remover: %d", verifiedTier))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, ">>> Tier removido do item: " .. itemName)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Tier verificado após remoção: " .. verifiedTier)
		-- Usa a posição do player para evitar crash
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	else
		print(string.format("[TIER DEBUG] /tier %d - Player: %s", tierValue, player:getName()))
		print(string.format("[TIER DEBUG] Item: %s (ID: %d)", itemName, itemId))
		print(string.format("[TIER DEBUG] Tier ANTES: %d", tierBefore))
		print(string.format("[TIER DEBUG] Tier A APLICAR: %d", tierValue))
		
		-- Proteção para setCustomAttribute
		local success, errorMsg = pcall(function()
			item:setCustomAttribute("tier", tierValue)
			
			-- Atualiza a descrição do item com o tier
			local baseDescription = ItemType(item:getId()):getDescription()
			local currentDesc = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION) or ""
			
			-- Remove qualquer descrição de tier anterior
			if currentDesc:find("Tier:") then
				currentDesc = currentDesc:gsub("\nTier: %d+", "")
				currentDesc = currentDesc:gsub("Tier: %d+", "")
			end
			
			-- Adiciona o tier na descrição se for maior que 0
			if tierValue > 0 then
				local newDescription = baseDescription
				if currentDesc ~= "" and currentDesc ~= baseDescription then
					newDescription = currentDesc
				end
				newDescription = newDescription .. "\nTier: " .. tierValue
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
		end)
		
		if not success then
			print(string.format("[TIER DEBUG] ERRO ao aplicar tier: %s", tostring(errorMsg)))
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] ERRO ao definir tier: " .. tostring(errorMsg))
			return false
		end
		
		-- DEBUG: Verificar se os atributos críticos ainda estão presentes após aplicar tier
		local critChance = 0
		local critAmount = 0
		local success, rarityAttrs = pcall(function() 
			if item.getRarityAttributes then
				return item:getRarityAttributes()
			end
			return nil
		end)
		
		-- TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE = 26, TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT = 27
		local CRITICAL_HIT_CHANCE_ID = 26
		local CRITICAL_HIT_AMOUNT_ID = 27
		
		if success and rarityAttrs and type(rarityAttrs) == "table" then
			for _, attr in ipairs(rarityAttrs) do
				if attr.id == CRITICAL_HIT_CHANCE_ID then
					critChance = attr.value or 0
				elseif attr.id == CRITICAL_HIT_AMOUNT_ID then
					critAmount = attr.value or 0
				end
			end
		end
		
		print(string.format("[TIER DEBUG] Após aplicar tier - Critical Chance: %d | Critical Amount: %d", critChance, critAmount))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[DEBUG] Critical Chance: %d | Critical Amount: %d", critChance, critAmount))
		
		-- Verifica se foi aplicado corretamente
		local verifiedTierAttr = item:getCustomAttribute("tier")
		local currentTier = 0
		if verifiedTierAttr then
			if type(verifiedTierAttr) == "number" then
				currentTier = verifiedTierAttr
			else
				currentTier = tonumber(verifiedTierAttr) or 0
			end
		end
		print(string.format("[TIER DEBUG] Tier APÓS aplicar: %d", currentTier))
		print(string.format("[TIER DEBUG] Tier esperado: %d", tierValue))
		
		if currentTier == tierValue then
			print(string.format("[TIER DEBUG] SUCESSO: Tier %d aplicado corretamente ao item %s", tierValue, itemName))
		else
			print(string.format("[TIER DEBUG] ERRO: Tier não foi aplicado! Esperado: %d, Obtido: %d", tierValue, currentTier))
		end
		
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, ">>> Tier " .. tierValue .. " aplicado no item: " .. itemName)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Tier verificado: " .. currentTier)
		-- Usa a posição do player para evitar crash
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end

	-- Verifica se foi aplicado corretamente (para ambos os casos)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Verificando se o tier foi salvo...")
	local verifiedTierAttr = item:getCustomAttribute("tier")
	local currentTier = 0
	if verifiedTierAttr then
		if type(verifiedTierAttr) == "number" then
			currentTier = verifiedTierAttr
		else
			currentTier = tonumber(verifiedTierAttr) or 0
		end
	end
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Tier lido após definir: " .. tostring(currentTier))
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[DEBUG] Tier esperado: " .. tostring(tierValue))
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "========================================")
	if currentTier == tierValue then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[SUCESSO] Tier " .. currentTier .. " confirmado no item: " .. itemName)
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[ERRO] Tier não foi aplicado corretamente!")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[ERRO] Item: " .. itemName .. " (ID: " .. itemId .. ")")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[ERRO] Esperado: " .. tierValue .. " | Obtido: " .. currentTier)
	end
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "========================================")
	
	return false
end

