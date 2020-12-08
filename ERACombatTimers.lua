-- TODO
-- revoir l'affichage de la barre de cast
-- barres plus fines ?

if (ERACombatTimersGroup) then
    return
end

----------------
-- constantes --
----------------

-- barres
ERACombat_TimerWidth = 400
ERACombat_TimerBarSpacing = 4
ERACombat_TimerBarDefaultSize = 22
ERACombat_TimerGCDCount = 5
-- icones
ERACombat_TimerIconCooldownSize = 22
ERACombat_TimerIconSize = 44
--36
ERACombat_TimerIconSpacing = 8

ERACombatTimersGroup = {}
ERACombatTimersGroup.__index = ERACombatTimersGroup
setmetatable(ERACombatTimersGroup, {__index = ERACombatModule})

--------------------------------------------------------------------------------------------------------------------------------
---- NESTED --------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatModuleNestedInTimers = {}
ERACombatModuleNestedInTimers.__index = ERACombatModuleNestedInTimers
setmetatable(ERACombatModuleNestedInTimers, {__index = ERACombatModule})

function ERACombatModuleNestedInTimers:constructNested(timers, offsetX, offsetY, anchor, requiresCLEU, ...)
    self:construct(timers.cFrame, -1, -1, requiresCLEU, ...)
    self.timers = timers
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.anchor = anchor
    self.frame:SetFrameLevel(0)
    timers.nestedModule = self
end

-- abstract function ERACombatModuleNestedInTimers:updateAsNested_returnHeightForTimerOverlay(t)

--------------------------------------------------------------------------------------------------------------------------------
---- UTILISATION ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

function ERACombatTimersGroup:AddTrackedBuff(spellID, talent)
    local b = ERACombatAura:create(self, spellID, false, talent)
    self.trackedBuffs[spellID] = b
    return b
end
function ERACombatTimersGroup:AddTrackedDebuff(spellID, talent)
    local b = ERACombatAura:create(self, spellID, true, talent)
    self.trackedDebuffs[spellID] = b
    return b
end
function ERACombatTimersGroup:AddTrackedDebuffOnPlayer(spellID, talent)
    local b = ERACombatAura:create(self, spellID, true, talent)
    self.hasTrackedDebuffsOnPlayer = true
    self.trackedDebuffsOnPlayer[spellID] = b
    return b
end
function ERACombatTimersGroup:AddTrackedCooldown(spellID, talent)
    return ERACombatCooldown:create(self, spellID, talent)
end

function ERACombatTimersGroup:AddAuraBar(aura, iconID, r, g, b, talent)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(aura.spellID)
    end
    return ERACombatTimerAuraBar:create(aura, iconID, r, g, b, talent)
end
function ERACombatTimersGroup:AddTotemBar(totemID, iconID, r, g, b, talent)
    return ERACombatTimerTotemBar:create(self, totemID, iconID, r, g, b, talent)
end
function ERACombatTimersGroup:AddCooldownIcon(cd, iconID, x, y, showOnTimer, availableIfLessThanGCD, talent)
    return ERACombatCooldownIcon:create(cd, x, y, iconID, showOnTimer, availableIfLessThanGCD, talent)
end
function ERACombatTimersGroup:AddAuraIcon(aura, x, y, iconID, talent)
    return ERACombatAuraIcon:create(aura, x, y, iconID, talent)
end

function ERACombatTimersGroup:AddCovenantClassCooldown(x, y, kyrian, venthyr, nightfae, necrolords)
    self:AddCooldownIcon(self:AddTrackedCooldown(kyrian, ERALIBTalent_Kyrian), nil, x, y, true, true, nil)
    self:AddCooldownIcon(self:AddTrackedCooldown(venthyr, ERALIBTalent_Venthyr), nil, x, y, true, true, nil)
    self:AddCooldownIcon(self:AddTrackedCooldown(nightfae, ERALIBTalent_Nightfae), nil, x, y, true, true, nil)
    self:AddCooldownIcon(self:AddTrackedCooldown(necrolords, ERALIBTalent_Necrolords), nil, x, y, true, true, nil)
end

function ERACombatTimersGroup:AddMissingAura(aura, iconID, x, y, beam, talent)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(aura.spellID)
    end
    return ERACombatTimersMissingAura:create(aura, iconID, x, y, beam, talent)
end

function ERACombatTimersGroup:AddProc(aura, iconID, x, y, beam, talent)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(aura.spellID)
    end
    return ERACombatTimersProc:create(aura, iconID, x, y, beam, talent)
end

function ERACombatTimersGroup:AddChannelInfo(spellID, tick)
    self.channelInfo[spellID] = tick
end

function ERACombatTimersGroup:AddOffensiveDispellIcon(iconID, x, y, beam, talent, ...)
    return ERACombatTimersTargetDispellableIcon:create(self, iconID, x, y, beam, talent, ...)
end

function ERACombatTimersGroup:AddKick(spellID, x, y, talent, displayOnlyIfSpellPetKnown)
    local timer = self:AddTrackedCooldown(spellID, talent)
    local display = self:AddCooldownIcon(timer, nil, x, y, true, false)
    display.displayOnlyIfSpellPetKnown = displayOnlyIfSpellPetKnown
    function display:OverrideTimerVisibility()
        if (self.group.targetCast > 0.1 + timer.remDuration) then
            self.icon:SetAlpha(1.0)
            return true
        else
            if (timer.remDuration > 0) then
                self.icon:SetAlpha(0.4)
            else
                self.icon:SetAlpha(0.08)
            end
            return false
        end
    end
    table.insert(self.kicks, display)
end
function ERACombatTimersGroup:AddOffensiveDispellCooldown(spellID, x, y, talent, ...)
    self.watchTargetDispellable = true
    local timer = self:AddTrackedCooldown(spellID)
    local display = self:AddCooldownIcon(timer, nil, x, y, false, false, talent)
    display.types = {}
    for i, t in ipairs {...} do
        table.insert(display.types, t)
    end
    local selfThis = self
    function display:OverrideTimerVisibility()
        --[[
        local dispellable = false
        for i, t in ipairs(display.types) do
            if (t == "Magic") then
                if (selfThis.targetDispellableMagic) then
                    dispellable = true
                    break
                end
            elseif (t == "Rage") then
                if (selfThis.targetDispellableRage) then
                    dispellable = true
                    break
                end
            end
        end
        if (dispellable) then
            ]]
        if (selfThis.targetDispellable) then
            display.icon:SetAlpha(1.0)
            if (timer.remDuration <= 0) then
                display.icon:Beam()
            else
                display.icon:StopBeam()
            end
        else
            display.icon:SetAlpha(0.1)
            display.icon:StopBeam()
        end
        return false
    end
    return display
end

--------------------------------------------------------------------------------------------------------------------------------
---- TIMERS GROUP --------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

function ERACombatTimersGroup:Create(cFrame, x, y, baseGCD, ...)
    local group = {}
    setmetatable(group, ERACombatTimersGroup)

    -- affichage
    group.frame = CreateFrame("Frame", nil, UIParent, "ERACombatTimersFrame")
    group.frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    group.timerHeight = 0
    group.barsHeight = 0

    -- dispell offensif
    group.watchTargetDispellable = false
    group.targetDispellable = false
    group.targetDispellableMagic = false
    group.targetDispellableRage = false

    -- kick
    group.kicks = {}
    group.targetCast = 0

    -- mécanique
    group.minGCD = 1
    group.baseGCD = baseGCD
    group.channelInfo = {}
    group.channelTicks = {}
    group.channelTickCount = 0

    -- contenu
    group.timers = {}
    group.activeTimers = {}
    group.bars = {}
    group.activeBars = {}
    group.icons = {}
    group.activeIcons = {}
    group.hints = {}
    group.activeHints = {}
    group.trackedBuffs = {}
    group.trackedDebuffs = {}
    group.trackedDebuffsOnPlayer = {}

    -- cast bar
    group.castBackground = group.frame:CreateTexture(nil, "BACKGROUND")
    group.castBackground:SetPoint("BOTTOMRIGHT", group.frame, "CENTER", 0, -ERACombat_TimerIconCooldownSize)
    group.castBackground:SetColorTexture(0.0, 0.0, 0.0, 0.66)
    group.castBar = group.frame:CreateTexture(nil, "BORDER")
    group.castBar:SetPoint("BOTTOMRIGHT", group.frame, "CENTER", 0, -ERACombat_TimerIconCooldownSize)
    --group.castBar:SetColorTexture(0.2, 0.6, 0.7, 0.55)
    group.castBar:SetColorTexture(0.2, 0.8, 0.6, 0.66)

    -- perte de contrôle
    group.loc = {}
    group.events = {}
    --[[
    local loc_root = ERACombatTimerLOCBar:create(group, "ROOT", "ROOT", 136113, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
    group.loc["ROOT"] = loc_root
    local loc_stun_mech = ERACombatTimerLOCBar:create(group, "STUN_MECHANIC", "STUN", 132308, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
    group.loc["STUN_MECHANIC"] = loc_stun_mech
    local loc_stun = ERACombatTimerLOCBar:create(group, "STUN", "STUN", 132308, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
    group.loc["STUN"] = loc_stun
    local loc_confuse = ERACombatTimerLOCBar:create(group, "CONFUSE", "CONFUSE", 135899, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
    group.loc["CONFUSE"] = loc_confuse
    local loc_fear = ERACombatTimerLOCBar:create(group, "FEAR_MECHANIC", "FEAR", 135899, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
    group.loc["FEAR_MECHANIC"] = loc_fear
    ]]
    -- évènements
    --[[
    function group.events:LOSS_OF_CONTROL_ADDED(locIndex)
        local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(locIndex)
        local loc = group.loc[locType]
        -- STUN_MECHANIC, ROOT, CONFUSE, FEAR_MECHANIC, STUN, à compléter
        if (not loc) then
            loc = ERACombatTimerLOCBar:create(group, locType, text, iconTexture, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
            table.insert(group.bars, loc)
            table.insert(group.activeBars, loc)
            group.loc[locType] = loc
        end
        loc:updateLOC(locIndex, timeRemaining, duration)
    end
    function group.events:LOSS_OF_CONTROL_UPDATE()
        -- hum, on ne fait rien car on recalcule toujours dans ERACombatTimerLOCBar:GetRemDurationOr0IfInvisible
    end
    group.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            group.events[event](self, ...)
        end
    )
    for k, v in pairs(group.loc) do
        table.insert(group.bars, v)
        table.insert(group.activeBars, v)
    end
    ]]
    group:construct(cFrame, -1, 0.02, false, ...)
    return group
end

function ERACombatTimersGroup:EnterCombat()
    self.frame:Show()
end

function ERACombatTimersGroup:ExitCombat()
    for i, c in ipairs(self.activeIcons) do
        c:hide()
    end
    for i, b in ipairs(self.activeBars) do
        b:hide()
    end
    self.frame:Hide()
end

function ERACombatTimersGroup:ResetToIdle()
    for i, c in ipairs(self.activeIcons) do
        c:hide()
    end
    for i, b in ipairs(self.activeBars) do
        b:hide()
    end
    self.frame:Hide()
    for k, v in pairs(self.events) do
        self.frame:RegisterEvent(k)
    end
end

function ERACombatTimersGroup:SpecInactive(wasActive)
    if (wasActive) then
        self.frame:Hide()
        self.frame:UnregisterAllEvents()
    end
end
function ERACombatTimersGroup:CheckTalents()
    self.activeTimers = {}
    for i, t in ipairs(self.timers) do
        if (t:checkTalents()) then
            table.insert(self.activeTimers, t)
        end
    end
    self.activeBars = {}
    for i, b in ipairs(self.bars) do
        if (b:checkTalentsOrHide()) then
            table.insert(self.activeBars, b)
        end
    end
    self.activeIcons = {}
    for i, c in ipairs(self.icons) do
        if (c:checkTalentsOrHide()) then
            table.insert(self.activeIcons, c)
        end
    end
    self.activeHints = {}
    for i, h in ipairs(self.hints) do
        if (h:checkTalent()) then
            table.insert(self.activeHints, h)
        end
    end
end

function ERACombatTimersGroup:UpdateAfterReset(t)
    for _, i in ipairs(self.activeIcons) do
        i:updateAfterReset(t)
    end
    for _, t in ipairs(self.activeTimers) do
        t:updateAfterReset(t)
    end
end

function ERACombatTimersGroup:Pack()
    self.frameOverlay = CreateFrame("Frame", nil, self.frame)
    self.frameOverlay:SetFrameLevel(3)
    self.frameOverlay:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    self.frameOverlay:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
    self.gcdTicks = {}
    for i = 0, ERACombat_TimerGCDCount do
        local line = self.frameOverlay:CreateLine(nil, "OVERLAY", "ERACombatTimersVerticalTick")
        line:SetStartPoint("CENTER", self.frameOverlay, 0 - i * (ERACombat_TimerWidth / ERACombat_TimerGCDCount), 0)
        table.insert(self.gcdTicks, line)
    end
    if (#(self.kicks) > 0) then
        self.targetCastBar = ERACombatTimerTargetCastBar:create(self, self.frameOverlay)
    end
    self.gcdBar = self.frameOverlay:CreateTexture(nil, "BACKGROUND")
    self.gcdBar:SetPoint("BOTTOMRIGHT", self.frameOverlay, "CENTER", 0, ERACombat_TimerBarSpacing)
    self.gcdBar:SetColorTexture(1.0, 1.0, 1.0, 0.8)
    for _, icon in ipairs(self.icons) do
        icon:createOverlayDisplay()
    end
end

function ERACombatTimersGroup:updateAura(aura, t, stacks, durAura, expirationTime)
    local auraRemDuration
    if (expirationTime and expirationTime > 0) then
        auraRemDuration = expirationTime - t
    else
        auraRemDuration = 4096
    end
    if ((not durAura) or auraRemDuration > durAura) then
        durAura = auraRemDuration
    end
    if (not (stacks and stacks > 0)) then
        stacks = 1
    end
    aura:auraFound(auraRemDuration, durAura, stacks)
end
function ERACombatTimersGroup:UpdateCombat(t)
    if (self.hasTrackedDebuffsOnPlayer) then
        for i = 1, 40 do
            local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitDebuff("player", i)
            if (spellID) then
                local td = self.trackedDebuffsOnPlayer[spellID]
                if (td ~= nil) then
                    self:updateAura(td, t, stacks, durAura, expirationTime)
                end
            else
                break
            end
        end
    end
    for i = 1, 40 do
        local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitDebuff("target", i, "PLAYER")
        if (spellID) then
            local td = self.trackedDebuffs[spellID]
            if (td ~= nil) then
                self:updateAura(td, t, stacks, durAura, expirationTime)
            end
        else
            break
        end
    end
    for i = 1, 40 do
        local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitBuff("player", i, "PLAYER")
        if (spellID) then
            local tb = self.trackedBuffs[spellID]
            if (tb ~= nil) then
                self:updateAura(tb, t, stacks, durAura, expirationTime)
            end
        else
            break
        end
    end

    if (self.watchTargetDispellable) then
        self.targetDispellable = false
        self.targetDispellableMagic = false
        self.targetDispellableRage = false
        for i = 1, 40 do
            local _, _, _, buffType, _, _, _, canStealOrPurge, _, spellID = UnitBuff("target", i)
            if (spellID) then
                if (canStealOrPurge) then
                    self.targetDispellable = true
                end
                -- blizzard bug, Enrage is an empty string.
                buffType = (buffType == "" and "Enrage") or buffType
                if (buffType == "Magic") then
                    self.targetDispellableMagic = true
                elseif (buffType == "Enrage") then
                    self.targetDispellableRage = true
                end
            else
                break
            end
        end
    end
    self.targetCast = 0

    local name, text, _, _, endTargetCastMS, _, _, notInterruptible, spellCastID = UnitCastingInfo("target")
    if (spellCastID and not notInterruptible) then
        self.targetCast = endTargetCastMS / 1000 - t
        if (self.targetCastBar) then
            self.targetCastBar.view:SetText(name)
        end
    else
        name, text, _, _, endTargetCastMS, _, notInterruptible, spellCastID = UnitChannelInfo("target")
        if (spellCastID and not notInterruptible) then
            self.targetCast = endTargetCastMS / 1000 - t
            if (self.targetCastBar) then
                self.targetCastBar.view:SetText(name)
            end
        end
    end

    local haste = 1 + GetHaste() / 100
    local started, duration = GetSpellCooldown(61304)
    if (self.baseGCD <= self.minGCD) then
        self.totGCD = self.minGCD
    else
        self.totGCD = math.max(self.minGCD, self.baseGCD / haste)
    end
    if (duration and duration > 0) then
        self.remGCD = duration - (t - started)
    else
        self.remGCD = 0
    end
    self.timerStandardDuration = self.totGCD * ERACombat_TimerGCDCount

    local channelEnd = -1
    local tickInfo = -1
    local _, _, castTexture, startTimeMS, endCastMS, _, _, _, spellID = UnitCastingInfo("player")
    if (endCastMS) then
        self.remCast = (endCastMS / 1000) - t
        self.totCast = (endCastMS - startTimeMS) / 1000
        self.castingSpellID = spellID
        self.channelingSpellID = nil
        self.castingOrChannelingSpellID = spellID
    else
        _, _, castTexture, startTimeMS, endCastMS, _, _, spellID = UnitChannelInfo("player")
        if (endCastMS) then
            channelEnd = endCastMS / 1000
            self.remCast = channelEnd - t
            self.totCast = (endCastMS - startTimeMS) / 1000
            tickInfo = self.channelInfo[spellID]
            self.castingSpellID = nil
            self.channelingSpellID = spellID
            self.castingOrChannelingSpellID = spellID
        else
            self.remCast = 0
            self.totCast = 0
            self.castingSpellID = nil
            self.channelingSpellID = nil
            self.castingOrChannelingSpellID = nil
        end
    end
    self.occupied = math.max(self.remCast, self.remGCD)

    -----------------
    -- màj données --
    -----------------

    self:PreUpdateCombat(t)

    local locCount = C_LossOfControl.GetActiveLossOfControlDataCount()
    for i = 1, locCount do
        local locBar
        if (i > #(self.loc)) then
            locBar = ERACombatTimerLOCBar:create(self)
            table.insert(self.bars, locBar)
            table.insert(self.activeBars, locBar)
            table.insert(self.loc, locBar)
        else
            locBar = self.loc[i]
        end
        local locData = C_LossOfControl.GetActiveLossOfControlData(i)
        local remDurLoc
        if (locData.timeRemaining and locData.timeRemaining > 0) then
            --elseif (locData.startTime and locData.duration) then
            --remDurLoc = locData.startTime + locData.duration - t
            remDurLoc = locData.timeRemaining
        else
            remDurLoc = 1024
        end
        local typeDescription = locData.locType
        if (typeDescription == "SCHOOL_INTERRUPT") then
            local shcool = locData.lockoutSchool
            if (shcool and shcool ~= 0) then
                typeDescription = "ø " .. GetSchoolString(shcool)
            else
                typeDescription = "INTERRUPT"
            end
        elseif (typeDescription == "STUN_MECHANIC") then
            typeDescription = "STUN"
        elseif (typeDescription == "FEAR_MECHANIC") then
            typeDescription = "FEAR"
        end
        --locData.displayText
        locBar:foundActive(typeDescription, remDurLoc, locData.iconTexture)
    end

    for _, tim in ipairs(self.activeTimers) do
        tim:updateDurations(t)
    end

    for _, b in ipairs(self.activeBars) do
        b:updateDuration(t)
    end
    -- la plupart du temps les barres sont déjà triées ; vérifions
    local alreadySorted = true
    local prv = nil
    for _, b in ipairs(self.activeBars) do
        if (prv and b.remDuration < prv.remDuration) then
            alreadySorted = false
            break
        else
            prv = b
        end
    end
    if (not alreadySorted) then
        table.sort(self.activeBars, ERACombatTimerStatusBar_compare)
    end

    for _, icon in ipairs(self.activeIcons) do
        icon:updateIcon()
    end
    -- la plupart du temps les icônes sont déjà triés ; vérifions
    alreadySorted = true
    prv = nil
    for _, icon in ipairs(self.activeIcons) do
        if (prv and icon.timerDuration < prv.timerDuration) then
            alreadySorted = false
            break
        else
            prv = icon
        end
    end
    if (not alreadySorted) then
        table.sort(self.activeIcons, ERACombatTimerIcon_compare)
    end

    for _, h in ipairs(self.activeHints) do
        h:update(t)
    end

    -- update nested
    local nestedHeight = 0
    if (self.nestedModule) then
        nestedHeight = self.nestedModule:updateAsNested_returnHeightForTimerOverlay(t) + self.nestedModule.offsetY
    end

    -------------------
    -- màj affichage --
    -------------------

    local barsHeight = ERACombat_TimerBarSpacing
    for i, b in ipairs(self.activeBars) do
        barsHeight = b:drawOrHide(barsHeight, self.timerStandardDuration)
    end
    if (barsHeight <= ERACombat_TimerBarSpacing + 0.01) then
        barsHeight = ERACombat_TimerBarDefaultSize + 2 * ERACombat_TimerBarSpacing
    end
    if (self.barsHeight ~= barsHeight) then
        self.barsHeight = barsHeight
        if (self.nestedModule) then
            self.nestedModule.frame:SetPoint(self.nestedModule.anchor, self.frame, "CENTER", self.nestedModule.offsetX, barsHeight + self.nestedModule.offsetY)
        end
    end
    local timerHeight = barsHeight + nestedHeight
    if (self.timerHeight ~= timerHeight) then
        self.timerHeight = timerHeight
        for i, g in ipairs(self.gcdTicks) do
            g:SetEndPoint("CENTER", self.frameOverlay, 0 - (i - 1) * (ERACombat_TimerWidth / ERACombat_TimerGCDCount), timerHeight)
        end
    end

    prv = nil
    for _, icon in ipairs(self.activeIcons) do
        icon:drawOnTimer(timerHeight, self.timerStandardDuration, prv)
        prv = icon
    end

    if (self.remGCD > 0) then
        self.gcdBar:SetPoint("TOPLEFT", self.frame, "CENTER", self:calcTimerPixel(self.remGCD), timerHeight - ERACombat_TimerBarSpacing)
    else
        self.gcdBar:SetPoint("TOPLEFT", self.frame, "CENTER", 0, timerHeight - ERACombat_TimerBarSpacing)
    end
    self.castBackground:SetPoint("TOPLEFT", self.frame, "CENTER", self:calcTimerPixel(self.totCast), timerHeight)
    self.castBar:SetPoint("TOPLEFT", self.frame, "CENTER", self:calcTimerPixel(self.remCast), timerHeight)

    if (tickInfo and tickInfo > 0) then
        tickInfo = tickInfo / haste
        local t_channelTick = channelEnd
        local i = 0
        while (t_channelTick > t) do
            i = i + 1
            local tickLine
            if (i > #(self.channelTicks)) then
                tickLine = self.frameOverlay:CreateLine(nil, "OVERLAY", "ERACombatTimersChannelTick")
                table.insert(self.channelTicks, tickLine)
            else
                tickLine = self.channelTicks[i]
            end
            local x = self:calcTimerPixel(t_channelTick - t)
            tickLine:SetStartPoint("CENTER", self.frameOverlay, x, 0)
            tickLine:SetEndPoint("CENTER", self.frameOverlay, x, timerHeight)
            t_channelTick = t_channelTick - tickInfo
        end
        for j = self.channelTickCount + 1, i do
            self.channelTicks[j]:Show()
        end
        for j = i + 1, self.channelTickCount do
            self.channelTicks[j]:Hide()
        end
        self.channelTickCount = i
    else
        for i = 1, self.channelTickCount do
            self.channelTicks[i]:Hide()
        end
        self.channelTickCount = 0
    end
end

function ERACombatTimersGroup:calcTimerPixel(t)
    return -(t / self.totGCD) * (ERACombat_TimerWidth / ERACombat_TimerGCDCount)
end

function ERACombatTimersGroup:PreUpdateCombat(t)
end

--------------------------------------------------------------------------------------------------------------------------------
---- TIMERS --------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

-- timer

ERACombatTimer = {}
ERACombatTimer.__index = ERACombatTimer

function ERACombatTimer:constructTimer(group, talent)
    self.totDuration = 1
    self.remDuration = 0
    self.group = group
    self.talent = talent
    table.insert(group.timers, self)
end

function ERACombatTimer:updateDurations(t)
    self.totDuration = 1
    self.remDuration = 0
end

function ERACombatTimer:checkTalents()
    if (self.talent) then
        self.talentActive = self.talent:PlayerHasTalent()
    else
        self.talentActive = true
    end
    self:TalentCheck()
    self.remDuration = 0
    if (self.talentActive) then
        self.totDuration = 1
        return true
    else
        return false
    end
end
-- abstract function ERACombatTimer:TalentCheck()

function ERACombatTimer:updateAfterReset(t)
end

-- cooldown

ERACombatCooldown = {}
ERACombatCooldown.__index = ERACombatCooldown
setmetatable(ERACombatCooldown, {__index = ERACombatTimer})

function ERACombatCooldown:create(group, spellID, talent)
    local t = {}
    setmetatable(t, ERACombatCooldown)
    t:constructTimer(group, talent)
    t.spellID = spellID
    t:updateKind()
    return t
end

function ERACombatCooldown_Update(cd, t, totGCD)
    if (cd.hasCharges) then
        local currentCharges, maxCharges, cooldownStart, cooldownDuration = GetSpellCharges(cd.spellID)
        if (maxCharges) then
            cd.currentCharges = currentCharges
            cd.maxCharges = maxCharges
            cd.totDuration = cooldownDuration
            if (currentCharges >= maxCharges) then
                cd.remDuration = 0
                cd.isAvailable = true
            else
                cd.remDuration = cooldownDuration - (t - cooldownStart)
                cd.isAvailable = currentCharges > 0
            end
            cd.lastGoodUpdate = t
            cd.lastGoodDuration = cd.remDuration
            return
        end
    end
    local started, duration = GetSpellCooldown(cd.spellID)
    if (started and started > 0) then
        cd.currentCharges = 0
        local remDur = duration - (t - started)
        if (duration <= totGCD + 0.5) then
            if (cd.lastGoodUpdate) then
                cd.isAvailable = true
                -- cd.totDuration reste inchangé
                cd.remDuration = cd.lastGoodDuration - (t - cd.lastGoodUpdate)
                if (cd.remDuration < 0) then
                    cd.remDuration = 0
                elseif (cd.remDuration > remDur) then
                    cd.remDuration = remDur
                end
                return
            end
        end
        cd.isAvailable = false
        cd.totDuration = duration
        cd.remDuration = remDur
        cd.lastGoodUpdate = t
        cd.lastGoodDuration = cd.remDuration
    else
        cd.isAvailable = true
        cd.totDuration = duration or 1
        cd.remDuration = 0
        cd.currentCharges = 1
        cd.lastGoodUpdate = t
        cd.lastGoodDuration = 0
    end
end

function ERACombatCooldown:updateDurations(t)
    if (self.mustAlwaysUpdateKind) then
        self:updateKind()
    end
    ERACombatCooldown_Update(self, t, self.group.totGCD)
end

function ERACombatCooldown:TalentCheck()
    self:updateKind()
    if (not self.talentActive) then
        self.currentCharges = 0
    end
end
function ERACombatCooldown:updateKind()
    local currentCharges, maxCharges = GetSpellCharges(self.spellID)
    if (maxCharges and maxCharges > 1) then
        self.currentCharges = currentCharges
        self.maxCharges = maxCharges
        self.hasCharges = true
    else
        self.currentCharges = 0
        self.maxCharges = 1
        self.hasCharges = false
    end
end

function ERACombatCooldown:updateAfterReset(t)
    self:updateKind()
    if (self.spellID == 35395) then
    end
end

-- aura

ERACombatAura = {}
ERACombatAura.__index = ERACombatAura
setmetatable(ERACombatAura, {__index = ERACombatTimer})

function ERACombatAura:create(group, spellID, isDebuff, talent)
    local t = {}
    setmetatable(t, ERACombatAura)
    t:constructTimer(group, talent)
    t.spellID = spellID
    t.stacks = 0
    t.found = false
    self.isDebuff = isDebuff
    return t
end

function ERACombatAura:TalentCheck()
    if (not self.talentActive) then
        self.stacks = 0
    end
end

function ERACombatAura:auraFound(rem, tot, stacks)
    self.remDuration = rem
    self.totDuration = tot
    self.stacks = stacks
    self.found = true
end

function ERACombatAura:updateDurations(t)
    if (self.found) then
        self.found = false
    else
        self.remDuration = 0
        self.totDuration = 1
        self.stacks = 0
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- ICONES --------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatTimerIcon = {}
ERACombatTimerIcon.__index = ERACombatTimerIcon

function ERACombatTimerIcon:construct(group, x, y, iconID, showOnTimer)
    self.group = group
    self.x = x
    self.y = y
    self.iconID = iconID
    self.icon = ERAPieIcon:Create(group.frame, "CENTER", ERACombat_TimerIconSize, iconID)
    self.icon.frame:SetFrameLevel(2)
    self.showOnTimer = showOnTimer
    self.mainVisible = true
    self.timerVisible = true
    self.icon:Draw(
        (x + 1) * ERACombat_TimerIconSpacing + (x + 0.5) * ERACombat_TimerIconSize + ERACombat_TimerBarDefaultSize,
        (y - 1) * ERACombat_TimerIconSpacing + (y - 0.5) * ERACombat_TimerIconSize - 1.5 * ERACombat_TimerIconCooldownSize,
        false
    )
    table.insert(group.icons, self)
end

function ERACombatTimerIcon:createOverlayDisplay()
    if (self.showOnTimer) then
        local frame = self.group.frameOverlay
        self.line = frame:CreateLine(nil, "OVERLAY", "ERACombatTimersVerticalTick")
        self.iconTimer = ERASquareIcon:Create(frame, "CENTER", ERACombat_TimerIconCooldownSize, self.iconID)
    else
        self.timerVisible = false
    end
end

function ERACombatTimerIcon:checkTalentsOrHide()
    self:hide()
    return false
end

function ERACombatTimerIcon:updateAfterReset(t)
end

function ERACombatTimerIcon:hide()
    if (self.mainVisible) then
        self.mainVisible = false
        self.icon:Hide()
    end
    if (self.timerVisible) then
        self.line:Hide()
        self.iconTimer:Hide()
        self.timerVisible = false
    end
end

function ERACombatTimerIcon_compare(i1, i2)
    return i1.timerDuration < i2.timerDuration
end

function ERACombatTimerIcon:updateIcon()
    self:updateTimerDurationAndMainIconVisibility()
    if (self.shouldShowMainIcon) then
        if (not self.mainVisible) then
            self.mainVisible = true
            self.icon:Show()
        end
    else
        if (self.mainVisible) then
            self.mainVisible = false
            self.icon:Hide()
        end
    end
end
function ERACombatTimerIcon:drawOnTimer(timerHeight, timerStandardDuration, prvIcon)
    if (self.showOnTimer and self.timerDuration > 0 and self.timerDuration <= timerStandardDuration) then
        if (not self.timerVisible) then
            self.line:Show()
            self.timerVisible = true
        end
        self.tickpos = self.group:calcTimerPixel(self.timerDuration)
        local yOffset
        if (prvIcon and prvIcon.iconTimerLayer > 0 and prvIcon.tickpos - ERACombat_TimerIconCooldownSize < self.tickpos) then
            if (prvIcon.iconTimerLayer == 1) then
                self.iconTimerLayer = 2
                yOffset = -ERACombat_TimerIconCooldownSize
            else
                self.iconTimerLayer = 1
                yOffset = 0
            end
        else
            self.iconTimerLayer = 1
            yOffset = 0
        end
        self.iconTimer:Draw(self.tickpos, yOffset - ERACombat_TimerIconCooldownSize / 2, false)
        self.line:SetStartPoint("CENTER", self.group.frameOverlay, self.tickpos, yOffset)
        self.line:SetEndPoint("CENTER", self.group.frameOverlay, self.tickpos, timerHeight)
        self:TimerIconDrawn(self.iconTimer)
    else
        self.iconTimerLayer = 0
        if (self.timerVisible) then
            self.line:Hide()
            self.iconTimer:Hide()
            self.timerVisible = false
        end
    end
end
function ERACombatTimerIcon:TimerIconDrawn(icon)
end

-- cooldown

ERACombatCooldownIcon = {}
ERACombatCooldownIcon.__index = ERACombatCooldownIcon
setmetatable(ERACombatCooldownIcon, {__index = ERACombatTimerIcon})

function ERACombatCooldownIcon:create(cd, x, y, iconID, showOnTimer, availableIfLessThanGCD, talent)
    local i = {}
    setmetatable(i, ERACombatCooldownIcon)
    i.iconID = iconID
    if (not iconID) then
        _, _, iconID = GetSpellInfo(cd.spellID)
    end
    i:construct(cd.group, x, y, iconID, showOnTimer)
    i.cd = cd
    i.talent = talent
    i.availableIfLessThanGCD = availableIfLessThanGCD
    i.chargesText = ""
    i.currentChargesText = 0
    i.maxChargesText = 0
    i.shouldShowMainIcon = true
    return i
end

function ERACombatCooldownIcon:checkTalentsOrHide()
    self.icon:SetSecondaryText(nil)
    if (self.cd.talentActive and ((not self.talent) or self.talent:PlayerHasTalent())) then
        local iconID = self:updateIconCooldownTexture()
        if (self.iconTimer) then
            self.iconTimer:SetIconTexture(iconID, true)
        end
        self.talentActive = true
        return true
    else
        self:hide()
        self.talentActive = false
        return false
    end
end

function ERACombatCooldownIcon:updateIconCooldownTexture()
    local iconID = self.iconID
    if (not iconID) then
        _, _, iconID = GetSpellInfo(self.cd.spellID)
    end
    self.icon:SetIconTexture(iconID, true)
    return iconID
end

function ERACombatCooldownIcon:updateAfterReset(t)
    self:updateIconCooldownTexture()
end

function ERACombatCooldownIcon_SetSaturatedAndChargesText(ui, cd)
    ui.icon:SetDesaturated(false)
    if (cd.remDuration > 0) then
        ui.icon:SetSecondaryText(math.floor(cd.remDuration))
    else
        ui.icon:SetSecondaryText(nil)
    end
    if (ui.currentChargesText ~= cd.currentCharges or ui.maxChargesText ~= cd.maxCharges) then
        ui.currentChargesText = cd.currentCharges
        ui.maxChargesText = cd.maxCharges
        ui.chargesText = ""
        for i = 1, cd.currentCharges do
            ui.chargesText = ui.chargesText .. "¤"
        end
        for i = cd.currentCharges + 1, cd.maxCharges do
            ui.chargesText = ui.chargesText .. "."
        end
    end
    ui.icon:SetMainText(ui.chargesText)
end

function ERACombatCooldownIcon:updateTimerDurationAndMainIconVisibility()
    if (self.displayOnlyIfSpellPetKnown and not IsSpellKnown(self.cd.spellID, true)) then
        self.shouldShowMainIcon = false
        self.timerDuration = 0
    else
        self.shouldShowMainIcon = self:ShouldShowMainIcon()
        local dur = self.cd.remDuration
        if (self.cd.hasCharges) then
            self.icon:SetOverlayValue(dur / self.cd.totDuration)
            if (self.cd.currentCharges > 0) then
                ERACombatCooldownIcon_SetSaturatedAndChargesText(self, self.cd)
                if (self.cd.currentCharges + 1 >= self.cd.maxCharges) then
                    self.timerDuration = dur
                    if (not self:OverrideTimerVisibility()) then
                        self.timerDuration = 0
                    end
                else
                    self.timerDuration = 0
                end
            else
                self.icon:SetDesaturated(true)
                self.icon:SetSecondaryText(nil)
                self.icon:SetMainText(math.floor(dur))
                self.timerDuration = 0
            end
        else
            if (self.overrideSecondaryText) then
                self.icon:SetSecondaryText(self.overrideSecondaryText())
            else
                self.icon:SetSecondaryText(nil)
            end
            if (self.cd.isAvailable) then
                self.icon:SetOverlayValue(0)
                self.icon:SetDesaturated(false)
                self.icon:SetMainText(nil)
                if (self:OverrideTimerVisibility()) then
                    self.timerDuration = dur
                else
                    self.timerDuration = 0
                end
            else
                self.icon:SetOverlayValue(dur / self.cd.totDuration)
                self.icon:SetDesaturated(dur > 30)
                if (self:OverrideTimerVisibility()) then
                    self.timerDuration = dur
                    if (dur < self.group.timerStandardDuration) then
                        self.icon:SetMainText(nil)
                    else
                        self.icon:SetMainText(math.floor(dur))
                    end
                else
                    self.timerDuration = 0
                    self.icon:SetMainText(math.floor(dur))
                end
            end
        end
    end
end
function ERACombatCooldownIcon:ShouldShowMainIcon()
    return true
end
function ERACombatCooldownIcon:OverrideTimerVisibility()
    return true
end

-- aura

ERACombatAuraIcon = {}
ERACombatAuraIcon.__index = ERACombatAuraIcon
setmetatable(ERACombatAuraIcon, {__index = ERACombatTimerIcon})

function ERACombatAuraIcon:create(aura, x, y, iconID, talent)
    local i = {}
    setmetatable(i, ERACombatAuraIcon)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(aura.spellID)
    end
    i:construct(aura.group, x, y, iconID, false)
    i.aura = aura
    i.talent = talent
    i.shouldShowMainIcon = true
    i.timerDuration = 0
    return i
end

function ERACombatAuraIcon:checkTalentsOrHide()
    if (self.aura.talentActive and ((not self.talent) or self.talent:PlayerHasTalent())) then
        local iconID = self.iconID
        if (not iconID) then
            _, _, iconID = GetSpellInfo(self.cd.spellID)
        end
        self.icon:SetIconTexture(iconID, true)
        return true
    else
        self:hide()
        return false
    end
end

function ERACombatAuraIcon:updateTimerDurationAndMainIconVisibility()
    local dur = self.aura.remDuration
    if (dur > 0) then
        self.shouldShowMainIcon = true
        self.icon:SetOverlayValue(1 - dur / self.aura.totDuration)
        self.icon:SetDesaturated(false)
        if (self.aura.stacks > 1) then
            self.icon:SetMainText(self.aura.stacks)
        else
            self.icon:SetMainText(nil)
        end
        self.icon:SetMainTextColor(1.0, 1.0, 1.0)
        self:IconUpdatedAndShown()
    else
        if (self:ShouldShowWhenAbsent()) then
            self.icon:SetOverlayValue(0)
            self.icon:SetDesaturated(true)
            self.icon:SetMainText("X")
            self.icon:SetMainTextColor(1.0, 0.0, 0.0)
            self.shouldShowMainIcon = true
        else
            self.shouldShowMainIcon = false
        end
    end
end
function ERACombatAuraIcon:IconUpdatedAndShown()
end
function ERACombatAuraIcon:ShouldShowWhenAbsent()
    return true
end

--------------------------------------------------------------------------------------------------------------------------------
---- BARRES --------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatTimerStatusBar = {}
ERACombatTimerStatusBar.__index = ERACombatTimerStatusBar

function ERACombatTimerStatusBar:construct(group, iconID, r, g, b, texture, parentFrame)
    -- assignation
    self.group = group
    table.insert(group.bars, self)
    -- affichage
    self.view = ERACombatTimersBar:create(parentFrame or group.frame, "CENTER", iconID, r, g, b, texture)
    -- mécanique
    self.remDuration = 0
end

function ERACombatTimerStatusBar_compare(b1, b2)
    return b1.remDuration < b2.remDuration
end

function ERACombatTimerStatusBar:checkTalentsOrHide()
    self:hide()
    return false
end

function ERACombatTimerStatusBar:hide()
    self.view:hide()
end

function ERACombatTimerStatusBar:updateDuration(t)
    self.remDuration = self:GetRemDurationOr0IfInvisible(t)
end
-- abstract function ERACombatTimerStatusBar:GetRemDurationOr0IfInvisible()

function ERACombatTimerStatusBar:drawOrHide(y, timerStandardDuration)
    if (self.remDuration > 0) then
        self.view:draw(y, self.remDuration, timerStandardDuration)
        return y + self.view.height + ERACombat_TimerBarSpacing
    else
        self:hide()
        return y
    end
end

-- aura

ERACombatTimerAuraBar = {}
ERACombatTimerAuraBar.__index = ERACombatTimerAuraBar
setmetatable(ERACombatTimerAuraBar, {__index = ERACombatTimerStatusBar})

function ERACombatTimerAuraBar:create(aura, iconID, r, g, b, talent)
    local bar = {}
    setmetatable(bar, ERACombatTimerAuraBar)
    bar:construct(aura.group, iconID, r, g, b, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    -- assignation
    bar.aura = aura
    bar.talent = talent
    return bar
end

function ERACombatTimerAuraBar:checkTalentsOrHide()
    if (self.aura.talentActive and ((not self.talent) or self.talent:PlayerHasTalent())) then
        return true
    else
        self:hide()
        return false
    end
end

function ERACombatTimerAuraBar:GetRemDurationOr0IfInvisible(t)
    if (self.showStacks) then
        self.view:SetText(self.aura.stacks)
    end
    return self.aura.remDuration
end

-- totem

ERACombatTimerTotemBar = {}
ERACombatTimerTotemBar.__index = ERACombatTimerTotemBar
setmetatable(ERACombatTimerTotemBar, {__index = ERACombatTimerStatusBar})

function ERACombatTimerTotemBar:create(timers, totemID, iconID, r, g, b, talent)
    local tot = {}
    setmetatable(tot, ERACombatTimerTotemBar)
    tot:construct(timers, iconID, r, g, b, "Interface\\Buttons\\WHITE8x8")
    tot.totemID = totemID
    tot.talent = talent
    return tot
end

function ERACombatTimerTotemBar:checkTalentsOrHide()
    if ((not self.talent) or self.talent:PlayerHasTalent()) then
        return true
    else
        self:hide()
        return false
    end
end

function ERACombatTimerTotemBar:GetRemDurationOr0IfInvisible(t)
    local haveTotem, _, startTime, duration = GetTotemInfo(self.totemID)
    if (haveTotem) then
        self.haveTotem = true
        if (duration and duration > 0 and startTime) then
            return self:UpdatingDuration(t, duration - (t - startTime))
        else
            return self:UpdatingDuration(t, 128)
        end
    else
        self.haveTotem = false
        return self:UpdatingDuration(t, 0)
    end
end
function ERACombatTimerTotemBar:UpdatingDuration(t, remDuration)
    return remDuration
end

-- loc

ERACombatTimerLOCBar = {}
ERACombatTimerLOCBar.__index = ERACombatTimerLOCBar
setmetatable(ERACombatTimerLOCBar, {__index = ERACombatTimerStatusBar})

function ERACombatTimerLOCBar:create(group)
    local bar = {}
    setmetatable(bar, ERACombatTimerLOCBar)
    bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\MINIMAP\\HumanUITile-TimeIndicator")
    bar.locRemDuration = 0
    return bar
end

function ERACombatTimerLOCBar:checkTalentsOrHide()
    return true
end

function ERACombatTimerLOCBar:foundActive(locTypeDescription, remDuration, icon)
    self.view:updateIconTexture(icon)
    self.view:SetText(locTypeDescription)
    self.locRemDuration = remDuration
end

function ERACombatTimerLOCBar:GetRemDurationOr0IfInvisible(t)
    if (self.locRemDuration > 0) then
        local tmp = self.locRemDuration
        self.locRemDuration = 0
        return tmp
    else
        return 0
    end
end

-- target cast

ERACombatTimerTargetCastBar = {}
ERACombatTimerTargetCastBar.__index = ERACombatTimerTargetCastBar
setmetatable(ERACombatTimerTargetCastBar, {__index = ERACombatTimerStatusBar})

function ERACombatTimerTargetCastBar:create(group, parentFrame)
    local bar = {}
    setmetatable(bar, ERACombatTimerTargetCastBar)
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\BUTTONS\\BLUEGRAD64")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\Legionfall\\LegionfallHorizontal")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\FontStyles\\FontStyleIronHordeMetal")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\FontStyles\\FontStyleGarrisons")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\FontStyles\\FontStyleLegion")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\PLAYERFRAME\\ShamanMaelstromBarHorizontal")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\PLAYERFRAME\\DruidLunarBarHorizontal")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\UNITPOWERBARALT\\FelCorruption_Horizontal_Flash")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\UNITPOWERBARALT\\FelCorruptionRed_Horizontal_Flash")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\UNITPOWERBARALT\\Generic1Player_Horizontal_Flash")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\RAIDFRAME\\Shield-Overlay")
    --bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\RAIDFRAME\\Shield-Fill")
    bar:construct(group, nil, 1.0, 1.0, 1.0, "Interface\\FontStyles\\FontStyleLegion", parentFrame)
    ERALIB_SetFont(bar.view.text, ERACombat_TimerBarDefaultSize * 0.5)
    return bar
end

function ERACombatTimerTargetCastBar:checkTalentsOrHide()
    return true
end

function ERACombatTimerTargetCastBar:GetRemDurationOr0IfInvisible(t)
    local c = self.group.targetCast
    if (c > 0) then
        for _, k in ipairs(self.group.kicks) do
            if (k.talentActive and c > 0.1 + k.cd.remDuration and ((not k.displayOnlyIfSpellPetKnown) or IsSpellKnown(k.cd.spellID, true))) then
                return c
            end
        end
        return 0
    else
        return 0
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- BARRE affichage -----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatTimersBar = {}
ERACombatTimersBar.__index = ERACombatTimersBar

function ERACombatTimersBar:create(parentFrame, parentAnchor, iconID, r, g, b, texture)
    local bar = {}
    setmetatable(bar, ERACombatTimersBar)

    bar.parentFrame = parentFrame
    bar.parentAnchor = parentAnchor

    -- affichage
    bar.sBar = CreateFrame("StatusBar", nil, parentFrame, "ERACombatTimersStatusBar")
    bar.sBar:SetStatusBarTexture(texture)
    bar.r = r
    bar.g = g
    bar.b = b
    bar.sBar:SetStatusBarColor(r, g, b, 1)
    bar.icon = bar.sBar.Icon
    bar:updateIconTexture(iconID)
    bar.iconID = iconID
    bar.text = bar.sBar.Text
    bar.textValue = nil
    bar.sBar:SetWidth(1.5 * ERACombat_TimerWidth)
    bar:SetSize(ERACombat_TimerBarDefaultSize)
    bar.anim = bar.sBar.Anim
    bar.translation = bar.anim.Translation
    bar.translation:SetScript(
        "OnFinished",
        function()
            bar:endAnimate()
        end
    )
    bar.lastY = 123456
    bar.sBar:Hide()
    bar.currentlyVisible = false
    bar.iconVisible = true
    bar.iconAlpha = 1.0

    return bar
end

function ERACombatTimersBar:SetIconVisibility(visible)
    if (visible) then
        if (not self.iconVisible) then
            self.iconVisible = true
            self.icon:Show()
        end
    else
        if (self.iconVisible) then
            self.iconVisible = false
            self.icon:Hide()
        end
    end
end

function ERACombatTimersBar:SetIconAlpha(alpha)
    if (self.iconAlpha ~= alpha) then
        self.iconAlpha = alpha
        self.icon:SetAlpha(alpha)
    end
end

function ERACombatTimersBar:SetIconDesaturated(desat)
    if (desat) then
        if (not self.desat) then
            self.desat = true
            self.icon:SetDesaturated(true)
        end
    else
        if (self.desat) then
            self.desat = false
            self.icon:SetDesaturated(false)
        end
    end
end

function ERACombatTimersBar:SetColor(r, g, b)
    if (self.r ~= r or self.g ~= g or self.b ~= b) then
        self.r = r
        self.g = g
        self.b = b
        self.sBar:SetStatusBarColor(r, g, b, 1)
    end
end
function ERACombatTimersBar:updateIconTexture(iconID)
    if (self.iconID ~= iconID) then
        self.iconID = iconID
        self.icon:SetTexture(iconID)
    end
end

function ERACombatTimersBar:SetSize(s)
    self.height = s
    self.icon:SetSize(s, s)
    self.sBar:SetHeight(s)
    self.text:SetHeight(s)
    ERALIB_SetFont(self.text, s * 0.8)
end

function ERACombatTimersBar:hide()
    if (self.currentlyVisible) then
        self.currentlyVisible = false
        self.sBar:Hide()
    end
end

function ERACombatTimersBar:SetText(text)
    if (self.textValue ~= text) then
        self.textValue = text
        self.text:SetText(text)
    end
end

function ERACombatTimersBar:draw(y, value, max)
    local wasVisible = self.currentlyVisible
    if (not self.currentlyVisible) then
        self.currentlyVisible = true
        self.sBar:Show()
    end
    self.sBar:SetMinMaxValues(0, 1.5 * max)
    if (value > max) then
        self.sBar:SetValue(max * (1 + 0.5 * (1 - math.exp(-0.2 * (value - max)))))
    else
        self.sBar:SetValue(value)
    end
    if (wasVisible) then
        if (self.lastY ~= y) then
            self.translation:SetOffset(0, y - self.lastY)
            self.anim:Play()
        end
    else
        self.sBar:SetPoint("BOTTOMRIGHT", self.parentFrame, self.parentAnchor, 0, y)
    end
    self.lastY = y
    return self.height
end

function ERACombatTimersBar:endAnimate()
    self.sBar:SetPoint("BOTTOMRIGHT", self.parentFrame, self.parentAnchor, 0, self.lastY)
end

--------------------------------------------------------------------------------------------------------------------------------
---- HINTS ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatTimersHintIcon = {}
ERACombatTimersHintIcon.__index = ERACombatTimersHintIcon

function ERACombatTimersHintIcon:construct(group, iconID, x, y, beam, talent)
    self.group = group
    self.icon = ERASquareIcon:Create(group.frame, "CENTER", ERACombat_TimerIconSize, iconID)
    self.icon:Draw(
        (x + 1) * ERACombat_TimerIconSpacing + (x + 0.5) * ERACombat_TimerIconSize + ERACombat_TimerBarDefaultSize,
        (y - 1) * ERACombat_TimerIconSpacing + (y - 0.5) * ERACombat_TimerIconSize - 1.5 * ERACombat_TimerIconCooldownSize,
        false
    )
    if (beam) then
        self.icon:Beam()
    end
    self.icon:Hide()
    self.talent = talent
    table.insert(group.hints, self)
end

function ERACombatTimersHintIcon:checkTalent()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.icon:Hide()
        return false
    else
        return true
    end
end

function ERACombatTimersHintIcon:update(t)
    if (self:ComputeIsVisible(t)) then
        self.icon:Show()
    else
        self.icon:Hide()
    end
end
-- abstract function ERACombatTimersHintIcon:ComputeIsVisible(t)

-- missing aura

ERACombatTimersMissingAura = {}
ERACombatTimersMissingAura.__index = ERACombatTimersMissingAura
setmetatable(ERACombatTimersMissingAura, {__index = ERACombatTimersHintIcon})

function ERACombatTimersMissingAura:create(aura, iconID, x, y, beam)
    local mi = {}
    setmetatable(mi, ERACombatTimersMissingAura)
    mi.aura = aura
    mi:construct(aura.group, iconID, x, y, beam, aura.talent)
    return mi
end

function ERACombatTimersMissingAura:ComputeIsVisible(t)
    if (self.aura.isDebuff and not UnitExists("target")) then
        return false
    else
        return self.aura.stacks <= 0 or self.aura.remDuration <= 0
    end
end

-- proc

ERACombatTimersProc = {}
ERACombatTimersProc.__index = ERACombatTimersProc
setmetatable(ERACombatTimersProc, {__index = ERACombatTimersHintIcon})

function ERACombatTimersProc:create(aura, iconID, x, y, beam, talent)
    local pr = {}
    setmetatable(pr, ERACombatTimersProc)
    pr.aura = aura
    if (talent) then
        if (aura.talent) then
            talent = ERALIBTalent:CreateAnd(talent, aura.talent)
        end
    else
        talent = aura.talent
    end
    pr:construct(aura.group, iconID, x, y, beam, talent)
    return pr
end

function ERACombatTimersProc:ComputeIsVisible(t)
    return self.aura.remDuration > 0
end

-- target dispellable

ERACombatTimersTargetDispellableIcon = {}
ERACombatTimersTargetDispellableIcon.__index = ERACombatTimersTargetDispellableIcon
setmetatable(ERACombatTimersTargetDispellableIcon, {__index = ERACombatTimersHintIcon})

function ERACombatTimersTargetDispellableIcon:create(group, iconID, x, y, beam, talent, ...)
    local mi = {}
    setmetatable(mi, ERACombatTimersTargetDispellableIcon)
    mi:construct(group, iconID, x, y, beam, talent)
    mi.types = {}
    for i, t in ipairs {...} do
        table.insert(mi.types, t)
    end
    group.watchTargetDispellable = true
    return mi
end

function ERACombatTimersTargetDispellableIcon:ComputeIsVisible(t)
    return self.group.targetDispellable
    --[[
    for i, t in ipairs(self.types) do
        if (t == "Magic") then
            if (self.group.targetDispellableMagic) then
                return true
            end
        elseif (t == "Enrage") then
            if (self.group.targetDispellableRage) then
                return true
            end
        end
    end
    return false
    ]]
end
