#pragma once

#include "luascript.h"
#include "tools.h"
#include <string>
#include <map>
#include <vector>
#include <tuple>
#include <sstream>

struct ItemRarityAttributesData
{
	ItemTooltipAttributes_t id = TOOLTIP_ATTRIBUTE_NONE;
	IntegerVector types;
	std::pair<IntegerVector, IntegerVector> range; // First list holds min range, the second list the max range
	int32_t chance = 100;
	bool useFactor = true;
};

typedef std::map<slots_t, std::vector<ItemRarityAttributesData>> ItemRarityAttributesDataMap;
typedef std::map<ItemRarity_t, std::tuple<int32_t, int32_t, int32_t>> ItemRarityModifiers;
typedef std::map<bool, std::map<ItemRarity_t, int32_t>> ItemRarityChances;

class ItemRarityAttributes
{
	public:
		static ItemRarityAttributes* getInstance()
		{
			static ItemRarityAttributes instance;
			return &instance;
		}

		bool load();
		ItemRarity_t getRandomRarityId(bool fromMonster) const;
		bool setRandomAttributes(ItemRarity_t rarityId, slots_t slotId, std::multimap<ItemTooltipAttributes_t, std::pair<int32_t, IntegerVector>>* attributes);
		
		static std::string printVector(const IntegerVector& vec);
		static std::string getSlotName(slots_t slot);

		void applyFactor(int32_t& value, float factor);

	private:
		bool loadChances(lua_State* L);
		bool loadModifiers(lua_State* L);
		bool loadAttributes(lua_State* L);

		ItemRarityAttributesDataMap m_attributes;
		ItemRarityModifiers m_modifiers;
		ItemRarityChances m_chances;
};
