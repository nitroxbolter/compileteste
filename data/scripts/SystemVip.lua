local vipConfig = {
    storageKey = 30017,          -- Storage global que guarda até quando o player é VIP (em timestamp UNIX).
    vipBenefitsKey = 30000,      -- Storage que guarda se o player já tem os benefícios aplicados.
    outfits = {963, 965, 967},   -- Lista de outfits exclusivos de VIP.
    mounts = {168, 169, 170},    -- Lista de mounts exclusivas de VIP.
    townId = 1,                  -- Cidade para onde o player volta quando perde o VIP.
    vipPrice = 1000000,          -- Preço em gold coins para comprar 30 dias de VIP.
    vipDays = 30,                -- Quantos dias de VIP serão comprados.

    messages = {
        expired = "Seu VIP expirou. Considere adquirir mais dias de VIP.",
        remaining = "Você possui atualmente %d dias de VIP restantes, que expiram em %s.",
        newPlayer = "Melhore sua experiência adquirindo dias de VIP e desbloqueie benefícios exclusivos.",
        buySuccess = "Você comprou %d dias de conta VIP!",
        buyFailure = "Você não tem dinheiro suficiente, %d dias de VIP custam %d moedas de ouro.",
        alreadyVIP = "Você não pode comprar mais de %d dias de conta VIP.",
        checkVIP = "Você possui %d dias de conta VIP."
    }
    
}

function Player.isVIP(self)
    local currentExpiration = self:getAccountStorageValue(vipConfig.storageKey)
    local currentTime = os.time()

    if currentExpiration and currentExpiration > currentTime then
        return true
    else
        return false
    end
end

function Player.addVIP(self, days)
    local currentExpiration = self:getAccountStorageValue(vipConfig.storageKey)
    local currentTime = os.time()

    if currentExpiration <= currentTime then
        currentExpiration = currentTime
    end

    local newExpiration = currentExpiration + (days * 24 * 60 * 60)
    self:setAccountStorageValue(vipConfig.storageKey, newExpiration)
end

function Player.removeVIP(self, days)
    local currentExpiration = self:getAccountStorageValue(vipConfig.storageKey)
    local currentTime = os.time()

    if currentExpiration > currentTime then
        local remainingSeconds = currentExpiration - currentTime
        local remainingDays = math.floor(remainingSeconds / (24 * 60 * 60))
        local newExpiration = currentExpiration - (days * 24 * 60 * 60)

        if newExpiration < currentTime then
            newExpiration = currentTime
        end

        self:setAccountStorageValue(vipConfig.storageKey, newExpiration)
    end
end

function Player.getVIPDays(self)
    local currentExpiration = self:getAccountStorageValue(vipConfig.storageKey)
    local currentTime = os.time()

    if currentExpiration > currentTime then
        local remainingSeconds = currentExpiration - currentTime
        local remainingDays = math.floor(remainingSeconds / (24 * 60 * 60))
        return remainingDays
    end

    return 0
end

function Player.getVIPExpirationDate(self)
    local expirationTime = self:getAccountStorageValue(vipConfig.storageKey)

    if expirationTime > os.time() then
        local remainingSeconds = expirationTime - os.time()
        local remainingDays = math.floor(remainingSeconds / (24 * 60 * 60))
        local expirationDateTime = os.date("%m/%d/%y at %H:%M", expirationTime)
        return remainingDays, expirationDateTime
    end

    return 0, "N/A"
end

function Player.addVIPBenefits(self)
    for i, outfitId in ipairs(vipConfig.outfits) do
        if not self:hasOutfit(outfitId) then
            self:addOutfit(outfitId)
        end
    end

    for i, mountId in ipairs(vipConfig.mounts) do
        if not self:hasMount(mountId) then
            self:addMount(mountId)
        end
    end
end

function Player.removeVIPBenefits(self)
    local outfitsToDelete = vipConfig.outfits
    for i = 1, #outfitsToDelete do
        self:removeOutfit(outfitsToDelete[i])
    end

    local mountsToDelete = vipConfig.mounts
    for i = 1, #mountsToDelete do
        self:removeMount(mountsToDelete[i])
    end

    self:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    self:setTown(vipConfig.townId)
    self:teleportTo(self:getTown():getTemplePosition())
    self:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
end

function Player.getVIPBenefits(self)
    return self:getStorageValue(vipBenefitsKey) == 1
end

function Player.setVIPBenefits(self, enabled)
    if enabled then
        if not self:getVIPBenefits() then
            self:addVIPBenefits()
            self:setStorageValue(vipBenefitsKey, 1)
        end
    else
        if self:getVIPBenefits() then
            self:removeVIPBenefits()
            self:setStorageValue(vipBenefitsKey, -1)
        end
    end
end

function Player.sendVIPStatus(self)
    local daysRemaining, expirationDateTime = self:getVIPExpirationDate()

    if daysRemaining > 0 then
        self:sendTextMessage(MESSAGE_INFO_DESCR, string.format(vipConfig.messages.remaining, daysRemaining, expirationDateTime))
        self:setVIPBenefits(true)
    elseif daysRemaining == 0 then
        self:sendTextMessage(MESSAGE_STATUS_WARNING, vipConfig.messages.expired)
        self:setVIPBenefits(false)
    else
        self:sendTextMessage(MESSAGE_INFO_DESCR, vipConfig.messages.newPlayer)
    end
end

local buyVipDays = TalkAction("!buyvip")

function buyVipDays.onSay(player, words, param)
    local daysRemaining = player:getVIPExpirationDate()
    if player:isVIP() then
        player:sendCancelMessage(string.format(vipConfig.messages.alreadyVIP, daysRemaining))
        return false
    end

    local vipPrice = vipConfig.vipPrice
    local vipDays = vipConfig.vipDays
    if player:removeTotalMoney(vipPrice) then
        player:addVIP(vipDays)
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format(vipConfig.messages.buySuccess, vipDays))
    else
        player:sendCancelMessage(string.format(vipConfig.messages.buyFailure, vipDays, vipPrice))
    end

    return false
end

buyVipDays:register()

local checkVipDays = TalkAction("!vip")

function checkVipDays.onSay(player, words, param)
    local daysRemaining = player:getVIPExpirationDate()
    if player:isVIP() then
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format(vipConfig.messages.checkVIP, daysRemaining))
    else
        player:sendTextMessage(MESSAGE_INFO_DESCR, vipConfig.messages.newPlayer)
    end

    return false
end

checkVipDays:register()