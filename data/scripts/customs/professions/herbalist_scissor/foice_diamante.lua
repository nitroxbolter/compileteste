local herbalistSystem = Action()
local COOLDOWN_SECONDS = 4

local config = {
    [30327] = {text = {"The plant is regenerating."}}, -- flor commum
    [2740] = {break_chance = 75, loot_chance = 80, lower_tier = 30327, requiredSkill = 0, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 2741, count = 1},--flor commum
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 2741, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 2741, count = 3},
        },
    },
    [30328] = {text = {"The plant is regenerating."}}, -- flor dalias
    [4158] = {break_chance = 75, loot_chance = 80, lower_tier = 30328, requiredSkill = 0, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 4156, count = 1},--flor commum
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 4156, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 4156, count = 3},
        },
    },
    [30329] = {text = {"The plant is regenerating."}}, -- flor jasmin
    [2742] = {break_chance = 75, loot_chance = 80, lower_tier = 30329, requiredSkill = 0, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30318, count = 1},--flor commum
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30318, count = 2},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30318, count = 3},
        },
    },
    [30330] = {text = {"The plant is regenerating."}}, -- violetas
    [26722] = {break_chance = 75, loot_chance = 80, lower_tier = 30330, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30319, count = 1}, --flor violeta
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30319, count = 2}, --flor violeta
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30319, count = 4}, --flor violeta
            [2] = {item_id = 30040, count = 5},-- fibras
        },
    },
    [30331] = {text = {"The plant is regenerating."}}, -- dente de leao
    [4154] = {break_chance = 75, loot_chance = 80, lower_tier = 30331, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 4152, count = 1}, --flor dente de leao
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 4152, count = 2}, --flor dente de leao
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 4152, count = 4}, --flor dente de leao
            [2] = {item_id = 30040, count = 5},-- fibras
        },
    },
    [30332] = {text = {"The plant is regenerating."}}, -- girassol
    [2752] = {break_chance = 75, loot_chance = 80, lower_tier = 30332, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 2753, count = 1}, --girassol
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 2753, count = 2}, --girassol
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 2753, count = 4}, --girassol
            [2] = {item_id = 30040, count = 5},-- fibras
        },
    },
    [30326] = {text = {"The plant is regenerating."}}, -- cogumelos
    [4183] = {break_chance = 75, loot_chance = 80, lower_tier = 30326, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 4182, count = 1}, --cogumelos
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 4182, count = 2}, --cogumelos
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 4182, count = 4}, --cogumelos
        },
    },
    [30333] = {text = {"The plant is regenerating."}}, -- calathea
    [2747] = {break_chance = 75, loot_chance = 80, lower_tier = 30333, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30320, count = 1}, --calathea
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30320, count = 2}, --calathea
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30320, count = 4}, --calathea
        },
    },
    [30334] = {text = {"The plant is regenerating."}}, -- camelias
    [4155] = {break_chance = 75, loot_chance = 80, lower_tier = 30334, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30321, count = 1}, --camelias
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30321, count = 2}, --camelias
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30321, count = 4}, --camelias
        },
    },
    [30335] = {text = {"The plant is regenerating."}}, -- tulipas
    [2743] = {break_chance = 75, loot_chance = 80, lower_tier = 30335, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30322, count = 1}, --tulipas
            [2] = {item_id = 30040, count = 5},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30322, count = 2}, --tulipas
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30322, count = 4}, --tulipas
        },
    },
    [26741] = {text = {"The plant is regenerating."}}, -- clemati
    [26717] = {break_chance = 75, loot_chance = 80, lower_tier = 26741, requiredSkill = 0, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30323, count = 1},--flor clemati
            [2] = {item_id = 30040, count = 15},-- fibras
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30323, count = 2},
            [2] = {item_id = 30040, count = 10},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30323, count = 3},
            [2] = {item_id = 30040, count = 15},
        },
    },
    [26742] = {text = {"The plant is regenerating."}}, --gentiane
    [26718] = {break_chance = 75, loot_chance = 80, lower_tier = 26742, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30324, count = 1},--flor gentiane
            [2] = {item_id = 30040, count = 10}, --fibra
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30324, count = 2},
            [2] = {item_id = 30040, count = 15}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30324, count = 3},
            [2] = {item_id = 30040, count = 15},
        },
    },
    [26743] = {text = {"The plant is regenerating."}}, -- scarlats
    [26719] = {break_chance = 75, loot_chance = 80, lower_tier = 26743, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26725, count = 4}, -- sementes de scarlats
            [2] = {item_id = 26726, count = 1}, -- flor scarlat
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26726, count = 5},
            [2] = {item_id = 26726, count = 1}, -- flor scarlat 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26726, count = 6},
            [2] = {item_id = 26726, count = 1}, -- flor scarlat
        },
    },
    [26744] = {text = {"The plant is regenerating."}}, -- gardenias
    [26720] = {break_chance = 75, loot_chance = 80, lower_tier = 26744, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 30325, count = 3}, -- flor gardenia
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 30325, count = 4}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 30325, count = 5},
        },
    },
    [26745] = {text = {"The mushroom is regenerating."}}, -- cogumelos brancos
    [26721] = {break_chance = 75, loot_chance = 80, lower_tier = 26745, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26723, count = 2}, -- cogumelos brancos
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26724, count = 3}, -- cogumelos brancos maduros
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26724, count = 5},-- cogumelos brancos maduros
        },
    },
    


}

local skillsStages = {
    {
        minlevel = 10,
        maxlevel = 20,
        multiplier = 30
    }, {
        minlevel = 21,
        maxlevel = 40,
        multiplier = 20
    }, {
        minlevel = 41,
        maxlevel = 60,
        multiplier = 15
    }, {
        minlevel = 61,
        maxlevel = 90,
        multiplier = 10
    }, {
        minlevel = 91,
        maxlevel = 120,
        multiplier = 8
    },{
        minlevel = 121,
        multiplier = 5
    }
}


function herbalistSystem.onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if not player then
        return true
    end
    
    local lastUsageTime = player:getStorageValue(215552) 

    if os.time() - lastUsageTime < COOLDOWN_SECONDS then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You must wait a few seconds before using the scissor's again.")
        return true
    end

    local object = config[itemEx.itemid]
    if object then
        if object.text then
            playSound(player, "herbalist_fail.ogg")
            local rand_text = math.random(#object.text)
            doCreatureSay(cid, object.text[rand_text], TALKTYPE_ORANGE_1, nil, nil, toPosition)
            SendMagicEffect(toPosition, 181)
            return true
        end
        
        local requiredSkill = object.requiredSkill or 0
        local playerSkill = player:getSkillLevel(SKILL_HERBALIST)

        if playerSkill < requiredSkill then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have the required herbalist skill to harvest on this plant.")
            return true
        end
        player:setNoMove(true)
            addEvent(function()
                player:setNoMove(false)
          end, 2300)
        local skillMultiplier = 1 

        for _, stage in ipairs(skillsStages) do
            if playerSkill >= stage.minlevel then
                if not stage.maxlevel or playerSkill <= stage.maxlevel then
                    skillMultiplier = stage.multiplier
                    break
                end
            end
        end
        toPosition.y = toPosition.y + 1
        toPosition.x = toPosition.x + 1

        SendMagicEffect(toPosition, 194)  
        SendMagicEffect(player:getPosition(), 176) 
        playSound(player, "herbalist.ogg")
        addEvent(function()
            local rand_event = math.random(200)
            if rand_event == 200 then
                SendMagicEffect(toPosition, 181)
                return true
            end

            local rand_break = math.random(100)
            if rand_break <= object.break_chance then
                doTransformItem(itemEx.uid, object.lower_tier)
                SendMagicEffect(toPosition, 181)
                local transformedItem = Item(itemEx.uid)
                transformedItem:decay()
            end

            local rand_reward = math.random(100)
            if rand_reward > (object.loot_chance + 10) then
                SendMagicEffect(toPosition, 181)
                return true
            end

            local multiple = 1
            local rand_multiple = math.random(15)
            if rand_multiple == 15 then
                multiple = math.random(2, 3)
            end
            for i = 1, multiple do
                local loot_table = object.normal_loot_table
                local rand_loot = math.random(100)
                if rand_loot < 6 then
                    loot_table = object.rare_loot_table
                elseif rand_loot < 21 then
                    loot_table = object.semi_rare_loot_table
                end
                local rand_item = math.random(#loot_table)
                rand_item = loot_table[rand_item]
                if rand_item.count == 1 then
                    doPlayerAddItem(cid, rand_item.item_id, 1, true)
                else
                    local new_count = math.random(rand_item.count)
                    doPlayerAddItem(cid, rand_item.item_id, new_count, true)
                end
            end
            local skillTries = math.floor(skillMultiplier)
            player:addSkillTries(SKILL_HERBALIST, skillTries)
        end, 3000)  
    else
        player:say("This scissor's cannot harvest this plant.", TALKTYPE_MONSTER_SAY)

    end
    player:setStorageValue(215552, os.time())
    return true
end

herbalistSystem:id(26716)
herbalistSystem:register()