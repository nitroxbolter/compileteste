local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- Armazena o estado do diálogo para reabrir após fechar a loja
local dialogState = {}

-- Função auxiliar para obter o CID do NPC atual
local function getNpcId()
    local npc = Npc()
    if npc then
        local id = npc:getId()
        if id and id > 0 then
            return id
        end
    end
    return getNpcCid()
end

-- Função para reabrir o diálogo após fechar a loja
local function reopenDialogAfterTrade(cid)
    if not dialogState[cid] then
        return
    end
    
    local player = Player(cid)
    if not player or not npcHandler:isFocused(cid) then
        dialogState[cid] = nil
        return
    end
    
    dialogState[cid] = nil
    openNpcDialog(player, getNpcId(), "Olá! Eu sou o Eduardo!\n\nAqui estão meus produtos! Veja a janela de trade.\n\nDeseja algo mais?", "Loja&Fechar")
end

function onThink()                     npcHandler:onThink()                     end
function onCreatureAppear(cid)         npcHandler:onCreatureAppear(cid)         end
function onCreatureDisappear(cid)      npcHandler:onCreatureDisappear(cid)      end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end

function greetCallback(cid)
    local player = Player(cid)
    if not player then
        return true
    end
    
    -- Adiciona o focus manualmente
    npcHandler:addFocus(cid)
    
    -- Envia o diálogo customizado
    openNpcDialog(player, getNpcId(), "Olá! Eu sou o Eduardo!\n\nBem-vindo à minha loja! O que você deseja fazer?", "Loja&Fechar")
    
    -- Retorna false para bloquear a mensagem padrão
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
    
    if msgcontains(msg_lower, "loja") then
        -- Fecha o diálogo customizado
        closeNpcDialog(player)
        
        -- Armazena o estado para reabrir o diálogo após fechar a loja
        dialogState[cid] = true
        
        -- Processa o trade através do keywordHandler
        addEvent(function()
            local eventPlayer = Player(cid)
            if eventPlayer then
                npcHandler.keywordHandler:processMessage(cid, "trade")
                -- Reabre o diálogo após um tempo
                addEvent(function() reopenDialogAfterTrade(cid) end, 1500)
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
        
    elseif msgcontains(msg_lower, "fechar") or msgcontains(msg_lower, "bye") or msgcontains(msg_lower, "close") then
        dialogState[cid] = nil
        -- Fecha o diálogo customizado
        closeNpcDialog(player)
        -- Remove o foco do NPC
        npcHandler:releaseFocus(cid)
    end

    return true
end

function farewellCallback(cid)
    local player = Player(cid)
    if player then
        -- Fecha o diálogo customizado quando o NPC se despede
        closeNpcDialog(player)
    end
    -- Bloqueia a mensagem padrão de despedida
    return false
end

function onReleaseFocus(cid)
    local player = Player(cid)
    if player then
        dialogState[cid] = nil
        -- Fecha o diálogo customizado quando perde o foco (jogador se afasta)
        closeNpcDialog(player)
    end
    return true
end

function onThinkCallback()
    -- Verifica se há players focados
    for pos, focus in pairs(npcHandler.focuses) do
        if focus then
            local player = Player(focus)
            if player then
                local npcPos = Npc():getPosition()
                local playerPos = player:getPosition()
                
                -- Se o player está longe (mais de 3 sqm), remove o foco
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
