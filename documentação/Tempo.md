# Sistema de Tempo

## 📖 Resumo

O Sistema de Tempo gerencia o horário do servidor e envia atualizações periódicas para os clientes conectados. O sistema converte o tempo do mundo do Tibia (em minutos desde 00:00) para formato HH:MM e envia via Extended Opcode para todos os jogadores.

## 🎯 Como Funciona

1. **Obtenção do Tempo**: Sistema obtém o tempo do mundo do Tibia usando `getWorldTime()`
2. **Conversão**: Converte minutos para formato HH:MM
3. **Envio**: Envia o horário para todos os jogadores conectados via Extended Opcode
4. **Atualização Automática**: Sistema se atualiza a cada 60 segundos

### Formato do Tempo

- **Entrada**: Minutos desde 00:00 (ex: 360 = 06:00)
- **Saída**: String formatada "HH:MM" (ex: "06:00")

## 📁 Localização dos Arquivos

### Lua (Principal)

- **Sistema Principal**: `data/scripts/customs/tempo/tempopcode.lua`
  - Função de conversão de tempo
  - Envio via Extended Opcode
  - Loop de atualização automática

- **Sistema Alternativo**: `data/creaturescripts/scripts/custom/time_system.lua`
  - Função para obter tempo formatado
  - Função para enviar tempo para todos os jogadores
  - Formato: "HH:MM - DD/MM/YYYY"

### C++ (Base do Servidor)

- **Gerenciamento de Tempo**: `studio/src/game.cpp`, `studio/src/game.h`
  - `updateWorldTime()`: Atualiza o tempo do mundo
  - `getWorldTime()`: Retorna o tempo atual em minutos
  - Constantes de tempo:
    - `GAME_SUNRISE = 360` (06:00)
    - `GAME_DAYTIME = 480` (08:00)
    - `GAME_SUNSET = 1080` (18:00)
    - `GAME_NIGHTTIME = 1200` (20:00)

## 🔧 Funções Principais

### Lua

#### `data/scripts/customs/tempo/tempopcode.lua`

```lua
-- Converter tempo do Tibia para HH:MM
function getTibiaServerTime() -> string
  -- Retorna: "HH:MM"

-- Enviar tempo para todos os clientes
function sendTibiaTimeToClients()
  -- Envia via Extended Opcode (CODE_JSON_TEST = 150)
  -- Formato JSON: {status = "time_update", message = "HH:MM"}
```

#### `data/creaturescripts/scripts/custom/time_system.lua`

```lua
-- Obter tempo formatado
function timeSystem.getTime() -> string
  -- Retorna: "HH:MM - DD/MM/YYYY"

-- Enviar para todos os jogadores
function timeSystem.sendTimeToAllPlayers()
  -- Envia mensagem de texto para todos
```

### C++

#### `studio/src/game.cpp`

```cpp
// Atualizar tempo do mundo
void Game::updateWorldTime()
  // Calcula: (segundos + minutos*60) / 2.5
  // 2.5 segundos reais = 1 minuto de jogo

// Obter tempo do mundo
int16_t Game::getWorldTime() const
  // Retorna minutos desde 00:00

// Atualizar nível de luz baseado no tempo
void Game::updateWorldLightLevel()
  // Ajusta luz baseado em sunrise/daytime/sunset/nighttime
```

## 🎮 Detalhes de Implementação

### Extended Opcode

O sistema usa Extended Opcode para comunicação cliente-servidor:

- **CODE_JSON_TEST = 150**: Código do opcode
- **Formato de Dados**: JSON
- **Estrutura**:
  ```json
  {
    "status": "time_update",
    "message": "HH:MM"
  }
  ```

### Loop de Atualização

```lua
function sendTibiaTimeToClients()
  -- Obtém tempo
  -- Envia para todos os jogadores
  -- Agenda próxima execução em 60 segundos
  addEvent(sendTibiaTimeToClients, 60 * 1000)
end

-- Inicia o loop
sendTibiaTimeToClients()
```

### Conversão de Tempo

```lua
function getTibiaServerTime()
  local minutes = getWorldTime()  -- Minutos desde 00:00
  local hours = math.floor(minutes / 60)
  local mins = minutes % 60
  return string.format("%02d:%02d", hours, mins)
end
```

## ⏰ Relação Tempo Real vs Tempo do Jogo

- **1 hora real** = **1 dia no jogo** (24 horas)
- **2.5 segundos reais** = **1 minuto no jogo**
- **1 minuto real** = **24 minutos no jogo**

### Exemplos

- 00:00 real → 00:00 jogo
- 01:00 real → 24:00 jogo (meia-noite)
- 02:30 real → 12:00 jogo (meio-dia)

## 💾 Storages e Variáveis

O sistema não utiliza storages, apenas:
- Variáveis locais para cálculo
- Extended Opcode para comunicação
- Event scheduler para loop

## 🔄 Fluxo de Funcionamento

1. **Inicialização**: Script é carregado ao iniciar servidor
2. **Primeira Execução**: `sendTibiaTimeToClients()` é chamada
3. **Obtenção de Tempo**: `getWorldTime()` retorna minutos desde 00:00
4. **Conversão**: Tempo é convertido para "HH:MM"
5. **Envio**: Dados são enviados via Extended Opcode para todos os jogadores
6. **Agendamento**: Próxima execução é agendada em 60 segundos
7. **Repetição**: Processo se repete indefinidamente

## ⚠️ Notas Importantes

- O sistema **não armazena** histórico de tempo
- Atualizações são enviadas **a cada 60 segundos**
- O tempo do jogo é **independente** do tempo real do servidor
- O sistema usa **Extended Opcode**, requer suporte no cliente
- Múltiplos sistemas de tempo podem coexistir (tempopcode.lua e time_system.lua)

## 🛠️ Para Correções

### Modificar Intervalo de Atualização

Editar `data/scripts/customs/tempo/tempopcode.lua`:
```lua
addEvent(sendTibiaTimeToClients, 60 * 1000)  -- Alterar 60 para outro valor
```

### Modificar Formato de Tempo

Editar função `getTibiaServerTime()`:
```lua
-- Exemplo: Adicionar segundos
return string.format("%02d:%02d:%02d", hours, mins, secs)
```

### Adicionar Data ao Tempo

Editar para incluir data:
```lua
local date = os.date("%d/%m/%Y")
return string.format("%s - %s", time, date)
```

### Modificar Código do Opcode

Editar `data/scripts/customs/tempo/tempopcode.lua`:
```lua
local CODE_JSON_TEST = 150  -- Alterar para outro código
```

### Ajustar Constantes de Tempo (C++)

Editar `studio/src/game.h`:
```cpp
static constexpr int16_t GAME_SUNRISE = 360;  // Alterar valores
static constexpr int16_t GAME_DAYTIME = 480;
static constexpr int16_t GAME_SUNSET = 1080;
static constexpr int16_t GAME_NIGHTTIME = 1200;
```

---

**Tipo**: Sistema Lua (com base C++)  
**Requer Recompilação**: Não (para mudanças em Lua)  
**Requer Reload**: Sim  
**Requer Recompilação C++**: Sim (para mudanças em game.h/game.cpp)

