local OpcodeDialog = 54  -- Mudado de 80 para 54 para coincidir com o cliente
local Actions = {
    open = 1,
    closed = 2
}

function openNpcDialog(player, npcCid, message, options)
    if not player or not player:isPlayer() then
        return
    end

    if not npcCid or type(npcCid) ~= "number" then
        return
    end

    -- Pega informações do NPC
    local npc = Npc(npcCid)
    if not npc then
        return
    end

    local npcName = npc:getName()
    local npcOutfit = npc:getOutfit()

    -- Processa os botões
    local buttons = {}
    if options and options ~= '' then
        for option in string.gmatch(options, "[^&]+") do
            table.insert(buttons, {
                type = "Text",
                text = option,
                response = string.lower(option)
            })
        end
    end

    -- Monta o JSON no formato que o cliente espera
    local data = {
        npcInfo = {
            outfit = {
                lookType = npcOutfit.lookType or 128,
                lookHead = npcOutfit.lookHead or 0,
                lookBody = npcOutfit.lookBody or 0,
                lookLegs = npcOutfit.lookLegs or 0,
                lookFeet = npcOutfit.lookFeet or 0,
                lookAddons = npcOutfit.lookAddons or 0
            },
            NpcName = {
                name = npcName,
                color = "#ffffff"
            },
            image = nil,
            type = "HiNpc"
        },
        dialog = message,
        Buttons = buttons,
        closeTime = nil
    }

    local status, jsonData = pcall(json.encode, data)
    if not status then
        return
    end

    player:sendExtendedOpcode(OpcodeDialog, jsonData)
end

function openNpcDialogWithItems(player, npcCid, message, options, items, itemListTitle)
    if not player or not player:isPlayer() then
        return
    end

    if not npcCid or type(npcCid) ~= "number" then
        return
    end

    local npc = Npc(npcCid)
    if not npc then
        return
    end

    local npcName = npc:getName()
    local npcOutfit = npc:getOutfit()

    -- Processa os botões
    local buttons = {}
    if options and options ~= '' then
        for option in string.gmatch(options, "[^&]+") do
            table.insert(buttons, {
                type = "Text",
                text = option,
                response = string.lower(option)
            })
        end
    end
    
    -- Adiciona a lista de itens se fornecida
    if items and #items > 0 then
        table.insert(buttons, 1, {
            type = "ItemList",
            title = itemListTitle or "Itens",
            items = items
        })
    end

    local data = {
        npcInfo = {
            outfit = {
                lookType = npcOutfit.lookType or 128,
                lookHead = npcOutfit.lookHead or 0,
                lookBody = npcOutfit.lookBody or 0,
                lookLegs = npcOutfit.lookLegs or 0,
                lookFeet = npcOutfit.lookFeet or 0,
                lookAddons = npcOutfit.lookAddons or 0
            },
            NpcName = {
                name = npcName,
                color = "#ffffff"
            },
            image = nil,
            type = "HiNpc"
        },
        dialog = message,
        Buttons = buttons,
        closeTime = nil
    }

    local status, jsonData = pcall(json.encode, data)
    if not status then
        return
    end

    player:sendExtendedOpcode(OpcodeDialog, jsonData)
end

function closeNpcDialog(player)
    if not player or not player:isPlayer() then
        return
    end
    
    -- Fecha a janela de shop se estiver aberta
    closeShopWindow(player:getId())
    
    -- Envia um opcode para fechar o diálogo no cliente
    local data = {
        npcInfo = {
            type = "Close"
        }
    }
    
    local status, jsonData = pcall(json.encode, data)
    if status then
        player:sendExtendedOpcode(OpcodeDialog, jsonData)
    end
end