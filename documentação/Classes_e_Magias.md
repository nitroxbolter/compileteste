# Classes e Magias - RookLand Server

Este documento lista todas as classes (vocations) disponíveis no servidor, seus IDs e todas as magias de cada classe.

---

## 📋 Índice de Classes (Vocations)

### Tabela de IDs

| ID | Nome da Classe | Nome no XML | Client ID |
|----|----------------|-------------|-----------|
| 0 | None | None | 0 |
| 1 | Sorcerer | Sorcerer | 1 |
| 2 | Druid | Druid | 2 |
| 3 | Paladino | Paladino | 3 |
| 4 | Guerreiro | Guerreiro | 4 |
| 5 | Mago | Mago | 5 |
| 6 | Alquimista | Alquimista | 6 |
| 7 | Templario | Templario | 7 |
| 8 | Barbaro | Barbaro | 8 |
| 9 | Illusionist | Illusionist | 9 |
| 10 | Arch Illusionist | Arch Illusionist | 10 |
| 11 | Cidadao | Cidadao | 11 |
| 12 | Arqueiro | Arqueiro | 12 |
| 13 | Hunter | Hunter | 13 |
| 14 | Necromancer | Necromancer | 14 |
| 15 | Evoker | Evoker | 15 |

---

## 📚 Localização dos Arquivos

- **Definições de Vocations (XML):** `data/XML/vocations.xml`
- **Definições de Spells (XML):** `data/spells/spells.xml`
- **IDs em Lua:** `data/lib/core/vocation_id.lua`
- **Enum C++:** `studio/src/enums.h` (enum `Vocation_t`)
- **Classe C++:** `studio/src/vocation.h`, `studio/src/vocation.cpp`

---

## 🎯 Magias por Classe

### 1. Sorcerer (ID: 1)

#### Ataque
- **Energy Strike** (Level 20) - `exori vis`
- **Ignite** (Level 20) - `utori flam`
- **Flame Strike** (Level 20) - `exori flam`
- **Fire Wave** (Level 20) - `exevo flam hur`
- **Energy Beam** (Level 20) - `exevo vis lux`

#### Cura
- **Light Healing** (Level 20) - `exura`

#### Suporte
- **Magic Shield** (Level 20) - `utamo vita`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 2. Mago (ID: 5)

#### Ataque
- **Energy Strike** (Level 20) - `exori vis`
- **Ignite** (Level 20) - `utori flam`
- **Flame Strike** (Level 20) - `exori flam`
- **Fire Wave** (Level 20) - `exevo flam hur`
- **Energy Beam** (Level 20) - `exevo vis lux`
- **Ultimate Flame Strike** (Level 100) - `exori max flam`
- **Ultimate Energy Strike** (Level 100) - `exori max vis`
- **Great Fire Wave** (Level 100) - `exevo gran flam hur`
- **Great Energy Beam** (Level 100) - `exevo gran vis lux`
- **Energy Wave** (Level 100) - `exevo vis hur`
- **Hell's Core** (Level 100) - `exevo gran mas flam`

#### Cura
- **Light Healing** (Level 20) - `exura`
- **Ultimate Healing** (Level 100) - `exura vita`

#### Suporte
- **Strong Haste** (Level 20) - `utani gran hur`
- **Magic Shield** (Level 20) - `utamo vita`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 3. Druid (ID: 2)

#### Ataque
- **Terra Strike** (Level 20) - `exori tera`
- **Ice Strike** (Level 20) - `exori frigo`
- **Envenom** (Level 20) - `utori pox`
- **Ice Wave** (Level 20) - `exevo frigo hur`
- **Terra Burst** (Level 30) - `exevo ulus tera`
- **Wrath of Nature** (Level 55) - `exevo gran mas tera`

#### Cura
- **Heal Friend** (Level 20) - `exura sio`
- **Intense Healing** (Level 20) - `exura gran`

#### Suporte
- **Ultimate Light** (Level 20) - `utevo vis lux`
- **Magic Shield** (Level 20) - `utamo vita`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 4. Alquimista (ID: 6)

#### Ataque
- **Terra Strike** (Level 20) - `exori tera`
- **Ice Strike** (Level 20) - `exori frigo`
- **Envenom** (Level 20) - `utori pox`
- **Ice Wave** (Level 20) - `exevo frigo hur`
- **Terra Burst** (Level 30) - `exevo ulus tera`
- **Wrath of Nature** (Level 55) - `exevo gran mas tera`
- **Ultimate Terra Strike** (Level 90) - `exori max tera`
- **Ultimate Ice Strike** (Level 100) - `exori max frigo`
- **Strong Ice Wave** (Level 100) - `exevo gran frigo hur`
- **Terra Wave** (Level 100) - `exevo tera hur`
- **Ice Burst** (Level 100) - `exevo ulus frigo`
- **Eternal Winter** (Level 100) - `exevo gran mas frigo`

#### Cura
- **Heal Friend** (Level 20) - `exura sio`
- **Intense Healing** (Level 20) - `exura gran`
- **Mass Healing** (Level 100) - `exura gran mas res`
- **Restoration** (Level 100) - `exura max vita`
- **Natures Embrace** (Level 100) - `exura gran sio`

#### Suporte
- **Strong Haste** (Level 20) - `utani gran hur`
- **Heal Party** (Level 100) - `utura mas sio`
- **Ultimate Light** (Level 20) - `utevo vis lux`
- **Magic Shield** (Level 20) - `utamo vita`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 5. Paladino (ID: 3)

#### Ataque
- **Divine Missile** (Level 20) - `exori san`
- **Holy Flash** (Level 20) - `utori san`

#### Cura
- **Divine Healing** (Level 20) - `exura san`
- **Recovery** (Level 20) - `utura`

#### Suporte
- **Enchant Party** (Level 20) - `utori mas sio`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 6. Templario (ID: 7)

#### Ataque
- **Divine Missile** (Level 20) - `exori san`
- **Divine Caldera** (Level 100) - `exevo mas san`
- **Holy Flash** (Level 20) - `utori san`
- **Divine Grenade** (Level 100) - `exevo tempo mas san`
- **Divine Wave** (Level 18) - `exevo tempo wave`

#### Cura
- **Divine Healing** (Level 20) - `exura san`
- **Salvation** (Level 100) - `exura gran san`
- **Recovery** (Level 20) - `utura`
- **Intense Recovery** (Level 100) - `utura gran`

#### Suporte
- **Great Light** (Level 20) - `utevo gran lux`
- **Protect Party** (Level 20) - `utamo mas sio`
- **Enchant Party** (Level 20) - `utori mas sio`
- **Protector** (Level 100) - `utamo tempo`
- **Testadore** (Level 100) - `testadore`
- **Divine Empowerment** (Level 100) - `utevo grav san`
- **Swift Foot** (Level 100) - `utamo tempo san`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 7. Guerreiro (ID: 4)

#### Ataque
- **Brutal Strike** (Level 20) - `exori ico`
- **Whirlwind Throw** (Level 28) - `exori hur`
- **Berserk** (Level 35) - `exori`
- **Front Sweep** (Level 35) - `exori min`
- **Fierce Berserk** (Level 100) - `exori gran`

#### Cura
- **Wound Cleansing** (Level 20) - `exura ico`

#### Suporte
- **Challenge** (Level 20) - `exeta res`
- **Charge** (Level 20) - `utani tempo hur`
- **Chivalrous Challenge** (Level 40) - `exeta amp res`
- **Exeta Challenge** (Level 60) - `exeta challenge`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 8. Barbaro (ID: 8)

#### Ataque
- **Brutal Strike** (Level 20) - `exori ico`
- **Whirlwind Throw** (Level 28) - `exori hur`
- **Berserk** (Level 35) - `exori`
- **Groundshaker** (Level 100) - `exori mas`
- **Front Sweep** (Level 35) - `exori min`
- **Fierce Berserk** (Level 100) - `exori gran`
- **Annihilation** (Level 110) - `exori gran ico`
- **Executioners Throw** (Level 100) - `exori amp kor`

#### Cura
- **Wound Cleansing** (Level 20) - `exura ico`
- **Intense Wound Cleansing** (Level 80) - `exura gran ico`
- **Fair Wound Cleansing** (Level 100) - `exura med ico`

#### Suporte
- **Challenge** (Level 20) - `exeta res`
- **Charge** (Level 20) - `utani tempo hur`
- **Chivalrous Challenge** (Level 40) - `exeta amp res`
- **Blood Rage** (Level 100) - `utito tempo`
- **Exeta Challenge** (Level 60) - `exeta challenge`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 9. Necromancer (ID: 14)

#### Ataque
- **Death Strike** (Level 20) - `exori mort`
- **Arcane Strike** (Level 20) - `exori ar`
- **Grand Death Beam** (Level 20) - `exevo max mort`

#### Cura
- **Blood Healing** (Level 20) - `healing blood`

#### Suporte
- **Summon Creature** (Level 20) - `utevo res`
- **Creature Illusion** (Level 20) - `utevo res ina`

---

### 10. Evoker (ID: 15)

#### Ataque
- **Death Strike** (Level 20) - `exori mort`
- **Arcane Strike** (Level 20) - `exori ar`
- **Grand Death Beam** (Level 20) - `exevo max mort`
- **Rage of the Skies** (Level 100) - `exevo gran mas vis`
- **Evasion** (Level 100) - `exevo gran mas evasion`
- **Cruz** (Level 100) - `exevo cruz`
- **Bewitched Curse** (Level 100) - `exevo witched`
- **Arcane Wave** (Level 100) - `exevo wave`
- **Adento Grav** (Level 100) - `adento grav`
- **Expose Weakness** (Level 100) - `exori moe`

#### Cura
- **Vampire Blood** (Level 100) - `suck blood`
- **Blood Healing** (Level 20) - `healing blood`

#### Suporte
- **Summon Creature** (Level 20) - `utevo res`
- **Creature Illusion** (Level 20) - `utevo res ina`
- **Fear** (Level 100) - `exevo phobia`

---

### 11. Arqueiro (ID: 12)

#### Suporte
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

*Nota: Illusionist compartilha magias básicas com outras classes. Magias específicas podem estar em desenvolvimento.*

---

### 10. Arch Illusionist (ID: 10)

#### Suporte
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

*Nota: Arch Illusionist compartilha magias básicas com outras classes. Magias específicas podem estar em desenvolvimento.*

---

### 14. Cidadao (ID: 11)

#### Ataque
- **Golpear** (Level 1) - `golpear`

#### Cura
- **Magic Patch** (Level 1) - `curar`

#### Suporte
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 12. Arqueiro (ID: 12)

#### Ataque
- **Physical Strike** (Level 20) - `exori arrow ico`
- **Ethereal Spear** (Level 20) - `exori con`
- **Energy Arrow** (Level 20) - `light arrow`

#### Cura
- **Bruise Bane** (Level 20) - `vital nature`

#### Suporte
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 12. Hunter (ID: 13)

#### Ataque
- **Physical Strike** (Level 20) - `exori arrow ico`
- **Ethereal Spear** (Level 20) - `exori con`
- **Energy Arrow** (Level 20) - `light arrow`
- **Strong Ethereal Spear** (Level 100) - `impact arrow`
- **Explosion Arrow** (Level 100) - `flaming arrow`
- **Sky Arrow** (Level 100) - `skying arrow`
- **Disparo Perfurante** (Level 100) - `shot piercing`
- **Nevasca de Flechas** (Level 100) - `blizzard arrows`
- **Boma de Fumaça** (Level 100) - `smoke`

#### Cura
- **Bruise Bane** (Level 20) - `vital nature`
- **Vital Quiver** (Level 100) - `vitaling quiver`

#### Suporte
- **Sharpshooter** (Level 100) - `utito tempo san`
- **Magic Rope** (Level 20) - `exani tera`
- **Levitate** (Level 20) - `exani hur`
- **Haste** (Level 20) - `utani hur`

---

### 13. Illusionist (ID: 9)

## 🔧 Funções Principais

### C++ (studio/src/)

#### Vocation Class
- `Vocation::getId()` - Retorna o ID da vocação
- `Vocation::getClientId()` - Retorna o Client ID da vocação
- `Vocation::getVocName()` - Retorna o nome da vocação
- `Vocation::getVocDescription()` - Retorna a descrição da vocação
- `Vocation::getHPGain()` - Retorna o ganho de HP por level
- `Vocation::getManaGain()` - Retorna o ganho de mana por level
- `Vocation::getCapGain()` - Retorna o ganho de capacidade por level
- `Vocation::getManaGainTicks()` - Retorna os ticks para ganho de mana
- `Vocation::getManaGainAmount()` - Retorna a quantidade de mana ganha por tick
- `Vocation::getHealthGainTicks()` - Retorna os ticks para ganho de HP
- `Vocation::getHealthGainAmount()` - Retorna a quantidade de HP ganha por tick
- `Vocation::getSoulMax()` - Retorna o máximo de soul points
- `Vocation::getSoulGainTicks()` - Retorna os ticks para ganho de soul
- `Vocation::getAttackSpeed()` - Retorna a velocidade de ataque
- `Vocation::getBaseSpeed()` - Retorna a velocidade base
- `Vocation::getFromVocation()` - Retorna a vocação de origem
- `Vocation::allowsPvp()` - Verifica se permite PvP
- `Vocation::getReqSkillTries(uint8_t skill, uint16_t level)` - Retorna os skill tries necessários
- `Vocation::getReqMana(uint32_t magLevel)` - Retorna a mana necessária para um nível mágico

#### Spell Class
- `Spell::configureSpell(const pugi::xml_node& node)` - Configura uma magia a partir do XML
- `Spell::playerSpellCheck(Player* player)` - Verifica se o jogador pode usar a magia
- `Spell::canCastSpell(Player* player)` - Verifica se o jogador pode lançar a magia

### Lua

#### Player Functions
- `player:getVocation()` - Retorna a vocação do jogador
- `player:getVocationId()` - Retorna o ID da vocação do jogador
- `player:getVocationName()` - Retorna o nome da vocação do jogador

#### Spell Functions
- `spell:canCast(cid)` - Verifica se pode lançar a magia
- `spell:execute(cid, var)` - Executa a magia

---

## 📝 Notas Importantes

1. **Magias Compartilhadas**: Algumas magias são compartilhadas entre múltiplas classes (ex: Magic Rope, Levitate, Haste)
2. **Magias de Nível**: Cada magia possui um nível mínimo necessário para ser aprendida
3. **Custo de Mana**: Todas as magias consomem mana (exceto algumas especiais)
4. **Cooldowns**: Magias possuem cooldowns individuais e de grupo
5. **Runes**: Algumas magias podem ser criadas como runas (conjuring spells)
6. **Vocation IDs**: Os IDs são consistentes entre XML, Lua e C++
7. **Client IDs**: Algumas vocações possuem IDs diferentes no cliente (clientid)

---

## 🔄 Para Correções

### Adicionar Nova Magia
1. Edite `data/spells/spells.xml`
2. Adicione a tag `<instant>` ou `<rune>` com os atributos necessários
3. Especifique as vocações que podem usar com `<vocation name="NomeVocation" />`
4. Crie o script Lua correspondente em `data/spells/scripts/`

### Modificar Vocação
1. Edite `data/XML/vocations.xml`
2. Modifique os atributos da vocação (gainhp, gainmana, etc.)
3. Ajuste os multiplicadores de skills se necessário

### Adicionar Nova Vocação
1. Adicione a vocação em `data/XML/vocations.xml`
2. Adicione o ID em `data/lib/core/vocation_id.lua`
3. Adicione o enum em `studio/src/enums.h` (se necessário)
4. Atualize este documento

---

**Última atualização:** Dezembro 2025

