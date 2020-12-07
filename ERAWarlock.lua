-- TODO
-- rien

function ERACombatFrames_WarlockSetup(cFrame)
    ERACombatGlobals_SpecID1 = 265
    ERACombatGlobals_SpecID2 = 266
    ERACombatGlobals_SpecID3 = 267

    local affliActive = ERACombatOptions_IsSpecActive(1)
    local demoActive = ERACombatOptions_IsSpecActive(2)
    local destruActive = ERACombatOptions_IsSpecActive(3)

    ERAOutOfCombatStatusBars:Create(cFrame, 128, -32, 144, 22, -1, true, 0.0, 0.0, 0.0, true, affliActive, demoActive, destruActive)

    ERACombatHealth:Create(cFrame, 121, -44, 128, 22, affliActive, demoActive, destruActive)
    ERACombatHealth:Create(cFrame, 121, -66, 128, 22, affliActive, demoActive, destruActive):SetUnitID("pet")

    if (affliActive) then
        ERACombatFrames_WarlockAfflictionSetup(cFrame)
    end
    if (demoActive) then
        ERACombatFrames_WarlockDemonologySetup(cFrame)
    end
    if (destruActive) then
        ERACombatFrames_WarlockDestructionSetup(cFrame)
    end

    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_WarlockUtilityAndCovenant(cFrame, timers, x, y, spec)
    local utility = ERACombatUtilityFrame:Create(cFrame, x, y, spec)
    utility:AddCooldown(0, 0, 104773, nil, true) -- resolve
    utility:AddCooldown(1.5, 0.9, 48018, nil, true, ERALIBTalent:CreateLevel(41)).alphaWhenOffCooldown = 0 -- tp placement
    utility:AddCooldown(1, 0, 48020, nil, true, ERALIBTalent:CreateLevel(41)) -- tp
    utility:AddWarlockHealthStone(2, 0, true)
    utility:AddWarlockPortal(3, 0)

    utility:AddCooldown(-2, -1, 108416, nil, true, ERALIBTalent:Create(3, 3)) -- dark pact
    utility:AddCooldown(-1, -1, 6789, nil, true, ERALIBTalent:Create(5, 2)) -- heal fear
    utility:AddCooldown(-1, -1, 5484, nil, true, ERALIBTalent:Create(5, 3)) -- aoe fear
    utility:AddCooldown(0, -1, 30283, nil, true, ERALIBTalent:CreateLevel(38)) -- shadowfury

    utility:AddDefensiveDispellCooldown(1, -1, 89808, nil, nil, "Magic").showOnlyIfPetSpellKnown = true -- imp dispell
    utility:AddCooldown(1, -1, 6358, nil, true).showOnlyIfPetSpellKnown = true -- seduction
    utility:AddCooldown(1, -1, 17767, nil, true).showOnlyIfPetSpellKnown = true -- shadow bulwark

    utility:AddCooldown(2, -1, 333889, nil, true, ERALIBTalent:CreateLevel(22)) -- instant pet

    timers:AddChannelInfo(234153, 1)
    timers:AddChannelInfo(755, 1)

    utility:AddCovenantGenericAbility(0.5, 0.9)
    utility:AddCovenantClassAbility(-0.5, 0.9, 312321, 321792, 325640, 325289)
    timers:AddAuraBar(timers:AddTrackedDebuff(325640, ERALIBTalent:CreateNightfaeOrSpellKnown(325640)), nil, 0.0, 0.4, 0.8)

    return utility
end

ERACombatFrames_WarlockExhaustionBar = {}
ERACombatFrames_WarlockExhaustionBar.__index = ERACombatFrames_WarlockExhaustionBar
setmetatable(ERACombatFrames_WarlockExhaustionBar, {__index = ERACombatTimerStatusBar})

function ERACombatFrames_WarlockExhaustionBar:create(timers, curse)
    local c = {}
    setmetatable(c, ERACombatFrames_WarlockExhaustionBar)
    c:construct(timers, curse.iconID, 0.5, 0.5, 0.5, "Interface\\Buttons\\WHITE8x8")
    c.view:SetSize(16)
    c.curse = curse
    return c
end

function ERACombatFrames_WarlockExhaustionBar:checkTalentsOrHide()
    return true
end

function ERACombatFrames_WarlockExhaustionBar:GetRemDurationOr0IfInvisible(t)
    return self.curse.remDuration
end

ERACombatWarlockCurses_IconSize = 64
ERACombatWarlockCurses = {}
ERACombatWarlockCurses.__index = ERACombatWarlockCurses
setmetatable(ERACombatWarlockCurses, {__index = ERACombatModule})

function ERACombatWarlockCurses:create(cFrame, x, y, timers, spec)
    local c = {}
    setmetatable(c, ERACombatWarlockCurses)
    c:construct(cFrame, -1, 0.1, true, spec)

    c.frame = CreateFrame("Frame", nil, UIParent, nil)
    c.frame:SetSize(2 * ERACombatWarlockCurses_IconSize, ERACombatWarlockCurses_IconSize)
    c.frame:SetPoint("TOP", UIParent, "CENTER", x, y)

    c.cursesBySpellID = {}
    c.tongues = ERACombatWarlockCurse:create(c, 1714, 30, 136140, -ERACombatWarlockCurses_IconSize)
    c.weakness = ERACombatWarlockCurse:create(c, 702, 120, 136138, ERACombatWarlockCurses_IconSize)
    c.exhaustion = ERACombatWarlockCurse:create(c, 334275, 8, 136162, nil)

    ERACombatFrames_WarlockExhaustionBar:create(timers, c.exhaustion)

    c.targetInfos = {}

    return c
end

function ERACombatWarlockCurses:SpecInactive(wasActive)
    self.frame:Hide()
end

function ERACombatWarlockCurses:ResetToIdle()
    self.frame:Hide()
    self.targetInfos = {}
end
function ERACombatWarlockCurses:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERACombatWarlockCurses:ExitCombat(toIdle)
    self.frame:Hide()
    self.targetInfos = {}
end

function ERACombatWarlockCurses:CLEU(t)
    local _, evt, _, sourceGUY, _, _, _, targetGUY, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if (evt == "SPELL_AURA_APPLIED" or evt == "SPELL_AURA_REFRESH") then
        local c = self.cursesBySpellID[spellID]
        if (c) then
            local ti = self.targetInfos[targetGUY]
            if (not ti) then
                ti = {}
                self.targetInfos[targetGUY] = ti
            end
            ti[c] = t
        end
    end
end

function ERACombatWarlockCurses:UpdateCombat(t)
    if (UnitCanAttack("player", "target")) then
        for _, c in pairs(self.cursesBySpellID) do
            c:prepareUpdate()
        end
        local thisPlayerHasOneCurseActive
        for i = 1, 40 do
            local _, _, stacks, _, durAura, expirationTime, source, _, _, spellID = UnitDebuff("target", i)
            if (spellID) then
                local c = self.cursesBySpellID[spellID]
                if (c) then
                    c:auraFound(t, stacks, durAura, expirationTime, source == "player")
                end
            else
                break
            end
        end
        local thisPlayerHasOneCurseActive = false
        for _, c in pairs(self.cursesBySpellID) do
            if (c.maxDurationByPlayer) then
                thisPlayerHasOneCurseActive = true
                break
            end
        end
        local targetGUID = UnitGUID("target")
        for _, c in pairs(self.cursesBySpellID) do
            c:update(t, thisPlayerHasOneCurseActive, targetGUID)
        end
    else
        for _, c in pairs(self.cursesBySpellID) do
            c:noTarget()
        end
    end
end

ERACombatWarlockCurse = {}
ERACombatWarlockCurse.__index = ERACombatWarlockCurse

function ERACombatWarlockCurse:create(curses, spellID, standardDuration, iconID, x)
    local c = {}
    setmetatable(c, ERACombatWarlockCurse)
    c.curses = curses
    c.spellID = spellID
    c.iconID = iconID
    if (x) then
        c.icon = ERAPieIcon:Create(curses.frame, "CENTER", ERACombatWarlockCurses_IconSize, iconID)
        c.icon:Draw(x, 0)
        c.icon:Hide()
    end
    c.standardDuration = standardDuration
    c.remDuration = 0
    c.totDuration = 1
    curses.cursesBySpellID[spellID] = c
    return c
end

function ERACombatWarlockCurse:noTarget()
    if (self.icon) then
        self.icon:Hide()
    end
end

function ERACombatWarlockCurse:prepareUpdate()
    self.remDuration = 0
    self.totDuration = 1
    self.maxDurationByPlayer = false
end

function ERACombatWarlockCurse:auraFound(t, stacks, durAura, expirationTime, sourceIsPlayer)
    local auraRemDuration
    if (expirationTime and expirationTime > 0) then
        auraRemDuration = expirationTime - t
    else
        auraRemDuration = 4096
    end
    if ((not durAura) or durAura < auraRemDuration) then
        durAura = auraRemDuration
    end
    if (not (stacks and stacks > 0)) then
        stacks = 1
    end
    if (auraRemDuration > self.remDuration) then
        self.remDuration = auraRemDuration
        self.totDuration = durAura
        self.maxDurationByPlayer = sourceIsPlayer
    elseif (sourceIsPlayer) then
        self.maxDurationByPlayer = false
    end
end

function ERACombatWarlockCurse:update(t, thisPlayerHasOneCurseActive, targetGUID)
    if (self.icon) then
        if (self.remDuration > 0) then
            self.icon:SetOverlayValue(self.remDuration / self.totDuration)
            self.icon:SetVertexColor(1, 1, 1, 1)
            self.icon:Show()
            local ti = self.curses.targetInfos[targetGUID]
            if (ti) then
                if (not ti[self]) then
                    ti[self] = t - (self.totDuration - self.remDuration)
                end
            else
                ti = {}
                self.curses.targetInfos[targetGUID] = ti
                ti[self] = t - (self.totDuration - self.remDuration)
            end
        else
            if (thisPlayerHasOneCurseActive) then
                self.icon:Hide()
            else
                local ti = self.curses.targetInfos[targetGUID]
                if (ti) then
                    local lastApplied = ti[self]
                    if (lastApplied and (t - lastApplied) < 1.5 * self.standardDuration) then
                        self.icon:SetOverlayValue(0)
                        self.icon:SetVertexColor(1, 0, 0, 1)
                        self.icon:Show()
                        return
                    end
                end
                self.icon:Hide()
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
---- AFFLI -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_WarlockAfflictionSetup(cFrame)
    local talent_nightfall = ERALIBTalent:Create(1, 1)
    local talent_drainsoul = ERALIBTalent:Create(1, 3)
    local talent_not_drainsoul = ERALIBTalent:CreateNotTalent(1, 3)
    local talent_big_agony = ERALIBTalent:Create(2, 1)
    local talent_eternal_corruption = ERALIBTalent:Create(2, 2)
    local talent_not_eternal_corruption = ERALIBTalent:CreateNotTalent(2, 2)
    local talent_leech = ERALIBTalent:Create(2, 3)
    local talent_fast_dots = ERALIBTalent:Create(7, 2)

    ERACombatPointsUnitPower:Create(cFrame, -155, -64, 7, 5, 0.1, 0.6, 0.1, 1.0, 0.0, 1.0, nil, 1).idlePoints = 3

    local timers = ERACombatTimersGroup:Create(cFrame, -121, -32, 1.5, 1)

    timers:AddChannelInfo(198590, 1)

    local drainLifeBuff = timers:AddAuraIcon(timers:AddTrackedBuff(334320, ERALIBTalent:Create(1, 2)), 0, 0)
    function drainLifeBuff:ShouldShowWhenAbsent()
        return false
    end
    timers:AddCooldownIcon(timers:AddTrackedCooldown(48181, ERALIBTalent:Create(6, 2)), nil, 0, 2, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(205179, ERALIBTalent:Create(4, 2)), nil, 0, 1, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(278350, ERALIBTalent:Create(4, 3)), nil, 0, 1, true, true)
    timers:AddKick(19647, 1, 0, nil, true)

    local corruptionTimerForEternal = timers:AddTrackedDebuff(146739, talent_eternal_corruption)
    timers:AddMissingAura(corruptionTimerForEternal, 136118, 0, 2, true)

    local remember_default_bar_size = ERACombat_TimerBarDefaultSize
    ERACombat_TimerBarDefaultSize = 16

    local lvl = UnitLevel("player")

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        1,
        function(tracker)
            if (talent_drainsoul:PlayerHasTalent()) then
                if (UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") < 0.2) then
                    return 0.84375
                else
                    return 0.421875
                end
            else
                return 0.25875
            end
        end
    )

    local unstableDuration
    local unstableDurationFast
    local unstableDamage
    if (lvl >= 56) then
        unstableDuration = 21
        unstableDurationFast = 17.85
        unstableDamage = 2.415
    else
        unstableDuration = 16
        unstableDurationFast = 13.6
        unstableDamage = 1.84
    end
    dotracker:AddDOT(
        316099,
        nil,
        0.9,
        0.9,
        0.2,
        1.5,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return unstableDurationFast
            else
                return unstableDuration
            end
        end,
        function(dotDef, currentTarget)
            return 0, unstableDamage
        end,
        nil,
        true,
        0.5,
        0.5,
        0.1
    )

    local corruptionInstantDamage
    if (lvl >= 54) then
        corruptionInstantDamage = 0.12
    else
        corruptionInstantDamage = 0
    end
    dotracker:AddDOT(
        146739,
        nil,
        0.9,
        0.2,
        0.2,
        0,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return 11.9
            else
                return 14
            end
        end,
        function(dotDef, currentTarget)
            return corruptionInstantDamage, 0.7875
        end,
        talent_not_eternal_corruption
    )

    dotracker:AddDOT(
        980,
        nil,
        0.9,
        0.5,
        0.1,
        0,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return 15.3
            else
                return 18
            end
        end,
        function(dotDef, currentTarget)
            if (talent_big_agony:PlayerHasTalent()) then
                return 0, 1.8144
            else
                return 0, 1.008
            end
        end
    )

    dotracker:AddDOT(
        63106,
        nil,
        0.0,
        0.7,
        0.0,
        0,
        function(dotDef, hasteMod)
            if (talent_fast_dots:PlayerHasTalent()) then
                return 12.75
            else
                return 15
            end
        end,
        function(dotDef, currentTarget)
            return 0, 0.82
        end,
        talent_leech
    )

    ERACombat_TimerBarDefaultSize = remember_default_bar_size

    local utility = ERACombatFrames_WarlockUtilityAndCovenant(cFrame, timers, 0, -188, 1)
    utility:AddCooldown(-1, 0, 205180, nil, true, ERALIBTalent:CreateLevel(42)) -- gazer
    utility:AddCooldown(-2, 0, 113860, nil, true, ERALIBTalent:Create(7, 3)) -- dark soul
    utility:AddTrinket1Cooldown(-3, 0)
    utility:AddTrinket2Cooldown(-4, 0)

    ERACombatFrames_WarlockRapture:create(cFrame, dotracker, talent_eternal_corruption)

    ERACombatWarlockCurses:create(cFrame, -300, -128, timers, 1)
end

ERACombatFrames_WarlockRapture = {}
ERACombatFrames_WarlockRapture.__index = ERACombatFrames_WarlockRapture
setmetatable(ERACombatFrames_WarlockRapture, {__index = ERACombatFrames_PseudoResourceBar})

function ERACombatFrames_WarlockRapture:create(cFrame, dotracker, eternalTalent)
    local ig = {}
    setmetatable(ig, ERACombatFrames_WarlockRapture)
    ig:constructPseudoResource(cFrame, -101, -88, 77, 20, 2, 1)

    ig.dotracker = dotracker
    ig.eternalTalent = eternalTalent

    return ig
end

function ERACombatFrames_WarlockRapture:GetMax(t)
    return 9
end
function ERACombatFrames_WarlockRapture:GetValue(t)
    local cpt = 0
    for _, d in pairs(self.dotracker.activeDOTsByID) do
        for _, i in ipairs(d.instances) do
            if (i.remDuration >= 1.5) then
                cpt = cpt + 1
            end
        end
    end
    if (self.eternalTalent:PlayerHasTalent()) then
        for _, e in pairs(self.dotracker.enemiesTracker.enemiesByGUID) do
            for i = 1, 40 do
                local _, _, _, _, _, expirationTime, _, _, _, spellID = UnitDebuff(e.plateID, i, "PLAYER")
                if (spellID) then
                    if (spellID == 146739) then
                        cpt = cpt + 1
                        break
                    end
                else
                    break
                end
            end
        end
    end
    return cpt
end

------------------------------------------------------------------------------------------------------------------------
---- DEMO --------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_WarlockDemonologySetup(cFrame)
    ERACombatPointsUnitPower:Create(cFrame, -188, -64, 7, 5, 0.1, 0.6, 0.1, 1.0, 0.0, 1.0, nil, 2).idlePoints = 3

    local timers = ERACombatTimersGroup:Create(cFrame, -121, -32, 1.5, 2)

    local doomTimer = timers:AddTrackedDebuff(603, ERALIBTalent:Create(2, 3))
    local doomDisplay = timers:AddAuraIcon(doomTimer, 0, 3, 1397641, nil)
    function doomDisplay:IconUpdatedAndShown()
        self.icon:SetVertexColor(1, 1, 1, 1)
    end
    function doomDisplay:ShouldShowWhenAbsent()
        self.icon:SetVertexColor(1, 0, 0, 1)
        return true
    end

    timers:AddCooldownIcon(timers:AddTrackedCooldown(264130, ERALIBTalent:Create(2, 2)), nil, 0, 3, true, true) -- sacrifice imp

    timers:AddCooldownIcon(timers:AddTrackedCooldown(264057, ERALIBTalent:Create(4, 2)), nil, 0, 2, true, true) -- guard soul strike
    timers:AddCooldownIcon(timers:AddTrackedCooldown(264119, ERALIBTalent:Create(4, 3)), nil, 0, 2, true, true) -- summon yet another demon

    timers:AddCooldownIcon(timers:AddTrackedCooldown(104316, ERALIBTalent:CreateLevel(13)), nil, 0, 1, true, true) -- fel hunters

    timers:AddCooldownIcon(timers:AddTrackedCooldown(267211, ERALIBTalent:Create(1, 2)), nil, -0.7, 0.3, true, true) -- aoe bats
    timers:AddCooldownIcon(timers:AddTrackedCooldown(267171, ERALIBTalent:Create(1, 3)), nil, -0.7, 0.3, true, true) -- kill command

    local instantBoldDisplay = timers:AddAuraIcon(timers:AddTrackedBuff(264173), 0.2, 0, nil, nil)
    function instantBoldDisplay:ShouldShowWhenAbsent()
        return false
    end

    timers:AddKick(19647, 1, 0, nil, true)

    ERACombatFrames_WarlockDemonologyImps:create(cFrame, -131, -88)

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        2,
        function(tracker)
            -- 1 shadow bolt + 1/3 guldan
            -- dmg : 0.345 + enemies * 0.176
            -- incantation : 2 + 1/3 * 1.5 (1.5/2.5 = 0.6)
            return (0.345 + 0.176 * tracker.enemiesTracker:GetEnemiesCount()) * 0.6
        end
    )
    dotracker:AddDOT( -- corruption
        146739,
        nil,
        0.9,
        0.2,
        0.2,
        2,
        function(dotDef, hasteMod)
            return 14
        end,
        function(dotDef, currentTarget)
            -- 78.75%SP * 1.5/2
            return 0, 0.590625
        end
    )

    local utility = ERACombatFrames_WarlockUtilityAndCovenant(cFrame, timers, 16, -202, 2)
    utility:AddCooldown(-1, 0, 265187, nil, true, ERALIBTalent:CreateLevel(42)) -- tyrant
    utility:AddCooldown(-2, 0, 111898, nil, true, ERALIBTalent:Create(6, 3)) -- big guard
    utility:AddCooldown(-3, 0, 267217, nil, true, ERALIBTalent:Create(7, 3)) -- demon portal
    utility:AddCooldown(1, -1, 89766, nil, true).showOnlyIfPetSpellKnown = true -- stun guard
    utility:AddTrinket1Cooldown(-1.5, 0.9)
    utility:AddTrinket2Cooldown(-4, 0)

    ERACombatWarlockCurses:create(cFrame, -300, -128, timers, 2)
end

ERACombatFrames_WarlockDemonologyImps = {}
ERACombatFrames_WarlockDemonologyImps.__index = ERACombatFrames_WarlockDemonologyImps
setmetatable(ERACombatFrames_WarlockDemonologyImps, {__index = ERACombatFrames_PseudoResourceBar})

function ERACombatFrames_WarlockDemonologyImps:create(cFrame, x, y)
    local imps = {}
    setmetatable(imps, ERACombatFrames_WarlockDemonologyImps)
    imps:constructPseudoResource(cFrame, x, y, 100, 20, 2, 2)

    imps:updateSlot()

    return imps
end
function ERACombatFrames_WarlockDemonologyImps:OnResetToIdle()
    self:updateSlot()
end
function ERACombatFrames_WarlockDemonologyImps:updateSlot()
    self.slot = -1
    for s = 1, 72 do
        actionType, id = GetActionInfo(s)
        if (actionType == "spell" and id == 196277) then
            self.slot = s
            break
        end
    end
end

function ERACombatFrames_WarlockDemonologyImps:GetMax(t)
    return 9
end
function ERACombatFrames_WarlockDemonologyImps:GetValue(t)
    if (self.slot and self.slot > 0) then
        return GetActionCount(self.slot)
    else
        return 0
    end
end

------------------------------------------------------------------------------------------------------------------------
---- DESTRU ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_WarlockDestructionSetup(cFrame)
    local embers = ERACombatWarlockDestruEmbers:create(cFrame)

    local timers = ERACombatTimersGroup:Create(cFrame, -121, -32, 1.5, 3)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(17877, ERALIBTalent:Create(2, 3)), nil, 0, 3, true, true) -- shadowburn
    timers:AddCooldownIcon(timers:AddTrackedCooldown(17962, ERALIBTalent:CreateLevel(13)), nil, 0, 2, true, true) -- conflag
    timers:AddCooldownIcon(timers:AddTrackedCooldown(80240, ERALIBTalent:CreateLevel(27)), nil, 0, 1, true, true) -- double tap
    timers:AddCooldownIcon(timers:AddTrackedCooldown(152108, ERALIBTalent:Create(4, 3)), nil, -0.8, 0.5, true, true) -- cata
    timers:AddCooldownIcon(timers:AddTrackedCooldown(196447, ERALIBTalent:Create(7, 2)), nil, -0.8, -0.5, true, true) -- demon fire
    timers:AddCooldownIcon(timers:AddTrackedCooldown(6353, ERALIBTalent:Create(1, 3)), nil, 0, 0, true, true) -- soulfire
    timers:AddKick(19647, 0.8, 0.5, nil, true)

    local backdraftTimer = timers:AddTrackedBuff(117828)

    ERACombatWarlockDestruHavocBar:create(timers, embers, backdraftTimer)

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        3,
        function(tracker)
            return 0.48075
        end
    )

    dotracker:AddDOT(
        157736,
        nil,
        0.9,
        0.7,
        0.0,
        1.5,
        function(dotDef, hasteMod)
            return 18
        end,
        function(dotDef, currentTarget)
            return 0.4, 1.5
        end
    )
    dotracker:AddDOT( -- corruption
        146739,
        nil,
        0.9,
        0.2,
        0.2,
        2,
        function(dotDef, hasteMod)
            return 14
        end,
        function(dotDef, currentTarget)
            -- 78.75%SP * 1.5/2
            return 0, 0.590625
        end
    )

    local utility = ERACombatFrames_WarlockUtilityAndCovenant(cFrame, timers, 32, -188, 3)
    utility:AddCooldown(-1, 0, 1122, nil, true, ERALIBTalent:CreateLevel(42)) -- infernal
    utility:AddCooldown(-2, 0, 113858, nil, true, ERALIBTalent:Create(7, 3)) -- dark soul
    utility:AddTrinket1Cooldown(-3, 0)
    utility:AddTrinket2Cooldown(-4, 0)

    ERACombatWarlockCurses:create(cFrame, -300, -128, timers, 3)
end

ERACombatWarlockDestruHavocBar = {}
ERACombatWarlockDestruHavocBar.__index = ERACombatWarlockDestruHavocBar
setmetatable(ERACombatWarlockDestruHavocBar, {__index = ERACombatTimerStatusBar})

function ERACombatWarlockDestruHavocBar:create(timers, embers, backdraftTimer)
    local bar = {}
    setmetatable(bar, ERACombatWarlockDestruHavocBar)
    bar.embers = embers
    bar.backdraftTimer = backdraftTimer
    bar:construct(timers, 460695, 0.8, 0.4, 0.3, "Interface\\TargetingFrame\\UI-StatusBar-Glow")
    bar.chaosBoltOK = true
    if (UnitLevel("player") >= 54) then
        bar.havocTotalDuration = 12
    else
        bar.havocTotalDuration = 10
    end
    return bar
end

function ERACombatWarlockDestruHavocBar:checkTalentsOrHide()
    return true
end

function ERACombatWarlockDestruHavocBar:GetRemDurationOr0IfInvisible(t)
    local rem = self.havocTotalDuration - (t - self.embers.lastHavoc)
    if (rem > 0) then
        local remCastOrGCD = math.max(self.group.remCast, self.group.remGCD)
        local chaosBoltCast
        if (self.backdraftTimer.remDuration > remCastOrGCD + 0.1) then
            chaosBoltCast = 3 / (1 + GetHaste() / 100)
        else
            chaosBoltCast = 0.7 * 3 / (1 + GetHaste() / 100)
        end
        if (rem > 0.2 + remCastOrGCD + chaosBoltCast) then
            self.view:SetColor(0.8, 0.4, 0.3)
        else
            self.view:SetColor(0.5, 0.4, 0.3)
        end
        return rem
    else
        return 0
    end
end

ERACombatWarlockDestruEmbers_EmberSize = 44
ERACombatWarlockDestruEmbers_EmberHalfSize = ERACombatWarlockDestruEmbers_EmberSize / 2
ERACombatWarlockDestruEmbers_EmberOverlayAlpha = 0.8

ERACombatWarlockDestruEmbers = {}
ERACombatWarlockDestruEmbers.__index = ERACombatWarlockDestruEmbers
setmetatable(ERACombatWarlockDestruEmbers, {__index = ERACombatModule})

function ERACombatWarlockDestruEmbers:create(cFrame)
    local e = {}
    setmetatable(e, ERACombatWarlockDestruEmbers)
    e:construct(cFrame, 0.5, 0.1, true, 3)

    e.frame = CreateFrame("Frame", nil, UIParent, nil)
    e.frame:SetSize(ERACombatWarlockDestruEmbers_EmberSize * 5, ERACombatWarlockDestruEmbers_EmberSize)
    e.frame:SetPoint("TOPRIGHT", UIParent, "CENTER", -144, -55)
    e.embers = {}
    for i = 1, 5 do
        table.insert(e.embers, ERACombatWarlockDestruEmber:create(e, i))
    end

    e.events = {}
    function e.events:UNIT_POWER_FREQUENT(unitID)
        if (unitID == "player") then
            e:updateEmbers()
        end
    end
    e.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            group.events[event](self, ...)
        end
    )

    e.embersValue = -1
    e.idleStable = -1

    e.playerGUID = UnitGUID("player")
    e.lastHavoc = 0

    e.frame:Hide()
    return e
end

function ERACombatWarlockDestruEmbers:CLEU(t)
    local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if (evt == "SPELL_AURA_APPLIED" and sourceGUY == self.playerGUID and spellID == 80240) then
        self.lastHavoc = t
    end
end

function ERACombatWarlockDestruEmbers:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatWarlockDestruEmbers:EnterIdle(fromCombat)
    self.frame:Show()
    self.idleStable = -1
end
function ERACombatWarlockDestruEmbers:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERACombatWarlockDestruEmbers:EnterVehicle(fromCombat)
    self.frame:Hide()
end
function ERACombatWarlockDestruEmbers:ExitVehicle(toCombat)
    self.frame:Show()
end
function ERACombatWarlockDestruEmbers:ResetToIdle()
    self.frame:Show()
end

function ERACombatWarlockDestruEmbers:UpdateIdle(t)
    local e = UnitPower("player", 7, true)
    if (e == 30) then
        if (self.idleStable > 0) then
            if (t - self.idleStable > 10) then
                self.idleStable = 0
                self.frame:Hide()
                return
            end
        else
            self.idleStable = t
        end
        self:updateEmbersWithInfo(e)
    else
        if (self.idleStable <= 0) then
            self.frame:Show()
        end
        self:updateEmbersWithInfo(e)
    end
end
function ERACombatWarlockDestruEmbers:UpdateCombat(t)
    self:updateEmbers()
end
function ERACombatWarlockDestruEmbers:updateEmbers()
    self:updateEmbersWithInfo(UnitPower("player", 7, true))
end
function ERACombatWarlockDestruEmbers:updateEmbersWithInfo(e)
    if (self.embersValue ~= e) then
        self.embersValue = e
        local whole = math.floor(e / 10)
        local fragments = e - whole * 10
        local e
        for i = 1, whole do
            e = self.embers[i]
            e:SetOverlayValue(0)
            e.ember:Show()
            e.ember:SetVertexColor(1.0, 0.0, 0.0, 1.0)
            e.text:SetText(nil)
        end
        if (whole < 5) then
            local emptyStart
            if (fragments > 0) then
                e = self.embers[whole + 1]
                e:SetOverlayValue(1 - fragments / 10)
                e.ember:Show()
                e.ember:SetVertexColor(0.7, 0.5, 0.0, 1.0)
                e.text:SetText(fragments)
                emptyStart = whole + 2
            else
                emptyStart = whole + 1
            end
            for i = emptyStart, 5 do
                e = self.embers[i]
                e:SetOverlayValue(0)
                e.ember:Hide()
                e.text:SetText(nil)
            end
        end
    end
end

ERACombatWarlockDestruEmber = {}
ERACombatWarlockDestruEmber.__index = ERACombatWarlockDestruEmber

function ERACombatWarlockDestruEmber:create(group, i)
    local e = {}
    setmetatable(e, ERACombatWarlockDestruEmber)

    e.frame = CreateFrame("Frame", nil, group.frame, "ERAWarlockEmberFrame")
    e.frame:SetSize(ERACombatWarlockDestruEmbers_EmberSize, ERACombatWarlockDestruEmbers_EmberSize)
    e.frame:SetPoint("TOPLEFT", group.frame, "TOPLEFT", (i - 1) * ERACombatWarlockDestruEmbers_EmberSize, 0)

    e.ember = e.frame.Ember
    e.text = e.frame.Text
    ERALIB_SetFont(e.text, 16)

    e.trt = e.frame.TRT
    e.trr = e.frame.TRR
    e.tlt = e.frame.TLT
    e.tlr = e.frame.TLR
    e.blr = e.frame.BLR
    e.blt = e.frame.BLT
    e.brt = e.frame.BRT
    e.brr = e.frame.BRR
    e.rec = {}
    table.insert(e.rec, e.tlr)
    table.insert(e.rec, e.trr)
    table.insert(e.rec, e.brr)
    table.insert(e.rec, e.blr)
    for i, r in ipairs(e.rec) do
        r:SetColorTexture(0, 0, 0, ERACombatWarlockDestruEmbers_EmberOverlayAlpha)
        r:Hide()
    end
    e.tri = {}
    table.insert(e.tri, e.tlt)
    table.insert(e.tri, e.trt)
    table.insert(e.tri, e.brt)
    table.insert(e.tri, e.blt)
    for i, t in ipairs(e.tri) do
        t:SetVertexColor(0, 0, 0, ERACombatWarlockDestruEmbers_EmberOverlayAlpha)
        t:Hide()
    end
    e.oClear = true
    e.quadrant = 0

    return e
end

function ERACombatWarlockDestruEmber_calcPosition(p, halfSize, straight)
    if (straight) then
        return halfSize * math.tan(2 * p * 3.1416)
    else
        return halfSize * (1 - math.tan((1 - 8 * p) * 3.1416 / 4))
    end
end

function ERACombatWarlockDestruEmber:SetOverlayValue(value)
    local halfSize = ERACombatWarlockDestruEmbers_EmberHalfSize
    if ((not value) or value <= 0) then
        if (not self.oClear) then
            self.oClear = true
            self.quadrant = 0
            for i, t in ipairs(self.tri) do
                t:Hide()
            end
            for i, r in ipairs(self.rec) do
                r:Hide()
            end
        end
    elseif (value >= 1) then
        self.oClear = false
        self.quadrant = 0
        for i, t in ipairs(self.tri) do
            t:Hide()
        end
        for i, r in ipairs(self.rec) do
            r:Show()
        end
        self.trr:SetWidth(halfSize)
        self.brr:SetHeight(halfSize)
        self.blr:SetWidth(halfSize)
        self.tlr:SetHeight(halfSize)
    else
        self.oClear = false
        if (value <= 0.125) then
            if (self.quadrant ~= 1) then
                self.quadrant = 1
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Hide()
                self.tlr:Hide()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Show()
            end
            self.tlt:SetPoint("TOPLEFT", self.frame, "TOP", -ERACombatWarlockDestruEmber_calcPosition(value, halfSize, true), 0)
        elseif (value <= 0.25) then
            if (self.quadrant ~= 2) then
                self.quadrant = 2
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Hide()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Show()
            end
            local h = ERACombatWarlockDestruEmber_calcPosition(value - 0.125, halfSize, false)
            self.tlt:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -h)
            self.tlr:SetHeight(h)
        elseif (value <= 0.375) then
            if (self.quadrant ~= 3) then
                self.quadrant = 3
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Hide()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Show()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blt:SetPoint("BOTTOMLEFT", self.frame, "LEFT", 0, -ERACombatWarlockDestruEmber_calcPosition(value - 0.25, halfSize, true))
        elseif (value <= 0.5) then
            if (self.quadrant ~= 4) then
                self.quadrant = 4
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Hide()
                self.blt:Show()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            local w = ERACombatWarlockDestruEmber_calcPosition(value - 0.375, halfSize, false)
            self.blt:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", w, 0)
            self.blr:SetWidth(w)
        elseif (value <= 0.625) then
            if (self.quadrant ~= 5) then
                self.quadrant = 5
                self.trr:Hide()
                self.brr:Hide()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Show()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            self.brt:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOM", ERACombatWarlockDestruEmber_calcPosition(value - 0.5, halfSize, true), 0)
        elseif (value <= 0.75) then
            if (self.quadrant ~= 6) then
                self.quadrant = 6
                self.trr:Hide()
                self.brr:Show()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Hide()
                self.brt:Show()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            local h = ERACombatWarlockDestruEmber_calcPosition(value - 0.625, halfSize, false)
            self.brr:SetHeight(h)
            self.brt:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, h)
        elseif (value <= 0.875) then
            if (self.quadrant ~= 7) then
                self.quadrant = 7
                self.trr:Hide()
                self.brr:Show()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Show()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            self.brr:SetHeight(halfSize)
            self.trt:SetPoint("TOPRIGHT", self.frame, "RIGHT", 0, ERACombatWarlockDestruEmber_calcPosition(value - 0.75, halfSize, true))
        else
            if (self.quadrant ~= 8) then
                self.quadrant = 8
                self.trr:Show()
                self.brr:Show()
                self.blr:Show()
                self.tlr:Show()
                self.trt:Show()
                self.brt:Hide()
                self.blt:Hide()
                self.tlt:Hide()
            end
            self.tlr:SetHeight(halfSize)
            self.blr:SetWidth(halfSize)
            self.brr:SetHeight(halfSize)
            local w = ERACombatWarlockDestruEmber_calcPosition(value - 0.875, halfSize, false)
            self.trr:SetWidth(w)
            self.trt:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -w, 0)
        end
    end
end
