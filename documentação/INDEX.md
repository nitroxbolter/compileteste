# Índice de Sistemas - RookLand Server

Este documento serve como índice principal para todos os sistemas implementados no servidor. Cada sistema possui sua própria documentação detalhada.

## 📋 Sistemas Documentados

### 1. [Sistema de Raridade](./Raridade.md)
Sistema que atribui raridades aos itens (Common, Rare, Epic, Legendary, Brutal) e aplica atributos aleatórios baseados na raridade e no slot do item.

**Localização:**
- Lua: `data/LUA/rarityAttributes.lua`
- Lua: `data/scripts/customs/rarity/`
- C++: `studio/src/itemattributes.h`, `studio/src/itemattributes.cpp`

### 2. [Sistema de Tier](./Tier.md)
Sistema de upgrade de itens através de tiers (0-10), com habilidades especiais ativadas baseadas no tier do equipamento.

**Localização:**
- Lua: `data/lib/core/tier_ability_config.lua`
- Lua: `data/scripts/customs/tier_system/`
- C++: `studio/src/` (suporte para custom attributes)

### 3. [Sistema de Tempo](./Tempo.md)
Sistema que gerencia o tempo do servidor e envia atualizações de horário para os clientes.

**Localização:**
- Lua: `data/scripts/customs/tempo/tempopcode.lua`
- Lua: `data/creaturescripts/scripts/custom/time_system.lua`
- C++: `studio/src/game.cpp`, `studio/src/game.h`

### 4. [Sistema de Tooltip](./Tooltip.md)
Sistema que gerencia a exibição de informações detalhadas dos itens no cliente através de tooltips.

**Localização:**
- C++: `studio/src/item.cpp`, `studio/src/protocolgame.cpp`
- C++: `studio/src/enums.h` (definições de atributos)
- Lua: Integração com sistema de raridade

### 5. [Sistema de Crafting](./Crafting.md)
Sistema completo de criação de itens através de diferentes profissões (Herbalist, Woodcutting, Mining, Armorsmith, Weaponsmith, Jewelsmith).

**Localização:**
- Lua: `data/scripts/customs/crafting/`
- Lua: `data/lib/core/crafting.lua`

### 6. [Atributos e Funções](./Atributos_e_Funções.md)
Documentação completa sobre Special Skills (Critical Hit, Life Leech, Mana Leech) e suas funções disponíveis no servidor.

**Localização:**
- C++: `studio/src/enums.h` (definições)
- C++: `studio/src/player.cpp` (implementação)
- Lua: Bindings em `studio/src/luascript.cpp`

### 7. [Sistema de Monster Level](./Monster_Level.md)
Sistema que permite que monstros tenham níveis variáveis, afetando HP, velocidade, experiência, loot e skull.

**Localização:**
- C++: `studio/src/monster.cpp`, `studio/src/monster.h`
- Lua: `data/scripts/eventcallbacks/monster/default_onDropLoot.lua`
- Lua: `data/events/scripts/player.lua`

### 8. [Classes e Magias](./Classes_e_Magias.md)
Documentação completa de todas as classes (vocations) disponíveis no servidor, seus IDs e todas as magias de cada classe.

**Localização:**
- XML: `data/XML/vocations.xml`
- XML: `data/spells/spells.xml`
- Lua: `data/lib/core/vocation_id.lua`
- C++: `studio/src/vocation.h`, `studio/src/vocation.cpp`
- C++: `studio/src/enums.h` (enum Vocation_t)

### 9. [Comandos do Servidor](./Comandos.md)
Documentação completa de todos os comandos disponíveis no servidor, incluindo comandos de Player, Game Master e God.

**Localização:**
- XML: `data/talkactions/talkactions.xml`
- Lua: `data/talkactions/scripts/`
- C++: `studio/src/talkaction.h`, `studio/src/talkaction.cpp`

---

## 🔍 Como Usar Esta Documentação

1. **Para entender um sistema específico:** Acesse o arquivo correspondente (ex: `Raridade.md`)
2. **Para encontrar funções principais:** Cada documento lista as funções principais e onde estão localizadas
3. **Para fazer correções:** Cada documento indica se o sistema está em Lua, C++ ou ambos
4. **Para entender o funcionamento:** Cada documento contém um resumo explicativo do sistema

---

## 📝 Notas Importantes

- **Lua**: Sistemas implementados apenas em Lua podem ser modificados sem recompilar o servidor
- **C++**: Sistemas que envolvem código C++ requerem recompilação do servidor
- **Híbrido**: Alguns sistemas usam ambos (Lua para lógica, C++ para comunicação com cliente)

---

## 🔄 Atualizações

Esta documentação deve ser atualizada sempre que:
- Um novo sistema for adicionado
- Um sistema existente for modificado significativamente
- Novas funções forem adicionadas a sistemas existentes

---

**Última atualização:** Dezembro 2025

