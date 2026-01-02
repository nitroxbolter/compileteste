# Comandos do Servidor - RookLand Server

Este documento lista todos os comandos disponíveis no servidor, organizados por nível de acesso.

---

## 📋 Níveis de Acesso

- **Player**: Comandos públicos disponíveis para todos os jogadores
- **Game Master (GM)**: Comandos disponíveis para jogadores com acesso (`getGroup():getAccess()`)
- **God**: Comandos disponíveis apenas para contas God (`ACCOUNT_TYPE_GOD`)

---

## 📚 Localização dos Arquivos

- **Definições XML:** `data/talkactions/talkactions.xml`
- **Scripts Lua:** `data/talkactions/scripts/`
- **Classe C++:** `studio/src/talkaction.h`, `studio/src/talkaction.cpp`

---

## 🎮 Comandos de Player (Públicos)

### Informações e Utilidades

#### `!commands`
Mostra a lista de comandos disponíveis para jogadores.

**Uso:** `!commands`

**Descrição:** Exibe um popup com todos os comandos públicos disponíveis.

---

#### `!resis`
Mostra as resistências do jogador.

**Uso:** `!resis`

**Script:** `resistances.lua`

---

#### `!uptime`
Mostra o tempo de atividade do servidor.

**Uso:** `!uptime`

**Script:** `uptime.lua`

---

#### `!online` ou `/online`
Mostra a lista de jogadores online.

**Uso:** `!online` ou `/online`

**Script:** `online.lua`

---

#### `!serverinfo`
Exibe informações sobre o servidor.

**Uso:** `!serverinfo`

**Script:** `serverinfo.lua`

---

#### `!deathlist`
Mostra uma lista de mortes recentes.

**Uso:** `!deathlist`

**Script:** `deathlist.lua`

---

#### `!kills`
Mostra o total de kills do jogador.

**Uso:** `!kills`

**Script:** `kills.lua`

---

#### `!ancestral`
Exibe informações sobre o sistema ancestral.

**Uso:** `!ancestral`

**Script:** `ancestral.lua`

---

### Sistema de Casas

#### `!buyhouse`
Permite comprar uma casa.

**Uso:** `!buyhouse`

**Script:** `buyhouse.lua`

---

#### `!sellhouse [preço]`
Permite vender uma casa.

**Uso:** `!sellhouse [preço]`

**Exemplo:** `!sellhouse 50000`

**Script:** `sellhouse.lua`

---

#### `!leavehouse`
Sai da casa atual.

**Uso:** `!leavehouse`

**Script:** `leavehouse.lua`

---

### Sistema de Autoloot

#### `!autoloot [ação], [nome do item]`
Gerencia a lista de autoloot.

**Uso:** 
- `!autoloot add, knight armor` - Adiciona um item à lista
- `!autoloot remove, knight armor` - Remove um item da lista
- `!autoloot show` - Mostra a lista atual
- `!autoloot clear` - Limpa toda a lista

**Limite:** Máximo de 10 itens na lista

**Script:** `autoloot.lua`

---

### Loja Ancestral

#### `!ancestralstore [categoria], [item]`
Acessa a loja ancestral para comprar itens.

**Categorias:**
- **1** - Auras
- **2** - Wings (Asas)
- **3** - Exercise Chests (Baús de Exercício)

**Exemplos:**
- `!ancestralstore 2, 1` - Compra Fiery Wings
- `!ancestralstore 1, 6` - Compra Fireflies (Aura)
- `!ancestralstore 3, 11` - Compra Sword Chest

**Scripts:** Vários scripts específicos para cada item

---

## 👑 Comandos de Game Master (GM)

### Teleporte

#### `/up`
Move o jogador um andar acima.

**Uso:** `/up`

**Script:** `up.lua`

**Acesso:** GM

---

#### `/down`
Move o jogador um andar abaixo.

**Uso:** `/down`

**Script:** `down.lua`

**Acesso:** GM

---

#### `/t`
Teleporta o jogador para sua cidade natal (home).

**Uso:** `/t`

**Script:** `teleport_home.lua`

**Acesso:** GM

---

#### `/town [nome da cidade]`
Teleporta o jogador para uma cidade específica.

**Uso:** `/town venore`

**Script:** `teleport_to_town.lua`

**Acesso:** GM

---

#### `/goto [nome do jogador/criatura]`
Teleporta para a posição de um jogador ou criatura.

**Uso:** `/goto PlayerName`

**Script:** `teleport_to_creature.lua`

**Acesso:** GM

---

#### `/c [nome do jogador/criatura]`
Teleporta um jogador ou criatura para sua posição.

**Uso:** `/c PlayerName`

**Script:** `teleport_creature_here.lua`

**Acesso:** GM

---

#### `/a [x], [y], [z]`
Teleporta para coordenadas específicas.

**Uso:** `/a 1000, 1000, 7`

**Script:** `teleport_ntiles.lua`

**Acesso:** GM

---

### Informações

#### `/info [nome do jogador]`
Mostra informações detalhadas sobre um jogador.

**Uso:** `/info PlayerName`

**Informações exibidas:**
- Nome
- Acesso (0 ou 1)
- Level
- Magic Level
- Velocidade
- Posição
- IP
- Outros jogadores no mesmo IP

**Script:** `info.lua`

**Acesso:** GM

---

### Moderação

#### `/kick [nome do jogador]`
Expulsa um jogador do servidor.

**Uso:** `/kick PlayerName`

**Script:** `kick.lua`

**Acesso:** GM

---

#### `/ban [nome do jogador], [motivo]`
Bane uma conta por 7 dias.

**Uso:** `/ban PlayerName, Cheating`

**Script:** `ban.lua`

**Acesso:** GM

---

#### `/ipban [IP]`
Bane um endereço IP.

**Uso:** `/ipban 127.0.0.1`

**Script:** `ipban.lua`

**Acesso:** GM

---

#### `/unban [nome do jogador]`
Remove o banimento de uma conta.

**Uso:** `/unban PlayerName`

**Script:** `unban.lua`

**Acesso:** GM

---

### Servidor

#### `/openserver`
Abre o servidor para novos jogadores.

**Uso:** `/openserver`

**Script:** `openserver.lua`

**Acesso:** GM

---

#### `/closeserver [motivo]`
Fecha o servidor para novos jogadores.

**Uso:** `/closeserver Maintenance`

**Script:** `closeserver.lua`

**Acesso:** GM

---

#### `/B [mensagem]`
Envia um broadcast (anúncio) para todos os jogadores.

**Uso:** `/B Server will restart in 5 minutes!`

**Script:** `broadcast.lua`

**Acesso:** GM

---

### Utilidades

#### `/r`
Remove um item ou criatura na sua frente.

**Uso:** `/r`

**Script:** `removething.lua`

**Acesso:** GM

---

#### `/save [nome do jogador]`
Força o salvamento de um jogador.

**Uso:** `/save PlayerName`

**Script:** `save.lua`

**Acesso:** GM

---

#### `/ghost`
Ativa/desativa modo ghost (invisível para monstros).

**Uso:** `/ghost`

**Script:** `ghost.lua`

**Acesso:** GM

---

#### `/hide`
Ativa/desativa modo invisível.

**Uso:** `/hide`

**Script:** `hide.lua`

**Acesso:** GM

---

#### `/clean`
Limpa o chão ao redor do jogador.

**Uso:** `/clean`

**Script:** `clean.lua`

**Acesso:** GM

---

#### `/mccheck`
Verifica informações sobre multiclient.

**Uso:** `/mccheck`

**Script:** `mccheck.lua`

**Acesso:** GM

---

#### `/get [storage_id]`
Obtém o valor de um storage.

**Uso:** `/get 12345`

**Script:** `storage_get.lua`

**Acesso:** GM

---

#### `/owner [nome do jogador]`
Define o dono de uma casa.

**Uso:** `/owner PlayerName`

**Script:** `owner.lua`

**Acesso:** GM

---

#### `/position`
Mostra a posição atual do jogador.

**Uso:** `/position`

**Script:** `position.lua`

**Acesso:** GM

---

#### `/time`
Mostra o tempo atual do servidor.

**Uso:** `/time`

**Script:** `time.lua`

**Acesso:** GM

---

## 🔱 Comandos de God

### Criação de Itens e Criaturas

#### `/i [nome/ID do item], [quantidade]`
Cria um item.

**Uso:** 
- `/i gold coin, 1000`
- `/i 2148, 1000`

**Limites:**
- Itens stackáveis: máximo 10.000
- Itens não stackáveis: máximo 100
- Fluid containers: quantidade do fluido

**Script:** `create_item.lua`

**Acesso:** God

---

#### `/icharges [nome/ID do item], [charges]`
Cria um item com cargas específicas.

**Uso:** `/icharges wand of inferno, 100`

**Script:** `create_item_charges.lua`

**Acesso:** God

---

#### `/m [nome do monstro]`
Cria um monstro na sua posição.

**Uso:** `/m dragon`

**Script:** `place_monster.lua`

**Acesso:** God

---

#### `/s [nome do NPC]`
Cria um NPC na sua posição.

**Uso:** `/s banker`

**Script:** `place_npc.lua`

**Acesso:** God

---

#### `/summon [nome da criatura]`
Cria uma criatura como summon.

**Uso:** `/summon wolf`

**Script:** `place_summon.lua`

**Acesso:** God

---

### Atributos e Modificações

#### `/attr [atributo], [valor]`
Define um atributo em um item na sua frente.

**Uso:** `/attr description, This is a special item`

**Atributos suportados:**
- `description` - Descrição do item
- `name` - Nome do item
- E outros atributos de item

**Script:** `attributes.lua`

**Acesso:** GM

---

#### `/looktype [looktype]`
Altera a aparência do jogador.

**Uso:** `/looktype 130`

**Script:** `looktype.lua`

**Acesso:** GM

---

#### `/chameleon [looktype]`
Ativa/desativa modo chameleon (mudança de aparência).

**Uso:** `/chameleon 130`

**Script:** `chameleon.lua`

**Acesso:** GM

---

#### `/addskill [skill], [valor]`
Adiciona pontos de skill ao jogador.

**Uso:** `/addskill sword, 10`

**Script:** `add_skill.lua`

**Acesso:** GM

---

### Sistema de Tier

#### `/god tier [comando] [parâmetros]`
Gerencia o tier de itens.

**Uso:**
- `/god tier` - Mostra informações e ajuda
- `/god tier add [tier]` - Adiciona tier ao item na mão/frente (1-10)
- `/god tier remove` - Remove tier do item
- `/god tier info` - Mostra informações do tier do item
- `/god tier set [tier]` - Define tier (0-10, 0 remove)
- `/god tier [número]` - Define tier diretamente (0-10)
- `/god tier classification set [level]` - Define classification (0-2)
- `/god tier classification remove` - Remove classification

**Exemplos:**
- `/god tier add 5` - Adiciona tier 5
- `/god tier set 0` - Remove tier
- `/god tier classification set 2` - Define Exalted

**Classification Levels:**
- 0 = Base
- 1 = Improved
- 2 = Exalted

**Nota:** O item deve estar na mão ou na frente do jogador.

**Script:** `god_tier.lua`

**Acesso:** God

---

#### `/tier [tier]`
Comando alternativo para testar tier.

**Uso:** `/tier 5`

**Script:** `test_tier.lua`

**Acesso:** GM

---

### Efeitos Visuais

#### `/magic [effect_id]`
Cria um efeito mágico na sua posição.

**Uso:** `/magic 13`

**Script:** `magiceffect.lua`

**Acesso:** GM

---

### Sistema de Reload

#### `/reload [tipo]`
Recarrega um sistema específico do servidor.

**Uso:** `/reload spells`

**Tipos disponíveis:**
- `all` - Recarrega tudo
- `action` / `actions` - Ações
- `chat` / `channel` / `chatchannels` - Canais de chat
- `config` / `configuration` - Configurações
- `creaturescript` / `creaturescripts` - Creature scripts
- `events` - Eventos
- `global` - Global
- `globalevent` / `globalevents` - Global events
- `items` - Itens
- `monster` / `monsters` - Monstros
- `mount` / `mounts` - Montarias
- `aura` / `auras` - Auras
- `wing` / `wings` - Wings
- `shader` / `shaders` - Shaders
- `move` / `movement` / `movements` - Movimentos
- `npc` / `npcs` - NPCs
- `quest` / `quests` - Quests
- `raid` / `raids` - Raids
- `spell` / `spells` - Magias
- `talk` / `talkaction` / `talkactions` - Talkactions
- `weapon` / `weapons` - Armas
- `scripts` - Scripts
- `libs` - Bibliotecas

**Exemplos:**
- `/reload spells` - Recarrega magias
- `/reload monsters` - Recarrega monstros
- `/reload all` - Recarrega tudo

**Script:** `reload.lua`

**Acesso:** God

---

### Sistema de Raids

#### `/raid [nome da raid]`
Força o spawn de uma raid específica.

**Uso:** `/raid dragon`

**Script:** `force_raid.lua`

**Acesso:** GM

---

### Sistema de Tutores

#### `/addtutor [nome do jogador]`
Adiciona um jogador como tutor.

**Uso:** `/addtutor PlayerName`

**Script:** `add_tutor.lua`

**Acesso:** GM

---

#### `/removetutor [nome do jogador]`
Remove um jogador da lista de tutores.

**Uso:** `/removetutor PlayerName`

**Script:** `remove_tutor.lua`

**Acesso:** GM

---

## 🔧 Funções Principais

### C++ (studio/src/)

#### TalkAction Class
- `TalkAction::getWords()` - Retorna as palavras do comando
- `TalkAction::getSeparator()` - Retorna o separador de parâmetros
- `TalkAction::getRequiredAccountType()` - Retorna o tipo de conta necessário
- `TalkAction::getNeedAccess()` - Verifica se precisa de acesso
- `TalkAction::executeSay(Player*, const std::string&, const std::string&, SpeakClasses)` - Executa o comando

### Lua

#### Funções de Verificação
- `player:getGroup():getAccess()` - Verifica se o jogador tem acesso GM
- `player:getAccountType()` - Retorna o tipo de conta (ACCOUNT_TYPE_GOD, etc.)
- `player:getGroup()` - Retorna o grupo do jogador

#### Funções de Execução
- `onSay(player, words, param)` - Função principal executada quando o comando é usado
- `logCommand(player, words, param)` - Registra o comando no log (para alguns comandos)

---

## 📝 Notas Importantes

1. **Separadores**: A maioria dos comandos usa espaço (` `) como separador padrão, mas alguns usam vírgula (`,`)
2. **Case Sensitive**: Nomes de jogadores e criaturas são case-sensitive
3. **Parâmetros Opcionais**: Alguns comandos têm parâmetros opcionais entre colchetes `[]`
4. **Logs**: Comandos de God são geralmente logados no servidor
5. **Validação**: Todos os comandos validam o nível de acesso antes de executar
6. **Erros**: Comandos inválidos retornam mensagens de erro apropriadas

---

## 🔄 Para Correções

### Adicionar Novo Comando

1. **Criar o script Lua** em `data/talkactions/scripts/`
2. **Adicionar entrada no XML** em `data/talkactions/talkactions.xml`:
   ```xml
   <talkaction words="/comando" separator=" " script="nome_script.lua" />
   ```
3. **Implementar a função `onSay`** no script:
   ```lua
   function onSay(player, words, param)
       -- Verificar acesso se necessário
       if not player:getGroup():getAccess() then
           return true
       end
       
       -- Lógica do comando
       
       return false
   end
   ```

### Modificar Comando Existente

1. Edite o script correspondente em `data/talkactions/scripts/`
2. O servidor pode precisar de reload: `/reload talkactions`

### Adicionar Restrição de Acesso

- **GM:** Verifique `player:getGroup():getAccess()`
- **God:** Verifique `player:getAccountType() >= ACCOUNT_TYPE_GOD`

---

## 🎯 Exemplos de Uso

### Exemplo 1: Criar Item
```
/i gold coin, 1000
```

### Exemplo 2: Teleportar Jogador
```
/goto PlayerName
```

### Exemplo 3: Adicionar Tier a Item
```
/god tier add 5
```

### Exemplo 4: Recarregar Sistema
```
/reload spells
```

### Exemplo 5: Gerenciar Autoloot
```
!autoloot add, knight armor
!autoloot remove, knight armor
!autoloot show
```

---

**Última atualização:** Dezembro 2025

