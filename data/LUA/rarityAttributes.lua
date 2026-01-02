-- Tabela com todos os atributos poss�veis
ALL_ATTRIBUTES = {
	COMBAT_PHYSICALDAMAGE,        -- Dano f�sico
	COMBAT_ENERGYDAMAGE,          -- Dano de energia
	COMBAT_FIREDAMAGE,            -- Dano de fogo
	COMBAT_DEATHDAMAGE,           -- Dano de morte
	COMBAT_HOLYDAMAGE,            -- Dano sagrado
	COMBAT_ICEDAMAGE,             -- Dano de gelo
	COMBAT_LIFEDRAIN,             -- Dano de dreno de vida (Life Drain)
	COMBAT_DROWNDAMAGE,           -- Dano de afogamento (Drown)
	SKILL_SWORD,                  -- Habilidade com espada
	SKILL_SHIELD,                 -- Habilidade com escudo
	SKILL_DISTANCE,               -- Habilidade de ataque � dist�ncia
	STAT_MAGICPOINTS,             -- Pontos de magia
	STAT_MAXHITPOINTS,            -- Pontos de vida m�ximos
	STAT_MAXMANAPOINTS,           -- Pontos de mana m�ximos
	TOOLTIP_ATTRIBUTE_INCREMENTS,  -- Aumentos de atributos
	TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE, -- Chance de acerto cr�tico
	TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT, -- Quantidade de dano cr�tico
	TOOLTIP_ATTRIBUTE_LIFE_LEECH_CHANCE,  -- Chance de roubo de vida
	TOOLTIP_ATTRIBUTE_LIFE_LEECH_AMOUNT,  -- Quantidade de roubo de vida
	TOOLTIP_ATTRIBUTE_MANA_LEECH_CHANCE,  -- Chance de roubo de mana
	TOOLTIP_ATTRIBUTE_MANA_LEECH_AMOUNT,   -- Quantidade de roubo de mana
	TOOLTIP_ATTRIBUTE_RESISTANCES,          -- Resist�ncias a danos
	TOOLTIP_ATTRIBUTE_STATS,                -- Atributos gerais
	TOOLTIP_ATTRIBUTE_SKILL,                -- Habilidades
	TOOLTIP_ATTRIBUTE_INCREMENT_COINS,      -- Aumenta a quantidade de moedas obtidas
	TOOLTIP_ATTRIBUTE_SPEED,                 -- Velocidade de movimento
	TOOLTIP_ATTRIBUTE_EXPERIENCE,           -- B�nus de experi�ncia
	TOOLTIP_ATTRIBUTE_EXTRADEFENSE,         -- Defesa extra
	TOOLTIP_ATTRIBUTE_INCREMENTS,           -- Aumentos de atributos
}

RARITY_CHANCE = {
	fromMonster = {
		{ id = ITEM_RARITY_COMMON, chance = 40 },
		{ id = ITEM_RARITY_RARE, chance = 20 },
		{ id = ITEM_RARITY_EPIC, chance = 15 },
		{ id = ITEM_RARITY_LEGENDARY, chance = 10 },
		{ id = ITEM_RARITY_BRUTAL, chance = 5 },
	},

	fromQuest = {
		{ id = ITEM_RARITY_COMMON, chance = 1 },
		{ id = ITEM_RARITY_RARE, chance = 1 },
		{ id = ITEM_RARITY_EPIC, chance = 1 },
		{ id = ITEM_RARITY_LEGENDARY, chance = 1 },
		{ id = ITEM_RARITY_BRUTAL, chance = 1 },
	}
}

RARITY_MODIFIERS = {
	{ id = ITEM_RARITY_COMMON, amount = 1, amountMax = 1, factor = 1 },-- 1 %
	{ id = ITEM_RARITY_RARE, amount = 2, amountMax = 4, factor = 5 },-- 5 %
	{ id = ITEM_RARITY_EPIC, amount = 4, amountMax = 6, factor = 15 },-- 15 %
	{ id = ITEM_RARITY_LEGENDARY, amount = 4, amountMax = 8, factor = 30 },-- 35 %
	{ id = ITEM_RARITY_BRUTAL, amount = 5, amountMax = 8, factor = 50 },-- 50 %
}

RARITY_ATTRIBUTES = {
	{ id = CONST_SLOT_WEAPON, attributes = {
		{	-- Physical Damage
			id = TOOLTIP_ATTRIBUTE_INCREMENTS,
			type = {COMBAT_PHYSICALDAMAGE},
			min = 1,
			max = 20,
			chance = 60
		},
		{	-- SKILL
			id = TOOLTIP_ATTRIBUTE_SKILL,
			type = {SKILL_SWORD},
			min = 1,
			max = 4,
			chance = 60
		},
		{	-- Distance
			id = TOOLTIP_ATTRIBUTE_SKILL,
			type = {SKILL_DISTANCE},
			min = 1,
			max = 4,
			chance = 60
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE,
			min = 50,
			max = 100,
			chance = 50
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT,
			min = 1,
			max = 25,
			chance = 50
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_LIFE_LEECH_CHANCE,
			min = 1,
			max = 15,
			chance = 40
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_LIFE_LEECH_AMOUNT,
			min = 1,
			max = 25,
			chance = 40
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_MANA_LEECH_CHANCE,
			min = 1,
			max = 15,
			chance = 30
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_MANA_LEECH_AMOUNT,
			min = 1,
			max = 25,
			chance = 30
		},
	}},
	{ id = CONST_SLOT_HEAD, attributes = {
		{	-- Distance
			id = TOOLTIP_ATTRIBUTE_SKILL,
			type = {SKILL_DISTANCE},
			min = 1,
			max = 4,
			chance = 50
		},
		{ 	-- Physical Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_PHYSICALDAMAGE},
			min = 1,
			max = 4,
			chance = 60
		},
		{	-- Energy Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ENERGYDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Fire Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_FIREDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Earth Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_EARTHDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Ice Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ICEDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- hOLY Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_HOLYDAMAGE},
			min = 1,
			max = 8,
			chance = 60
		},
		{	-- Death Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_DEATHAMAGE},
			min = 1,
			max = 8,
			chance = 60
		},
		{	-- Life Drain Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_LIFEDRAIN},
			min = 1,
			max = 8,
			chance = 40
		},
	}},
	{ id = CONST_SLOT_ARMOR, attributes = {
		{	-- Extra Health
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXHITPOINTS},
			min = 5,
			max = 300,
			chance = 50
		},
		{	-- Extra Mana
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXMANAPOINTS},
			min = 5,
			max = 200,
			chance = 60
		},
		{ 	-- Physical Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_PHYSICALDAMAGE},
			min = 1,
			max = 4,
			chance = 60
		},
		{	-- Energy Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ENERGYDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Fire Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_FIREDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Earth Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_EARTHDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Ice Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ICEDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- hOLY Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_HOLYDAMAGE},
			min = 1,
			max = 8,
			chance = 60
		},
		{	-- Death Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_DEATHAMAGE},
			min = 1,
			max = 8,
			chance = 60
		},
		{	-- Life Drain Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_LIFEDRAIN},
			min = 1,
			max = 8,
			chance = 40
		},
	}},
	{ id = CONST_SLOT_LEGS, attributes = {
		{	-- Experience % bonus
			id = TOOLTIP_ATTRIBUTE_INCREMENT_COINS,
			min = 30,
			max = 80,
			chance = 30
		},
		{	-- Extra Health
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXHITPOINTS},
			min = 5,
			max = 100,
			chance = 40
		},
		{ 	-- Physical Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_PHYSICALDAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Energy Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ENERGYDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Fire Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_FIREDAMAGE},
			min = 1,
			max = 8,
			chance = 60
		},
		{	-- Earth Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_EARTHDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- Ice Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ICEDAMAGE},
			min = 1,
			max = 8,
			chance = 50
		},
		{	-- hOLY Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_HOLYDAMAGE},
			min = 1,
			max = 8,
			chance = 60
		},
		{	-- Death Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_DEATHAMAGE},
			min = 1,
			max = 8,
			chance = 60
		},
		{	-- Life Drain Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_LIFEDRAIN},
			min = 1,
			max = 8,
			chance = 40
		},
		{	-- Experience % bonus
			id = TOOLTIP_ATTRIBUTE_EXPERIENCE,
			min = 5,
			max = 20,
			chance = 30
		},
	}},
	{ id = CONST_SLOT_SHIELD, attributes = {
		{	-- Physical Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_PHYSICALDAMAGE},
			min = 1,
			max = 25,
			chance = 60
		},
		{	-- Shielding
			id = TOOLTIP_ATTRIBUTE_SKILL,
			type = {SKILL_SHIELD},
			min = 1,
			max = 5,
			chance = 80
		},
		{	-- Extra Health
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXHITPOINTS},
			min = 25,
			max = 100,
			chance = 60
		},
		{	-- Energy Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ENERGYDAMAGE},
			min = 1,
			max = 10,
			chance = 50
		},
		{	-- Fire Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_FIREDAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Earth Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_EARTHDAMAGE},
			min = 1,
			max = 10,
			chance = 50
		},
		{	-- Ice Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ICEDAMAGE},
			min = 1,
			max = 10,
			chance = 50
		},
		{	-- hOLY Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_HOLYDAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Death Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_DEATHAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Life Drain Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_LIFEDRAIN},
			min = 1,
			max = 10,
			chance = 40
		},
	}},
	{ id = CONST_SLOT_SPELLBOOK, attributes = {
		{	-- Magic Level
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAGICPOINTS},
			min = 1,
			max = 6,
			chance = 80
		},
		{	-- Extra Mana
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXMANAPOINTS},
			min = 25,
			max = 400,
			chance = 80
		},
		{	-- Extra Health
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXHITPOINTS},
			min = 25,
			max = 200,
			chance = 40
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_MANA_LEECH_CHANCE,
			min = 1,
			max = 15,
			chance = 80
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_MANA_LEECH_AMOUNT,
			min = 1,
			max = 25,
			chance = 80
		},
		{	-- Energy Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ENERGYDAMAGE},
			min = 1,
			max = 10,
			chance = 35
		},
		{	-- Fire Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_FIREDAMAGE},
			min = 1,
			max = 10,
			chance = 35
		},
		{	-- Earth Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_EARTHDAMAGE},
			min = 1,
			max = 10,
			chance = 35
		},
		{	-- Ice Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_ICEDAMAGE},
			min = 1,
			max = 10,
			chance = 35
		},
		{	-- hOLY Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_HOLYDAMAGE},
			min = 1,
			max = 10,
			chance = 35
		},
		{	-- Death Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_DEATHAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Life Drain Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_LIFEDRAIN},
			min = 1,
			max = 10,
			chance = 35
		},
		
	}},
	{ id = CONST_SLOT_WAND, attributes = {
		{	-- Magic Level
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAGICPOINTS},
			min = 1,
			max = 4,
			chance = 80
		},
		{	-- Energy Damage
			id = TOOLTIP_ATTRIBUTE_INCREMENTS,
			type = {COMBAT_ENERGYDAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Fire Damage
			id = TOOLTIP_ATTRIBUTE_INCREMENTS,
			type = {COMBAT_FIREDAMAGE},
			min = 1,
			max = 10,
			chance = 50
		},
		{	-- Death Damage
			id = TOOLTIP_ATTRIBUTE_INCREMENTS,
			type = {COMBAT_DEATHDAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Ice Damage
			id = TOOLTIP_ATTRIBUTE_INCREMENTS,
			type = {COMBAT_ICEDAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Earth Damage
			id = TOOLTIP_ATTRIBUTE_INCREMENTS,
			type = {COMBAT_EARTHDAMAGE},
			min = 1,
			max = 10,
			chance = 60
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE,
			min = 1,
			max = 15,
			chance = 60
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_CRITICALHIT_AMOUNT,
			min = 1,
			max = 25,
			chance = 60
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_LIFE_LEECH_CHANCE,
			min = 1,
			max = 15,
			chance = 40
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_LIFE_LEECH_AMOUNT,
			min = 1,
			max = 25,
			chance = 40
		},
	}},
	{ id = CONST_SLOT_FEET, attributes = {
		{	-- Movement Speed
			id = TOOLTIP_ATTRIBUTE_SPEED,
			min = 1,
			max = 40,
			chance = 80
		},
		{	-- Experience % bonus
			id = TOOLTIP_ATTRIBUTE_EXPERIENCE,
			min = 1,
			max = 5,
			chance = 30
		},
		{	-- Physical Protection
			id = TOOLTIP_ATTRIBUTE_RESISTANCES,
			type = {COMBAT_PHYSICALDAMAGE},
			min = 1,
			max = 5,
			chance = 60
		},
	}},
	{ id = CONST_SLOT_NECKLACE, attributes = {
		{	-- Extra Health
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXHITPOINTS},
			min = 1,
			max = 80,
			chance = 40
		},
		{	-- Extra Mana
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXMANAPOINTS},
			min = 1,
			max = 100,
			chance = 50
		},
		{	-- Magic Level
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAGICPOINTS},
			min = 1,
			max = 2,
			chance = 40
		},
		{	-- SKILL
			id = TOOLTIP_ATTRIBUTE_SKILL,
			type = {SKILL_SWORD},
			min = 1,
			max = 3,
			chance = 40
		},
		{	-- Critical Hit chance
			id = TOOLTIP_ATTRIBUTE_CRITICALHIT_CHANCE,
			min = 1,
			max = 5,
			chance = 50
		},
	}},
	{ id = CONST_SLOT_RING, attributes = {
		{	-- Extra Health
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXHITPOINTS},
			min = 1,
			max = 50,
			chance = 40
		},
		{	-- Extra Mana
			id = TOOLTIP_ATTRIBUTE_STATS,
			type = {STAT_MAXMANAPOINTS},
			min = 1,
			max = 50,
			chance = 50
		},
	}},
}