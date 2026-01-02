#include "otpch.h"
#include "itemattributes.h"
#include <unordered_set>

// Define quais atributos exigem verifica��o por id + types
static const std::unordered_set<ItemTooltipAttributes_t> attributesWithTypes = {
	TOOLTIP_ATTRIBUTE_INCREMENTS,
	TOOLTIP_ATTRIBUTE_RESISTANCES,
	TOOLTIP_ATTRIBUTE_STATS,
	TOOLTIP_ATTRIBUTE_SKILL
};

// Estrutura para armazenar informa��es sobre atributos de raridade
static struct I {
	const char* name; // Nome do atributo
	int type; // Tipo do atributo
} itemrarityattributes[] = {
	{ "id", LUA_TNUMBER },
	{ "type", LUA_TTABLE },
	{ "min", LUA_TUSERDATA },
	{ "max", LUA_TUSERDATA },
	{ "chance", LUA_TNUMBER },
	{ nullptr, 0 }
};

bool ItemRarityAttributes::loadChances(lua_State* L)
{
	auto getChances = [&](const char* name, bool fromMonster) {
		lua_getfield(L, -1, name); // Obtem o campo fornecido
		if (!lua_istable(L, -1)) {
			std::cout << "[Warning - ItemAttributes::loadChances] Missing " << name << " node." << std::endl;
			return false; // Retorna falso se o campo n�o for uma tabela
		}

		lua_pushnil(L); // Prepara para iterar sobre a tabela
		while (lua_next(L, -2)) { // Itera sobre os elementos da tabela
			lua_getfield(L, -1, "id");
			if (!lua_isnumber(L, -1)) {
				std::cout << "[Warning - ItemAttributes::loadChances] Missing id." << std::endl;
				return false; // Retorna falso se o id estiver ausente
			}

			ItemRarity_t rarityId = static_cast<ItemRarity_t>(lua_tonumber(L, -1));
			lua_pop(L, 1); // Remove o id da pilha

			lua_getfield(L, -1, "chance");
			if (!lua_isnumber(L, -1)) {
				std::cout << "[Warning - ItemAttributes::loadChances] Missing chance." << std::endl;
				return false; // Retorna falso se a chance estiver ausente
			}

			int32_t chance = static_cast<int32_t>(lua_tonumber(L, -1)); // Obtem a chance
			lua_pop(L, 1); // Remove a chance da pilha

			m_chances[fromMonster][rarityId] = chance; // Armazena a chance com o nome do campo correto
			lua_pop(L, 1); // Remove o elemento da tabela
		}

		lua_pop(L, 1); // Remove a tabela da pilha
		return true; // Retorna verdadeiro se tudo foi carregado corretamente
	};

	lua_getglobal(L, "RARITY_CHANCE"); // Obtem a tabela global de chances

	// Carrega as chances de raridade de monstros e de quests
	if (!getChances("fromMonster", true) || !getChances("fromQuest", false)) {
		lua_pop(L, 1); // Remove a tabela da pilha em caso de erro
		return false; // Retorna falso se houve erro
	}

	lua_pop(L, 1); // Remove a tabela da pilha
	return true; // Retorna verdadeiro se tudo foi carregado corretamente
}

bool ItemRarityAttributes::loadModifiers(lua_State* L)
{
	lua_getglobal(L, "RARITY_MODIFIERS");
	for (uint16_t i = 1; ; i++)
	{
		lua_rawgeti(L, -1, i);
		if (lua_isnil(L, -1)) {
			lua_pop(L, 1);
			break;
		}

		lua_getfield(L, -1, "id");
		if (!lua_isnumber(L, -1)) {
			std::cout << "[Warning - ItemAttributes::loadModifiers] Missing rarity id." << std::endl;
			return false;
		}

		ItemRarity_t rarityId = static_cast<ItemRarity_t>(lua_tonumber(L, -1));
		lua_pop(L, 1);

		lua_getfield(L, -1, "amount");
		if (!lua_isnumber(L, -1)) {
			std::cout << "[Warning - ItemAttributes::loadModifiers] Missing amount." << std::endl;
			return false;
		}
		int32_t amount = lua_tonumber(L, -1);
		lua_pop(L, 1);

		lua_getfield(L, -1, "amountMax");
		int32_t amountMax = amount; // fallback se nao for definido
		if (lua_isnumber(L, -1)) {
			amountMax = lua_tonumber(L, -1);
		}
		lua_pop(L, 1);

		lua_getfield(L, -1, "factor");
		if (!lua_isnumber(L, -1)) {
			std::cout << "[Warning - ItemAttributes::loadModifiers] Missing factor." << std::endl;
			return false;
		}

		float factor = static_cast<float>(lua_tonumber(L, -1));
		lua_pop(L, 1);
		
		m_modifiers[rarityId] = {amount, amountMax, factor};
		lua_pop(L, 1);
	}

	return true;
}

bool ItemRarityAttributes::loadAttributes(lua_State* L)
{
	lua_getglobal(L, "RARITY_ATTRIBUTES");
	for (uint16_t i = 1; ; i++)
	{
		lua_rawgeti(L, -1, i);
		if (lua_isnil(L, -1)) {
			lua_pop(L, 1);
			break;
		}

		lua_getfield(L, -1, "id");
		if (!lua_isnumber(L, -1)) {
			std::cout << "[Warning - ItemAttributes::loadAttributes] Missing slot id." << std::endl;
			return false;
		}

		slots_t slotId = static_cast<slots_t>(lua_tonumber(L, -1));
		lua_pop(L, 1);

		lua_getfield(L, -1, "attributes");
		if (!lua_istable(L, -1)) {
			std::cout << "[Warning - ItemAttributes::loadAttributes] Missing attributes node." << std::endl;
			return false;
		}

		lua_pushnil(L);
		while (lua_next(L, -2)) {
			ItemRarityAttributesData data;
			// FORA DO LOOP, pegue o ID do atributo primeiro
			lua_getfield(L, -1, "id");
			if (!lua_isnumber(L, -1)) {
				std::cout << "[Warning - ItemAttributes::loadAttributes] Missing attribute id." << std::endl;
				lua_pop(L, 1);
				continue;  // ignora esse atributo
			}
			data.id = static_cast<ItemTooltipAttributes_t>(lua_tonumber(L, -1));
			lua_pop(L, 1);

			for (uint16_t j = 0; itemrarityattributes[j].name != nullptr; j++) {
				const std::string name = itemrarityattributes[j].name;
				if (name == "id") continue; // j� lido acima
				const int type = itemrarityattributes[j].type;

				lua_getfield(L, -1, itemrarityattributes[j].name);
				if (type == LUA_TNUMBER && lua_isnumber(L, -1)) {
					if (name == "chance") {
						data.chance = lua_tonumber(L, -1);
					}
				}
				else if (type == LUA_TTABLE && lua_istable(L, -1)) {
					if (name == "type") {
						// S� atribui se o atributo exige 'types'
						if (attributesWithTypes.count(data.id) > 0) {
							lua_pushnil(L);
							while (lua_next(L, -2)) {
								int value = lua_tointeger(L, -1);
								data.types.push_back(value); // Aceita zero como valor v�lido
								lua_pop(L, 1);
							}
						}
					}
				}
				else if (type == LUA_TUSERDATA) {
					if (lua_istable(L, -1)) {
						lua_pushnil(L);
						while (lua_next(L, -2)) {
							if (name == "min") {
								data.range.first.push_back(lua_tonumber(L, -1));
								lua_pop(L, 1);
							}
							else if (name == "max") {
								data.range.second.push_back(lua_tonumber(L, -1));
								lua_pop(L, 1);
							}
						}
					}
					else if (lua_isnumber(L, -1)) {
						if (name == "min") {
							data.range.first.push_back(lua_tonumber(L, -1));
						}
						else if (name == "max") {
							data.range.second.push_back(lua_tonumber(L, -1));
						}
					}
				}

				lua_pop(L, 1);
			}

			// Adicionar leitura do campo factor
			lua_getfield(L, -1, "factor");
			if (lua_isboolean(L, -1)) {
				data.useFactor = lua_toboolean(L, -1);
			} else {
				data.useFactor = true; // padr�o � aplicar o fator
			}
			lua_pop(L, 1);

			m_attributes[slotId].push_back(data);
			lua_pop(L, 1);
		}

		lua_pop(L, 1);
		lua_pop(L, 1);
	}

	return true;
}

bool ItemRarityAttributes::load()
{
	lua_State* L = luaL_newstate();
	if (!L) {
		throw std::runtime_error("Failed to allocate memory in ItemAttributes");
	}

	luaL_openlibs(L);
	LuaScriptInterface::registerEnums(L);

	if (luaL_dofile(L, "data/LUA/rarityAttributes.lua")) {
		std::cout << "[Error - rarityAttributes] " << lua_tostring(L, -1) << std::endl;
		lua_close(L);
		return false;
	}

	if (!loadChances(L) || !loadModifiers(L) || !loadAttributes(L)) {
		return false;
	}

	lua_close(L);
	return true;
}

ItemRarity_t ItemRarityAttributes::getRandomRarityId(bool fromMonster) const
{
	auto itChances = m_chances.find(fromMonster);
	if (itChances == m_chances.end()) {
		return ITEM_RARITY_NONE;
	}

	for (auto& itChance : itChances->second) {
		if (uniform_random(0, 100) <= itChance.second) {
			return itChance.first;
		}
	}

	return ITEM_RARITY_COMMON;
}

void ItemRarityAttributes::applyFactor(int32_t& value, float factor)
{
	int32_t oldValue = value;
	float result = value + (value * factor / 100.0f);
	value = static_cast<int32_t>(std::round(result));

	if (value == oldValue) {
		// Se o aumento foi muito pequeno, chance de subir +1
		if (uniform_random(1, static_cast<int>(std::ceil(factor)))) {
			value++;
		}
	}
}

bool ItemRarityAttributes::setRandomAttributes(ItemRarity_t rarityId, slots_t slotId, std::multimap<ItemTooltipAttributes_t, std::pair<int32_t, IntegerVector>>* itemAttributes)
{
	// Print de incio do processo
	//std::cout << "====================== APLICANDO ATRIBUTOS ALEATORIOS ======================" << std::endl;

	itemAttributes->clear();
	//std::cout << "[Info] Item slot: " << getSlotName(slotId) << " (" << static_cast<int>(slotId) << ")" << std::endl;

	// Debug log added here
	//std::cout << "[DEBUG] Final slot detected: " << getSlotName(slotId) << " (" << (int)slotId << ")" << std::endl;

	auto itModifiers = m_modifiers.find(rarityId);
	if (itModifiers == m_modifiers.end()) {
		std::cout << "[setRandomAttributes] Raridade ID " << (uint16_t)rarityId << " nao encontrada nos modificadores." << std::endl;
		return false;
	}

	int32_t amountMin = std::get<0>(itModifiers->second);
	int32_t amountMax = std::get<1>(itModifiers->second);
	float fator = std::get<2>(itModifiers->second);

	const auto itAttributes = m_attributes.find(slotId);
	if (itAttributes == m_attributes.end()) {
		//std::cout << "[setRandomAttributes] No attributes found for slot ID: " << (uint16_t)slotId << std::endl;
		return false;
	}

	// Clonar a lista de atributos dispon�veis
	std::vector<ItemRarityAttributesData> cloneList = itAttributes->second; // Clonando a lista de atributos
	std::vector<ItemRarityAttributesData> finalList;

	int32_t quantidadeDisponivel = static_cast<int32_t>(cloneList.size());
	int32_t quantidadeAtributos = uniform_random(amountMin, amountMax);
	quantidadeAtributos = std::max(amountMin, std::min(quantidadeAtributos, quantidadeDisponivel));

	// Print de separador
	//	std::cout << "====================== Attributes to generate ======================" << std::endl;
	//	std::cout << "[Modificadores] Atributos a gerar: " << quantidadeAtributos
	//	          << " (minimo: " << amountMin << ", mximo: " << amountMax << "), Fator: " << fator
	//	          << ", Disponveis: " << quantidadeDisponivel << std::endl;

	if (quantidadeAtributos == 0) {
		//std::cout << "[setRandomAttributes] No attributes defined for this rarity." << std::endl;
		return true;
	}

	// 1. Novo loop de tentativas
	int tentativas = 0;
	while (static_cast<int32_t>(finalList.size()) < quantidadeAtributos && tentativas < 100) {
		if (cloneList.empty()) {
			// Recarrega a lista com os atributos originais, removendo os j� aplicados
			cloneList = itAttributes->second;

			// Remove da cloneList os atributos que j� est�o na finalList
			for (const auto& usado : finalList) {
				cloneList.erase(std::remove_if(cloneList.begin(), cloneList.end(),
					[&](const ItemRarityAttributesData& d) {
						return d.id == usado.id && d.types == usado.types;
					}), cloneList.end());
			}

			if (cloneList.empty()) {
				std::cout << "[Loop] No remaining attributes to try again." << std::endl;
				break;
			}
		}

		const size_t index = uniform_random(0, cloneList.size() - 1);
		ItemRarityAttributesData candidate = cloneList[index];
		cloneList.erase(cloneList.begin() + index);  // Garante que ele n�o ser� repetido
		tentativas++;

		if (uniform_random(1, 100) <= candidate.chance) {
			finalList.push_back(candidate);
		}
	}

	if (tentativas >= 100) {
		std::cout << "[Aviso] Loop de tentativa de atributos excedeu 100 iteracoes!" << std::endl;
	}

	// Print de separador antes da aplicacao dos atributos
	//std::cout << "[ APLICACAO DE ATRIBUTOS ]" << std::endl;

	// 3. Apply attributes from finalList
	int indexAplicado = 1;
	for (const auto& attributeData : finalList) {
		ItemTooltipAttributes_t attributeId = attributeData.id;
		int32_t value = uniform_random(attributeData.range.first.at(0), attributeData.range.second.at(0));


		// Apply factor only if useFactor is true
		if (attributeData.useFactor) {
			applyFactor(value, fator);
		}


		switch (attributeId) {
			case TOOLTIP_ATTRIBUTE_RESISTANCES:
			case TOOLTIP_ATTRIBUTE_INCREMENTS:
			case TOOLTIP_ATTRIBUTE_SKILL:
			case TOOLTIP_ATTRIBUTE_STATS: {
				IntegerVector itemTypes;
				if (attributeId == TOOLTIP_ATTRIBUTE_RESISTANCES || attributeId == TOOLTIP_ATTRIBUTE_INCREMENTS) {
					for (auto& itCombatType : attributeData.types) {
						itemTypes.push_back(combatTypeToIndex(static_cast<CombatType_t>(itCombatType)));
					}
				} else {
					itemTypes = attributeData.types;
				}

				itemAttributes->emplace(attributeId, std::make_pair(value, itemTypes));
				std::cout << "Applied Attribute [#" << indexAplicado++ << "] ID: " << attributeId << ", Value: " << value << ", Types: " << printVector(itemTypes) << std::endl;
				break;
			}
			default: {
				itemAttributes->emplace(attributeId, std::make_pair(value, IntegerVector{}));
				std::cout << "Applied Attribute [#" << indexAplicado++ << "] ID: " << attributeId << ", Value: " << value << ", Types: []" << std::endl;
				break;
			}
		}
	}

	// Print de finalizacao
	//std::cout << "====================== ATRIBUTOS APLICADOS ======================" << std::endl;
	return true;
}

// Funcao auxiliar de impressao de vetores
std::string ItemRarityAttributes::printVector(const IntegerVector& vec) {
	std::ostringstream oss;
	oss << "[";
	for (size_t i = 0; i < vec.size(); ++i) {
		oss << vec[i];
		if (i != vec.size() - 1) {
			oss << ", ";
		}
	}
	oss << "]";
	return oss.str();
}

// Fun��o auxiliar para converter slotId em string
std::string ItemRarityAttributes::getSlotName(slots_t slot) {
	switch (slot) {
		case CONST_SLOT_WHEREEVER: return "wherever";
		case CONST_SLOT_HEAD: return "head";
		case CONST_SLOT_NECKLACE: return "necklace";
		case CONST_SLOT_BACKPACK: return "backpack";
		case CONST_SLOT_ARMOR: return "armor";
		case CONST_SLOT_RIGHT: return "right hand";
		case CONST_SLOT_LEFT: return "left hand";
		case CONST_SLOT_LEGS: return "legs";
		case CONST_SLOT_FEET: return "feet";
		case CONST_SLOT_RING: return "ring";
		case CONST_SLOT_AMMO: return "ammo";
		case CONST_SLOT_STORE_INBOX: return "store inbox";
		case CONST_SLOT_DECK: return "deck";
		case CONST_SLOT_BADGE: return "badge";
		case CONST_SLOT_SHIP: return "ship";
		case CONST_SLOT_BELT: return "belt";
		case CONST_SLOT_GLOVES: return "gloves";
		case CONST_SLOT_SHIELD: return "shield";
		case CONST_SLOT_SPELLBOOK: return "spellbook";
		case CONST_SLOT_WEAPON: return "weapon";
		case CONST_SLOT_WAND: return "wand";
		default: return "unknown";
	}
}