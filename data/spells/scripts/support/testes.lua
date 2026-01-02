-- Função para aplicar o efeito visual repetidamente
local function applyEffect(creatureId, ticksLeft)
    local creature = Creature(creatureId)
    if creature and ticksLeft > 0 then
        local position = creature:getPosition() -- Atualiza a posição do personagem a cada ciclo
        position:sendMagicEffect(300) -- Aplica o efeito visual na posição exata do personagem
        addEvent(applyEffect, 1000, creatureId, ticksLeft - 1000) -- Reaplica o efeito após 1 segundo
    end
end

function onCastSpell(creature, variant)
    playSound(creature, "utito.ogg")

    -- Inicia o efeito visual por 10 segundos
    applyEffect(creature:getId(), 10000) -- 10 segundos de efeito visual

    return true
end
