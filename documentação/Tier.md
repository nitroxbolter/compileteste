# Sistema de Tier

## 📖 Resumo

O Sistema de Tier permite que itens sejam melhorados através de níveis de tier (0-10). Cada tier aumenta as chances de ativação de habilidades especiais baseadas no slot do equipamento. O sistema também inclui um sistema de upgrade que permite aumentar o tier dos itens usando itens especiais.

## 🎯 Como Funciona

1. **Tier de Item**: Itens podem ter um tier de 0 a 10, armazenado como **Custom Attribute "tier"**
2. **Habilidades por Slot**: Cada slot tem uma habilidade específica que pode ser ativada
3. **Chance de Ativação**: A chance aumenta com o tier do item
4. **Sistema de Upgrade**: Itens especiais podem ser usados para aumentar o tier
5. **Amplification**: Botas com tier amplificam outras habilidades

### ⚙️ Armazenamento de Tier (Custom Attributes)

O tier é armazenado como **Custom Attribute** no item, não como atributo direto. Isso permite:
- Persistência do tier mesmo após reload
- Flexibilidade para adicionar outros atributos customizados
- Compatibilidade com sistema de salvamento

**Como o Tier é Atribuído:**
```lua
-- Em upgrade_system_tiers.lua
item:setCustomAttribute("tier", tier)  -- Define o tier
```

**Como Acessar o Tier:**
```lua
-- Função padrão usada no sistema
local function getItemTier(item)
    if not item then
        return 0
    end
    
    local tierAttr = item:getCustomAttribute("tier")  -- Acessa custom attribute
    if not tierAttr then
        return 0
    end
    
    -- Converte para número (pode vir como string ou number)
    if type(tierAttr) == "number" then
        return tierAttr
    else
        return tonumber(tierAttr) or 0
    end
end
```

**Funções de Custom Attributes (Lua):**
- `item:getCustomAttribute("tier")` - Obtém o valor do custom attribute
- `item:setCustomAttribute("tier", valor)` - Define o valor do custom attribute
- `item:removeCustomAttribute("tier")` - Remove o custom attribute

**Nota Importante:** Sempre use `getCustomAttribute()` e `setCustomAttribute()`, **NÃO** use atributos diretos como `getAttribute()` para o tier, pois ele é armazenado como custom attribute.

### Habilidades por Slot

- **Hand (Armas)**: Onslaught - Aumenta dano crítico em 60%
- **Armor (Armadura)**: Ruse - Chance de dodge completo
- **Legs (Pernas)**: Transcendence - Avatar automático (tier 3+)
- **Head (Cabeça)**: Momentum - Redução de cooldown
- **Feet (Pés)**: Amplification - Amplifica outras habilidades
- **Necklace (Colar)**: Lucky Drop - Aumenta drop rate

### Chances de Ativação

As chances variam por tier e habilidade:
- **Onslaught/Ruse/Amplification**: 0.5% a 5.0% (tier 1-10)
- **Momentum/Lucky Drop**: 1.0% a 10.0% (tier 1-10)
- **Transcendence**: 0% até tier 2, depois 5.0% a 35.0% (tier 3-10)

## 📁 Localização dos Arquivos

### Lua (Principal)

- **Configuração**: `data/lib/core/tier_ability_config.lua`
  - Define todas as configurações do sistema
  - Chances de ativação por tier
  - Configurações de upgrade
  - Outfits de avatar

- **Habilidades**: `data/scripts/customs/tier_system/tier_abilities.lua`
  - Implementa todas as habilidades
  - Event handlers de combate
  - Sistema de lucky drop
  - Gerenciamento de equipamento

- **Sistema de Upgrade**: `data/scripts/customs/tier_system/upgrade_system_tiers.lua`
  - Action para upgrade de tier
  - Validação de itens
  - Aplicação de tier

### C++ (Suporte)
- Suporte para Custom Attributes em `studio/src/item.h`, `studio/src/item.cpp`
- Não há código C++ específico para tier, apenas suporte genérico

## 🔧 Funções Principais

### Lua

#### `data/lib/core/tier_ability_config.lua`

```lua
-- Obter tier de um item
TierSystem.getItemTier(item) -> number

-- Obter chance de ativação
TierSystem.getActivationChance(abilityType, tier) -> number

-- Calcular chance de upgrade
TierSystem.calculateUpgradeChance(currentTier) -> number

-- Obter boost de drop
TierSystem.getDropBoost(tier) -> number

-- Verificar se item pode receber tier
TierSystem.isItemTierable(itemId) -> boolean
```

#### `data/scripts/customs/tier_system/tier_abilities.lua`

- **processOnslaught(player, target, damage)**: Processa habilidade Onslaught
- **processRuse(player, damage)**: Processa habilidade Ruse (dodge)
- **processTranscendence(player)**: Processa habilidade Transcendence (avatar)
- **processMomentum(player)**: Processa habilidade Momentum
- **processAmplification(player)**: Processa habilidade Amplification
- **calculateTotalChance(player, baseChance, abilityType)**: Calcula chance total com amplification

#### `data/scripts/customs/tier_system/upgrade_system_tiers.lua`

- **getItemTier(item)**: Obtém tier atual do item
- **setItemTier(item, tier)**: Define tier do item
- **canItemReceiveTier(item)**: Verifica se item pode receber tier
- **updateItemDescription(item)**: Atualiza descrição do item com tier

### Configurações

#### Itens de Upgrade
- **Common Tier (1-3)**: IDs 27134-27136
- **Rare Tier (4-6)**: IDs 27137-27139
- **Very Rare Tier (7-9)**: IDs 27140-27142
- **Epic Tier (10-12)**: IDs 27143-27145
- **Legendary Tier (13-15)**: IDs 27146-27148

#### Chances de Upgrade
- Tier 0: 100%
- Tier 1: 90%
- Tier 2: 80%
- Tier 3: 70%
- Tier 4: 60%
- Tier 5: 50%
- Tier 6: 40%
- Tier 7: 30%
- Tier 8: 20%
- Tier 9: 10%

## 🎮 Habilidades Detalhadas

### Onslaught (Hand)
- **Arquivo**: `data/scripts/customs/tier_system/tier_abilities.lua` (linha 88-116)
- **Função**: `processOnslaught(player, target, damage)`
- **Efeito**: Aumenta dano crítico em 60%
- **Ativação**: Durante ataque (evento `onHealthChange`)
- **Amplificação**: Sim (50% do valor de amplification)
- **Como Funciona**: Modifica diretamente o dano antes de aplicar ao alvo

### Ruse (Armor)
- **Arquivo**: `data/scripts/customs/tier_system/tier_abilities.lua` (linha 119-143)
- **Função**: `processRuse(player, damage)`
- **Efeito**: Dodge completo (reduz dano para 0)
- **Ativação**: Ao receber dano (evento `onHealthChange`)
- **Storage**: Usa storage 100001 para armazenar chance (atualizado via `updateDodgeStorage`)
- **Amplificação**: Sim
- **Como Funciona**: Verifica storage de dodge e reduz dano para 0 se ativado

### Transcendence (Legs)
- **Arquivo**: `data/scripts/customs/tier_system/tier_abilities.lua` (linha 146-196)
- **Função**: `processTranscendence(player)`
- **Efeito**: Avatar automático com buffs
- **Ativação**: Durante combate (evento `onHealthChange`)
- **Requisitos**: Tier 3+, fora de PZ
- **Duração**: 10 segundos
- **Buffs Aplicados**:
  - Outfit de avatar (via `CONDITION_OUTFIT`)
  - 85% de dano (`CONDITION_PARAM_STAT_PERCENTDAMAGE`)
  - 100% critical hit chance (`CONDITION_PARAM_SPECIALSKILL_CRITICALHITPERCENT`)
  - 1500% critical hit amount (`CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT`)
- **Como Funciona**: Aplica condições temporárias ao jogador

### Momentum (Head)
- **Arquivo**: `data/scripts/customs/tier_system/tier_abilities.lua` (linha 199-227)
- **Função**: `processMomentum(player)`
- **Efeito**: Redução de cooldown (visual apenas, precisa implementação na src)
- **Ativação**: Durante combate (evento `onHealthChange`)
- **Requisitos**: Fora de PZ
- **Como Funciona**: Apenas efeito visual, redução real de cooldown precisa ser implementada na src

### Amplification (Feet)
- **Arquivo**: `data/scripts/customs/tier_system/tier_abilities.lua` (linha 230-257)
- **Função**: `processAmplification(player)`
- **Efeito**: 
  - Bônus próprio: +25% critical hit chance, +500% critical hit amount
  - Amplifica outras habilidades em 50% do seu valor
- **Ativação**: Durante combate (evento `onHealthChange`)
- **Duração**: 10 segundos
- **Condições Aplicadas**:
  - `CONDITION_ATTRIBUTES` com `CONDITIONID_COMBAT`
  - `CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE = 25`
  - `CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT = 500`
- **Como Funciona**: Aplica condições e também amplifica outras habilidades via `calculateTotalChance()`

### Lucky Drop (Necklace)
- **Arquivo**: `data/scripts/customs/tier_system/tier_abilities.lua` (linha 322-363)
- **Função**: Event callback `onDropLoot`
- **Efeito**: Aumenta drop rate
- **Ativação**: Ao matar monstro
- **Requisitos**: Stamina > 840
- **Boost**: 5% por tier (tier 1 = 5%, tier 10 = 50%)
- **Como Funciona**: Modifica a taxa de loot ao dropar itens do monstro

## 💾 Storages Utilizados

- **100001**: Dodge storage (chance de dodge da armadura)
- **100002**: Condition subId para bônus de tier

## 🔄 Fluxo de Funcionamento

### Upgrade de Tier
1. Jogador usa item de upgrade em item alvo
2. Sistema valida se item pode receber tier
3. Verifica se não está no tier máximo (10)
4. Aplica tier usando `setItemTier()`
5. Atualiza descrição do item
6. Remove item de upgrade

### Ativação de Habilidades
1. Evento de combate é disparado
2. Sistema verifica tier do item no slot correspondente
3. Calcula chance de ativação (com amplification se aplicável)
4. Se ativado, aplica efeito
5. Envia feedback visual (magic effect, say)

### Equipamento/Desequipamento
1. Item é movido para slot de equipamento
2. Sistema detecta movimento via `onMoveItem`
3. Atualiza storages e condições
4. Habilidades ficam ativas enquanto item estiver equipado

## 📂 Localização dos Bônus e Funções por Habilidade

### Onslaught (Hand/Arma)
- **Arquivo Principal**: `data/scripts/customs/tier_system/tier_abilities.lua`
- **Função**: `processOnslaught(player, target, damage)` (linha 88-116)
- **Evento**: `tier_onHealthChange` (linha 265-304)
- **Chamada**: Quando `source:isPlayer()` ataca
- **Modificação**: Altera `damage.primary.value` e `damage.secondary.value` diretamente
- **Efeito Visual**: `CONST_ME_MAGIC_RED` + mensagem "Onslaught!"

### Ruse (Armor/Armadura)
- **Arquivo Principal**: `data/scripts/customs/tier_system/tier_abilities.lua`
- **Função**: `processRuse(player, damage)` (linha 119-143)
- **Função Auxiliar**: `updateDodgeStorage(playerId)` (linha 48-66)
- **Evento**: `tier_onHealthChange` (linha 265-304)
- **Chamada**: Quando `target:isPlayer()` recebe dano
- **Storage**: 100001 (chance de dodge)
- **Modificação**: Reduz `damage.primary.value` e `damage.secondary.value` para 0
- **Efeito Visual**: `CONST_ME_POFF` + mensagem "Ruse!"
- **Atualização**: `onMoveItem` atualiza storage ao equipar/desequipar (linha 400-410)

### Transcendence (Legs/Pernas)
- **Arquivo Principal**: `data/scripts/customs/tier_system/tier_abilities.lua`
- **Função**: `processTranscendence(player)` (linha 146-196)
- **Evento**: `tier_onHealthChange` (linha 265-304)
- **Chamada**: Quando `source:isPlayer()` ataca
- **Condições Aplicadas**:
  - `CONDITION_OUTFIT` (linha 176-179)
  - `CONDITION_ATTRIBUTES` com buffs (linha 182-187)
- **Configuração**: Outfits por vocação em `tier_ability_config.lua` (linha 78-83)
- **Efeito Visual**: `CONST_ME_MAGIC_GREEN` + mensagem "Transcendence!"

### Momentum (Head/Cabeça)
- **Arquivo Principal**: `data/scripts/customs/tier_system/tier_abilities.lua`
- **Função**: `processMomentum(player)` (linha 199-227)
- **Evento**: `tier_onHealthChange` (linha 265-304)
- **Chamada**: Quando `source:isPlayer()` ataca
- **Efeito Visual**: Magic effect 232 + mensagem "Momentum!"
- **Nota**: Redução de cooldown real precisa ser implementada na src

### Amplification (Feet/Pés)
- **Arquivo Principal**: `data/scripts/customs/tier_system/tier_abilities.lua`
- **Função**: `processAmplification(player)` (linha 230-257)
- **Função Auxiliar**: `calculateTotalChance(player, baseChance, abilityType)` (linha 27-45)
- **Evento**: `tier_onHealthChange` (linha 265-304)
- **Chamada**: Quando `source:isPlayer()` ataca
- **Condições Aplicadas**: `CONDITION_ATTRIBUTES` com critical hit (linha 245-249)
- **Efeito Visual**: `CONST_ME_MAGIC_RED` + mensagem "Amplification!"
- **Bônus**: Amplifica outras habilidades em 50% do seu valor

### Lucky Drop (Necklace/Colar)
- **Arquivo Principal**: `data/scripts/customs/tier_system/tier_abilities.lua`
- **Função**: Event callback `onDropLoot` (linha 322-363)
- **Função Auxiliar**: `TierSystem.getDropBoost(tier)` em `tier_ability_config.lua` (linha 145-151)
- **Evento**: `ecDropLoot.onDropLoot`
- **Chamada**: Quando monstro dropa loot
- **Modificação**: Aumenta taxa de loot baseado no tier
- **Efeito Visual**: `CONST_ME_TUTORIALARROW` + `CONST_ME_TUTORIALSQUARE`

### Gerenciamento de Equipamento
- **Arquivo Principal**: `data/scripts/customs/tier_system/tier_abilities.lua`
- **Função**: `onMoveItem` (linha 389-419)
- **Funções Auxiliares**:
  - `updateDodgeStorage(playerId)` (linha 48-66)
  - `updateStatBonus(playerId)` (linha 69-81)
- **Evento**: `ecMove.onMoveItem`
- **Chamada**: Quando item é movido para/do equipamento
- **Ações**: Atualiza storages e condições ao equipar/desequipar

### Sistema de Upgrade
- **Arquivo Principal**: `data/scripts/customs/tier_system/upgrade_system_tiers.lua`
- **Função Principal**: `upgradeAction.onUse` (linha 127-224)
- **Funções Auxiliares**:
  - `getItemTier(item)` (linha 8-20)
  - `setItemTier(item, tier)` (linha 23-25)
  - `canItemReceiveTier(item)` (linha 94-125)
  - `updateItemDescription(item)` (linha 28-62)
- **Action IDs**: Itens de upgrade registrados (linha 228-234)

## ⚠️ Notas Importantes

- Tier máximo é **10** (configurável em `upgrade_system_tiers.lua`)
- Sistema usa **Custom Attributes** para armazenar tier
- Habilidades são processadas em **eventos de combate**
- **Amplification** afeta todas as outras habilidades exceto ela mesma
- **Transcendence** só funciona fora de Protection Zone
- **Lucky Drop** só funciona com stamina > 840
- **Custom Attributes** devem ser acessados via `getCustomAttribute()`, não diretamente

## 🛠️ Para Correções

### Modificar Chances de Ativação
Editar `data/lib/core/tier_ability_config.lua`:
```lua
TierSystem.abilityConfig["hand"].activationChances = {
    [1] = 0.5, [2] = 1.0, ...
}
```

### Adicionar Nova Habilidade
1. Adicionar configuração em `tier_ability_config.lua`
2. Criar função de processamento em `tier_abilities.lua`
3. Adicionar chamada no evento apropriado

### Modificar Itens de Upgrade
Editar `data/scripts/customs/tier_system/upgrade_system_tiers.lua`:
```lua
local tierUpgradeItems = {
    [ITEM_ID] = {tierAdd = 1, tierName = "Nome"},
    ...
}
```

### Ajustar Tier Máximo
Editar `upgrade_system_tiers.lua`:
```lua
local maxTier = 10 -- Alterar aqui
```

---

**Tipo**: Sistema Lua  
**Requer Recompilação**: Não  
**Requer Reload**: Sim

