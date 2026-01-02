-- Opcode Manager CreatureScript
-- Handler principal para processar mensagens do opcode manager

function onExtendedOpcode(player, opcode, buffer)
    -- Verifica se é o opcode do nosso sistema
    if opcode ~= OpcodeManager.getMainOpcode() then
        return false
    end
    
    -- Processa a mensagem através do opcode manager
    return OpcodeManager.processChannelMessage(player, buffer)
end

