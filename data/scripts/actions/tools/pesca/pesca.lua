fishingTable = {
	["waters"] = { 493, 4608, 4609, 4610, 4611, 4612, 4613, 4614, 4615, 4616, 4617, 4618, 4619, 4620, 4621, 4622, 4623, 4624, 4625, 7236, 10499, 15401, 15402 },

	-- Tabelas para cada tipo de vara
	varas = {
		[2580] = {
			maxDistanceToFish = 3,
			requiredSkillLevel = 1,
			tesouros = {
				{ itemId = 9817, quantity = 1, rarity = "Raro" },
			},
			peixes = {
				{itemId = 2667, name = "peixe normal"},
				{itemId = 30349, name = "siri"},
				{itemId = 30363, name = "robalo filhote"},
				{itemId = 30367, name = "lambari"},
			}
		},
		[30357] = {
			maxDistanceToFish = 6,
			requiredSkillLevel = 25,
			tesouros = {
				{ itemId = 9814, quantity = 1, rarity = "super dificil" },
				{ itemId = 9810, quantity = 1, rarity = "Ultra Raro" },
			},
			peixes = {
				{itemId = 30338, name = "enguia"},
				{itemId = 30339, name = "truta azulada"},
				{itemId = 30340, name = "peixe espinho"},
				{itemId = 30341, name = "tabacu"},
				{itemId = 30342, name = "salmonete"},
				{itemId = 30344, name = "linguado"},
				{itemId = 30345, name = "tilapia"},
				{itemId = 30346, name = "tubarino"},
				{itemId = 30352, name = "peixe abissal"},
				{itemId = 30353, name = "tucunare"},
				{itemId = 30354, name = "piranha"},
				{itemId = 30355, name = "peixe zumbi"},
				{itemId = 30356, name = "bagre"},
				{itemId = 30362, name = "robalo medio"},
				{itemId = 30363, name = "robalo"},
				{itemId = 30364, name = "salmão"},
			}
		},
		[30360] = {
			maxDistanceToFish = 8,
			requiredSkillLevel = 45,
			tesouros = {
				{ itemId = 30372, quantity = 1, rarity = "comum" },
			},
			peixes = {
				{itemId = 30347, name = "peixe brilhante"},
				{itemId = 30341, name = "tabacu"},
				{itemId = 30342, name = "salmonete"},
				{itemId = 30343, name = "dourado imperial"},
				{itemId = 30344, name = "linguado"},
				{itemId = 30345, name = "tilapia"},
				{itemId = 30346, name = "tubarino"},
				{itemId = 30350, name = "peixe espada"},
				{itemId = 30351, name = "dourado branco"},
				{itemId = 30348, name = "dourado"},
			}
		}
	},

	isFishing = 1000001,     -- storage do player / checa se está pescando
	boia = 30337,            -- id do item da boia na agua.
	efeito = 367,            -- efeito na agua de bolha
	tempoMin = 3,            -- mínimo tempo para pescar
	tempoMax = 25,           -- máximo tempo para pescar
	expPesca = 1,            -- exp da pesca
	chanceQuebrarLinha = 10, -- chance de quebrar a linha
	chanceTesouro = 5,      -- chance de vir o tesouro
}

local function registerFishingRod(rodId)
	local action = Action()
	action:id(rodId)
	action:allowFarUse(true)

	function action.onUse(player, item, fromPosition, target, toPosition)
		-- Verifica se o jogador tem a isca (ID 3976)
		if not player:removeItem(3976, 1) then
			return player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você está sem ISCAS!")
		end

		local fishingRodId = item:getId()
		local fishingData = fishingTable.varas[fishingRodId]

		-- Verifica se o jogador tem o nível de habilidade de pesca requerido
		local requiredSkillLevel = fishingData.requiredSkillLevel or 0
		if player:getSkillLevel(SKILL_FISHING) < requiredSkillLevel then
			return player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você precisa de nível " .. requiredSkillLevel .. " em pesca para usar esta vara!")
		end

		if not fishingData then
			return player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Essa vara de pesca não é válida!")
		end

		if not isInArray(fishingTable.waters, getTileInfo(toPosition).itemid) then
			return player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		end

		if player:isFishing() then
			return player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		end

		if isFishFar(player:getPosition(), toPosition, fishingData.maxDistanceToFish) then
			return player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Você não tem linha suficiente para alcançar!')
		end

		player:startFishing(toPosition, fishingRodId)
		return true
	end

	action:register()
end

-- Registra todas as varas de pesca
registerFishingRod(2580)
registerFishingRod(30357)
registerFishingRod(30360)

function Player:startFishing(toPos, fishingRodId)
	local tile = Tile(toPos)
	if not tile then
		return false
	end

	self:setStorageValue(fishingTable.isFishing, 1)

	local pesca = Game.createItem(fishingTable.boia, 1, toPos)
	pesca:setAttribute("name", "uma boia. Pertence a: " .. self:getName())

	-- Obter a habilidade de pesca do jogador
	local fishingSkill = self:getSkillLevel(SKILL_FISHING)
	

	-- Calcular a distância
	local maxDistance = fishingTable.varas[fishingRodId].maxDistanceToFish
	local distance = isFishFar(self:getPosition(), toPos, maxDistance) and maxDistance or math.floor(math.sqrt((self:getPosition().x - toPos.x)^2 + (self:getPosition().y - toPos.y)^2))
	

	-- Calcular o tempo de pesca com base na habilidade e na distância
	local timeFish = math.random(fishingTable.tempoMin, fishingTable.tempoMax) * 1000 -- Convertendo para milissegundos
	

	local timeReduction = math.floor(fishingSkill / 10) + math.floor(distance / 2) -- Exemplo de fórmula
	

	-- Aplicar a redução ao tempo de pesca
	timeFish = timeFish - (timeReduction * 1000) -- Reduzir em segundos

	-- Garantir que o tempo de pesca não seja menor que o mínimo
	if timeFish < fishingTable.tempoMin * 1000 then
		timeFish = fishingTable.tempoMin * 1000
	end

	

	-- Bloqueando movimento do jogador
	self:setMovementBlocked(true)
	local playerOutfit = self:getOutfit()

	if not playerOutfit then
		return false -- Retorna falso se o outfit não for válido
	end

	local outfits = {
		[PLAYERSEX_FEMALE] = 1395,
		[PLAYERSEX_MALE] = 1395,
	}

	local sex = self:getSex()
	if not outfits[sex] then
		return false -- Retorna falso se o sexo não estiver na tabela
	end

	-- Usando a condição para definir o look do jogador
	local outfit = {lookType = outfits[sex]}
	local condition = Condition(CONDITION_OUTFIT)
	condition:setTicks(timeFish) -- tempo em milissegundos
	condition:setOutfit(outfit)
	self:addCondition(condition)

	-- Efeitos mágicos durante a pesca
	addEvent(doSendMagicEffect, timeFish / 2, toPos, fishingTable.efeito)

	-- Direção do jogador
	local fishDirection = getLookToFish(self:getPosition(), toPos)
	self:setDirection(fishDirection)

	local selfId = self:getId()
	addEvent(function()
		local player = Player(selfId)
		if player then
			-- Chama a função fishCatch para determinar o resultado da pesca
			player:fishCatch(nil, nil, toPos, fishingRodId)
		end
	end, timeFish)
end

function Player:fishCatch(fishId, quantity, toPos, fishingRodId)
	self:stopFishing(toPos)

	local roll = math.random(100)

	if roll <= fishingTable.chanceQuebrarLinha then
		-- Perdeu o peixe
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A linha quebrou e você perdeu o peixe!")
		return true
	elseif roll <= (fishingTable.chanceQuebrarLinha + fishingTable.chanceTesouro) then
		-- Pegou um tesouro
		local tesouroData = fishingTable.varas[fishingRodId].tesouros
		if tesouroData and #tesouroData > 0 then
			local tesouro = tesouroData[math.random(#tesouroData)]
			self:addItem(tesouro.itemId, tesouro.quantity or 1)
			self:sendTextMessage(MESSAGE_EVENT_ADVANCE, ("Você pescou um tesouro de categoria: %s!"):format(tesouro.rarity))
			self:addFishingSkill()
		end
	else
		-- Pegou o peixe normalmente
		local peixeData = fishingTable.varas[fishingRodId].peixes
		if peixeData and #peixeData > 0 then
			local peixe = peixeData[math.random(#peixeData)]
			self:addItem(peixe.itemId, 1)
			self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você pescou um " .. peixe.name .. "!")
			self:addFishingSkill()
		end
	end
end

function clearFishing(baitPos, ownerFloater)
	for stack = 1, 10, 1 do
		baitPos.stackpos = stack
		local item = getThingfromPos(baitPos)
		if item and fishingTable.boia == item.itemid then
			local item = Item(item.uid)
			local name = item and item:getAttribute("name") or ""
			local player = name:match("uma boia. Pertence a: (.*)")
			if not ownerFloater or player == ownerFloater then
				if item then
					item:remove() -- Remove a boia
				end
				break
			end
		end
	end
end

function Player:stopFishing(baitPos)
    self:setMovementBlocked(false)
    self:setStorageValue(fishingTable.isFishing, -1)
	clearFishing(baitPos, self:getName())
	self:removeCondition(CONDITION_OUTFIT)
end

function isFishFar(from, to, maxDistance)
	local distanceX = math.abs(from.x - to.x)
	local distanceY = math.abs(from.y - to.y)
	local distance = math.sqrt(distanceX^2 + distanceY^2) -- Calcula a distância euclidiana

	if distance > maxDistance then
		return true
	end
	return false
end

function Player:isFishing()
	return self:getStorageValue(fishingTable.isFishing) == 1 and true or false
end

function getLookToFish(pos, pos2)
    if pos.y > pos2.y then
        return DIRECTION_NORTH
    elseif pos.y < pos2.y then
        return DIRECTION_SOUTH
    elseif pos.x < pos2.x then
        return DIRECTION_EAST
    elseif pos.x > pos2.x then
        return DIRECTION_WEST
    end
    return DIRECTION_WEST
end

local creatureEvent = CreatureEvent("OnLoginFishing")
function creatureEvent.onLogin(player)
    player:setStorageValue(fishingTable.isFishing, -1)
    return true
end
creatureEvent:register()

function Player:addFishingSkill()
    local skillLevel = self:getSkillLevel(SKILL_FISHING)

    -- Adiciona experiência de pesca se o jogador não atingiu o nível máximo
    if skillLevel < 999 then
        self:addSkillTries(SKILL_FISHING, fishingTable.expPesca)
    end
end