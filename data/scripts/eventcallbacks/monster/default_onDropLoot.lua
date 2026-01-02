local ec = EventCallback

local COINS = {
    [2148] = 1,    -- gold coin
    [2152] = 100,  -- platinum coin
    [2160] = 10000 -- crystal coin
}

local function getSkillId(skillName)
    if skillName == "club" then return SKILL_CLUB
    elseif skillName == "sword" then return SKILL_SWORD
    elseif skillName == "axe" then return SKILL_AXE
    elseif skillName == "mining" then return SKILL_MINING
    elseif skillName == "crafting" then return SKILL_CRAFTING
    elseif skillName == "woodcutting" then return SKILL_WOODCUTTING
    elseif skillName == "herbalist" then return SKILL_HERBALIST
    elseif skillName == "armorsmith" then return SKILL_ARMORSMITH
    elseif skillName == "weaponsmith" then return SKILL_WEAPONSMITH
    elseif skillName == "jewelsmith" then return SKILL_JEWELSMITH
    elseif skillName:sub(1, 4) == "dist" then return SKILL_DISTANCE
    elseif skillName:sub(1, 6) == "shield" then return SKILL_SHIELD
    elseif skillName:sub(1, 4) == "fish" then return SKILL_FISHING
    elseif skillName:sub(1, 4) == "fist" then return SKILL_FIST
    elseif skillName:sub(1, 1) == "m" then return SKILL_MAGLEVEL
    end
    return nil
end

local function hasRelevantStats(item)
    if type(item) ~= "userdata" then return false end

    local itemType = ItemType(item:getId())
    if not itemType then return false end

    local hasWeapon = (itemType:getAttack() > 0 or itemType:getDefense() > 0)
    local hasArmor = (itemType:getArmor() > 0)
    local hasHit = (itemType:getHitChance() > 0)
    local hasAbsorb = false
    local abilities = itemType:getAbilities()

    if abilities and abilities.absorbPercent then
        for _, percent in pairs(abilities.absorbPercent) do
            if percent > 0 then
                hasAbsorb = true
                break
            end
        end
    end

    local hasSkill = false
    if abilities and abilities.skills then
        local skillTypes = {"fist", "club", "sword", "axe", "distance", "shield", "magic", "mining", "crafting", "woodcutting", "herbalist", "armorsmith", "weaponsmith", "jewelsmith"}
        for _, skillName in ipairs(skillTypes) do
            local skillId = getSkillId(skillName)
            if skillId then
                local skillValue = abilities.skills[skillId]
                if skillValue and skillValue > 0 then
                    hasSkill = true
                    break
                end
            end
        end
    end

    local hasSpecialSkill = false
    local specialSkillTypes = {"criticalHitChance", "criticalHitAmount", "manaLeechChance", "manaLeechAmount", "lifeLeechChance", "lifeLeechAmount"}
    if abilities and abilities.specialSkills then
        for _, spec in ipairs(specialSkillTypes) do
            if abilities.specialSkills[spec] and abilities.specialSkills[spec] > 0 then
                hasSpecialSkill = true
                break
            end
        end
    end

    return (hasWeapon or hasArmor or hasHit or hasAbsorb or hasSkill or hasSpecialSkill)
end

ec.onDropLoot = function(self, corpse)
    local mType = self:getType()
    local player = Player(corpse:getCorpseOwner())
    if not player then return end

    local monsterLoot = mType:getLoot()
    local lootMultiplier = 1
    local monsterLevel = self:getMonsterLevel()

    -- Loot scaling por nível do monstro
    if monsterLevel >= 5 and monsterLevel < 50 then
        lootMultiplier = 1.15
    elseif monsterLevel >= 51 and monsterLevel < 100 then
        lootMultiplier = 1.35
    elseif monsterLevel >= 101 and monsterLevel < 200 then
        lootMultiplier = 1.65
    elseif monsterLevel >= 201 and monsterLevel < 300 then
        lootMultiplier = 1.95
    elseif monsterLevel >= 301 and monsterLevel < 500 then
        lootMultiplier = 2.25
    elseif monsterLevel >= 501 then
        lootMultiplier = 2.70
    end

    -- Storage de boost pessoal
    local storageBoost = player:getStorageValue(76855)
    if storageBoost >= 1 and storageBoost <= 6 then
        lootMultiplier = lootMultiplier + ({1.15, 1.35, 1.65, 1.95, 2.25, 2.70})[storageBoost]
    end

    -- Aplica loot extra conforme multiplicador
    for i = 1, #monsterLoot do
        for _ = 1, lootMultiplier do
            local additionalItem = corpse:createLootItem(monsterLoot[i])
            if not additionalItem then
                Spdlog.warn(string.format("[3][Monster:onDropLoot] - Could not add additional loot item to monster: %s, from corpse id: %d.", self:getName(), corpse:getId()))
            end
        end
    end

    -- Itens raros universais com 3% de chance
    if math.random(1, 100) <= 3 then
        corpse:addItem(28343, math.random(1, 5))
        corpse:addItem(28344, math.random(1, 3))
    end

    -- Calcula bônus de gold do jogador
    local goldBonusPercent = player:getTotalIncrementCoins()
    local extraGold = 0

    for i = 0, corpse:getSize() - 1 do
        local item = corpse:getItem(i)
        if item then
            local id = item:getId()
            local value = COINS[id]
            if value then
                extraGold = extraGold + math.floor((item:getCount() * value) * (goldBonusPercent / 100))
            end
        end
    end

    -- Mensagem de loot
    local lootText = corpse:getContentDescription()
    -- Envia apenas a mensagem normal do loot (sem bônus)
local lootMessage = ("Loot of %s: %s"):format(mType:getNameDescription(), lootText)
local party = player:getParty()

if party then
    for _, member in pairs(party:getMembers()) do
        member:sendTextMessage(MESSAGE_INFO_DESCR, lootMessage)
    end
else
    player:sendTextMessage(MESSAGE_INFO_DESCR, lootMessage)
end

-- Envia o bônus em azul, separado
if extraGold > 0 then
    local bonusText = string.format("+ %d gold extra (bonus %d%%)", extraGold, goldBonusPercent)
    if party then
        for _, member in pairs(party:getMembers()) do
            member:sendTextMessage(MESSAGE_EVENT_ADVANCE, bonusText)
        end
    end
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, bonusText)
end

end

ec:register()
