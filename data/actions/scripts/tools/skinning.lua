local config = {
	[29838] = { -- FACA DE PEDRA
		chance = 70,
		time = 10,
		items = {
			{item = {6017, 3119}, newItem = 13159}, -- pé de coelho
			{item = {5970, 3095}, newItem = 29854}, -- couro de cervo
			{item = {5968, 3086}, newItem = 29857}, -- couro de Lobo
		},
	},
	[29839] = { -- FACA DE BRONZE
		chance = 80,
		time = 8,
		items = {
			{item = {3104}, newItem = 5877},
			{item = {6017, 3119}, newItem = 13159}, -- pé de coelho
			{item = {5970, 3095}, newItem = 29854}, -- couro de cervo
			{item = {5968, 3086}, newItem = 29857}, -- couro de Lobo
		},
	},
	[29840] = { -- FACA DE FERRO
		chance = 85,
		time = 5,
		items = {
			{item = {6017, 3119}, newItem = 13159}, -- pé de coelho
			{item = {5970, 3095}, newItem = 29854}, -- couro de cervo
			{item = {6051, 4292}, newItem = 29850}, -- couro de tigre
			{item = {5969, 3090}, newItem = 5878}, -- couro de Minotauro
			{item = {6074, 5666}, newItem = 11224}, -- couro de mammoth
			{item = {5968, 3086}, newItem = 29857}, -- couro de Lobo
		},
	},
	[29841] = { -- FACA DE OURO
		chance = 90,
		time = 3,
		items = {
			{item = {3104}, newItem = 5877}, 	-- couro de dragão
			{item = {6017, 3119}, newItem = 13159}, -- pé de coelho
			{item = {5970, 3095}, newItem = 29854}, -- couro de cervo
			{item = {6051, 4292}, newItem = 29850}, -- couro de tigre
			{item = {5969, 3090}, newItem = 5878}, -- couro de Minotauro
			{item = {6074, 5666}, newItem = 11224}, -- couro de mammoth
			{item = {5968, 3086}, newItem = 29857}, -- couro de Lobo
		},
	},
	[5908] = { -- OBSIDIAN KNIFE
		chance = 92,
		time = 2,
		items = {
			{item = {3104}, newItem = 5877}, 	-- couro de dragão
			{item = {6017, 3119}, newItem = 13159}, -- pé de coelho
			{item = {5970, 3095}, newItem = 29854}, -- couro de cervo
			{item = {6051, 4292}, newItem = 29850}, -- couro de tigre
			{item = {5969, 3090}, newItem = 5878}, -- couro de Minotauro
			{item = {6074, 5666}, newItem = 11224}, -- couro de mammoth
			{item = {5968, 3086}, newItem = 29857}, -- couro de Lobo
		},
	},
	[29842] = { -- FACA DE DIAMANTE
		chance = 95,
		time = 0,
		items = {
			{item = {3104}, newItem = 5877}, 	-- couro de dragão
			{item = {6017, 3119}, newItem = 13159}, -- pé de coelho
			{item = {5970, 3095}, newItem = 29854}, -- couro de cervo
			{item = {6051, 4292}, newItem = 29850}, -- couro de tigre
			{item = {5969, 3090}, newItem = 5878}, -- couro de Minotauro
			{item = {6074, 5666}, newItem = 11224}, -- couro de mammoth
			{item = {5968, 3086}, newItem = 29857}, -- couro de Lobo
		},
	},	

}

local activePlayers = {}
local originalPosition = nil -- Variável para armazenar a posição original do jogador

-- Função para encontrar o item de pele
local function findSkinItem(configItems, targetId)
	for _, v in ipairs(configItems) do
		if type(v.item) == "table" then
			for _, id in ipairs(v.item) do
				if id == targetId then return v end
			end
		elseif v.item == targetId then
			return v
		end
	end
	return nil
end

-- Função principal chamada ao usar o item
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local skinConfig = config[item.itemid]

	if not skinConfig then
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		return true
	end

	-- Verifica se o jogador já está esfolando
	if activePlayers[player:getId()] then
		player:sendCancelMessage("Você já está esfolando um animal.")
		return true
	end

	activePlayers[player:getId()] = true

	local skin = findSkinItem(skinConfig.items, target.itemid)

	if not skin then
		player:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		activePlayers[player:getId()] = nil
		return true
	end

	local waitTime = skinConfig.time -- Pega o tempo da faca
	local chance = skinConfig.chance -- Pega a chance da faca
	local random = math.random(1, 100)

	local effect, transform = 163, true

	-- Função para aplicar o efeito após o delay
	local function applyEffect()
		toPosition:sendMagicEffect(effect)

		local itemType = ItemType(skin.newItem)
		local itemName = itemType and itemType:getName() or "item"

		if random <= chance then
			if player:addItem(skin.newItem, 1) then
				player:say("Você coletou " .. itemName .. " com sucesso!", TALKTYPE_MONSTER_SAY)
				target:remove() -- Remove o corpo após a coleta bem-sucedida
			else
				player:sendCancelMessage("Sua mochila está cheia. O item caiu no chão.")
				toPosition:sendMagicEffect(CONST_ME_GIFT_WRAPS) -- Efeito visual opcional
				Game.createItem(skin.newItem, 1, toPosition) -- Cria o item no chão
			end
		else
			-- Adicionando um atraso de 500 ms antes de ativar o efeito de falha
			addEvent(function()
				toPosition:sendMagicEffect(164)
				player:say('A tentativa de coleta falhou.', TALKTYPE_MONSTER_SAY)
			end, 500) -- 500 ms de atraso
		end
	
		activePlayers[player:getId()] = nil -- Resetar a contagem
	end

	-- Função para a contagem regressiva
	local function countdown(seconds)
		if seconds > 0 then
			toPosition:sendMagicEffect(163)
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Coletando " .. seconds .. " segundos.")
			addEvent(countdown, 1000, seconds - 1) -- Chama a função novamente após 1 segundo
		else
			applyEffect() -- Chama a função para aplicar o efeito após a contagem
		end
	end

	-- Função para verificar se o jogador se moveu
	local function checkMovement()
		if not activePlayers[player:getId()] then
			return -- Já foi cancelado ou terminou
		end

		if player:getPosition() ~= originalPosition then
			player:sendCancelMessage("Você está longe do corpo.")
			activePlayers[player:getId()] = nil
			return -- Interrompe tudo
		end

		addEvent(checkMovement, 1000) -- Checa a cada 1 segundo
	end

	-- Inicia a contagem e a verificação de movimento
	originalPosition = player:getPosition()
	countdown(waitTime)
	checkMovement()

	return true
end
