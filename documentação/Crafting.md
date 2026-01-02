# Sistema de Crafting

## 📖 Resumo

O Sistema de Crafting permite que jogadores criem itens usando materiais e habilidades de diferentes profissões. O sistema suporta múltiplas categorias de crafting (Herbalist, Woodcutting, Mining, General Crafting, Armorsmith, Weaponsmith, Jewelsmith) e integra-se com o sistema de Raridade para gerar itens com raridades aleatórias.

## 🎯 Como Funciona

1. **Acesso**: Jogador interage com objeto (Action ID específico) para abrir interface
2. **Seleção**: Jogador escolhe receita da categoria
3. **Validação**: Sistema verifica materiais, nível de skill, dinheiro e storage
4. **Criação**: Após delay, item é criado
5. **Raridade**: Sistema rola raridade para o item criado
6. **Falha**: Há chance de 15% de falha (materiais e dinheiro são consumidos)
7. **Experiência**: Jogador ganha skill tries baseado no nível

### Categorias de Crafting

- **Herbalist**: Plantas e poções
- **Woodcutting**: Itens de madeira
- **Mining**: Itens de minério
- **General Crafting**: Itens gerais
- **Armorsmith**: Armaduras
- **Weaponsmith**: Armas
- **Jewelsmith**: Joias e acessórios

## 📁 Localização dos Arquivos

### Lua (Principal)

- **Sistema Principal**: `data/scripts/customs/crafting/1crafting_mod.lua`
  - Lógica principal de crafting
  - Gerenciamento de categorias
  - Sistema de raridade
  - Interface com cliente

- **Categorias Individuais**:
  - `data/scripts/customs/crafting/herbalist.lua`
  - `data/scripts/customs/crafting/woodcutting.lua`
  - `data/scripts/customs/crafting/mining.lua`
  - `data/scripts/customs/crafting/generalcrafting.lua`
  - `data/scripts/customs/crafting/armorsmith.lua`
  - `data/scripts/customs/crafting/weaponsmith.lua`
  - `data/scripts/customs/crafting/jewelsmith.lua`

- **Sistema Alternativo**: `data/lib/core/crafting.lua`
  - Sistema de crafting via NPC
  - Interface modal window

### C++ (Suporte)

- **Extended Opcode**: Suporte para comunicação cliente-servidor
- **Skills**: Definições de skills em `studio/src/enums.h`
  - `SKILL_HERBALIST = 9`
  - `SKILL_WOODCUTTING = 10`
  - `SKILL_MINING = 11`
  - `SKILL_CRAFTING = 8`
  - `SKILL_ARMORSMITH = 12`
  - `SKILL_WEAPONSMITH = 13`
  - `SKILL_JEWELSMITH = 14`

## 🔧 Funções Principais

### Lua

#### `data/scripts/customs/crafting/1crafting_mod.lua`

```lua
-- Função principal de crafting
Crafting:craft(player, category, craftId)
  -- Valida materiais, skill, dinheiro
  -- Cria item após delay
  -- Aplica raridade
  -- Adiciona skill tries

-- Enviar lista de crafts
Crafting:sendCrafts(player, category, page)
  -- Envia lista paginada via Extended Opcode

-- Enviar materiais atualizados
Crafting:sendMaterials(player, category, craftId)
  -- Envia quantidade de materiais do jogador

-- Enviar dinheiro atualizado
Crafting:sendMoney(player)
  -- Envia quantidade de dinheiro do jogador

-- Mostrar interface de crafting
player:showCrafting(category)
  -- Abre interface no cliente
```

#### Sistema de Raridade

```lua
-- Rolar raridade baseado no skill
function rollRarity(player)
  -- Calcula chance baseada no skill level
  -- Retorna rarityId e rarityName
end
```

### Action IDs por Categoria

- **Herbalist**: 38820
- **Woodcutting**: 38821
- **Mining**: 38822
- **General Crafting**: 38823
- **Jewelsmith**: 38824
- **Armorsmith**: 38825
- **Weaponsmith**: 38826

## 📊 Estrutura de Receita

Cada receita é definida como uma tabela:

```lua
Crafting[category][craftId] = {
    id = itemId,              -- ID do item a ser criado
    count = quantidade,       -- Quantidade a criar
    level = skillLevel,       -- Nível mínimo de skill
    cost = goldCost,          -- Custo em gold
    materials = {             -- Materiais necessários
        {id = materialId, count = quantidade},
        ...
    },
    storage = storageId,      -- Storage necessário (opcional)
    storageText = "texto"     -- Texto se storage não desbloqueado
}
```

## 🎮 Sistema de Skills

### Multiplicadores por Nível

```lua
local skillsStages = {
    {minlevel = 0, maxlevel = 50, multiplier = 1.0},
    {minlevel = 51, maxlevel = 100, multiplier = 1.5},
    {minlevel = 101, maxlevel = 200, multiplier = 2.0},
    {minlevel = 201, multiplier = 3.0}
}
```

### Chances de Raridade por Skill

O sistema calcula chances de raridade baseado no nível de skill:
- Skill baixo: Maior chance de Common
- Skill alto: Maior chance de raridades superiores

## 💰 Sistema de Falha

- **Chance de Falha**: 15% (configurável)
- **Consequências**: Materiais e dinheiro são consumidos mesmo em falha
- **Feedback**: Mensagem "O item falhou!!"

## 🔄 Fluxo de Funcionamento

### Processo Completo

1. **Acesso**: Jogador clica em objeto com Action ID
2. **Interface**: `showCrafting()` abre interface no cliente
3. **Lista**: Cliente solicita lista de crafts
4. **Seleção**: Jogador seleciona receita
5. **Validação**: Sistema valida:
   - Nível de skill suficiente
   - Materiais suficientes
   - Dinheiro suficiente
   - Storage desbloqueado (se aplicável)
   - Espaço na mochila
6. **Delay**: Sistema aguarda 860ms
7. **Verificação Final**: Verifica mochila novamente
8. **Rolagem de Falha**: 15% de chance de falhar
9. **Criação**: Item é criado
10. **Raridade**: Sistema rola raridade
11. **Aplicação**: Raridade é aplicada ao item
12. **Entrega**: Item é adicionado à mochila
13. **Consumo**: Materiais e dinheiro são removidos
14. **Experiência**: Skill tries são adicionados
15. **Atualização**: Interface é atualizada

### Extended Opcode

- **CODE_CRAFTING = 91**: Código do opcode
- **Formato**: JSON
- **Ações**:
  - `craft`: Solicitar criação
  - `list`: Solicitar lista
  - `materials`: Solicitar materiais
  - `money`: Solicitar dinheiro

## 📋 Exemplo de Receita

```lua
Crafting.armorsmith[1] = {
    id = 2463,  -- Plate Armor
    count = 1,
    level = 10,
    cost = 500,
    materials = {
        {id = 5880, count = 5},  -- Iron Ingot
        {id = 5878, count = 2}   -- Leather
    }
}
```

## ⚠️ Notas Importantes

- **Arquivo Principal**: `1crafting_mod.lua` deve ser carregado primeiro (número no nome garante ordem)
- **Chance de Falha**: 15% fixa, não afetada por skill
- **Delay**: 860ms entre validação e criação
- **Raridade**: Apenas itens criados recebem raridade (não itens de receitas básicas)
- **Paginamento**: Lista é paginada (10 itens por página)
- **Storage**: Algumas receitas requerem storage desbloqueado

## 🛠️ Para Correções

### Adicionar Nova Receita

Editar arquivo da categoria (ex: `armorsmith.lua`):
```lua
Crafting.armorsmith[novoId] = {
    id = itemId,
    count = 1,
    level = skillLevel,
    cost = goldCost,
    materials = {
        {id = materialId, count = quantidade}
    }
}
```

### Modificar Chance de Falha

Editar `1crafting_mod.lua`:
```lua
local failChance = 15  -- Alterar valor (0-100)
```

### Adicionar Nova Categoria

1. Criar arquivo `data/scripts/crafting/nova_categoria.lua`
2. Adicionar Action ID em `1crafting_mod.lua`:
```lua
local categoryAIDs = {
    nova_categoria = 38827
}
```
3. Adicionar skill correspondente (se necessário)
4. Carregar arquivo em `1crafting_mod.lua`

### Modificar Multiplicadores de Skill

Editar `1crafting_mod.lua`:
```lua
local skillsStages = {
    {minlevel = 0, maxlevel = 50, multiplier = 1.0},
    -- Adicionar novos estágios
}
```

### Ajustar Delay de Criação

Editar `1crafting_mod.lua`:
```lua
addEvent(function() ... end, 860)  -- Alterar 860 para outro valor (ms)
```

### Modificar Itens por Página

Editar `1crafting_mod.lua`:
```lua
local fetchLimit = 10  -- Alterar quantidade
```

---

**Tipo**: Sistema Lua  
**Requer Recompilação**: Não  
**Requer Reload**: Sim  
**Extended Opcode**: Sim (CODE_CRAFTING = 91)

