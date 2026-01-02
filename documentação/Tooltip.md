# Sistema de Tooltip

## 📖 Resumo

O Sistema de Tooltip gerencia a exibição de informações detalhadas dos itens no cliente. Quando um jogador passa o mouse sobre um item ou clica nele, o servidor envia dados estruturados que são exibidos em uma tooltip no cliente. O sistema suporta diversos tipos de atributos (dano, defesa, resistências, skills, etc.) e integra-se com os sistemas de Raridade e Tier.

## 🎯 Como Funciona

1. **Solicitação**: Cliente solicita tooltip ao passar mouse ou clicar em item
2. **Coleta de Dados**: Servidor coleta todos os atributos do item
3. **Processamento**: Dados são processados e formatados
4. **Envio**: Dados são enviados via protocolo para o cliente
5. **Exibição**: Cliente exibe tooltip formatada

### Tipos de Tooltip

- **Virtual Item**: Item não físico (ex: no market)
- **Real Inventory Item**: Item no inventário do jogador
- **Trade Item**: Item na janela de trade

## 📁 Localização dos Arquivos

### C++ (Principal)

- **Definições**: `studio/src/enums.h`
  - `ItemTooltipAttributes_t`: Enum com todos os tipos de atributos
  - `TooltipData`: Estrutura para dados de tooltip
  - `TooltipDataContainer`: Container para múltiplos dados

- **Implementação Principal**: `studio/src/item.cpp`
  - `Item::getTooltipData()`: Coleta todos os dados do item
  - `Item::addTooltipData()`: Adiciona dados à tooltip
  - `Item::getAttributeValue()`: Obtém valor de atributo específico
  - Funções auxiliares:
    - `getTooltipStats()`: Stats (HP, Mana, Magic Level)
    - `getTooltipSkills()`: Skills (Sword, Shield, Distance, etc.)
    - `getTooltipOther()`: Outros atributos

- **Protocolo**: `studio/src/protocolgame.cpp`
  - `ProtocolGame::sendTooltipData()`: Envia dados para cliente
  - `ProtocolGame::parseTooltip()`: Processa solicitação do cliente

- **Game Logic**: `studio/src/game.cpp`
  - `Game::playerSendTooltip()`: Envia tooltip para jogador específico

- **Atributos de Raridade**: `studio/src/itemattributes.h`, `studio/src/itemattributes.cpp`
  - Integração com sistema de raridade
  - Aplicação de atributos aleatórios

### Lua (Integração)

- **Configuração de Raridade**: `data/LUA/rarityAttributes.lua`
  - Define atributos que aparecem em tooltips
  - Integração com sistema de raridade

## 🔧 Funções Principais

### C++

#### `studio/src/item.cpp`

```cpp
// Obter todos os dados de tooltip de um item
void Item::getTooltipData(Item* item, uint16_t spriteId, uint16_t count, 
                          TooltipDataContainer& tooltipData)

// Adicionar dado à tooltip
void Item::addTooltipData(TooltipDataContainer& tooltipData, 
                          ItemTooltipAttributes_t id, int32_t value, int32_t type)

// Obter valor de atributo específico
int32_t Item::getAttributeValue(ItemTooltipAttributes_t id, int32_t type = -1)
```

#### `studio/src/protocolgame.cpp`

```cpp
// Enviar dados de tooltip para cliente
void ProtocolGame::sendTooltipData(const TooltipDataContainer& tooltipData)

// Processar solicitação de tooltip do cliente
void ProtocolGame::parseTooltip(NetworkMessage& msg)
  // Case 0: Virtual item (spriteId + count)
  // Case 1: Real inventory item (position + stackpos)
```

#### `studio/src/game.cpp`

```cpp
// Enviar tooltip para jogador (virtual item)
void Game::playerSendTooltip(uint32_t playerId, uint16_t spriteId, uint16_t count)

// Enviar tooltip para jogador (real item)
void Game::playerSendTooltip(uint32_t playerId, const Position pos, 
                             uint16_t spriteId, uint8_t stackPos, bool counterOffer)
```

## 📊 Tipos de Atributos (ItemTooltipAttributes_t)

### Atributos Básicos
- `TOOLTIP_ATTRIBUTE_NONE = 0`
- `TOOLTIP_ATTRIBUTE_NAME = 3`
- `TOOLTIP_ATTRIBUTE_WEIGHT = 4`
- `TOOLTIP_ATTRIBUTE_COUNT = 18`
- `TOOLTIP_ATTRIBUTE_TEXT = 16`

### Combate
- `TOOLTIP_ATTRIBUTE_ATTACK = 1`
- `TOOLTIP_ATTRIBUTE_DEFENSE = 2`
- `TOOLTIP_ATTRIBUTE_ARMOR = 5`
- `TOOLTIP_ATTRIBUTE_HITCHANCE = 6`
- `TOOLTIP_ATTRIBUTE_SHOOTRANGE = 7`
- `TOOLTIP_ATTRIBUTE_ATTACK_SPEED = 11`
- `TOOLTIP_ATTRIBUTE_EXTRADEFENSE = 42`

### Resistências
- `TOOLTIP_ATTRIBUTE_RESISTANCES = 12`
  - Physical, Energy, Fire, Earth, Ice, Holy, Death, Life Drain, Drown

### Stats
- `TOOLTIP_ATTRIBUTE_STATS = 13`
  - HP, Mana, Magic Level

### Skills
- `TOOLTIP_ATTRIBUTE_SKILL = 14`
  - Sword, Club, Axe, Distance, Shielding, Fishing, etc.

### Especiais
- `TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE = 26`
- `TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT = 27`
- `TOOLTIP_ATTRIBUTE_LIFE_LEECH_CHANCE = 30`
- `TOOLTIP_ATTRIBUTE_LIFE_LEECH_AMOUNT = 31`
- `TOOLTIP_ATTRIBUTE_MANA_LEECH_CHANCE = 28`
- `TOOLTIP_ATTRIBUTE_MANA_LEECH_AMOUNT = 29`

### Bônus
- `TOOLTIP_ATTRIBUTE_EXPERIENCE = 33`
- `TOOLTIP_ATTRIBUTE_INCREMENT_COINS = 32`
- `TOOLTIP_ATTRIBUTE_SPEED = 23`
- `TOOLTIP_ATTRIBUTE_INCREMENTS = 47`

### Raridade
- `TOOLTIP_ATTRIBUTE_RARITY = 24`

### Dano Elemental
- `TOOLTIP_ATTRIBUTE_FIRE_ATTACK = 34`
- `TOOLTIP_ATTRIBUTE_ENERGY_ATTACK = 35`
- `TOOLTIP_ATTRIBUTE_ICE_ATTACK = 36`
- `TOOLTIP_ATTRIBUTE_DEATH_ATTACK = 37`
- `TOOLTIP_ATTRIBUTE_EARTH_ATTACK = 38`
- `TOOLTIP_ATTRIBUTE_HOLY_ATTACK = 39`
- `TOOLTIP_ATTRIBUTE_WATER_ATTACK = 40`
- `TOOLTIP_ATTRIBUTE_ARCANE_ATTACK = 41`

### Regeneração
- `TOOLTIP_ATTRIBUTE_HEALTH_REGENERATE_ON_KILL_AMOUNT = 43`
- `TOOLTIP_ATTRIBUTE_HEALTH_REGENERATE_ON_KILL_CHANCE = 44`
- `TOOLTIP_ATTRIBUTE_MANA_REGENERATE_ON_KILL_AMOUNT = 45`
- `TOOLTIP_ATTRIBUTE_MANA_REGENERATE_ON_KILL_CHANCE = 46`

### Outros
- `TOOLTIP_ATTRIBUTE_DURATION = 8`
- `TOOLTIP_ATTRIBUTE_CHARGES = 9`
- `TOOLTIP_ATTRIBUTE_FLUIDTYPE = 10`
- `TOOLTIP_ATTRIBUTE_KEY = 15`
- `TOOLTIP_ATTRIBUTE_WIELDINFO = 17`
- `TOOLTIP_ATTRIBUTE_RUNE_LEVEL = 19`
- `TOOLTIP_ATTRIBUTE_RUNE_MAGIC_LEVEL = 20`
- `TOOLTIP_ATTRIBUTE_RUNE_NAME = 21`
- `TOOLTIP_ATTRIBUTE_CONTAINER_SIZE = 22`
- `TOOLTIP_ATTRIBUTE_FIELD_ABSORB = 25`

## 🔄 Fluxo de Funcionamento

### Solicitação de Tooltip

1. **Cliente**: Jogador passa mouse ou clica em item
2. **Protocolo**: Cliente envia opcode de tooltip
3. **Servidor**: `parseTooltip()` processa solicitação
4. **Identificação**: Sistema identifica tipo (virtual/real)
5. **Coleta**: `getTooltipData()` coleta todos os atributos
6. **Processamento**: Dados são formatados
7. **Envio**: `sendTooltipData()` envia para cliente
8. **Cliente**: Exibe tooltip formatada

### Coleta de Dados

1. **Atributos Base**: ItemType fornece atributos básicos
2. **Atributos de Item**: Item fornece atributos específicos
3. **Raridade**: Sistema de raridade adiciona atributos
4. **Tier**: Sistema de tier pode adicionar informações
5. **Agregação**: Todos os dados são agregados em container

## 💾 Estrutura de Dados

### TooltipData

```cpp
struct TooltipData {
    ItemTooltipAttributes_t attributeId;  // Tipo de atributo
    std::any attributeValue;               // Valor (int32_t ou string)
    int32_t attributeType;                 // Tipo específico (SKILL_SWORD, etc.)
}
```

### Formato de Envio

```
Byte 0x9E (Opcode)
Byte: Quantidade de atributos
Para cada atributo:
  Byte: attributeId
  Byte: isNumber (1 = número, 0 = string)
  Se número:
    Byte: isNegative
    Uint32: valor absoluto
    Uint32: attributeType
  Se string:
    String: valor
```

## ⚠️ Notas Importantes

- Tooltips são **geradas sob demanda** (não são cacheadas)
- Sistema suporta **valores numéricos e strings**
- **Raridade** é exibida automaticamente se item tiver
- **Atributos de raridade** são somados aos atributos base
- Sistema integra com **custom attributes** para raridade/tier

## 🛠️ Para Correções

### Adicionar Novo Tipo de Atributo

1. **Adicionar ao enum** (`studio/src/enums.h`):
```cpp
TOOLTIP_ATTRIBUTE_NOVO_ATRIBUTO = 48,
```

2. **Implementar coleta** (`studio/src/item.cpp`):
```cpp
// Em getTooltipData() ou função específica
if (novoAtributo > 0) {
    tooltipData.push_back(TooltipData(TOOLTIP_ATTRIBUTE_NOVO_ATRIBUTO, novoAtributo));
}
```

3. **Atualizar cliente** (se necessário)

### Modificar Exibição de Raridade

Editar `studio/src/item.cpp` em `getTooltipData()`:
```cpp
if (item && item->getRarityLevel() > 0) {
    tooltipData.push_back(TooltipData(TOOLTIP_ATTRIBUTE_RARITY, item->getRarityLevel()));
}
```

### Adicionar Atributo Custom

Usar `Item::addTooltipData()` em eventos Lua:
```lua
-- Exemplo em evento de equipamento
item:addTooltipData(tooltipData, TOOLTIP_ATTRIBUTE_EXPERIENCE, bonusExp)
```

---

**Tipo**: Sistema C++ (com integração Lua)  
**Requer Recompilação**: Sim  
**Requer Reload**: Não (mudanças em Lua não afetam tooltip base)

