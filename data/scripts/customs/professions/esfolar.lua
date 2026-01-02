local skinningTable = {
	tools = {
		[29838] = { chance = 70, items = {
			{ item = {5991}, newItem = 11236, decayId = 2907 },-- ovelha
			{ item = {6017}, newItem = 13159, decayId = 2994 },-- coelho
			{ item = {5970}, newItem = 29854, decayId = 2837 },-- deer
			{ item = {13513}, newItem = 29849, decayId = 13518 },-- white deer
		}},
		[29839] = { chance = 80, items = {
			{ item = {5991}, newItem = 11236, decayId = 2907 },-- ovelha
			{ item = {6017}, newItem = 13159, decayId = 2994 },-- coelho
			{ item = {5970}, newItem = 29854, decayId = 2837 },-- deer
			{ item = {13513}, newItem = 29849, decayId = 13518 },-- white deer
			{ item = {5968}, newItem = 29857, decayId = 2829 },-- lobo
			{ item = {6051}, newItem = 29850, decayId = 4294 },-- tigre
		}},
		[29840] = { chance = 85, items = {
			{ item = {5991}, newItem = 11236, decayId = 2907 },-- ovelha
			{ item = {6017}, newItem = 13159, decayId = 2994 },-- coelho
			{ item = {5970}, newItem = 29854, decayId = 2837 },-- deer
			{ item = {13513}, newItem = 29849, decayId = 13518 },-- white deer
			{ item = {5968}, newItem = 29857, decayId = 2829 },-- lobo
			{ item = {6051}, newItem = 29850, decayId = 4294 },-- tigre
			{ item = {3109}, newItem = 5896, decayId = 2896 },-- urso
			{ item = {13311}, newItem = 30044, decayId = 13311 },-- boar
			{ item = {11430}, newItem = 29870, decayId = 11433 },-- caiam
		}},
		[29841] = { chance = 90, items = {
			{ item = {5991}, newItem = 11236, decayId = 2907 },-- ovelha
			{ item = {6017}, newItem = 13159, decayId = 2994 },-- coelho
			{ item = {5970}, newItem = 29854, decayId = 2837 },-- deer
			{ item = {13513}, newItem = 29849, decayId = 13518 },-- white deer
			{ item = {5968}, newItem = 29857, decayId = 2829 },-- lobo
			{ item = {6051}, newItem = 29850, decayId = 4294 },-- tigre
			{ item = {3109}, newItem = 5896, decayId = 2896 },-- urso
			{ item = {13311}, newItem = 30044, decayId = 13311 },-- boar
			{ item = {11430}, newItem = 29870, decayId = 11433 },-- caiam
			{ item = {5666}, newItem = 29859, decayId = 5668 },-- mammut
			{ item = {5969}, newItem = 5878, decayId = 2834 },-- minotauro
		}},
		[5908] = { chance = 92, items = {
			{ item = {5991}, newItem = 11236, decayId = 2907 },-- ovelha
			{ item = {6017}, newItem = 13159, decayId = 2994 },-- coelho
			{ item = {5970}, newItem = 29854, decayId = 2837 },-- deer
			{ item = {13513}, newItem = 29849, decayId = 13518 },-- white deer
			{ item = {5968}, newItem = 29857, decayId = 2829 },-- lobo
			{ item = {6051}, newItem = 29850, decayId = 4294 },-- tigre
			{ item = {3109}, newItem = 5896, decayId = 2896 },-- urso
			{ item = {13311}, newItem = 30044, decayId = 13311 },-- boar
			{ item = {11430}, newItem = 29870, decayId = 11433 },-- caiam
			{ item = {5666}, newItem = 29859, decayId = 5668 },-- mammut
			{ item = {5969}, newItem = 5878, decayId = 2834 },-- minotauro
			{ item = {25398}, newItem = 30047, decayId = 25401 },-- clomp
			{ item = {3104}, newItem = 5877, decayId = 3107 },-- dragon
		}},
		[29842] = { chance = 95, items = {
			{ item = {5991}, newItem = 11236, decayId = 2907 },-- ovelha
			{ item = {6017}, newItem = 13159, decayId = 2994 },-- coelho
			{ item = {5970}, newItem = 29854, decayId = 2837 },-- deer
			{ item = {13513}, newItem = 29849, decayId = 13518 },-- white deer
			{ item = {5968}, newItem = 29857, decayId = 2829 },-- lobo
			{ item = {6051}, newItem = 29850, decayId = 4294 },-- tigre
			{ item = {3109}, newItem = 5896, decayId = 2896 },-- urso
			{ item = {13311}, newItem = 30044, decayId = 13311 },-- boar
			{ item = {11430}, newItem = 29870, decayId = 11433 },-- caiam
			{ item = {5666}, newItem = 29859, decayId = 5668 },-- mammut
			{ item = {5969}, newItem = 5878, decayId = 2834 },-- minotauro
			{ item = {25398}, newItem = 30047, decayId = 25401 },-- clomp
			{ item = {3104}, newItem = 5877, decayId = 3107 },-- dragon
			{ item = {5984}, newItem = 5948, decayId = 3107 },-- dragon lord
			{ item = {5995}, newItem = 5906, decayId = 2919 },-- demon
		}},
	},
	successEffect = CONST_ME_MAGIC_GREEN,
	failEffect = CONST_ME_POFF,
}

local activePlayers = {}
local originalPositions = {}

local function findSkinItem(configItems, targetId)
	for _, v in ipairs(configItems) do
		for _, id in ipairs(v.item) do
			if id == targetId then
				return v
			end
		end
	end
	return nil
end

local function registerSkinningTool(toolId)
	local action = Action()
	action:id(toolId)

	function action.onUse(player, item, fromPos, target, toPos, isHotkey)
		if activePlayers[player:getId()] then
			return player:sendCancelMessage("Você já está esfolando.")
		end

		local toolConfig = skinningTable.tools[toolId]
		local skin = findSkinItem(toolConfig.items, target:getId())
		if not skin then
			return player:sendCancelMessage("Esse corpo não pode ser esfolado com essa faca.")
		end

		activePlayers[player:getId()] = true
		originalPositions[player:getId()] = player:getPosition()

		-- Inicia o efeito imediatamente ao usar a ferramenta
		toPos:sendMagicEffect(163) -- Efeito de esfolar

		local function reset()
			activePlayers[player:getId()] = nil
			originalPositions[player:getId()] = nil
		end

		local function applyEffect()
			if not player or not player:isPlayer() then return end
			if player:getPosition() ~= originalPositions[player:getId()] then
				player:sendCancelMessage("Você se moveu.")
				reset()
				return
			end

			local success = math.random(100) <= toolConfig.chance
			if success then
				if player:addItem(skin.newItem, 1) then
					player:say("Você coletou com sucesso!", TALKTYPE_MONSTER_SAY)
					target:transform(skin.decayId) -- Transforma o corpo no decayId
					toPos:sendMagicEffect(skinningTable.successEffect)
				else
					player:sendCancelMessage("Você não tem espaço na mochila.")
				end
			else
				player:say("Falha ao coletar.", TALKTYPE_MONSTER_SAY)
				toPos:sendMagicEffect(skinningTable.failEffect)
			end

			reset()
		end

		applyEffect() -- Chama a função de aplicar efeito imediatamente

		return true
	end

	action:register()
end

for toolId, _ in pairs(skinningTable.tools) do
	registerSkinningTool(toolId)
end
