local CODE_JSON_TEST = 151
local clientTest = {}
print("MODULO JSON CXARREGADO")

function clientTest.onExtendedOpcode(protocol, opcode, buffer)
    if opcode ~= CODE_JSON_TEST then return end
    local ok, json_data = pcall(function() return json.decode(buffer) end)
    if not ok or not json_data or not json_data.message then
        print("[Client] Erro ao receber JSON do servidor!")
        return
    end
    print("[Client] Resposta do servidor:", json_data.message)
end

function clientTest.sendTestData()
    local myData = {
        a = "teste",
        b = 123,
        c = { x = "abc", y = 456 }
    }
    local protocolGame = g_game:getProtocolGame()
    if protocolGame then
        protocolGame:sendExtendedOpcode(CODE_JSON_TEST, json.encode(myData))
        print("[Client] Dados enviados ao servidor!")
    else
        print("[Client] Protocolo não disponível ainda")
    end
end

connect(g_game, {
    onGameStart = function()
        ProtocolGame.registerExtendedOpcode(CODE_JSON_TEST, clientTest.onExtendedOpcode)
        print("[Client] ExtendedOpcode registrado após login!")
        scheduleEvent(clientTest.sendTestData, 1000)
    end
})

connect(g_game, {
    onGameEnd = function()
        ProtocolGame.unregisterExtendedOpcode(CODE_JSON_TEST, clientTest.onExtendedOpcode)
        print("[Client] ExtendedOpcode descarregado.")
    end
})
