local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_NONE) -- Nenhum efeito imediato do combat
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_NONE) -- Sem projétil

-- Função para aplicar o efeito visual repetidamente na posição do personagem
local function applyEffect(creatureId, ticksLeft)
	local creature = Creature(creatureId)
	if creature and ticksLeft > 0 then
		-- Pegar a posição atual do personagem (atualiza caso ele se mova)
		local position = creature:getPosition()
		if position then
			-- Enviar efeito na posição do personagem com renderBelow=true
			-- Isso fará o efeito renderizar abaixo do personagem (entre o chão e a criatura)
			position:sendMagicEffect(299, true)
		end
		-- Agendar próximo efeito após 500ms (meio segundo)
		addEvent(applyEffect, 500, creatureId, ticksLeft - 500)
	end
end

function onCastSpell(creature, variant)
	-- Calcular dano baseado no nível e magic level
	local min = (creature:getLevel() / 5) + (creature:getMagicLevel() * 0.8) + 5
	local max = (creature:getLevel() / 5) + (creature:getMagicLevel() * 1.2) + 10
	combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, min, 0, max)
	
	-- Iniciar efeito visual repetitivo por 10 segundos na posição do personagem
	-- Inicia ANTES do combat para o efeito aparecer imediatamente
	applyEffect(creature:getId(), 10000)
	
	-- Executar o combate
	return combat:execute(creature, variant)
end

