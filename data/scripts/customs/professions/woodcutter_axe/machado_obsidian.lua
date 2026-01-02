local woodcutterSystem = Action()
local COOLDOWN_SECONDS = 4

local config = {
    [30039] = {text = {"Arvore seca esta em Regeneração"}}, 
    [2710] = {break_chance = 75, loot_chance = 80, lower_tier = 30039, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26599, count = 5}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26599, count = 6}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26599, count = 7},
        },
    },
    [29863] = {text = {"Arvore comum esta em Regeneração"}}, 
    [2705] = {break_chance = 75, loot_chance = 80, lower_tier = 29863, requiredSkill = 1, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26593, count = 5},--tronco de arvore
            [2] = {item_id = 29877, count = 15},--folhas
            [3] = {item_id = 2770, count = 4},--galho
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26593, count = 6},
            [2] = {item_id = 29877, count = 20},
            [3] = {item_id = 2770, count = 3},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26593, count = 7},
            [2] = {item_id = 29877, count = 25},
            [3] = {item_id = 2770, count = 5},
        },
    },
    [29865] = {text = {"Acacia Tree esta em Regeneração"}}, 
    [2703] = {break_chance = 75, loot_chance = 80, lower_tier = 29865, requiredSkill = 10, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26594, count = 4},
            [2] = {item_id = 29877, count = 15}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26594, count = 5},
            [2] = {item_id = 29877, count = 20}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26594, count = 6},
            [2] = {item_id = 29877, count = 25},
        },
    },
    [29864] = {text = {"Cinereia Tree esta em Regeneração"}}, 
    [8313] = {break_chance = 75, loot_chance = 80, lower_tier = 29864, requiredSkill = 20, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26595, count = 3}, 
            [2] = {item_id = 29877, count = 10},
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26595, count = 4}, 
            [2] = {item_id = 29877, count = 12},
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26595, count = 5},
            [2] = {item_id = 29877, count = 15},
        },
    },
    [29866] = {text = {"Claraurea esta em Regeneração"}}, 
    [2706] = {break_chance = 75, loot_chance = 80, lower_tier = 29866, requiredSkill = 28, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26596, count = 2},
            [2] = {item_id = 29871, count = 15},-- folhas secas
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26596, count = 3},
            [2] = {item_id = 29871, count = 15},-- folhas secas
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26596, count = 4},
            [2] = {item_id = 29871, count = 15},-- folhas secas
        },
    },
    [29867] = {text = {"Cerejeira esta em Regeneração"}}, 
    [2704] = {break_chance = 75, loot_chance = 80, lower_tier = 29867, requiredSkill = 39, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26597, count = 3}, 
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26597, count = 4}, 
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26597, count = 5},
        },
    },
    [26604] = {text = {"Olivera esta em Regeneração"}}, 
    [26606] = {break_chance = 75, loot_chance = 80, lower_tier = 26604, requiredSkill = 58, 
        normal_loot_table = { -- 80%
            [1] = {item_id = 26598, count = 1},
            [2] = {item_id = 29877, count = 15},--folhas
        },
        semi_rare_loot_table = { -- 15%
            [1] = {item_id = 26598, count = 2},
            [2] = {item_id = 29877, count = 25},--folhas
        },
        rare_loot_table = { -- 5%
            [1] = {item_id = 26598, count = 3},
            [2] = {item_id = 29877, count = 20},--folhas
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


function woodcutterSystem.onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid)
    if not player then
        return true
    end
    
    local lastUsageTime = player:getStorageValue(215563) 

    if os.time() - lastUsageTime < COOLDOWN_SECONDS then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You must wait a few seconds before using the axe again.")
        return true
    end

    local object = config[itemEx.itemid]
    if object then
        if object.text then
            playSound(player, "woodcutting_fail.ogg")
            local rand_text = math.random(#object.text)
            doCreatureSay(cid, object.text[rand_text], TALKTYPE_ORANGE_1, nil, nil, toPosition)
            SendMagicEffect(toPosition, 181)
            return true
        end
        
        local requiredSkill = object.requiredSkill or 0
        local playerSkill = player:getSkillLevel(SKILL_WOODCUTTING)

        if playerSkill < requiredSkill then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Você não tem skill suficiente para coletar este recurso!")
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
        SendMagicEffect(toPosition, 180)  
        SendMagicEffect(player:getPosition(), 176) 
        playSound(player, "woodcutting.ogg")
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
            player:addSkillTries(SKILL_WOODCUTTING, skillTries)
        end, 3000)  
    else
        player:say("This axe cannot cut on this tree.", TALKTYPE_MONSTER_SAY)


    end
    player:setStorageValue(215563, os.time())
    return true
end

woodcutterSystem:id(26592)
woodcutterSystem:register()