-- Quest Storages
-- Sistema de storages para quests customizadas

QuestStorages = {
    -- Sistema de Vocação (Tutor)
    VocationChoice = {
        Started = 50001,        -- Quest iniciada
        ChoseVocation = 50002,  -- Vocação escolhida (1-4: Sorc, Druid, Paladin, Knight)
        Completed = 50003       -- Quest completa
    },
    
    -- Exemplo de outras quests
    Tutorial = {
        Started = 50010,
        Step1 = 50011,
        Step2 = 50012,
        Completed = 50013
    }
}

-- Função auxiliar para verificar se completou uma quest
function Player:hasCompletedQuest(questStorage)
    return self:getStorageValue(questStorage) > 0
end

-- Função auxiliar para iniciar uma quest
function Player:startQuest(questStorage)
    self:setStorageValue(questStorage, 1)
end

