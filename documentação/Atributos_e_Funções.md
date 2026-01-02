# Atributos e Funções do Servidor

## 📖 Resumo

Este documento lista todos os atributos especiais (Special Skills) e suas funções disponíveis no servidor, incluindo como acessá-los, modificá-los e aplicá-los através de condições.

## 🎯 Special Skills (Habilidades Especiais)

### 📋 Lista de Atributos e IDs

| Nome do Atributo (C++) | ID (SpecialSkills_t) | ID (CONDITION_PARAM) | Descrição |
|------------------------|----------------------|----------------------|-----------|
| `SPECIALSKILL_CRITICALHITCHANCE` | **0** | **48** | Chance de acerto crítico |
| `SPECIALSKILL_CRITICALHITAMOUNT` | **1** | **49** | Quantidade de dano crítico |
| `SPECIALSKILL_LIFELEECHCHANCE` | **2** | **50** | Chance de roubo de vida |
| `SPECIALSKILL_LIFELEECHAMOUNT` | **3** | **51** | Quantidade de roubo de vida |
| `SPECIALSKILL_MANALEECHCHANCE` | **4** | **52** | Chance de roubo de mana |
| `SPECIALSKILL_MANALEECHAMOUNT` | **5** | **53** | Quantidade de roubo de mana |

**Uso dos IDs:**
- **ID (SpecialSkills_t)**: Usado em `player:getSpecialSkill()` e `player:setSpecialSkill()`
- **ID (CONDITION_PARAM)**: Usado em `condition:setParameter()` para aplicar via condições temporárias

### Definições em C++

Localização: `studio/src/enums.h`

#### Enum SpecialSkills_t (linha 329-338)

```cpp
enum SpecialSkills_t {
    SPECIALSKILL_CRITICALHITCHANCE,    // ID: 0 - Chance de acerto crítico
    SPECIALSKILL_CRITICALHITAMOUNT,    // ID: 1 - Quantidade de dano crítico
    SPECIALSKILL_LIFELEECHCHANCE,      // ID: 2 - Chance de roubo de vida
    SPECIALSKILL_LIFELEECHAMOUNT,       // ID: 3 - Quantidade de roubo de vida
    SPECIALSKILL_MANALEECHCHANCE,      // ID: 4 - Chance de roubo de mana
    SPECIALSKILL_MANALEECHAMOUNT,      // ID: 5 - Quantidade de roubo de mana

    SPECIALSKILL_FIRST = SPECIALSKILL_CRITICALHITCHANCE,
    SPECIALSKILL_LAST = SPECIALSKILL_MANALEECHAMOUNT
};
```

#### Parâmetros de Condição (linha 264-269)

```cpp
CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE = 48,
CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT = 49,
CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE = 50,
CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT = 51,
CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE = 52,
CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT = 53,
```

## 🔧 Funções Disponíveis

### Lua (Player)

#### Obter Valores

```lua
-- Obter chance de critical hit
player:getSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE)

-- Obter amount de critical hit
player:getSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT)

-- Obter chance de life leech
player:getSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE)

-- Obter amount de life leech
player:getSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT)

-- Obter chance de mana leech
player:getSpecialSkill(SPECIALSKILL_MANALEECHCHANCE)

-- Obter amount de mana leech
player:getSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT)
```

#### Definir Valores

```lua
-- Definir chance de critical hit
player:setSpecialSkill(SPECIALSKILL_CRITICALHITCHANCE, valor)

-- Definir amount de critical hit
player:setSpecialSkill(SPECIALSKILL_CRITICALHITAMOUNT, valor)

-- Definir chance de life leech
player:setSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE, valor)

-- Definir amount de life leech
player:setSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT, valor)

-- Definir chance de mana leech
player:setSpecialSkill(SPECIALSKILL_MANALEECHCHANCE, valor)

-- Definir amount de mana leech
player:setSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT, valor)
```

## 📊 Aplicação via Condições

### Como Aplicar Atributos Temporários

```lua
-- Criar condição de atributos
local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT)
condition:setParameter(CONDITION_PARAM_TICKS, 10000)  -- 10 segundos

-- Aplicar critical hit chance
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 25)

-- Aplicar critical hit amount
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 500)

-- Aplicar life leech chance
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE, 15)

-- Aplicar life leech amount
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT, 25)

-- Aplicar mana leech chance
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE, 15)

-- Aplicar mana leech amount
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT, 25)

-- Adicionar condição ao jogador
player:addCondition(condition)
```

### Exemplo Real (Amplification do Tier System)

```lua
-- Em tier_abilities.lua (linha 245-249)
local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT)
condition:setParameter(CONDITION_PARAM_TICKS, 10000)
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, 25)
condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, 500)
player:addCondition(condition)
```

## 🎮 Detalhes de Cada Atributo

### Critical Hit Chance (Chance de Acerto Crítico)

- **ID**: `SPECIALSKILL_CRITICALHITCHANCE`
- **Parâmetro**: `CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE = 48`
- **Descrição**: Chance percentual de acertar um golpe crítico
- **Valores Típicos**: 0-100 (percentual)
- **Uso**: Aumenta a probabilidade de críticos

### Critical Hit Amount (Quantidade de Dano Crítico)

- **ID**: `SPECIALSKILL_CRITICALHITAMOUNT`
- **Parâmetro**: `CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT = 49`
- **Descrição**: Multiplicador de dano quando crítico é ativado
- **Valores Típicos**: 100-2000 (percentual, 100 = 100%, 2000 = 2000%)
- **Uso**: Define quanto dano extra o crítico causa

### Life Leech Chance (Chance de Roubo de Vida)

- **ID**: `SPECIALSKILL_LIFELEECHCHANCE`
- **Parâmetro**: `CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE = 50`
- **Descrição**: Chance percentual de roubar vida do alvo
- **Valores Típicos**: 0-100 (percentual)
- **Uso**: Probabilidade de ativar life leech

### Life Leech Amount (Quantidade de Roubo de Vida)

- **ID**: `SPECIALSKILL_LIFELEECHAMOUNT`
- **Parâmetro**: `CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT = 51`
- **Descrição**: Percentual do dano que é convertido em vida
- **Valores Típicos**: 0-100 (percentual)
- **Uso**: Define quanto do dano causado é convertido em HP

### Mana Leech Chance (Chance de Roubo de Mana)

- **ID**: `SPECIALSKILL_MANALEECHCHANCE`
- **Parâmetro**: `CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE = 52`
- **Descrição**: Chance percentual de roubar mana do alvo
- **Valores Típicos**: 0-100 (percentual)
- **Uso**: Probabilidade de ativar mana leech

### Mana Leech Amount (Quantidade de Roubo de Mana)

- **ID**: `SPECIALSKILL_MANALEECHAMOUNT`
- **Parâmetro**: `CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT = 53`
- **Descrição**: Percentual do dano que é convertido em mana
- **Valores Típicos**: 0-100 (percentual)
- **Uso**: Define quanto do dano causado é convertido em MP

## 📁 Localização das Implementações

### C++

- **Definições**: `studio/src/enums.h`
  - Enums de Special Skills
  - Parâmetros de condição

- **Implementação Player**: `studio/src/player.h`, `studio/src/player.cpp`
  - `getSpecialSkill(skillId)`
  - `setSpecialSkill(skillId, value)`
  - Array: `int32_t varSpecialSkills[SPECIALSKILL_LAST + 1]`

- **Processamento de Combate**: `studio/src/combat.cpp`
  - Aplicação de life/mana leech
  - Cálculo de critical hit

- **Movimento**: `studio/src/movement.cpp`
  - Aplicação de special skills em movimentos

- **Tools**: `studio/src/tools.cpp`
  - Funções auxiliares para special skills

### Lua

- **Bindings**: `studio/src/luascript.cpp`
  - Registro de funções Lua para special skills
  - `luaPlayerGetSpecialSkill()`
  - `luaPlayerSetSpecialSkill()`

## 🔄 Como Funcionam no Combate

### Critical Hit

1. **Chance**: Sistema verifica `SPECIALSKILL_CRITICALHITCHANCE`
2. **Rolagem**: Se passar, ativa critical hit
3. **Dano**: Multiplica dano base por `SPECIALSKILL_CRITICALHITAMOUNT / 100`

### Life Leech

1. **Chance**: Sistema verifica `SPECIALSKILL_LIFELEECHCHANCE`
2. **Rolagem**: Se passar, ativa life leech
3. **Cura**: Converte `SPECIALSKILL_LIFELEECHAMOUNT%` do dano em HP

### Mana Leech

1. **Chance**: Sistema verifica `SPECIALSKILL_MANALEECHCHANCE`
2. **Rolagem**: Se passar, ativa mana leech
3. **Regeneração**: Converte `SPECIALSKILL_MANALEECHAMOUNT%` do dano em MP

## ⚠️ Notas Importantes

- **Valores são percentuais**: Critical Hit Amount usa valores como 500 = 500% (5x dano)
- **Condições temporárias**: Atributos aplicados via condições são temporários
- **Atributos permanentes**: Usar `setSpecialSkill()` para valores permanentes
- **Soma de valores**: Múltiplas fontes somam seus valores
- **Limites**: Não há limite máximo definido, mas valores muito altos podem causar problemas

## 🛠️ Exemplos de Uso

### Aplicar Bônus Temporário de Critical Hit

```lua
local function applyCriticalBonus(player, chance, amount, duration)
    local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT)
    condition:setParameter(CONDITION_PARAM_TICKS, duration)
    condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE, chance)
    condition:setParameter(CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT, amount)
    player:addCondition(condition)
end

-- Uso
applyCriticalBonus(player, 25, 500, 10000)  -- 25% chance, 500% dano, 10 segundos
```

### Verificar e Aumentar Life Leech

```lua
local function increaseLifeLeech(player, chanceBonus, amountBonus)
    local currentChance = player:getSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE)
    local currentAmount = player:getSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT)
    
    player:setSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE, currentChance + chanceBonus)
    player:setSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT, currentAmount + amountBonus)
end
```

### Aplicar Bônus Completo de Leech

```lua
local function applyLeechBonus(player, duration)
    local condition = Condition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT)
    condition:setParameter(CONDITION_PARAM_TICKS, duration)
    condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE, 15)
    condition:setParameter(CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT, 25)
    condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE, 15)
    condition:setParameter(CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT, 25)
    player:addCondition(condition)
end
```

---

**Tipo**: Sistema C++ (com bindings Lua)  
**Requer Recompilação**: Sim (para mudanças em C++)  
**Requer Reload**: Não (funções Lua disponíveis via bindings)

