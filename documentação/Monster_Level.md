# Sistema de Monster Level

## 📖 Resumo

O Sistema de Monster Level permite que monstros tenham níveis variáveis dentro de uma faixa definida (minLevel e maxLevel). O nível do monstro afeta seus atributos (HP, velocidade), experiência concedida, multiplicador de loot, e até mesmo a cor do skull. O sistema usa uma distribuição probabilística para gerar níveis, favorecendo níveis mais baixos mas permitindo níveis muito altos raramente.

## 🎯 Como Funciona

1. **Definição**: Monstros podem ter `minLevel` e `maxLevel` definidos no XML
2. **Geração Aleatória**: Ao spawnar, o nível é gerado aleatoriamente com distribuição probabilística
3. **Bônus de Atributos**: O nível afeta HP e velocidade do monstro
4. **Experiência**: Experiência concedida é multiplicada pelo nível do monstro
5. **Loot**: Multiplicador de loot aumenta com o nível do monstro
6. **Skull**: Cor do skull muda baseado no nível

### Distribuição de Níveis

O sistema usa uma distribuição probabilística que favorece níveis mais baixos:

| Chance | Faixa de Nível | Descrição |
|--------|----------------|-----------|
| 1-20% | minLevel até maxLevel | Nível normal (faixa completa) |
| 20-40% | minLevel+71 até maxLevel-70 | Nível elevado (+71 da base) |
| 40-70% | minLevel+151 até maxLevel-150 | Nível alto (+151 da base) |
| 70-90% | minLevel+301 até maxLevel-300 | Nível muito alto (+301 da base) |
| 90-99% | minLevel+451 até maxLevel-450 | Nível extremo (+451 da base) |

**Nota**: A lógica atual tem um bug - as condições usam `||` (OR) ao invés de `&&` (AND), mas funciona devido à ordem de verificação.

## 📁 Localização dos Arquivos

### C++ (Principal)

- **Definições**: `studio/src/monsters.h` (linha 130-131)
  - `int32_t minLevel = 0`
  - `int32_t maxLevel = 0`

- **Implementação**: `studio/src/monster.cpp`
  - Construtor `Monster::Monster(MonsterType* mType)` (linha 40-95)
  - Geração aleatória de nível (linha 50-68)
  - Aplicação de bônus de HP e velocidade (linha 76-86)
  - Aplicação de skull baseado no nível (linha 87-95)

- **Funções**: `studio/src/monster.h` (linha 163-171)
  - `getMinLevelMonster()` - Retorna minLevel
  - `getMaxLevelMonster()` - Retorna maxLevel
  - `isMonsterLevelSystem()` - Verifica se sistema está ativo
  - `getMonsterLevel()` - Retorna nível atual (herdado de Creature)

- **Carregamento XML**: `studio/src/monsters.cpp` (linha 909-920)
  - Carrega `<level min="X" max="Y">` do XML do monstro

- **Bindings Lua**: `studio/src/luascript.cpp` (linha 2742, 14092)
  - `monster:getMonsterLevel()` - Função Lua para obter nível

### Lua (Integração)

- **Sistema de Loot**: `data/scripts/eventcallbacks/monster/default_onDropLoot.lua` (linha 86-101)
  - Multiplicador de loot baseado no nível

- **Sistema de Experiência**: `data/events/scripts/player.lua` (linha 380-385)
  - Bônus de experiência baseado no nível do monstro

## 🔧 Funções Principais

### C++

#### `studio/src/monster.cpp`

```cpp
// Geração de nível no construtor
Monster::Monster(MonsterType* mType) {
    int randomChance = std::rand() % 100;
    
    if (mType->info.minLevel != 0 && mType->info.maxLevel != 0) {
        // Distribuição probabilística de níveis
        // ...
    }
    
    // Aplicação de bônus baseado no nível
    if (level > 0) {
        float bonusHp = g_config.getFloat(ConfigManager::MLVL_BONUSHP) * level;
        healthMax += healthMax * bonusHp;
        health += health * bonusHp;
        
        float bonusSpeed = g_config.getFloat(ConfigManager::MLVL_BONUSSPEED) * level;
        baseSpeed += baseSpeed * bonusSpeed;
    }
    
    // Aplicação de skull baseado no nível
    if (level >= 50 && level <= 100) {
        skull = SKULL_WHITE;
    }
    // ...
}
```

#### `studio/src/monster.h`

```cpp
// Verificar se sistema está ativo
bool isMonsterLevelSystem() const {
    return mType->info.minLevel != 0 || mType->info.maxLevel != 0;
}

// Obter níveis mínimo e máximo
bool getMinLevelMonster() const {
    return mType->info.minLevel;
}

bool getMaxLevelMonster() const {
    return mType->info.maxLevel;
}
```

### Lua

#### Obter Nível do Monstro

```lua
-- Obter nível atual do monstro
local level = monster:getMonsterLevel()

-- Verificar se monstro tem sistema de nível
if monster:isMonsterLevelSystem() then
    -- Sistema ativo
end
```

#### Usar Nível em Sistemas

```lua
-- Em default_onDropLoot.lua
local monsterLevel = self:getMonsterLevel()

-- Multiplicador de loot baseado no nível
if monsterLevel >= 5 and monsterLevel < 50 then
    lootMultiplier = 1.15
elseif monsterLevel >= 51 and monsterLevel < 100 then
    lootMultiplier = 1.35
-- ...
end
```

```lua
-- Em player.lua (onGainExperience)
if source:isMonster() then
    local bonusExperience = source:getMonsterLevel() * 0.03
    if source:getMonsterLevel() > 0 and bonusExperience > 1 then
        exp = exp * bonusExperience
    end
end
```

## 📊 Configurações

### Configurações do Servidor

No arquivo de configuração (config.lua ou similar), existem configurações para bônus:

- **MLVL_BONUSHP**: Bônus de HP por nível (float)
- **MLVL_BONUSSPEED**: Bônus de velocidade por nível (float)
- **MLVL_BONUSDMG**: Bônus de dano por nível (float)

**Localização**: `studio/src/configmanager.h` (linha 128)

### Exemplo de Configuração XML

```xml
<monster name="Dragon" nameDescription="a dragon" race="fire" experience="2000" speed="200">
    <health now="1000" max="1000"/>
    <level min="1" max="500"/>
    <!-- ... -->
</monster>
```

## 🎮 Efeitos do Nível

### Bônus de HP

- **Fórmula**: `bonusHp = MLVL_BONUSHP * level`
- **Aplicação**: `healthMax += healthMax * bonusHp`
- **Efeito**: HP máximo e atual aumentam proporcionalmente ao nível

### Bônus de Velocidade

- **Fórmula**: `bonusSpeed = MLVL_BONUSSPEED * level`
- **Aplicação**: `baseSpeed += baseSpeed * bonusSpeed`
- **Efeito**: Velocidade base aumenta proporcionalmente ao nível

### Bônus de Dano

- **Fórmula**: `bonusDmg = MLVL_BONUSDMG * level`
- **Aplicação**: Aplicado no cálculo de dano do monstro
- **Efeito**: Dano do monstro aumenta proporcionalmente ao nível
- **Localização**: `studio/src/game.cpp` (linha 4164, 4370)

### Skull por Nível

| Nível | Skull | Cor |
|-------|-------|-----|
| 0-49 | SKULL_NONE | Nenhum |
| 50-100 | SKULL_WHITE | Branco |
| 101-200 | SKULL_GREEN | Verde |
| 201-300 | SKULL_YELLOW | Amarelo |
| 301-350 | SKULL_ORANGE | Laranja |
| 351-400 | SKULL_RED | Vermelho |
| 401-500000 | SKULL_BLACK | Preto |

**Localização**: `studio/src/monster.cpp` (linha 87-104)

### Multiplicador de Loot

| Nível do Monstro | Multiplicador |
|------------------|---------------|
| 5-50 | 1.15x |
| 51-100 | 1.35x |
| 101-200 | 1.65x |
| 201-300 | 1.95x |
| 301-500 | 2.25x |
| 501+ | 2.70x |

**Localização**: `data/scripts/eventcallbacks/monster/default_onDropLoot.lua`

### Bônus de Experiência

- **Fórmula**: `bonusExperience = monsterLevel * 0.03`
- **Aplicação**: `exp = exp * bonusExperience` (se bonusExperience > 1)
- **Efeito**: Experiência concedida é multiplicada pelo bônus

**Localização**: `data/events/scripts/player.lua` (linha 381-384)

## 🔄 Fluxo de Funcionamento

### Spawn do Monstro

1. **Carregamento XML**: Sistema carrega `minLevel` e `maxLevel` do XML
2. **Verificação**: Se ambos são diferentes de 0, sistema está ativo
3. **Geração Aleatória**: Nível é gerado usando distribuição probabilística
4. **Aplicação de Bônus**: HP e velocidade são ajustados baseado no nível
5. **Aplicação de Skull**: Skull é definido baseado no nível
6. **Monstro Spawnado**: Monstro aparece com nível, atributos e skull definidos

### Durante o Jogo

1. **Combate**: Monstro usa HP e velocidade ajustados pelo nível
2. **Morte**: Ao morrer, sistema de loot usa multiplicador baseado no nível
3. **Experiência**: Sistema de experiência aplica bônus baseado no nível

## ⚠️ Notas Importantes

- **Nível 0**: Se `minLevel` e `maxLevel` forem 0, o sistema está desativado
- **Distribuição**: A distribuição atual favorece níveis mais baixos (80% chance de nível normal)
- **Bônus Configuráveis**: MLVL_BONUSHP e MLVL_BONUSSPEED devem ser configurados no config
- **Experiência Mínima**: Bônus de experiência só aplica se `bonusExperience > 1`
- **Loot Mínimo**: Multiplicador de loot só aplica se nível >= 5
- **Skull Automático**: Skull é aplicado automaticamente baseado no nível

## 🛠️ Para Correções

### Modificar Distribuição de Níveis

Editar `studio/src/monster.cpp` (linha 50-68):
```cpp
int randomChance = std::rand() % 100;

if (randomChance >= 0 && randomChance < 20) {
    // 20% chance - nível normal
    level = std::rand() % (mType->info.maxLevel - mType->info.minLevel + 1) + mType->info.minLevel;
}
// Adicionar mais faixas conforme necessário
```

### Ajustar Multiplicadores de Loot

Editar `data/scripts/eventcallbacks/monster/default_onDropLoot.lua` (linha 88-101):
```lua
if monsterLevel >= 5 and monsterLevel < 50 then
    lootMultiplier = 1.15  -- Alterar valor
elseif monsterLevel >= 51 and monsterLevel < 100 then
    lootMultiplier = 1.35  -- Alterar valor
-- ...
end
```

### Modificar Bônus de Experiência

Editar `data/events/scripts/player.lua` (linha 381):
```lua
local bonusExperience = source:getMonsterLevel() * 0.03  -- Alterar multiplicador
```

### Ajustar Skulls por Nível

Editar `studio/src/monster.cpp` (linha 87-95):
```cpp
if (level >= 50 && level <= 100) {
    skull = SKULL_WHITE;  // Alterar faixa ou skull
}
// ...
```

### Configurar Bônus de HP, Velocidade e Dano

No arquivo de configuração:
```lua
-- Exemplo (valores devem ser definidos em ConfigManager)
MLVL_BONUSHP = 0.01     -- 1% de HP por nível
MLVL_BONUSSPEED = 0.005 -- 0.5% de velocidade por nível
MLVL_BONUSDMG = 0.01    -- 1% de dano por nível
```

**Nota**: Esses valores são acessados via `g_config.getFloat(ConfigManager::MLVL_BONUS*)` no código C++

---

**Tipo**: Sistema Híbrido (C++ + Lua)  
**Requer Recompilação**: Sim (para mudanças em C++)  
**Requer Reload**: Sim (para mudanças em Lua)

