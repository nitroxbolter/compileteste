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
	
	-- Atualiza a descrição do item com o tier
	local baseDescription = ItemType(item:getId()):getDescription()
	local currentDesc = item:getAttribute(ITEM_ATTRIBUTE_DESCRIPTION) or ""
	
	-- Remove qualquer descrição de tier anterior
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

function onSay(player, words, param)
	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	-- Busca o item primeiro (na frente ou na mão)
	local item = nil
	
	-- Primeiro tenta pegar o item na frente do jogador (no chão)
	local position = player:getPosition()
	position:getNextPosition(player:getDirection())
	local tile = Tile(position)
	
	if tile then
		local thing = tile:getTopVisibleThing(player)
		if thing and thing:isItem() then
			item = thing
		end
	end
	
	-- Se não encontrou na frente, tenta na mão
	if not item then
		item = player:getSlotItem(CONST_SLOT_LEFT)
		if not item then
			item = player:getSlotItem(CONST_SLOT_RIGHT)
		end
	end

	if not item then
		player:sendCancelMessage("Você precisa ter um item na sua frente ou na mão.")
		print(string.format("[TIER DEBUG] /god tier - Player %s não tem item na frente ou na mão", player:getName()))
		return false
	end
	
	print(string.format("[TIER DEBUG] /god tier - Item encontrado: %s (ID: %d)", item:getName(), item:getId()))

	if param == "" or param == nil then
		-- Se não tem parâmetro, mostra as informações do item automaticamente
		local tier = getItemTier(item)
		local classification = item:getAttribute(ITEM_ATTRIBUTE_CLASSIFICATION) or 0
		
		local classificationName = "Nenhuma"
		if classification == 1 then
			classificationName = "Improved"
		elseif classification == 2 then
			classificationName = "Exalted"
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("=== Informações do Item: %s ===", item:getName()))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Tier: %d %s", tier, tier > 0 and "(Aplicado)" or "(Sem tier)"))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Classification: %s (%d)", classificationName, classification))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Item ID: %d", item:getId()))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Uso: /god tier [add/remove/info] [tier]")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Exemplos:")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/god tier add 5 - Adiciona tier 5 ao item na mão")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/god tier remove - Remove tier do item na mão")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "/god tier info - Mostra informações do tier do item")
		return false
	end

	local params = param:split(" ")
	local command = params[1]:lower()

	if command == "add" then
		if not params[2] then
			player:sendCancelMessage("Uso: /god tier add [tier] (1-10)")
			return false
		end

		local tier = tonumber(params[2])
		if not tier or tier < 1 or tier > 10 then
			player:sendCancelMessage("Tier deve ser um número entre 1 e 10.")
			return false
		end

		local currentTier = getItemTier(item)
		
		-- DEBUG: Aplicando tier
		print(string.format("[TIER DEBUG] /god tier add - Player: %s", player:getName()))
		print(string.format("[TIER DEBUG] Item: %s (ID: %d)", item:getName(), item:getId()))
		print(string.format("[TIER DEBUG] Tier ANTES: %d", currentTier))
		print(string.format("[TIER DEBUG] Tier A APLICAR: %d", tier))
		
		setItemTier(item, tier)
		
		-- Verifica se foi aplicado
		local verifiedTier = getItemTier(item)
		print(string.format("[TIER DEBUG] Tier APÓS aplicar: %d", verifiedTier))
		
		if verifiedTier == tier then
			print(string.format("[TIER DEBUG] SUCESSO: Tier %d aplicado corretamente", tier))
		else
			print(string.format("[TIER DEBUG] ERRO: Tier não foi aplicado! Esperado: %d, Obtido: %d", tier, verifiedTier))
		end
		
		item:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Tier do item '%s' alterado de %d para %d.", 
			item:getName(), currentTier, tier))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("[DEBUG] Tier verificado: %d", verifiedTier))
		
		return false

	elseif command == "remove" then
		local currentTier = getItemTier(item)
		local currentClassification = item:getAttribute(ITEM_ATTRIBUTE_CLASSIFICATION) or 0
		
		if currentTier == 0 and currentClassification == 0 then
			player:sendCancelMessage("Este item não possui tier ou classification.")
			return false
		end

		item:removeCustomAttribute("tier")
		item:removeAttribute(ITEM_ATTRIBUTE_CLASSIFICATION)
		
		item:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Tier e classification removidos do item '%s'.", item:getName()))
		
		return false

	elseif command == "info" then
		local tier = getItemTier(item)
		local classification = item:getAttribute(ITEM_ATTRIBUTE_CLASSIFICATION) or 0
		
		print(string.format("[TIER DEBUG] /god tier info - Tier encontrado: %d", tier))
		
		local classificationName = "Nenhuma"
		if classification == 1 then
			classificationName = "Improved"
		elseif classification == 2 then
			classificationName = "Exalted"
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("=== Informações do Item: %s ===", item:getName()))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Tier: %d %s", tier, tier > 0 and "(Aplicado)" or "(Sem tier)"))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Classification: %s (%d)", classificationName, classification))
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
			string.format("Item ID: %d", item:getId()))
		
		return false

	elseif command == "set" then
		-- Comando alternativo: /god tier set [tier]
		if not params[2] then
			player:sendCancelMessage("Uso: /god tier set [tier] (0-10, 0 remove o tier)")
			return false
		end

		local tier = tonumber(params[2])
		if not tier or tier < 0 or tier > 10 then
			player:sendCancelMessage("Tier deve ser um número entre 0 e 10 (0 remove o tier).")
			return false
		end

		if tier == 0 then
			local currentTier = getItemTier(item)
			print(string.format("[TIER DEBUG] /god tier set 0 - Removendo tier %d do item %s", currentTier, item:getName()))
			item:removeCustomAttribute("tier")
			local verifiedTier = getItemTier(item)
			print(string.format("[TIER DEBUG] Tier após remover: %d", verifiedTier))
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
				string.format("Tier removido do item '%s'.", item:getName()))
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
				string.format("[DEBUG] Tier verificado após remoção: %d", verifiedTier))
		else
			local currentTier = getItemTier(item)
			print(string.format("[TIER DEBUG] /god tier set %d - Player: %s", tier, player:getName()))
			print(string.format("[TIER DEBUG] Item: %s (ID: %d)", item:getName(), item:getId()))
			print(string.format("[TIER DEBUG] Tier ANTES: %d", currentTier))
			print(string.format("[TIER DEBUG] Tier A APLICAR: %d", tier))
			setItemTier(item, tier)
			local verifiedTier = getItemTier(item)
			print(string.format("[TIER DEBUG] Tier APÓS aplicar: %d", verifiedTier))
			if verifiedTier == tier then
				print(string.format("[TIER DEBUG] SUCESSO: Tier %d aplicado corretamente", tier))
			else
				print(string.format("[TIER DEBUG] ERRO: Tier não foi aplicado! Esperado: %d, Obtido: %d", tier, verifiedTier))
			end
			item:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
				string.format("Tier do item '%s' definido para %d.", item:getName(), tier))
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
				string.format("[DEBUG] Tier verificado: %d", verifiedTier))
		end
		
		return false

	elseif command == "classification" or command == "class" then
		-- Comando para gerenciar classification: /god tier classification [set/remove] [level]
		if not params[2] then
			player:sendCancelMessage("Uso: /god tier classification [set/remove] [level]")
			player:sendCancelMessage("Levels: 0 = Base, 1 = Improved, 2 = Exalted")
			return false
		end

		local subCommand = params[2]:lower()

		if subCommand == "remove" then
			item:removeAttribute(ITEM_ATTRIBUTE_CLASSIFICATION)
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
				string.format("Classification removida do item '%s'.", item:getName()))
			return false
		elseif subCommand == "set" then
			if not params[3] then
				player:sendCancelMessage("Uso: /god tier classification set [level] (0-2)")
				return false
			end

			local level = tonumber(params[3])
			if not level or level < 0 or level > 2 then
				player:sendCancelMessage("Classification deve ser entre 0 e 2 (0=Base, 1=Improved, 2=Exalted).")
				return false
			end

			local classificationNames = {"Base", "Improved", "Exalted"}
			item:setAttribute(ITEM_ATTRIBUTE_CLASSIFICATION, level)
			item:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
				string.format("Classification do item '%s' definida para %s (%d).", 
				item:getName(), classificationNames[level + 1] or "Unknown", level))
			return false
		end
	else
		-- Se não for nenhum comando conhecido, tenta interpretar como número direto
		local tier = tonumber(command)
		if tier and tier >= 0 and tier <= 10 then
			if tier == 0 then
				local currentTier = getItemTier(item)
				print(string.format("[TIER DEBUG] /god tier %d (direto) - Removendo tier %d do item %s", tier, currentTier, item:getName()))
				item:removeCustomAttribute("tier")
				local verifiedTier = getItemTier(item)
				print(string.format("[TIER DEBUG] Tier após remover: %d", verifiedTier))
				item:getPosition():sendMagicEffect(CONST_ME_POFF)
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
					string.format("Tier removido do item '%s'.", item:getName()))
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
					string.format("[DEBUG] Tier verificado após remoção: %d", verifiedTier))
			else
				local currentTier = getItemTier(item)
				print(string.format("[TIER DEBUG] /god tier %d (direto) - Player: %s", tier, player:getName()))
				print(string.format("[TIER DEBUG] Item: %s (ID: %d)", item:getName(), item:getId()))
				print(string.format("[TIER DEBUG] Tier ANTES: %d", currentTier))
				print(string.format("[TIER DEBUG] Tier A APLICAR: %d", tier))
				setItemTier(item, tier)
				local verifiedTier = getItemTier(item)
				print(string.format("[TIER DEBUG] Tier APÓS aplicar: %d", verifiedTier))
				if verifiedTier == tier then
					print(string.format("[TIER DEBUG] SUCESSO: Tier %d aplicado corretamente", tier))
				else
					print(string.format("[TIER DEBUG] ERRO: Tier não foi aplicado! Esperado: %d, Obtido: %d", tier, verifiedTier))
				end
				item:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
					string.format("Tier do item '%s' definido para %d.", item:getName(), tier))
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 
					string.format("[DEBUG] Tier verificado: %d", verifiedTier))
			end
			return false
		else
			player:sendCancelMessage("Comando inválido. Use: add, remove, info, set, ou classification")
			return false
		end
	end

	return false
end

