local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- Armazena o estado do diálogo para reabrir após fechar a loja
local dialogState = {}
-- Armazena o ID do NPC por player para garantir que sempre use o NPC correto
local npcIdCache = {}

-- Função auxiliar para obter o CID do NPC atual
-- Tenta obter o CID do NPC de forma mais confiável
local function getNpcId(cid)
    -- Se um cid foi fornecido e temos o ID em cache, usa ele
    if cid and npcIdCache[cid] then
        return npcIdCache[cid]
    end
    
    -- Tenta usar Npc() primeiro
    local npc = Npc()
    if npc then
        -- Tenta diferentes métodos para obter o ID
        local id = npc:getId()
        if id and id > 0 then
            -- Armazena no cache se cid foi fornecido
            if cid then
                npcIdCache[cid] = id
            end
            return id
        end
    end
    -- Fallback para getNpcCid()
    local fallbackId = getNpcCid()
    if cid and fallbackId then
        npcIdCache[cid] = fallbackId
    end
    return fallbackId
end

-- Função para reabrir o diálogo após fechar a loja
local function reopenDialogAfterTrade(cid, state)
    -- Verifica se ainda deve reabrir (se o estado ainda está ativo)
    if not dialogState[cid] then
        return
    end
    
    local player = Player(cid)
    if not player or not npcHandler:isFocused(cid) then
        dialogState[cid] = nil
        npcIdCache[cid] = nil
        return
    end
    
    -- Obtém o ID do NPC do cache ou tenta obter novamente
    local npcId = getNpcId(cid)
    if not npcId or npcId <= 0 then
        -- Se não conseguiu obter o ID, tenta novamente sem cache
        npcIdCache[cid] = nil
        npcId = getNpcId(cid)
    end
    
    -- Limpa o estado
    dialogState[cid] = nil
    
    -- Reabre o diálogo apropriado usando o ID correto
    if npcId and npcId > 0 then
        if state == "completed" then
            -- Já completou a quest
            local chosenVoc = player:getStorageValue(QuestStorages.VocationChoice.ChoseVocation)
            local vocName = vocations[chosenVoc] and vocations[chosenVoc].name or "Aventureiro"
            openNpcDialog(player, npcId, "eusou tutor teste\n\nAqui estão meus produtos! Veja a janela de trade.\n\nDeseja algo mais?", "Loja&Voltar&Fechar")
        else
            -- Ainda não escolheu vocação
            openNpcDialog(player, npcId, "eusou tutor teste\n\nAqui estão meus produtos! Veja a janela de trade.\n\nDeseja continuar escolhendo sua vocação?", "Sim&Voltar&Fechar")
        end
    end
end

function onThink()                     npcHandler:onThink()                     end
function onCreatureAppear(cid)         npcHandler:onCreatureAppear(cid)         end
function onCreatureDisappear(cid)      npcHandler:onCreatureDisappear(cid)      end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end

-- Informações das vocações
local vocations = {
    [1] = {
        name = "Sorcerer",
        vocationId = 1,
        description = "Mestres da magia elemental, especialistas em magias de ataque destrutivas. Usam o poder do fogo e energia para devastar seus inimigos.",
        spells = "Explosion, Great Fireball, Thunderstorm"
    },
    [2] = {
        name = "Druid",
        vocationId = 2,
        description = "Guardiões da natureza, dominam magias de cura e controle. Podem invocar criaturas e usar o poder da terra e gelo.",
        spells = "Heal Friend, Ice Wave, Terra Wave"
    },
    [3] = {
        name = "Paladin",
        vocationId = 3,
        description = "Arqueiros habilidosos que combinam ataques à distância com magias de suporte. Equilibram ataque físico e magia.",
        spells = "Divine Missile, Ethereal Spear, Sharpshooter"
    },
    [4] = {
        name = "Knight",
        vocationId = 4,
        description = "Guerreiros poderosos, mestres do combate corpo a corpo. Possuem alta defesa e podem usar armas pesadas com facilidade.",
        spells = "Berserk, Fierce Berserk, Groundshaker"
    }
}

function greetCallback(cid)
    local player = Player(cid)
    if not player then
        return true
    end
    
    npcHandler:addFocus(cid)
    
    -- Obtém e armazena o ID do NPC no cache
    local npcId = getNpcId(cid)
    
    -- Verifica se já escolheu vocação
    if player:getStorageValue(QuestStorages.VocationChoice.Completed) > 0 then
        local chosenVoc = player:getStorageValue(QuestStorages.VocationChoice.ChoseVocation)
        local vocName = vocations[chosenVoc] and vocations[chosenVoc].name or "Aventureiro"
        openNpcDialog(player, npcId, "eusou tutor teste\n\nOlá " .. player:getName() .. "!\n\nVejo que você já escolheu ser um " .. vocName .. ". Boa sorte em sua jornada!\n\nO que você deseja fazer?", "Loja&Fechar")
    else
        openNpcDialog(player, npcId, "eusou tutor teste\n\nBem-vindo, jovem aventureiro!\n\nEstou aqui para ajudá-lo a escolher sua vocação.\n\nVocê está pronto para conhecer as vocações disponíveis?", "Sim&Não&Loja&Fechar")
    end
    
    return false
end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
    
    local player = Player(cid)
    if not player then
        return false
    end
    
    local msg_lower = msg:lower()
    
    -- Já completou a quest
    if player:getStorageValue(QuestStorages.VocationChoice.Completed) > 0 then
        if msgcontains(msg_lower, "loja") then
            -- Fecha o diálogo customizado
            closeNpcDialog(player)
            
            -- Armazena o estado para reabrir o diálogo após fechar a loja
            dialogState[cid] = "completed"
            
            -- Processa o trade através do keywordHandler
            addEvent(function()
                local eventPlayer = Player(cid)
                if eventPlayer then
                    npcHandler.keywordHandler:processMessage(cid, "trade")
                    -- Reabre o diálogo após um tempo (assumindo que a loja foi fechada)
                    addEvent(function() reopenDialogAfterTrade(cid, "completed") end, 1500)
                end
            end, 100)
            
        elseif msgcontains(msg_lower, "trade") then
            -- Se estava esperando reabrir o diálogo, cancela
            if dialogState[cid] then
                dialogState[cid] = nil
            end
            -- Permite que o trade seja processado normalmente
            closeNpcDialog(player)
            return false
            
        elseif msgcontains(msg_lower, "voltar") or msgcontains(msg_lower, "back") then
            local chosenVoc = player:getStorageValue(QuestStorages.VocationChoice.ChoseVocation)
            local vocName = vocations[chosenVoc] and vocations[chosenVoc].name or "Aventureiro"
            openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nOlá " .. player:getName() .. "!\n\nVejo que você já escolheu ser um " .. vocName .. ". Boa sorte em sua jornada!\n\nO que você deseja fazer?", "Loja&Fechar")
            
        elseif msgcontains(msg_lower, "fechar") or msgcontains(msg_lower, "bye") then
            dialogState[cid] = nil
            npcIdCache[cid] = nil
            closeNpcDialog(player)
            npcHandler:releaseFocus(cid)
        end
        return true
    end
    
    -- Loja (antes de escolher vocação)
    if msgcontains(msg_lower, "loja") then
        -- Fecha o diálogo customizado
        closeNpcDialog(player)
        
        -- Armazena o estado para reabrir o diálogo após fechar a loja
        dialogState[cid] = "choosing"
        
        -- Processa o trade através do keywordHandler
        addEvent(function()
            local eventPlayer = Player(cid)
            if eventPlayer then
                npcHandler.keywordHandler:processMessage(cid, "trade")
                -- Reabre o diálogo após um tempo (assumindo que a loja foi fechada)
                addEvent(function() reopenDialogAfterTrade(cid, "choosing") end, 1500)
            end
        end, 100)
        
    elseif msgcontains(msg_lower, "trade") then
        -- Se estava esperando reabrir o diálogo, cancela
        if dialogState[cid] then
            dialogState[cid] = nil
        end
        -- Permite que o trade seja processado normalmente
        closeNpcDialog(player)
        return false
    
    -- Quer conhecer as vocações
    elseif msgcontains(msg_lower, "sim") or msgcontains(msg_lower, "yes") then
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nExcelente! Existem 4 vocações para você escolher:\n\n1. Sorcerer - Magia de Ataque\n2. Druid - Magia de Cura\n3. Paladin - Distância\n4. Knight - Corpo a Corpo\n\nQual vocação você deseja conhecer melhor?", "Sorcerer&Druid&Paladin&Knight&Loja&Fechar")
    
    -- Não quer escolher agora
    elseif msgcontains(msg_lower, "não") or msgcontains(msg_lower, "no") then
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nSem problemas! Volte quando estiver pronto para escolher sua vocação.", "Fechar")
    
    -- Informações sobre Sorcerer
    elseif msgcontains(msg_lower, "sorcerer") then
        local voc = vocations[1]
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\n=== " .. voc.name .. " ===\n\n" .. voc.description .. "\n\nMagias principais: " .. voc.spells .. "\n\nDeseja se tornar um " .. voc.name .. "?", "Escolher Sorcerer&Ver Outras&Fechar")
    
    -- Informações sobre Druid
    elseif msgcontains(msg_lower, "druid") then
        local voc = vocations[2]
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\n=== " .. voc.name .. " ===\n\n" .. voc.description .. "\n\nMagias principais: " .. voc.spells .. "\n\nDeseja se tornar um " .. voc.name .. "?", "Escolher Druid&Ver Outras&Fechar")
    
    -- Informações sobre Paladin
    elseif msgcontains(msg_lower, "paladin") then
        local voc = vocations[3]
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\n=== " .. voc.name .. " ===\n\n" .. voc.description .. "\n\nMagias principais: " .. voc.spells .. "\n\nDeseja se tornar um " .. voc.name .. "?", "Escolher Paladin&Ver Outras&Fechar")
    
    -- Informações sobre Knight
    elseif msgcontains(msg_lower, "knight") then
        local voc = vocations[4]
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\n=== " .. voc.name .. " ===\n\n" .. voc.description .. "\n\nMagias principais: " .. voc.spells .. "\n\nDeseja se tornar um " .. voc.name .. "?", "Escolher Knight&Ver Outras&Fechar")
    
    -- Ver outras vocações
    elseif msgcontains(msg_lower, "ver outras") then
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nQual vocação você deseja conhecer melhor?\n\n1. Sorcerer - Magia de Ataque\n2. Druid - Magia de Cura\n3. Paladin - Distância\n4. Knight - Corpo a Corpo", "Sorcerer&Druid&Paladin&Knight&Loja&Fechar")
    
    -- Escolher Sorcerer
    elseif msgcontains(msg_lower, "escolher sorcerer") then
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nVocê tem certeza que deseja se tornar um Sorcerer?\n\nEsta decisão é PERMANENTE e não pode ser desfeita!", "Confirmar Sorcerer&Ver Outras&Fechar")
    
    -- Escolher Druid
    elseif msgcontains(msg_lower, "escolher druid") then
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nVocê tem certeza que deseja se tornar um Druid?\n\nEsta decisão é PERMANENTE e não pode ser desfeita!", "Confirmar Druid&Ver Outras&Fechar")
    
    -- Escolher Paladin
    elseif msgcontains(msg_lower, "escolher paladin") then
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nVocê tem certeza que deseja se tornar um Paladin?\n\nEsta decisão é PERMANENTE e não pode ser desfeita!", "Confirmar Paladin&Ver Outras&Fechar")
    
    -- Escolher Knight
    elseif msgcontains(msg_lower, "escolher knight") then
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nVocê tem certeza que deseja se tornar um Knight?\n\nEsta decisão é PERMANENTE e não pode ser desfeita!", "Confirmar Knight&Ver Outras&Fechar")
    
    -- Confirmações
    elseif msgcontains(msg_lower, "confirmar sorcerer") then
        player:setVocation(Vocation(1))
        player:setStorageValue(QuestStorages.VocationChoice.ChoseVocation, 1)
        player:setStorageValue(QuestStorages.VocationChoice.Completed, 1)
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nParabéns! Você agora é um Sorcerer!\n\nQue o poder da magia elemental esteja com você. Boa sorte em sua jornada!", "Fechar")
        
    elseif msgcontains(msg_lower, "confirmar druid") then
        player:setVocation(Vocation(2))
        player:setStorageValue(QuestStorages.VocationChoice.ChoseVocation, 2)
        player:setStorageValue(QuestStorages.VocationChoice.Completed, 1)
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nParabéns! Você agora é um Druid!\n\nQue a natureza guie seus passos. Boa sorte em sua jornada!", "Fechar")
        
    elseif msgcontains(msg_lower, "confirmar paladin") then
        player:setVocation(Vocation(3))
        player:setStorageValue(QuestStorages.VocationChoice.ChoseVocation, 3)
        player:setStorageValue(QuestStorages.VocationChoice.Completed, 1)
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nParabéns! Você agora é um Paladin!\n\nQue sua mira seja sempre certeira. Boa sorte em sua jornada!", "Fechar")
        
    elseif msgcontains(msg_lower, "confirmar knight") then
        player:setVocation(Vocation(4))
        player:setStorageValue(QuestStorages.VocationChoice.ChoseVocation, 4)
        player:setStorageValue(QuestStorages.VocationChoice.Completed, 1)
        openNpcDialog(player, getNpcId(cid), "eusou tutor teste\n\nParabéns! Você agora é um Knight!\n\nQue sua espada seja sempre afiada. Boa sorte em sua jornada!", "Fechar")
    
    -- Fechar
    elseif msgcontains(msg_lower, "fechar") or msgcontains(msg_lower, "bye") then
        dialogState[cid] = nil
        npcIdCache[cid] = nil
        closeNpcDialog(player)
        npcHandler:releaseFocus(cid)
    end

    return true
end

function farewellCallback(cid)
    local player = Player(cid)
    if player then
        npcIdCache[cid] = nil
        closeNpcDialog(player)
    end
    return false
end

function onReleaseFocus(cid)
    local player = Player(cid)
    if player then
        dialogState[cid] = nil
        npcIdCache[cid] = nil
        closeNpcDialog(player)
    end
    return true
end

function onThinkCallback()
    for pos, focus in pairs(npcHandler.focuses) do
        if focus then
            local player = Player(focus)
            if player then
                local npcPos = Npc():getPosition()
                local playerPos = player:getPosition()
                
                if npcPos.z ~= playerPos.z or 
                   math.max(math.abs(npcPos.x - playerPos.x), math.abs(npcPos.y - playerPos.y)) > 3 then
                    closeNpcDialog(player)
                    npcHandler:releaseFocus(focus)
                end
            end
        end
    end
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_FAREWELL, farewellCallback)
npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, onReleaseFocus)
npcHandler:setCallback(CALLBACK_ONTHINK, onThinkCallback)
npcHandler:addModule(FocusModule:new())

