-- FunÃ§Ã£o para converter Ã­ndice de combate para tipo de resistÃªncia
local function indexToCombatType(index)
	local combatTypes = {
		[0] = "Physical",   -- COMBAT_PHYSICALDAMAGE
		[1] = "Energy",     -- COMBAT_ENERGYDAMAGE
		[2] = "Earth",      -- COMBAT_EARTHDAMAGE
		[3] = "Fire",       -- COMBAT_FIREDAMAGE
		[4] = "Undefined",  -- COMBAT_UNDEFINEDDAMAGE
		[5] = "Life Drain", -- COMBAT_LIFEDRAIN
		[6] = "Mana Drain", -- COMBAT_MANADRAIN
		[7] = "Healing",    -- COMBAT_HEALING
		[8] = "Drown",      -- COMBAT_DROWNDAMAGE
		[9] = "Ice",        -- COMBAT_ICEDAMAGE
		[10] = "Holy",      -- COMBAT_HOLYDAMAGE
		[11] = "Death",     -- COMBAT_DEATHDAMAGE
		[12] = "Water",     -- COMBAT_WATERDAMAGE
		[13] = "Arcane"     -- COMBAT_ARCANEDAMAGE
	}
	return combatTypes[index] or "Unknown"
end

-- FunÃ§Ã£o para processar atributos de raridade e adicionar tipos convertidos
local function processRarityAttributes(rarityAttributes)
	if not rarityAttributes then
		return nil
	end
	
	local processedAttributes = {}
	for i, attr in ipairs(rarityAttributes) do
		local processedAttr = {
			id = attr.id,
			value = attr.value
		}
		
		-- Se tem array de tipos, converter os Ã­ndices para nomes
		if attr.types and #attr.types > 0 then
			processedAttr.types = {}
			local hasDrown = false
			for j, typeIndex in ipairs(attr.types) do
				local typeName = indexToCombatType(typeIndex)
				if typeIndex == 8 then -- Drown
					hasDrown = true
				end
				table.insert(processedAttr.types, {
					index = typeIndex,
					name = typeName
				})
			end
			-- Debug apenas para itens Drown
			if hasDrown then
				print("[MARKET DEBUG] Drown resistance found in attribute ID", attr.id, "Value:", attr.value)
			end
		-- Se nÃ£o tem array de tipos mas tem campo 'type' (singular), criar array com um Ãºnico tipo
		elseif attr.type ~= nil then
			local typeIndex = attr.type
			local typeName = indexToCombatType(typeIndex)
			if typeIndex == 8 then -- Drown
				print("[MARKET DEBUG] Drown resistance found (single type) in attribute ID", attr.id, "Value:", attr.value)
			end
			processedAttr.types = {{
				index = typeIndex,
				name = typeName
			}}
		end
		
		table.insert(processedAttributes, processedAttr)
	end
	
	return processedAttributes
end

-- FunÃ§Ã£o auxiliar para enviar dados de refresh processados
local function sendProcessedRefresh(player, marketName, data)
	if data then
	-- Processar atributos de raridade se existirem
	for uid, offer in pairs(data) do
		if offer.rarityAttributes then
			-- Verificar se tem Drown antes de processar
			local hasDrownAttr = false
			for i, attr in ipairs(offer.rarityAttributes) do
				if attr.id == 12 then
					if attr.types then
						for j, typeIndex in ipairs(attr.types) do
							if typeIndex == 8 then -- Drown
								hasDrownAttr = true
								break
							end
						end
					elseif attr.type == 8 then -- Drown (campo singular)
						hasDrownAttr = true
					end
				end
			end
			
			-- Debug apenas para itens Drown
			if hasDrownAttr then
				print("[MARKET DEBUG] Item UID:", uid, "has Drown resistance attributes")
			end
			
			offer.rarityAttributes = processRarityAttributes(offer.rarityAttributes)
		end
	end
	end
	
	local refresh = json.encode({action = "Refresh", market = marketName, data = data})
	player:sendExtendedOpcode(96, refresh)
end

local marketing_area = {
	{["init"] = {x = 1063, y = 1046, z = 7}, ["end"]  = {x = 1120, y = 1089, z = 7}}, -- Nova Ã¡rea personalizada
	--{["init"] = {x = 33204, y = 32454, z = 9}, ["end"] = {x = 33224, y = 32467, z = 9}}, -- Darashia
	--{["init"] = {x = 33158, y = 31801, z = 11}, ["end"] = {x = 33178, y = 31815, z = 11}}, -- Edron
	--{["init"] = {x = 32618, y = 32736, z = 8}, ["end"] = {x = 32636, y = 32748, z = 8}}, -- Port Hope
	--{["init"] = {x = 32324, y = 31774, z = 9}, ["end"] = {x = 32345, y = 31786, z = 9}}, -- Carlin
	--{["init"] = {x = 32343, y = 32217, z = 4}, ["end"] = {x = 32355, y = 32232, z = 4}}, -- Thais
	--{["init"] = {x = 32677, y = 31682, z = 2}, ["end"] = {x = 32683, y = 31690, z = 2}}, -- Ab
	--{["init"] = {x = 32677, y = 31682, z = 1}, ["end"] = {x = 32683, y = 31690, z = 1}}, -- Ab
	-- Adicionar Ã¡rea que inclui PZ (Thais Temple)
	--{["init"] = {x = 32360, y = 32210, z = 7}, ["end"] = {x = 32370, y = 32220, z = 7}}, -- Thais Temple PZ
}

local marketMaxItems = 40

local subItems = 	{2316, 2266, 2291, 2290, 2310, 2261, 2277, 2279, 2262, 2292, 2313, 2301, 2303, 				-- Runas
					2302, 2305, 2304, 2311, 2265, 2287, 2293, 2273, 2285, 2289, 2286, 2308, 2268, 2273, 		-- Runas
					2671, 2666, 2672, 5109, 2789, 2667,															-- Foods
					1294, 2389, 2399, 2410, 2543, 2544, 2545, 2546, 5493, 5494}									-- MuniÃ§Ãµes
													
local subItemsRestritive = true

-- ADD TO DATABASE

local globalEvent = GlobalEvent("MarketingTables")
function globalEvent.onStartup()

	local columns_marketing_infos = [[(
		`player_id` int NOT NULL DEFAULT '0',
		`player_name` varchar(32) NOT NULL,
		`uid` int unsigned NOT NULL DEFAULT '0',
		`subitem` varchar(32) NOT NULL,
		`itemtype` smallint unsigned NOT NULL DEFAULT '0',
		`count` smallint NOT NULL DEFAULT '0',
		`price` bigint NOT NULL DEFAULT '0',
		`rarity` smallint NOT NULL DEFAULT '0',
		`attributes` blob NOT NULL,
		`completed` varchar(32) NOT NULL DEFAULT 'false',
		FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
	)]]
	if not db.tableExists("player_marketing") then
		db.query("CREATE TABLE `player_marketing` "..columns_marketing_infos.."")
	end

	local columns_marketing_reward_infos = [[(
		`player_name` varchar(32) NOT NULL,
		`uid` int unsigned NOT NULL DEFAULT '0',
		`reward` bigint NOT NULL DEFAULT '0',
		`completed` varchar(32) NOT NULL DEFAULT 'false'
	)]]
	if not db.tableExists("player_marketing_reward") then
		db.query("CREATE TABLE `player_marketing_reward` "..columns_marketing_reward_infos.."")
	end

	Game.loadMarketing()

	return true
end
globalEvent:register()

creatureEvent = CreatureEvent("MarketingLogin")
function creatureEvent.onLogin(player)
	player:registerEvent("MarketingInfo")

	local marketPos = nil
	for _, market in pairs(Game.getMonsters()) do
		if market:getName() == player:getName() then
			market:remove()
			marketPos = market:getPosition()
		end
	end

	if marketPos then
		player:teleportTo(player:getPosition())
	end

	local resultReward = db.storeQuery("SELECT * FROM `player_marketing_reward` WHERE `player_name` = "..db.escapeString(player:getName()).." AND `completed` = "..db.escapeString("false").."")
	if resultReward then
		local totalReward = 0
		repeat
			local reward = result.getNumber(resultReward, "reward")
			if reward then
				totalReward = totalReward + reward
			end
		until not result.next(resultReward)
		result.free(resultReward)
		
		-- Adiciona ao balance ao invÃ©s da mochila para evitar problemas de capacidade
		if totalReward > 0 then
			local currentBalance = player:getBankBalance()
			player:setBankBalance(currentBalance + totalReward)
		end
		
		db.query("UPDATE `player_marketing_reward` SET `completed` = 'true' WHERE `player_name` = "..db.escapeString(player:getName()).." AND `completed` = "..db.escapeString("false").."")
	end

	for _, pid in pairs(Game.getPlayers()) do
		local finish = json.encode({action = "Finish", market = player:getName()})
		pid:sendExtendedOpcode(96, finish)
	end

	return true
end

creatureEvent:register()

creatureEvent = CreatureEvent("MarketingInfo")
function creatureEvent.onExtendedOpcode(player, opcode, buffer)
	local buffer_status, buffer_decode = pcall(function() return json.decode(buffer) end)
	if opcode == 96 and buffer_status and buffer_decode then

		if buffer_decode.action == "Refresh" then
			local marketOffers = Game.getMarketingOffers(buffer_decode.market)
			sendProcessedRefresh(player, buffer_decode.market, marketOffers)

			-- Inclui o dinheiro da mochila + balance
			local money = tonumber(player:getMoney()) or 0
			local balance = tonumber(player:getBankBalance()) or 0
			local totalMoney = money + balance
			local coins = json.encode({action = "coins", data = {gold = totalMoney}})
			player:sendExtendedOpcode(96, coins)

		elseif buffer_decode.action == "Add" then

			if player:getSlotItem(3) then
				local item = player:getSlotItem(3):getItems()[buffer_decode.data.pos+1]
				if item then
					if item:getId() == Game.getItemTypeByClientId(buffer_decode.data.id):getId() then
						local itemCount = (item:getCharges() > 1 and item:getCharges()) or item:getCount()
						if itemCount >= buffer_decode.data.quant and buffer_decode.data.quant > 0 then
							local inMarketArea = false
							for _, area in pairs(marketing_area) do
								if player:getPosition().x >= area["init"].x and player:getPosition().x <= area["end"].x
								and player:getPosition().y >= area["init"].y and player:getPosition().y <= area["end"].y
								and player:getPosition().z >= area["init"].z and player:getPosition().z <= area["end"].z then
									inMarketArea = true
									break
								end
							end
							if inMarketArea then
								if ItemType(item:getId()):isContainer() then
									if #item:getItems() > 0 then
										local lastID = item:getItems()[1]:getId()
										for _, eachItem in pairs(item:getItems()) do
											if not table.contains(subItems, eachItem:getId()) then
												local msg = json.encode({action = "msg", data = {msg = "Não é permitido vender mochilas \n      com este tipo de item dentro."}})
												player:sendExtendedOpcode(96, msg)

												return false
											end

											if subItemsRestritive then
												if eachItem:getId() ~= lastID then
													local msg = json.encode({action = "msg", data = {msg = "Você só pode colocar um tipo \n de item na sua mochila."}})
													player:sendExtendedOpcode(96, msg)

													return false
												end
											end
										end
									end
								end

								if #Game.getMarketingOffers(player:getName()) >= marketMaxItems then
									local msg = json.encode({action = "msg", data = {msg = "O número máximo de itens que podem \n  ser colocados à venda no Mercado é "..marketMaxItems.."."}})
									player:sendExtendedOpcode(96, msg)
									return
								end

								-- if player:getStorageValue(175420) < os.time() then
								-- 	local msg = json.encode({action = "msg", data = {msg = "You need to purchase the Pack in the Store \n             to activate your Market."}})
								-- 	player:sendExtendedOpcode(96, msg)
								-- 	return false
								-- end

								-- Get the original rarity from the item using both systems for compatibility
								local originalRarity = item:getRarity() or 0
								local customRarity = item:getCustomAttribute("rarity")
								if customRarity then
									customRarity = tonumber(customRarity) or 0
								else
									customRarity = 0
								end
								
								-- Use the custom rarity if available, otherwise use getRarity()
								-- Sï¿½ considera raridade se realmente existir (maior que 0)
								local validRarity = 0
								if customRarity > 0 then
									validRarity = customRarity
								elseif originalRarity and originalRarity > 0 then
									validRarity = originalRarity
								end
								
								-- Additional validation: ensure stackable items can only have Common (1) or no rarity (0)
								if validRarity > 1 then
									local itemType = ItemType(item:getId())
									if itemType:isStackable() then
										validRarity = 1 -- Stackable sï¿½ pode ter Common se tiver raridade
									end
								end
								
								-- Corrige valores de raridade invï¿½lidos (valores muito altos)
								local finalRarity = validRarity
								if validRarity > 0 and validRarity > 6 then
									finalRarity = ((validRarity - 1) % 6) + 1
								end
								
								-- Para itens stackable, criar um item com a quantidade correta
								local itemToAdd = item
								local itemType = ItemType(item:getId())
								local requestedQuant = buffer_decode.data.quant or 1
								
								-- Gerar UID para o item (usado apenas para identificaï¿½ï¿½o no banco, nï¿½o como atributo do item)
								local uid = 65536
								local resultUID = db.storeQuery("SELECT * FROM `player_marketing` ORDER BY `uid` DESC LIMIT 1")
								if resultUID then
									uid = (result.getNumber(resultUID, "uid")+1 > uid and result.getNumber(resultUID, "uid")+1 or uid)
									result.free(resultUID)
								end
								
								-- Se precisar dividir o item (stackable com quantidade menor que total)
								if itemType:isStackable() and requestedQuant < itemCount then
									-- Remove qualquer UID antigo do item original antes do split
									if item:getCustomAttribute("uid") then
										item:removeCustomAttribute("uid")
									end
									
									-- Divide o item: cria uma cï¿½pia com a quantidade solicitada
									-- O split automaticamente reduz a quantidade do item original
									local splitItem = item:split(requestedQuant)
									if splitItem then
										-- Nï¿½O adicionar UID como atributo do item - serï¿½ passado apenas como parï¿½metro
										-- Isso evita que o item volte com UID e nï¿½o possa fazer stack
										itemToAdd = splitItem
									end
								else
									-- Se nï¿½o precisar dividir, remover qualquer UID existente antes de adicionar
									if itemToAdd:getCustomAttribute("uid") then
										itemToAdd:removeCustomAttribute("uid")
									end
								end
								
								-- Passar UID como parï¿½metro, nï¿½o como atributo do item
								Game.addMarketingOffer(player:getName(), uid, itemToAdd, false, buffer_decode.data.price, finalRarity)

								for _, pid in pairs(Game.getPlayers()) do
									sendProcessedRefresh(pid, buffer_decode.market, Game.getMarketingOffers(player:getName()))
								end
							else
								local msg = json.encode({action = "msg", data = {msg = "Vocï¿½ deve estar dentro das ï¿½reas permitidas \n do Mercado para adicionar/remover itens."}})
								player:sendExtendedOpcode(96, msg)
							end
						else
							local msg = json.encode({action = "msg", data = {msg = "A quantidade do item nï¿½o corresponde. \n Selecione o item novamente e nï¿½o o mova."}})
							player:sendExtendedOpcode(96, msg)
						end
					else
						local msg = json.encode({action = "msg", data = {msg = "O ID do item nï¿½o corresponde. \n  Selecione um item dentro da sua mochila principal e nÃ£o o mova."}})
						player:sendExtendedOpcode(96, msg)
					end
				else
					local msg = json.encode({action = "msg", data = {msg = "O item deve estar dentro da sua mochila principal."}})
					player:sendExtendedOpcode(96, msg)
				end
			end

		elseif buffer_decode.action == "Remove" then
			if not Game.removeMarketingOffer(player:getName(), buffer_decode.data.uid) then
				local msg = json.encode({action = "msg", data = {msg = "Falha ao remover item do mercado. \n        Por favor, tente novamente."}})
				player:sendExtendedOpcode(96, msg)
				return false
			end

			local msg = json.encode({action = "msg", data = {msg = "Item removido do mercado e \n        retornado para sua mochila."}})
			player:sendExtendedOpcode(96, msg)

			for _, pid in pairs(Game.getPlayers()) do
				sendProcessedRefresh(pid, buffer_decode.market, Game.getMarketingOffers(player:getName()))
			end

		elseif buffer_decode.action == "Buy" then

			local player_market = Player(buffer_decode.market)
			if not player_market then
				local priceAmount = 0
				local targetItem = nil
				for x, offer in pairs(Game.getMarketingOffers(buffer_decode.market)) do
					if offer.uid == buffer_decode.data.uid then
						priceAmount = offer.price*buffer_decode.data.quant
						targetItem = offer
						break
					end
				end
				
				if not targetItem then
					local msg = json.encode({action = "msg", data = {msg = "Item não encontrado no mercado."}})
					player:sendExtendedOpcode(96, msg)
					return false
				end
				
				local totalMoney = player:getMoney() + player:getBankBalance()
				if totalMoney < priceAmount then
					local msg = json.encode({action = "msg", data = {msg = "Você não tem moedas de ouro suficientes \n        para comprar este item."}})
					player:sendExtendedOpcode(96, msg)
					return false
				end
				
				local itemType = ItemType(targetItem.id)
				local itemWeight = itemType:getWeight() * buffer_decode.data.quant
				local playerCap = player:getFreeCapacity()
				
				if playerCap < itemWeight then
					local msg = json.encode({action = "msg", data = {msg = "Você encontrou um(a) " .. itemType:getName() .. " pesando " .. (itemWeight / 100) .. " oz. É muito pesado(a)."}})
					player:sendExtendedOpcode(96, msg)
					return false
				end
				
				local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
				if not backpack or backpack:getEmptySlots(false) < 1 then
					local msg = json.encode({action = "msg", data = {msg = "Sua mochila principal está cheia. Você precisa liberar 1 slot disponível para obter " .. itemType:getName() .. "."}})
					player:sendExtendedOpcode(96, msg)
					return false
				end
				
				if not Game.buyMarketingOffer(player, buffer_decode.market, buffer_decode.data.uid, buffer_decode.data.quant) then
					local msg = json.encode({action = "msg", data = {msg = "Falha ao comprar item. \n        Por favor, tente novamente."}})
					player:sendExtendedOpcode(96, msg)
					return false
				end

				-- Debita primeiro da mochila, depois do balance
				local moneyInBag = tonumber(player:getMoney()) or 0
				local balance = tonumber(player:getBankBalance()) or 0
				local debitFromBag = math.min(moneyInBag, priceAmount)
				local debitFromBalance = priceAmount - debitFromBag
				
				-- Remove da mochila primeiro (se houver)
				if debitFromBag > 0 then
					if not player:removeMoney(debitFromBag) then
						local msg = json.encode({action = "msg", data = {msg = "Falha ao processar pagamento. \n        Por favor, tente novamente."}})
						player:sendExtendedOpcode(96, msg)
						return false
					end
				end
				
				-- Remove do balance o restante (se necessÃ¡rio)
				if debitFromBalance > 0 then
					local currentBalance = tonumber(player:getBankBalance()) or 0
					if currentBalance < debitFromBalance then
						local msg = json.encode({action = "msg", data = {msg = "Falha ao processar pagamento. \n        Por favor, tente novamente."}})
						player:sendExtendedOpcode(96, msg)
						return false
					end
					player:setBankBalance(currentBalance - debitFromBalance)
				end

				-- Atualizar marketing em memï¿½ria apï¿½s compra parcial
				-- Nota: O cï¿½digo C++ atualiza o banco mas nï¿½o atualiza o item em memï¿½ria quando quant < dbCount
				-- Como workaround, recarregamos o marketing do banco para garantir que a quantidade esteja correta
				Game.loadMarketing()

				for _, pid in pairs(Game.getPlayers()) do
					sendProcessedRefresh(pid, buffer_decode.market, Game.getMarketingOffers(buffer_decode.market))
				end

				-- Inclui o dinheiro da mochila + balance
				local money = tonumber(player:getMoney()) or 0
				local balance = tonumber(player:getBankBalance()) or 0
				local totalMoney = money + balance
				local coins = json.encode({action = "coins", data = {gold = totalMoney}})
				player:sendExtendedOpcode(96, coins)
			end

		elseif buffer_decode.action == "Start" then

			local function formatMarketDescription(description)
				if #description > 40 then
					description = description:sub(1, 40) -- Return the string up to the character limit
				end

				local result = ""
				if #description > 20 then
					for i = 1, #description, 20 do
						result = ""..result..""..description:sub(i, i + 20 - 1).."\n"
					end
				else
					result = description
				end

				return result
			end


				local inMarketArea = true
				
				local randomPos = {
					{x = player:getPosition().x-1, y = player:getPosition().y-1, z = player:getPosition().z},
					{x = player:getPosition().x-1, y = player:getPosition().y, z = player:getPosition().z},
					{x = player:getPosition().x-1, y = player:getPosition().y+1, z = player:getPosition().z},
					{x = player:getPosition().x, y = player:getPosition().y-1, z = player:getPosition().z},
					{x = player:getPosition().x, y = player:getPosition().y, z = player:getPosition().z},
					{x = player:getPosition().x, y = player:getPosition().y+1, z = player:getPosition().z},
					{x = player:getPosition().x+1, y = player:getPosition().y-1, z = player:getPosition().z},
					{x = player:getPosition().x+1, y = player:getPosition().y, z = player:getPosition().z},
					{x = player:getPosition().x+1, y = player:getPosition().y+1, z = player:getPosition().z}
				}
				
				local checkCreature = false
				for _, pos in pairs(randomPos) do
					local tile = Tile(pos)
					if tile then
						if tile:getBottomCreature() then
							if tile:getBottomCreature():getId() ~= player:getId() then
								checkCreature = true
							end
						end
					end
				end

				if checkCreature then
					local msg = json.encode({action = "msg", data = {msg = "Você precisa de espaço ao seu redor \n     para abrir o seu Mercado."}})
					player:sendExtendedOpcode(96, msg)
					return false
				end


				local playerOutfit = player:getOutfit()
				local market = Game.createMonster("Market", player:getPosition(), true, true)
				if market then
					market:rename(player:getName())
					market:teleportTo(player:getPosition())
					market:setOutfit(playerOutfit)
					market:setMarketDescription(formatMarketDescription(buffer_decode.description))
					player:remove()
				else
					local altPos = Position(player:getPosition().x + 1, player:getPosition().y, player:getPosition().z)
					local marketAlt = Game.createMonster("Market", altPos, true, true)
					if marketAlt then
						marketAlt:remove()
					end
				end

		elseif buffer_decode.action == "Open" then

			local datted = {}
			for _, item in pairs(Game.getMarketingSubOffers(buffer_decode.data.market, buffer_decode.data.uid)) do
				table.insert(datted, {uid = 0, name = item:getName(), id = ItemType(item:getId()):getClientId(), quant = item:getCount(), price = 0, rarity = 0, look = "You see "..item:getDescription(0)..""})
			end

			if #datted <= 0 then
				return false
			end

			local refresh = json.encode({action = "Refresh", market = buffer_decode.market, data = datted, oppened = true})
			player:sendExtendedOpcode(96, refresh)

		elseif buffer_decode.action == "RefreshPos" then

			local refreshpos = json.encode({action = "marketpos", marketpos = marketing_area})
			player:sendExtendedOpcode(96, refreshpos)

		end

	end

	return true
end
creatureEvent:register()

EventCallback.onMoveItem = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if self:isPlayer() then
		local inMarketArea = false
		for _, area in pairs(marketing_area) do
			if self:getPosition().x >= area["init"].x and self:getPosition().x <= area["end"].x
			and self:getPosition().y >= area["init"].y and self:getPosition().y <= area["end"].y
			and self:getPosition().z >= area["init"].z and self:getPosition().z <= area["end"].z then
				inMarketArea = true
				break
			end
		end
		if inMarketArea then
			if self:getSlotItem(3) then
				if item == self:getSlotItem(3) then
					return RETURNVALUE_NOTPOSSIBLE
				end
			end
		end
	end
	return RETURNVALUE_NOERROR
end

EventCallback:register()