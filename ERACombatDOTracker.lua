-- TODO
-- debug éventuel

ERACombatDOTracker = {}
ERACombatDOTracker.__index = ERACombatDOTracker
setmetatable(ERACombatDOTracker, {__index = ERACombatModuleNestedInTimers})

function ERACombatDOTracker:AddDOT(
    auraID,
    iconID,
    r,
    g,
    b,
    castTime,
    damageFunction_instant_totalOverTime_duration,
    talent,
    limitedInstances,
    rNotOnCurrentTarget,
    gNotOnCurrentTarget,
    bNotOnCurrentTarget)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(auraID)
    end
    local d =
        ERACombatDOTDefinition:create(
        self,
        1 + #self.allDOTs,
        auraID,
        iconID,
        r,
        g,
        b,
        castTime,
        damageFunction_instant_totalOverTime_duration,
        talent,
        limitedInstances,
        rNotOnCurrentTarget,
        gNotOnCurrentTarget,
        bNotOnCurrentTarget
    )
    table.insert(self.allDOTs, d)
    return d
end

function ERACombatDOTracker:Create(timers, enemiesTracker, spec, fillerDamageFunction)
    local dt = {}
    setmetatable(dt, ERACombatDOTracker)
    dt.frame = CreateFrame("Frame", nil, timers.frame, nil)
    dt:constructNested(timers, 0, 0, "BOTTOM", true, spec)
    dt.frame:SetSize(2048, 512)

    dt.timers = timers
    if (enemiesTracker) then
        dt.enemiesTracker = enemiesTracker
    else
        dt.enemiesTracker = ERACombatEnemiesTracker:Create(timers.cFrame, -1, spec)
        dt.updateEnemiesTracker = true
    end
    dt.enemiesTracker:OnEnemyAdded(
        function(tar, t)
            for name, value in pairs(ERACombatDOTarget) do
                tar[name] = value
            end
            tar:initAsDOTarget(dt)
        end
    )
    --[[
    dt.enemiesTracker:OnEnemyRemoved(
        function(tar, t)
        end
    )
    ]]
    dt.fillerDamageFunction = fillerDamageFunction
    dt.allDOTs = {}
    dt.activeDOTsByID = {}
    dt.targetDOTs = {}

    return dt
end

function ERACombatDOTracker:CheckTalents()
    self.activeDOTsByID = {}
    self.targetDOTs = {}
    for i, d in ipairs(self.allDOTs) do
        if (d:checkTalents()) then
            self.activeDOTsByID[d.auraID] = d
            table.insert(self.targetDOTs, d)
        end
    end
end

function ERACombatDOTracker:CLEU(t)
    local _, evt, _, sourceGUY, _, _, _, targetGUY, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if (evt == "SPELL_AURA_APPLIED" or evt == "SPELL_AURA_REFRESH" and sourceGUY == self.enemiesTracker.playerGUID) then
        local def = self.activeDOTsByID[spellID]
        if (def ~= nil) then
            local enemy = self.enemiesTracker:analyzeTargetSourceIsPlayer(t, targetGUY)
            if (enemy and def.applied) then
                local i = enemy:GetDOTInstance(def)
                def.applied(enemy, i, evt == "SPELL_AURA_REFRESH")
            end
        end
    end
end

function ERACombatDOTracker:updateAsNested_returnHeightForTimerOverlay(t)
    if (self.updateEnemiesTracker) then
        self.enemiesTracker:updateEnemiesTracker(t)
    end

    for _, d in pairs(self.activeDOTsByID) do
        d:prepareUpdate()
    end
    for _, v in pairs(self.enemiesTracker.enemiesByNameplate) do
        v:updateDOT(t)
    end

    local currentTarget = self.enemiesTracker.currentTarget
    if (currentTarget) then
        for k, v in pairs(self.activeDOTsByID) do
            local i = currentTarget.dots[v.index]
            v.remDurationOnCurrentTarget = i.remDuration
            v.totDurationOnCurrentTarget = i.totDuration
            v.stacksOnCurrentTarget = i.stacks
            v.currentTargetInfo = currentTarget
        end
    else
        for i = 1, 40 do
            local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitDebuff("target", i, "PLAYER")
            if (spellID) then
                local def = self.activeDOTsByID[spellID]
                if (def ~= nil) then
                    local auraRemDuration
                    if (expirationTime and expirationTime > 0) then
                        auraRemDuration = expirationTime - t
                    else
                        auraRemDuration = 4096
                    end
                    if (not (stacks and stacks > 0)) then
                        stacks = 1
                    end
                    def:auraFoundParsingCurrentTarget(auraRemDuration, durAura, stacks)
                end
            else
                break
            end
        end
        for k, v in pairs(self.activeDOTsByID) do
            v:updateParsingCurrentTarget()
        end
    end

    local fillerDamage = self.fillerDamageFunction(self)
    table.sort(self.targetDOTs, ERACombatDOTDefinition_compare)
    local y = 0
    local hasteMod = 1 / (1 + GetHaste() / 100)
    for i, d in ipairs(self.targetDOTs) do
        y = d:draw(y, fillerDamage, hasteMod) + ERACombat_TimerBarSpacing
    end
    return y
end

--------------------------------------------------------------------------------------------------------------------------------
-- DOT TARGET -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatDOTarget = {}

function ERACombatDOTarget:initAsDOTarget(dotracker)
    self.dotracker = dotracker
    self.dots = {}
    for i, d in ipairs(dotracker.allDOTs) do
        table.insert(self.dots, ERACombatDOTInstance:create(self, d))
    end
end

function ERACombatDOTarget:GetDOTInstance(dotDef)
    return self.dots[dotDef.index]
end

function ERACombatDOTarget:updateDOT(t)
    for i = 1, 40 do
        local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitDebuff(self.plateID, i, "PLAYER")
        if (spellID) then
            local def = self.dotracker.activeDOTsByID[spellID]
            if (def ~= nil) then
                local auraRemDuration
                if (expirationTime and expirationTime > 0) then
                    auraRemDuration = expirationTime - t
                else
                    auraRemDuration = 4096
                end
                if (not (stacks and stacks > 0)) then
                    stacks = 1
                end
                self.dots[def.index]:auraFound(auraRemDuration, durAura, stacks)
            end
        else
            break
        end
    end
    for i, d in ipairs(self.dots) do
        d:update()
    end
end

--------------------------------------------------------------------------------------------------------------------------------
-- DOT DEFINITION --------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatDOTDefinition = {}
ERACombatDOTDefinition.__index = ERACombatDOTDefinition

function ERACombatDOTDefinition:create(
    tracker,
    index,
    auraID,
    iconID,
    r,
    g,
    b,
    castTime,
    durationFunction,
    damageFunction,
    talent,
    limitedInstances,
    rNotOnCurrentTarget,
    gNotOnCurrentTarget,
    bNotOnCurrentTarget)
    local def = {}
    setmetatable(def, ERACombatDOTDefinition)
    def.tracker = tracker
    def.index = index
    def.auraID = auraID
    def.iconID = iconID
    def.castTime = castTime
    def.durationFunction = durationFunction
    def.damageFunction = damageFunction
    def.talent = talent
    def.instances = {}
    def.barOnCurrentTarget = ERACombatTimersBar:create(tracker.frame, "BOTTOM", iconID, r, g, b, "Interface\\Buttons\\WHITE8x8")
    def.limitedInstances = limitedInstances
    def.r = r
    def.g = g
    def.b = b
    def.rNotOnCurrentTarget = rNotOnCurrentTarget or r
    def.gNotOnCurrentTarget = gNotOnCurrentTarget or g
    def.bNotOnCurrentTarget = bNotOnCurrentTarget or b
    return def
end

function ERACombatDOTDefinition_compare(d1, d2)
    if (d1.willBeWorthRefreshing) then
        if (not d2.willBeWorthRefreshing) then
            return true
        end
    else
        if (d2.willBeWorthRefreshing) then
            return false
        end
    end
    if (d1.remDurationOnCurrentTarget < d2.remDurationOnCurrentTarget) then
        return true
    elseif (d1.remDurationOnCurrentTarget > d2.remDurationOnCurrentTarget) then
        return false
    else
        return d1.index < d2.index
    end
end

function ERACombatDOTDefinition:checkTalents()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.talentActive = false
        self.barOnCurrentTarget:hide()
        self.remDurationOnCurrentTarget = 0
        self.totDurationOnCurrentTarget = 1
        self.stacksOnCurrentTarget = 0
        for i, ins in ipairs(self.instances) do
            ins.remDuration = 0
            ins.totDuration = 1
            ins.stacks = 0
        end
        self.instances = {}
        return false
    else
        self.talentActive = true
        return true
    end
end

function ERACombatDOTDefinition:prepareUpdate()
    self.instances = {}
end

function ERACombatDOTDefinition:auraFoundParsingCurrentTarget(auraRemDuration, durAura, stacks)
    self.found = true
    self.remDurationOnCurrentTarget = auraRemDuration
    self.totDurationOnCurrentTarget = durAura
    self.stacksOnCurrentTarget = stacks
end
function ERACombatDOTDefinition:updateParsingCurrentTarget()
    self.currentTargetInfo = nil
    if (self.found) then
        self.found = false
    else
        self.remDurationOnCurrentTarget = 0
        self.totDurationOnCurrentTarget = 1
        self.stacksOnCurrentTarget = 0
    end
end

--[[
function ERACombatDOTDefinition:init_debug_message()
    local t = GetTime()
    if (self.lastDebugPrint and self.lastDebugPrint + 1 > t) then
        self.do_debug_message = false
    else
        self.lastDebugPrint = t
        self.do_debug_message = true
        if (self.debugCount) then
            self.debugCount = self.debugCount + 1
        else
            self.debugCount = 0
        end
    end
end
function ERACombatDOTDefinition:debug_message(...)
    if (self.auraID == 146739 and self.do_debug_message) then
        print(self.debugCount, ...)
    end
end
]]
function ERACombatDOTDefinition:getDOTDamageOnTarget(tar, instant, dps, duration, lifeExpectancy, offset)
    local dotRemainingDuration = math.max(0, tar:GetDOTInstance(self).remDuration - offset)
    return instant + dps * math.min(lifeExpectancy, math.min(duration * 1.3 - dotRemainingDuration, duration))
end
function ERACombatDOTDefinition:computeDamageDOT(offset, fillerDamage, duration)
    if (self.overrideFillerDamage) then
        fillerDamage = self.overrideFillerDamage()
    end
    local lifeExpectancy = self.currentTargetInfo.lifeExpectancy - offset
    if (lifeExpectancy > 0) then
        local instantDamage, overTimeDamage, spreadsToNearbyTargets, instantDealtToNearbyTargets = self.damageFunction(self, self.currentTargetInfo)
        local dps = overTimeDamage / duration
        local secondaryEnemiesCount = self.tracker.enemiesTracker:GetEnemiesCount() - 1
        local dmg = self:getDOTDamageOnTarget(self.currentTargetInfo, instantDamage, dps, duration, lifeExpectancy, offset)
        if (secondaryEnemiesCount > 0 and spreadsToNearbyTargets ~= nil and spreadsToNearbyTargets ~= 0) then
            local spreadDamage = 0
            secondaryEnemiesCount = 0
            local instantSpread
            if (instantDealtToNearbyTargets) then
                instantSpread = instantDamage
            else
                instantSpread = 0
            end
            for _, tar in pairs(self.tracker.enemiesTracker.enemiesByNameplate) do
                if (tar ~= self.currentTargetInfo) then
                    lifeExpectancy = tar.lifeExpectancy - offset
                    if (lifeExpectancy > 0) then
                        secondaryEnemiesCount = secondaryEnemiesCount + 1
                        spreadDamage = spreadDamage + self:getDOTDamageOnTarget(tar, instantSpread, dps, duration, lifeExpectancy, offset)
                    end
                end
            end
            if (secondaryEnemiesCount > 0) then
                if (spreadsToNearbyTargets > 0) then
                    dmg = dmg + math.min(spreadsToNearbyTargets, secondaryEnemiesCount) * spreadDamage / secondaryEnemiesCount
                else
                    dmg = dmg + spreadDamage
                end
            end
        end
        return dmg, fillerDamage
    else
        return 0, fillerDamage
    end
end
function ERACombatDOTDefinition:draw(y, fillerDamage, hasteMod)
    --self:init_debug_message()
    local drawn_on_unknown_target = false
    local duration = self.durationFunction(self, hasteMod)
    local castTime = self.castTime * hasteMod
    local pandemic = 0.3 * duration
    local inPandemicWindow
    if (self.limitedInstances) then
        self.willBeWorthRefreshing = true
        local minPositiveDur = 0
        local minTar = nil
        for _, i in ipairs(self.instances) do
            if (i.remDuration > 0 and (minPositiveDur <= 0 or i.remDuration < minPositiveDur)) then
                minPositiveDur = i.remDuration
                minTar = i.target
            end
        end
        inPandemicWindow = minPositiveDur <= pandemic + castTime
        if (minTar) then
            if (minTar == self.currentTargetInfo) then
                self.barOnCurrentTarget:SetColor(self.r, self.g, self.b)
                if (inPandemicWindow) then
                    local dmg
                    dmg, fillerDamage = self:computeDamageDOT(castTime, fillerDamage, duration)
                    self.isWorthRefresing = fillerDamage < dmg
                else
                    self.isWorthRefresing = false
                end
            else
                self.barOnCurrentTarget:SetColor(self.rNotOnCurrentTarget, self.gNotOnCurrentTarget, self.bNotOnCurrentTarget)
                self.isWorthRefresing = false
                drawn_on_unknown_target = not self.currentTargetInfo
            end
        else
            self.barOnCurrentTarget:SetColor(self.rNotOnCurrentTarget, self.gNotOnCurrentTarget, self.bNotOnCurrentTarget)
            minPositiveDur = self.remDurationOnCurrentTarget
            self.isWorthRefresing = inPandemicWindow
            drawn_on_unknown_target = true
        end
        y = y + self.barOnCurrentTarget:draw(y, minPositiveDur, self.tracker.timers.timerStandardDuration)
    else
        y = y + self.barOnCurrentTarget:draw(y, self.remDurationOnCurrentTarget, self.tracker.timers.timerStandardDuration)
        local pandemicPlustCast = pandemic + castTime
        inPandemicWindow = self.remDurationOnCurrentTarget <= pandemicPlustCast
        if (self.currentTargetInfo) then
            if (inPandemicWindow) then
                offset = castTime
            else
                offset = self.remDurationOnCurrentTarget - pandemicPlustCast
            end
            local dmg
            dmg, fillerDamage = self:computeDamageDOT(offset, fillerDamage, duration)
            if (dmg > fillerDamage) then
                self.isWorthRefresing = inPandemicWindow
                self.willBeWorthRefreshing = true
            else
                self.isWorthRefresing = false
                self.willBeWorthRefreshing = false
            end
        else
            self.isWorthRefresing = inPandemicWindow
            self.willBeWorthRefreshing = true
            drawn_on_unknown_target = true
        end
    end
    self.inPandemicWindow = inPandemicWindow
    if (inPandemicWindow) then
        self.barOnCurrentTarget:SetIconVisibility(true)
        self.barOnCurrentTarget:SetIconAlpha(1)
        self.barOnCurrentTarget:SetIconDesaturated(not self.isWorthRefresing)
    else
        if (self.willBeWorthRefreshing) then
            self.barOnCurrentTarget:SetIconVisibility(true)
            self.barOnCurrentTarget:SetIconDesaturated(false)
            self.barOnCurrentTarget:SetIconAlpha(0.2)
        else
            self.barOnCurrentTarget:SetIconVisibility(false)
        end
    end
    if (drawn_on_unknown_target) then
        self:DrawnUnknownTarget()
    end
    return y
end
function ERACombatDOTDefinition:DrawnUnknownTarget()
end

--------------------------------------------------------------------------------------------------------------------------------
-- DOT INSTANCE ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatDOTInstance = {}
ERACombatDOTInstance.__index = ERACombatDOTInstance

function ERACombatDOTInstance:create(target, def)
    local ins = {}
    setmetatable(ins, ERACombatDOTInstance)
    ins.target = target
    ins.def = def
    ins.remDuration = 0
    ins.totDuration = 1
    ins.stacks = 0
    return ins
end

function ERACombatDOTInstance:auraFound(auraRemDuration, durAura, stacks)
    self.found = true
    self.remDuration = auraRemDuration
    self.totDuration = durAura
    self.stacks = stacks
end

function ERACombatDOTInstance:update()
    if (self.found) then
        self.found = false
        table.insert(self.def.instances, self)
    else
        self.remDuration = 0
        self.totDuration = 1
        self.stacks = 0
    end
end
