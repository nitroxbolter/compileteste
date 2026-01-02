-- Tier Ability Configuration System
-- This file contains all configuration for the tier system abilities

TierSystem = TierSystem or {}

-- Storage IDs
TierSystem.storageIds = {
	dodgeStorage = 100001,
	conditionSubId = 100002
}

-- Upgrade Items Configuration
TierSystem.upgradeItems = {
	[8302] = {type = "reset"},
	[8303] = {type = "tier"},
	[8304] = {type = "classification"},
	[8305] = {type = "dodge_boost"},
	[8306] = {type = "speed_boost"}
}

-- Ability Configuration by Slot
TierSystem.abilityConfig = {
	["hand"] = {
		ability = "onslaught",
		activationChances = {
			[1] = 0.5, [2] = 1.0, [3] = 1.5, [4] = 2.0, [5] = 2.5,
			[6] = 3.0, [7] = 3.5, [8] = 4.0, [9] = 4.5, [10] = 5.0
		}
	},
	["armor"] = {
		ability = "ruse",
		activationChances = {
			[1] = 0.5, [2] = 1.0, [3] = 1.5, [4] = 2.0, [5] = 2.5,
			[6] = 3.0, [7] = 3.5, [8] = 4.0, [9] = 4.5, [10] = 5.0
		}
	},
	["legs"] = {
		ability = "transcendence",
		activationChances = {
			[1] = 0.0, [2] = 0.0, [3] = 5.0, [4] = 8.0, [5] = 12.0,
			[6] = 16.0, [7] = 20.0, [8] = 25.0, [9] = 30.0, [10] = 35.0
		}
	},
	["head"] = {
		ability = "momentum",
		activationChances = {
			[1] = 1.0, [2] = 2.0, [3] = 3.0, [4] = 4.0, [5] = 5.0,
			[6] = 6.0, [7] = 7.0, [8] = 8.0, [9] = 9.0, [10] = 10.0
		}
	},
	["feet"] = {
		ability = "amplification",
		activationChances = {
			[1] = 0.5, [2] = 1.0, [3] = 1.5, [4] = 2.0, [5] = 2.5,
			[6] = 3.0, [7] = 3.5, [8] = 4.0, [9] = 4.5, [10] = 5.0
		}
	},
	["necklace"] = {
		ability = "lucky_drop",
		activationChances = {
			[1] = 1.0, [2] = 2.0, [3] = 3.0, [4] = 4.0, [5] = 5.0,
			[6] = 6.0, [7] = 7.0, [8] = 8.0, [9] = 9.0, [10] = 10.0
		}
	}
}

-- Slot to Constant Mapping
TierSystem.slotToConstant = {
	["hand"] = {CONST_SLOT_LEFT, CONST_SLOT_RIGHT},
	["head"] = {CONST_SLOT_HEAD},
	["legs"] = {CONST_SLOT_LEGS},
	["feet"] = {CONST_SLOT_FEET},
	["armor"] = {CONST_SLOT_ARMOR},
	["necklace"] = {CONST_SLOT_NECKLACE}
}

-- Avatar Outfits by Vocation
TierSystem.avatarOutfits = {
	["sorcerer"] = {lookType = 130, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0},
	["druid"] = {lookType = 130, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0},
	["paladin"] = {lookType = 129, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0},
	["knight"] = {lookType = 131, lookHead = 0, lookBody = 0, lookLegs = 0, lookFeet = 0, lookAddons = 0}
}

-- Avatar Duration (in milliseconds)
TierSystem.avatarDuration = 10000

-- Upgrade Chances by Tier
TierSystem.upgradeChances = {
	[0] = 100, [1] = 90, [2] = 80, [3] = 70, [4] = 60,
	[5] = 50, [6] = 40, [7] = 30, [8] = 20, [9] = 10
}

-- Classification Levels
TierSystem.classifications = {
	[0] = "Base",
	[1] = "Improved",
	[2] = "Exalted"
}

-- Helper Functions

-- Função global para obter tier de um item
-- Pode ser usada em qualquer lugar do servidor
-- @param item: O item do qual obter o tier
-- @return: O tier do item (0 se não tiver tier)
function TierSystem.getItemTier(item)
	if not item then
		return 0
	end
	
	local tierAttr = item:getCustomAttribute("tier")
	if not tierAttr then
		return 0
	end
	
	-- Tenta converter para número
	if type(tierAttr) == "number" then
		return tierAttr
	else
		return tonumber(tierAttr) or 0
	end
end

function TierSystem.getActivationChance(abilityType, tier)
	local slot = nil
	for slotName, config in pairs(TierSystem.abilityConfig) do
		if config.ability == abilityType then
			slot = slotName
			break
		end
	end
	
	if not slot or not TierSystem.abilityConfig[slot] then
		return 0
	end
	
	return TierSystem.abilityConfig[slot].activationChances[tier] or 0
end

function TierSystem.calculateUpgradeChance(currentTier)
	return TierSystem.upgradeChances[currentTier] or 0
end

function TierSystem.getDropBoost(tier)
	if tier == 0 then
		return 0
	end
	-- Drop boost increases by 5% per tier
	return tier * 5
end

function TierSystem.getItemSlot(itemId)
	-- This function should map item IDs to their slot names
	-- You'll need to implement this based on your item IDs
	-- Example implementation:
	local itemType = ItemType(itemId)
	if not itemType then
		return nil
	end
	
	local slotPosition = itemType:getSlotPosition()
	if slotPosition == SLOTP_HEAD then
		return "head"
	elseif slotPosition == SLOTP_ARMOR then
		return "armor"
	elseif slotPosition == SLOTP_LEGS then
		return "legs"
	elseif slotPosition == SLOTP_FEET then
		return "feet"
	elseif slotPosition == SLOTP_LEFT or slotPosition == SLOTP_RIGHT then
		return "hand"
	elseif slotPosition == SLOTP_AMULET then
		return "necklace"
	end
	
	return nil
end

function TierSystem.isItemTierable(itemId)
	-- Check if an item can receive tier upgrades
	-- You can customize this based on your needs
	local slot = TierSystem.getItemSlot(itemId)
	return slot ~= nil
end

function TierSystem.getMaxTierForItem(itemId)
	-- Maximum tier for items (default 10)
	return 10
end

-- Conditions storage for cleanup
TierSystem.conditions = {
	"dodge_bonus",
	"speed_bonus"
}

-- Avalanche Fusion System (if needed)
TierSystem.avalancheFusion = {
	actionId = 10001,
	positions = {
		item1 = Position(94, 112, 7),
		item2 = Position(95, 112, 7),
		result = Position(96, 112, 7)
	}
}

print(">> Tier Ability Configuration Loaded")

