-- TODO
-- vérifier les 40% du rang 2 attaque du raptor
-- vérifier la position de AddRacial

function ERACombatFrames_HunterSetup(cFrame)
    ERACombatGlobals_SpecID1 = 253
    ERACombatGlobals_SpecID2 = 254
    ERACombatGlobals_SpecID3 = 255

    ERAPieIcon_BorderR = 0.0
    ERAPieIcon_BorderG = 0.7
    ERAPieIcon_BorderB = 0.2

    local bmActive = ERACombatOptions_IsSpecActive(1)
    local mmActive = ERACombatOptions_IsSpecActive(2)
    local svActive = ERACombatOptions_IsSpecActive(3)

    ERAOutOfCombatStatusBars:Create(cFrame, 123, -32, 128, 22, 2, true, 1.0, 0.7, 0.0, true, bmActive, mmActive, svActive)

    ERACombatHealth:Create(cFrame, 131, -64, 123, 22, bmActive, mmActive, svActive)
    ERACombatHealth:Create(cFrame, 131, -88, 123, 22, bmActive, mmActive, svActive):SetUnitID("pet")

    if (bmActive) then
        ERACombatFrames_HunterBeastMasterySetup(cFrame)
    end
    if (mmActive) then
        ERACombatFrames_HunterMarksmanshipSetup(cFrame)
    end
    if (svActive) then
        ERACombatFrames_HunterSurvivalSetup(cFrame)
    end

    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- BEAST MASTERY -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_HunterBeastMasterySetup(cFrame)
    local talent_crows = ERALIBTalent:Create(4, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -123, 0, 1.5, 1)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(53209, ERALIBTalent:Create(2, 3)), nil, 0, 3, true, true) -- chimera
    ERACombatFrames_Hunter_KillShot(timers, 0, 2)
    local bleedShotTimer = timers:AddTrackedCooldown(217200, ERALIBTalent:CreateLevel(12))
    timers:AddCooldownIcon(bleedShotTimer, nil, 0, 1, true, true) -- bleed shot
    timers:AddCooldownIcon(timers:AddTrackedCooldown(34026), nil, 0, 0, true, true) -- odt
    timers:AddCooldownIcon(timers:AddTrackedCooldown(120360, ERALIBTalent:Create(6, 2)), nil, 0, -1, true, true) -- barrage
    timers:AddCooldownIcon(timers:AddTrackedCooldown(120679, ERALIBTalent:Create(1, 3)), nil, -0.8, -1.6, true, true) -- wild beast
    timers:AddCooldownIcon(timers:AddTrackedCooldown(321530, ERALIBTalent:Create(7, 3)), nil, -1.7, -1.7, true, true) -- blood bath
    timers:AddKick(147362, 0.9, 0.5, ERALIBTalent:CreateLevel(18))
    timers:AddOffensiveDispellCooldown(19801, 0.9, -0.5, ERALIBTalent:CreateLevel(37), "Magic", "Enrage")
    ERACombatFrames_Hunter_petTranqs(timers, 0.9, -1.5)

    ERACombatFrames_HunterCrows:create(cFrame, nil, 1, talent_crows, -123, -88)

    timers:AddAuraBar(timers:AddTrackedBuff(19574), nil, 0.8, 0.5, 0.1) -- wrath
    timers:AddAuraBar(timers:AddTrackedBuff(193530), nil, 0.0, 1.0, 0.4) -- nature
    ERACombatFrames_HunterBMBleedFrenzyBar:create(timers, bleedShotTimer)

    timers:AddAuraBar(timers:AddTrackedBuff(268877), nil, 0.5, 0.6, 0.7) -- beast cleave

    local utility = ERACombatFrames_Hunter_common_tricks(cFrame, 1, ERALIBTalent:Create(5, 3))
    utility:AddCooldown(1.5, 1.8, 5116, nil, true, ERALIBTalent:CreateLevel(13)) -- daze shot
    utility:AddCooldown(2, -1, 19577, nil, true, ERALIBTalent:CreateLevel(33)) -- stun beast
    local spiritHeal = utility:AddCooldown(1.5, 0.8, 90361, nil, true)
    function spiritHeal:IconUpdatedAndShown(t)
        if (not IsSpellKnown(90361, true)) then
            self.icon:Hide()
        end
    end

    local burstUtility = ERACombatUtilityFrame:Create(cFrame, -188, -100, 1)
    burstUtility:AddCooldown(0, 0, 19574, nil, true, ERALIBTalent:CreateLevel(20)) -- wrath
    burstUtility:AddCooldown(-1, 0, 193530, nil, true, ERALIBTalent:CreateLevel(38)) -- nature
    burstUtility:AddCooldown(-2, 0, 201430, nil, true, ERALIBTalent:Create(6, 3)) -- stampede
    burstUtility:AddCovenantClassAbility(-0.5, -0.9, 308491, 324149, 328231, 325028)
    burstUtility:AddTrinket1Cooldown(-1.5, -0.9)
    burstUtility:AddTrinket2Cooldown(-2.5, -0.9)

    local pullUtility = ERACombatUtilityFrame:Create(cFrame, 0, 128, 1)
    pullUtility:AddCooldown(0, 0, 217200, nil, false, ERALIBTalent:CreateLevel(12))
    ERACombatFrames_Hunter_pullCrowsUtility(pullUtility, talent_crows)

    local focus = ERACombatPower:Create(cFrame, -200, -28, 200, 22, 2, false, 1.0, 0.7, 0.0, 1)
    focus.bar:SetBorderColor(0.2, 1.0, 0.2)
    focus:AddConsumer(65, 461114)
end

ERACombatFrames_HunterBMBleedFrenzyBar = {}
ERACombatFrames_HunterBMBleedFrenzyBar.__index = ERACombatFrames_HunterBMBleedFrenzyBar
setmetatable(ERACombatFrames_HunterBMBleedFrenzyBar, {__index = ERACombatTimerStatusBar})

function ERACombatFrames_HunterBMBleedFrenzyBar:create(timers, bleedShotTimer)
    local fb = {}
    setmetatable(fb, ERACombatFrames_HunterBMBleedFrenzyBar)
    fb:construct(timers, 2058007, 1.0, 0.0, 0.0, "Interface\\Buttons\\WHITE8x8")
    fb.bleedShotTimer = bleedShotTimer
    return fb
end

function ERACombatFrames_HunterBMBleedFrenzyBar:checkTalentsOrHide()
    return true
end

function ERACombatFrames_HunterBMBleedFrenzyBar:GetRemDurationOr0IfInvisible(t)
    for i = 1, 40 do
        local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitBuff("pet", i)
        if (spellID) then
            if (spellID == 272790) then
                local auraRemDuration
                if (expirationTime and expirationTime > 0) then
                    auraRemDuration = expirationTime - t
                else
                    auraRemDuration = 0
                end
                if (not (stacks and stacks > 0)) then
                    stacks = 1
                end
                self.view:SetText(stacks)
                if (self.bleedShotTimer.currentCharges > 0 or self.bleedShotTimer.remDuration + 0.3 < auraRemDuration) then
                    self.view:SetColor(1.0, 0.0, 0.0)
                else
                    self.view:SetColor(0.6, 0.5, 0.5)
                end
                return auraRemDuration
            end
        else
            break
        end
    end
    return 0
end

------------------------------------------------------------------------------------------------------------------------
---- MARKSMANSHIP ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_HunterMarksmanshipSetup(cFrame)
    local talent_crows = ERALIBTalent:Create(1, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -123, 0, 1.5, 2)

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        2,
        function(tracker)
            -- 1 tir assuré donne 2/3 de tir des arcanes
            -- (0.6 (steady shot) * 0.7 (armure) + (2/3)*0.6) / (1.75/1.5+(2/3)*1)
            return 0.447
        end
    )
    local stingDOT =
        dotracker:AddDOT(
        259491,
        nil,
        0.0,
        0.8,
        0.2,
        0,
        function(dotDef, hasteMod)
            return 18
        end,
        function(dotDef, currentTarget)
            return 0.165, 0.99
        end,
        ERALIBTalent:Create(1, 2)
    )

    ERACombatFrames_Hunter_KillShot(timers, 0, 3)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(19434), nil, 0, 2, true, true) -- aimed shot
    timers:AddCooldownIcon(timers:AddTrackedCooldown(257044, ERALIBTalent:CreateLevel(20)), nil, 0, 1, true, true) -- quick shot
    timers:AddCooldownIcon(timers:AddTrackedCooldown(120360, ERALIBTalent:Create(2, 2)), nil, 0, 0, true, true) -- barrage
    timers:AddCooldownIcon(timers:AddTrackedCooldown(212431, ERALIBTalent:Create(2, 3)), nil, 0, 0, true, true) -- explosive
    timers:AddCooldownIcon(timers:AddTrackedCooldown(260402, ERALIBTalent:Create(6, 3)), nil, 0, -1, true, true) -- double tap
    timers:AddCooldownIcon(timers:AddTrackedCooldown(260243, ERALIBTalent:Create(7, 3)), nil, -0.8, -0.5, true, true) -- salvo

    timers:AddKick(147362, 0.9, 0.5, ERALIBTalent:CreateLevel(18))
    timers:AddOffensiveDispellCooldown(19801, 0.9, -0.5, ERALIBTalent:CreateLevel(37), "Magic", "Enrage")
    ERACombatFrames_Hunter_petTranqs(timers, 0.9, -1.5)

    ERACombatFrames_HunterCrows:create(cFrame, dotracker.enemiesTracker, 2, talent_crows, -166, -88)

    local focus = ERACombatPower:Create(cFrame, -200, -28, 200, 22, 2, false, 1.0, 0.7, 0.0, 2)
    focus.bar:SetBorderColor(0.2, 1.0, 0.2)
    focus:AddConsumer(35, 135130)
    focus:AddConsumer(15, 132218)

    local utility, healPet = ERACombatFrames_Hunter_common_tricks(cFrame, 2, nil)
    function healPet:IconUpdatedAndShown(t)
        if (not UnitExists("pet")) then
            self.icon:Hide()
        end
    end
    utility:AddCooldown(1.5, 1.8, 5116, nil, true, ERALIBTalent:CreateLevel(13)) -- daze shot
    utility:AddCooldown(2, -1, 186387, nil, true, ERALIBTalent:CreateLevel(12)) -- blast shot

    local burstUtility = ERACombatUtilityFrame:Create(cFrame, -234, -100, 2)
    burstUtility:AddCooldown(0, 0, 288613, nil, true, ERALIBTalent:CreateLevel(34)) -- precision
    burstUtility:AddCovenantClassAbility(0.5, -0.9, 308491, 324149, 328231, 325028)
    burstUtility:AddTrinket1Cooldown(-1, 0)
    burstUtility:AddTrinket2Cooldown(-0.5, -0.9)
end

------------------------------------------------------------------------------------------------------------------------
---- SURVIVAL ----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_HunterSurvivalSetup(cFrame)
    local talent_singlesting = ERALIBTalent:CreateNotTalent(2, 2)
    local talent_multisting = ERALIBTalent:Create(2, 2)
    local talent_crows = ERALIBTalent:Create(4, 3)
    local talent_mongoose = ERALIBTalent:Create(6, 2)

    local timers = ERACombatTimersGroup:Create(cFrame, -123, 0, 1.5, 3)

    local mongooseTimer = timers:AddTrackedBuff(259388, talent_mongoose)
    timers:AddAuraBar(mongooseTimer, nil, 1.0, 0.0, 1.0).showStacks = true

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        3,
        function(tracker)
            if (talent_mongoose:PlayerHasTalent()) then
                return 0.42 * (1 + 0.15 * mongooseTimer.stacks) -- 0.9 (90% AP) * 2/3 (mongoose 30, sting 20) * 0.7 (armure cible 30%)
            else
                return 0.47 -- 1 (100% AP) * 2/3 (raptor 30, sting 20) * 0.7 (armure cible 30%)
            end
        end
    )
    local stingDOT =
        dotracker:AddDOT(
        259491,
        nil,
        0.0,
        0.8,
        0.2,
        0,
        function(dotDef, hasteMod)
            return 12
        end,
        function(dotDef, currentTarget)
            return 0.2, 0.95
        end,
        talent_singlesting
    )
    local stingDOT_talent =
        dotracker:AddDOT(
        259491,
        nil,
        0.0,
        0.8,
        0.2,
        0,
        function(dotDef, hasteMod)
            return 12
        end,
        function(dotDef, currentTarget)
            return 0.2, 0.95 * 1.2, 2, true
        end,
        talent_multisting
    )

    ERACombatFrames_Hunter_KillShot(timers, 0, 3)

    local cleaveTimer = timers:AddTrackedCooldown(187708, ERALIBTalent:CreateNotTalent(2, 3))
    local cleaveTimerDisplay = timers:AddCooldownIcon(cleaveTimer, nil, 0, 2, true, true)
    function cleaveTimerDisplay:OverrideTimerVisibility()
        if (dotracker.enemiesTracker:GetEnemiesCount() > 2) then
            cleaveTimerDisplay.icon:SetAlpha(1.0)
            return true
        else
            cleaveTimerDisplay.icon:SetAlpha(0.3)
            return false
        end
    end
    timers:AddCooldownIcon(timers:AddTrackedCooldown(212436, ERALIBTalent:Create(2, 3, 23)), nil, 0, 2, true, true) -- cleave talent

    timers:AddCooldownIcon(timers:AddTrackedCooldown(259495, ERALIBTalent:CreateLevel(20)), nil, 0, 1, true, true) -- bombe
    timers:AddCooldownIcon(timers:AddTrackedCooldown(259489), nil, 0, 0, true, true, ERALIBTalent:CreateLevel(11)) -- odt
    timers:AddCooldownIcon(timers:AddTrackedCooldown(259391, ERALIBTalent:Create(7, 3)), nil, -0.8, 0.5, true, true) -- chakram
    timers:AddCooldownIcon(timers:AddTrackedCooldown(190925), nil, 0, -1, true, false, ERALIBTalent:CreateLevel(14)) -- harpon
    timers:AddCooldownIcon(timers:AddTrackedCooldown(162488, ERALIBTalent:Create(4, 2)), nil, -0.8, -0.5, true, false) -- steel trap
    timers:AddCooldownIcon(timers:AddTrackedCooldown(269751, ERALIBTalent:Create(6, 3)), nil, -0.8, -1.5, true, false)
    timers:AddKick(187707, 0.9, 0.5, ERALIBTalent:CreateLevel(18))
    timers:AddOffensiveDispellCooldown(19801, 0.9, -0.5, ERALIBTalent:CreateLevel(37), "Magic", "Enrage")
    ERACombatFrames_Hunter_petTranqs(timers, 0.9, -1.5)

    ERACombatFrames_HunterCrows:create(cFrame, dotracker.enemiesTracker, 3, talent_crows, -123, -88)

    timers:AddAuraBar(timers:AddTrackedBuff(266779), nil, 0.8, 0.5, 0.1)

    local utility = ERACombatFrames_Hunter_common_tricks(cFrame, 3, ERALIBTalent:Create(5, 3))
    utility:AddCooldown(2, -1, 19577, nil, true, ERALIBTalent:CreateLevel(33)) -- stun beast

    local burstUtility = ERACombatUtilityFrame:Create(cFrame, -188, -100, 3)
    burstUtility:AddCooldown(0, 0, 266779, nil, true, ERALIBTalent:CreateLevel(34)) -- assault
    burstUtility:AddCooldown(-1, 0, 186289, nil, true, ERALIBTalent:CreateLevel(24)) -- eagle aspect
    timers:AddAuraBar(timers:AddTrackedBuff(186289), nil, 1.0, 0.8, 0.7)
    burstUtility:AddCovenantClassAbility(-0.5, -0.9, 308491, 324149, 328231, 325028)
    burstUtility:AddTrinket1Cooldown(-2, 0)
    burstUtility:AddTrinket2Cooldown(-1.5, -0.9)

    local pullUtility = ERACombatUtilityFrame:Create(cFrame, 0, 128, 3)
    pullUtility:AddCooldown(0, 0, 190925, nil, false, ERALIBTalent:CreateLevel(14))
    ERACombatFrames_Hunter_pullCrowsUtility(pullUtility, talent_crows)

    local focus = ERACombatPower:Create(cFrame, -232, -28, 188, 22, 2, false, 1.0, 0.7, 0.0, 3)
    focus.bar:SetBorderColor(0.2, 1.0, 0.2)

    local raptorConsumerWhenSting = focus:AddConsumer(50, 1376046)
    --local raptorConsumerWhenCleave = focus:AddConsumer(65, 1376046)
    --local raptorConsumerWhenStingAndCleave = focus:AddConsumer(85, 1376046)

    function focus:PreUpdateCombat(t)
    end

    local stingConsumer = focus:AddConsumer(20, 1033905)
    function stingConsumer:ComputeVisibility()
        return stingDOT.isWorthRefreshing
    end
    function stingConsumer:ComputeIconVisibility()
        return stingDOT.isWorthRefreshing
    end
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_Hunter_KillShot(timers, x, y)
    local display = timers:AddCooldownIcon(timers:AddTrackedCooldown(53351, ERALIBTalent:CreateLevel(42)), nil, x, y, true, true)
    function display:ShouldShowMainIcon()
        self.killShotUsable = IsUsableSpell(53351)
        return self.killShotUsable
    end
    function display:OverrideTimerVisibility()
        return self.killShotUsable
    end
end
function ERACombatFrames_Hunter_pullCrowsUtility(utility, talent)
    utility:AddCooldown(-1, 0, 131894, nil, false, talent)
end

function ERACombatFrames_Hunter_common_tricks(cFrame, spec, tetherTalent)
    local utility = ERACombatUtilityFrame:Create(cFrame, 128, -144, spec)

    utility:AddCooldown(-1, 0, 186265, nil, true) -- turtle
    utility:AddCooldown(0, 0, 109304, nil, true) -- heal 30%
    local healPet = utility:AddCooldown(1, 0, 136, nil, true)
    utility:AddRacial(2, 0)
    utility:AddWarlockHealthStone(3, 0)
    utility:AddWarlockPortal(4, 0)
    utility:AddCooldown(-2, -1, 109248, nil, true, tetherTalent) -- tir de lien
    utility:AddCooldown(-1, -1, 781, nil, true) -- jump
    utility:AddCooldown(0, -1, 187650, nil, true) -- frost trap
    utility:AddCooldown(1, -1, 187698, nil, true, ERALIBTalent:CreateLevel(21)) -- tar trap
    utility:AddCooldown(-2, -2, 34477, nil, true, ERALIBTalent:CreateLevel(27)).alphaWhenOffCooldown = 0.4 -- misdirect
    utility:AddCooldown(-1, -2, 5384, nil, true).alphaWhenOffCooldown = 0.2 -- fd
    utility:AddCooldown(0, -2, 1543, nil, true, ERALIBTalent:CreateLevel(19)).alphaWhenOffCooldown = 0.2 -- fusée
    utility:AddCooldown(1, -2, 186257, nil, true) -- cheetah
    utility:AddCooldown(2, -2, 199483, nil, false, ERALIBTalent:Create(3, 3)) -- fufu

    local petCommand = utility:AddCooldown(-3, -1, 272678, 457329, true, ERALIBTalent:CreateLevel(22))
    function petCommand:IconUpdatedAndShown(t)
        if (not UnitExists("pet")) then
            self.icon:Hide()
        end
    end

    utility:AddCovenantGenericAbility(-4, -1)

    return utility, healPet
end

function ERACombatFrames_Hunter_petTranqs(timers, x, y)
    ERACombatFrames_Hunter_petTranq(timers, 344351, x, y)
end
function ERACombatFrames_Hunter_petTranq(timers, spellID, x, y)
    local display = timers:AddOffensiveDispellCooldown(spellID, x, y, nil, "Magic", "Enrage")
    function display:ShouldShowMainIcon()
        return IsSpellKnown(spellID, true)
    end
end

------------------------------------------------------------------------------------------------------------------------
---- CROWS -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatFrames_HunterCrows = {}
ERACombatFrames_HunterCrows.__index = ERACombatFrames_HunterCrows
setmetatable(ERACombatFrames_HunterCrows, ERACombatModule)

function ERACombatFrames_HunterCrows:create(cFrame, enemiesTracker, spec, talent, x, y)
    local c = {}
    setmetatable(c, ERACombatFrames_HunterCrows)
    c:construct(cFrame, -1, 0.2, true, spec)
    if (enemiesTracker) then
        c.enemiesTracker = enemiesTracker
    else
        c.enemiesTracker = ERACombatEnemiesTracker:Create(cFrame, -1, spec)
        c.updateEnemiesTracker = true
    end
    c.talent = talent
    c.icon = ERAPieIcon:Create(UIParent, "CENTER", 55, 645217)
    c.icon:Draw(x, y, false)
    c.icon:Hide()
    return c
end

function ERACombatFrames_HunterCrows:CheckTalents()
    if (not self.talent:PlayerHasTalent()) then
        self.icon:Hide()
    end
end
function ERACombatFrames_HunterCrows:SpecInactive(wasActive)
    self.icon:Hide()
end
function ERACombatFrames_HunterCrows:ResetToIdle()
    self.icon:Hide()
end
function ERACombatFrames_HunterCrows:EnterCombat(fromIdle)
    if (self.talent:PlayerHasTalent()) then
        self.icon:Show()
    end
end
function ERACombatFrames_HunterCrows:ExitCombat(toIdle)
    self.icon:Hide()
end

function ERACombatFrames_HunterCrows:UpdateCombat(t, elapsed)
    if (self.talent:PlayerHasTalent()) then
        if (self.updateEnemiesTracker) then
            self.enemiesTracker:updateEnemiesTracker(t)
        end
        local started, duration = GetSpellCooldown(131894)
        if (started and started > 0 and duration and duration > 2) then
            local remDur = duration - (t - started)
            self.icon:SetOverlayValue(remDur / duration)
            self.icon:SetDesaturated(remDur > 20)
            self.icon:SetMainText(math.floor(remDur))
            self.icon:SetMainTextColor(1.0, 1.0, 1.0, 1.0)
        else
            self.icon:SetOverlayValue(0)
            self.icon:SetDesaturated(false)
            local currentTarget = self.enemiesTracker.currentTarget
            if (currentTarget) then
                local expect = currentTarget.lifeExpectancy
                if (expect < 7) then
                    self.icon:SetMainText(math.floor(expect))
                    self.icon:SetMainTextColor(1.0, 1.0, 0.0, 1.0)
                elseif (expect < 13) then
                    self.icon:SetMainText(math.floor(expect))
                    self.icon:SetMainTextColor(0.0, 1.0, 0.0, 1.0)
                elseif (expect < 17) then
                    self.icon:SetMainText(math.floor(expect))
                    self.icon:SetMainTextColor(1.0, 1.0, 0.0, 1.0)
                else
                    self.icon:SetMainText(math.floor(expect))
                    for _, e in pairs(self.enemiesTracker.enemiesByGUID) do
                        if (7 <= e.lifeExpectancy and e.lifeExpectancy <= 15) then
                            self.icon:SetMainTextColor(1.0, 0.0, 0.0, 1.0)
                            return
                        end
                    end
                    self.icon:SetMainTextColor(1.0, 1.0, 1.0, 1.0)
                end
            else
                self.icon:SetMainText(nil)
            end
        end
    end
end
