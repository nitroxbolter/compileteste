# Sistema de Raridade

## 📖 Resumo

O Sistema de Raridade atribui níveis de raridade aos itens (Common, Rare, Epic, Legendary, Brutal) e aplica atributos aleatórios baseados na raridade e no slot do item. Quando um item é equipado, seus atributos de raridade são aplicados ao jogador através de condições e storages.

## 🎯 Como Funciona

1. **Geração de Raridade**: Itens podem receber raridade ao serem dropados de monstros ou criados via crafting
2. **Atributos Aleatórios**: Baseado na raridade e no slot, atributos são gerados aleatoriamente
3. **Aplicação de Efeitos**: Ao equipar um item, seus atributos são aplicados ao jogador
4. **Remoção de Efeitos**: Ao desequipar, os efeitos são removidos

### Níveis de Raridade (IDs em C++)

Definidos em `studio/src/enums.h` (linha 749-756):

```cpp
enum ItemRarity_t : uint8_t {
    ITEM_RARITY_NONE = 0,
    ITEM_RARITY_COMMON = 1,      // Common
    ITEM_RARITY_RARE = 2,        // Rare
    ITEM_RARITY_EPIC = 3,        // Epic
    ITEM_RARITY_LEGENDARY = 4,   // Legendary
    ITEM_RARITY_BRUTAL = 5       // Brutal
};
```

**Chances de Drop (de monstros):**
- **Common** (ITEM_RARITY_COMMON = 1): 40% chance
- **Rare** (ITEM_RARITY_RARE = 2): 20% chance
- **Epic** (ITEM_RARITY_EPIC = 3): 15% chance
- **Legendary** (ITEM_RARITY_LEGENDARY = 4): 10% chance
- **Brutal** (ITEM_RARITY_BRUTAL = 5): 5% chance

**Funções Lua para Raridade:**
- `item:getRarityLevel()` - Retorna o nível de raridade (0-5)
- `item:getRarity()` - Retorna a raridade (mesmo que getRarityLevel)
- `item:setRarityLevel(rarityLevel)` - Define a raridade (1-5)
- `item:setRandomRarity(fromMonster)` - Define raridade aleatória
- `item:getRarityAttributes()` - Retorna tabela com todos os atributos de raridade

### Modificadores por Raridade

- **Common**: 1% de bônus
- **Rare**: 2-4% de bônus, fator 5%
- **Epic**: 4-6% de bônus, fator 15%
- **Legendary**: 4-8% de bônus, fator 30%
- **Brutal**: 5-8% de bônus, fator 50%

## 📁 Localização dos Arquivos

### Lua (Principal)
- **Configuração de Atributos**: `data/LUA/rarityAttributes.lua`
  - Define todos os atributos possíveis
  - Define chances de raridade
  - Define modificadores por raridade
  - Define atributos por slot

- **Sistema Base**: `data/scripts/customs/rarity/base_rarity.lua`
  - Gerencia equipamento/desequipamento
  - Aplica condições ao jogador
  - Gerencia storages de absorção e dano elemental

- **Sistemas de Combate**:
  - `data/scripts/customs/rarity/rarity_onCombat_elementdamage.lua` - Dano elemental
  - `data/scripts/customs/rarity/rarity_onCombat_absorbs.lua` - Absorções

- **Sistema de Drop de Monstros**: `data/scripts/eventcallbacks/monster/default_onDropLoot.lua`
  - Gerencia multiplicadores de loot
  - Aplica boost pessoal de loot
  - Adiciona itens raros universais
  - Calcula bônus de gold
  - **Nota**: A raridade é aplicada automaticamente pelo C++ após este callback

### C++ (Suporte)
- **Definições**: `studio/src/enums.h`
  - `ItemRarity_t` - Enum de raridades
  - `ItemTooltipAttributes_t` - Atributos de tooltip

- **Implementação**: `studio/src/itemattributes.h`, `studio/src/itemattributes.cpp`
  - Classe `ItemRarityAttributes`
  - Funções de geração de raridade
  - Aplicação de atributos aleatórios

- **Aplicação de Raridade em Drops**: `studio/src/monster.cpp` (linha 2038-2084)
  - Função `Monster::dropLoot()`
  - Aplica raridade automaticamente aos itens dropados
  - Chama `item->setRarityLevel(corpse->getPosition(), true)` para cada item
  - O parâmetro `true` indica que é drop de monstro (usa chances `fromMonster`)

## 🔧 Funções Principais

### Lua

#### `data/LUA/rarityAttributes.lua`
- **RARITY_CHANCE**: Tabela com chances de raridade (fromMonster, fromQuest)
- **RARITY_MODIFIERS**: Modificadores de bônus por raridade
- **RARITY_ATTRIBUTES**: Atributos possíveis por slot

#### `data/scripts/customs/rarity/base_rarity.lua`
- **onEquip(player, item, slotPosition)**: Aplica atributos ao equipar
- **onDeEquip(player, slotPosition)**: Remove atributos ao desequipar
- **conditions**: Tabela com todas as condições possíveis (skills, stats, special skills)

#### `data/scripts/eventcallbacks/monster/default_onDropLoot.lua`
- **ec.onDropLoot(self, corpse)**: Event callback executado quando monstro dropa loot
- **getSkillId(skillName)**: Converte nome de skill para ID
- **hasRelevantStats(item)**: Verifica se item tem stats relevantes para raridade
- **Funções principais**:
  - Calcula multiplicador de loot baseado no nível do monstro
  - Aplica boost pessoal de loot (storage 76855)
  - Adiciona loot extra conforme multiplicador
  - Adiciona itens raros universais (3% de chance)
  - Calcula e aplica bônus de gold

### C++

#### `studio/src/itemattributes.h`
```cpp
class ItemRarityAttributes {
    bool load();
    ItemRarity_t getRandomRarityId(bool fromMonster) const;
    bool setRandomAttributes(ItemRarity_t rarityId, slots_t slotId, ...);
}
```

#### `studio/src/itemattributes.cpp`
- **load()**: Carrega configurações do arquivo Lua
- **getRandomRarityId()**: Retorna uma raridade aleatória baseada nas chances
- **setRandomAttributes()**: Aplica atributos aleatórios ao item

## 🎮 Atributos Aplicados por Slot

### Armas (CONST_SLOT_WEAPON)
- Dano físico
- Skills (Sword, Distance)
- Critical Hit (chance e amount)
- Life Leech (chance e amount)
- Mana Leech (chance e amount)

### Cabeça (CONST_SLOT_HEAD)
- Skills (Distance)
- Resistências (Physical, Energy, Fire, Earth, Ice, Holy, Death, Life Drain, Drown)

### Armadura (CONST_SLOT_ARMOR)
- Stats (HP, Mana)
- Resistências (todas)

### Pernas (CONST_SLOT_LEGS)
- Bônus de moedas
- HP extra
- Resistências
- Bônus de experiência

### Escudo (CONST_SLOT_SHIELD)
- Proteção física
- Skill de shielding
- HP extra
- Resistências

### Spellbook (CONST_SLOT_SPELLBOOK)
- Magic Level
- Mana extra
- HP extra
- Mana Leech
- Resistências

### Wand (CONST_SLOT_WAND)
- Magic Level
- Dano elemental (Energy, Fire, Death, Ice, Earth)
- Critical Hit
- Life/Mana Leech

### Pés (CONST_SLOT_FEET)
- Velocidade
- Bônus de experiência
- Proteção física

### Colar (CONST_SLOT_NECKLACE)
- HP/Mana extra
- Magic Level
- Skills
- Critical Hit chance

### Anel (CONST_SLOT_RING)
- HP/Mana extra

## 💾 Storages Utilizados

O sistema usa storages para gerenciar absorções e danos elementais:

- **977544**: Fire Absorb
- **977545**: Physical Absorb
- **977546**: Energy Absorb
- **977547**: Earth Absorb
- **977548**: Drown Absorb
- **977549**: Ice Absorb
- **977550**: Holy Absorb
- **977551**: Death Absorb
- **977552**: Water Absorb
- **977553**: Arcane Absorb
- **977554-977561**: Dano elemental (Fire, Ice, Energy, Earth, Death, Water, Holy, Arcane)

## 🔄 Fluxo de Funcionamento

### Drop de Monstros

1. **Monstro Morre**: `Monster::dropLoot()` é chamado em C++
2. **Event Callback**: `default_onDropLoot.lua` é executado primeiro
   - Aplica multiplicadores de loot baseados no nível do monstro
   - Adiciona loot extra conforme multiplicador
   - Adiciona itens raros universais (3% de chance)
   - Calcula bônus de gold
3. **Aplicação de Raridade**: C++ percorre todos os itens no corpse
   - Para cada item não-container: `item->setRarityLevel(corpse->getPosition(), true)`
   - O parâmetro `true` indica que é drop de monstro
4. **Geração de Raridade**: `getRandomRarityId(true)` usa chances `fromMonster`
5. **Aplicação de Atributos**: `setRandomAttributes()` aplica atributos aleatórios baseados na raridade e slot

### Equipamento de Itens

1. **Equipamento**: `onEquip()` é chamado quando item é equipado
2. **Aplicação de Condições**: Condições são aplicadas ao jogador
3. **Atualização de Storages**: Storages são atualizados com valores de absorção/dano
4. **Desequipamento**: `onDeEquip()` remove todos os efeitos

### Criação via Crafting

1. **Item Criado**: Sistema de crafting cria item
2. **Rolagem de Raridade**: `rollRarity(player)` calcula raridade baseada no skill
3. **Aplicação**: `item:setRarityLevel(rarityId)` aplica raridade
4. **Atributos**: Sistema de raridade aplica atributos automaticamente

## ⚠️ Notas Importantes

- O sistema usa **Custom Attributes** para armazenar valores de raridade
- Condições são aplicadas com **subId único** por slot para evitar conflitos
- O sistema verifica equipamentos a cada 3 segundos via `onThinkInventory`
- Absorções são somadas de todos os itens equipados
- Dano elemental é somado apenas de armas (slots RIGHT/LEFT)
- **Raridade em Drops**: Aplicada automaticamente pelo C++ em `Monster::dropLoot()`
- **Event Callback**: `default_onDropLoot.lua` é executado ANTES da aplicação de raridade
- **Multiplicadores de Loot**: Baseados no nível do monstro (5-50, 51-100, 101-200, etc.)
- **Boost Pessoal**: Storage 76855 controla multiplicador adicional de loot
- **Itens Raros Universais**: IDs 28343 e 28344 com 3% de chance de drop

## 🛠️ Para Correções

- **Modificar chances de raridade**: Editar `data/LUA/rarityAttributes.lua` (tabela `RARITY_CHANCE`)
- **Adicionar novos atributos**: Adicionar em `RARITY_ATTRIBUTES` e criar condição em `base_rarity.lua`
- **Modificar lógica de equipamento**: Editar `data/scripts/customs/rarity/base_rarity.lua`
- **Ajustar modificadores**: Editar `RARITY_MODIFIERS` em `rarityAttributes.lua`
- **Modificar multiplicadores de loot**: Editar `data/scripts/eventcallbacks/monster/default_onDropLoot.lua` (linha 88-101)
- **Ajustar boost pessoal de loot**: Modificar storage 76855 e valores em `default_onDropLoot.lua` (linha 104-107)
- **Alterar itens raros universais**: Editar IDs e chances em `default_onDropLoot.lua` (linha 119-123)
- **Modificar aplicação de raridade em C++**: Editar `studio/src/monster.cpp` (linha 2053)

---

**Tipo**: Sistema Híbrido (Lua + C++)  
**Requer Recompilação**: Sim (para mudanças em C++)  
**Requer Reload**: Sim (para mudanças em Lua)

