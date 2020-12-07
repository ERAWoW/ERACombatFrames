-- TODO
-- taunt

-- constantes
ERADK_RuneSize = 32

function ERACombatFrames_DeathKnightSetup(cFrame)
    ERACombatGlobals_SpecID1 = 250
    ERACombatGlobals_SpecID2 = 251
    ERACombatGlobals_SpecID3 = 252

    local bloodActive = ERACombatOptions_IsSpecActive(1)
    local frostActive = ERACombatOptions_IsSpecActive(2)
    local unholyActive = ERACombatOptions_IsSpecActive(3)

    ERAOutOfCombatStatusBars:Create(cFrame, 32, -44, 128, 22, 6, false, 0.2, 0.7, 1.0, false, bloodActive, frostActive)
    local combatHealth = ERACombatHealth:Create(cFrame, -144, -77, 200, 22, bloodActive, frostActive, unholyActive)
    local runes = ERARunes:Create(cFrame, combatHealth, bloodActive, frostActive, unholyActive)

    local talent_venthyr = ERALIBTalent:CreateVenthyrOrSpellKnown(311648)
    local talent_nightfae = ERALIBTalent:CreateNightfaeOrSpellKnown(324128)
    local talent_not_nightfae = ERALIBTalent:CreateNot(talent_nightfae)

    if (bloodActive) then
        ERACombatFrames_DeathKnightBloodSetup(cFrame, combatHealth, runes, talent_venthyr, talent_nightfae, talent_not_nightfae)
    end
    if (frostActive) then
        ERACombatFrames_DeathKnightFrostSetup(cFrame, runes, talent_venthyr, talent_nightfae, talent_not_nightfae)
    end
    if (unholyActive) then
        ERACombatFrames_DeathKnightUnholySetup(cFrame, runes, talent_venthyr, talent_nightfae, talent_not_nightfae)
    end

    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- BLOOD -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DeathKnightBloodSetup(cFrame, combatHealth, runes, talent_venthyr, talent_nightfae, talent_not_nightfae)
    local talent_bloodmark = ERALIBTalent:Create(4, 3)

    local combatPower = ERACombatPower:Create(cFrame, -144, -22, 200, 12, 6, true, 0.2, 0.7, 1.0, 1)

    local timers = ERACombatTimersGroup:Create(cFrame, -111, 32, 1.5, 1)
    ERACombatFrames_DeathKnightSetupTimersAndRunes(timers, runes)

    ERACombatFrames_DeathKnightFaFDisease(timers, 55078, 0, 3.6, 17)

    local bloodmarkAura = timers:AddTrackedDebuff(206940, talent_bloodmark)
    timers:AddAuraBar(bloodmarkAura, nil, 1.0, 0.6, 0.6)
    local bloodmarkCD = timers:AddCooldownIcon(timers:AddTrackedCooldown(206940, talent_bloodmark), nil, 0, 1.6, false, true)
    function bloodmarkCD:ShouldShowMainIcon()
        if (bloodmarkAura.remDuration <= 3.5) then
            self.icon:SetAlpha(1.0)
        else
            self.icon:SetAlpha(0.4)
        end
        return true
    end

    local boneShieldAura = timers:AddTrackedBuff(195181)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(50842, ERALIBTalent:CreateLevel(17)), nil, 0, 0.6, true, true) -- boil
    timers:AddAuraIcon(boneShieldAura, -1, 0.6, 237272)
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 43265, runes, ERALIBTalent:CreateAnd(talent_not_nightfae, ERALIBTalent:CreateLevel(3))), nil, -2, 0.6, true, true) -- dnd
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 194679, runes, ERALIBTalent:CreateLevel(19)), nil, -3, 0.6, true, true) -- rune tap
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 206931, runes, ERALIBTalent:Create(1, 2)), nil, -4, 0.6, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(219809, ERALIBTalent:Create(1, 3)), nil, -4, 0.6, true, true)
    timers:AddKick(47528, 2, 0, ERALIBTalent:CreateLevel(7))

    local utility = ERACombatFrames_DeathKnightUtility(cFrame, 32, -144, 1, ERALIBTalent:Create(5, 3))
    utility:AddCooldown(2.5, 0.9, 221562, nil, true, ERALIBTalent:CreateLevel(21)) -- darth vader
    utility:AddCooldown(3.5, 2.9, 108199, nil, true, ERALIBTalent:CreateLevel(32)) -- mass grip

    local bloodUtility = ERACombatUtilityFrame:Create(cFrame, -234, -141, 1)
    bloodUtility:AddCooldown(2, 0, 274156, nil, true, ERALIBTalent:Create(2, 3))
    bloodUtility:AddCooldown(1, 0, 55233, nil, true, ERALIBTalent:CreateLevel(29)) -- vampiric
    bloodUtility:AddCooldown(0, 0, 49028, nil, true, ERALIBTalent:CreateLevel(34)) -- drw
    bloodUtility:AddCooldown(1.5, -0.8, 48743, nil, true, ERALIBTalent:Create(6, 2)) -- death pact
    bloodUtility:AddCooldown(0.5, -0.8, 327574, nil, true, ERALIBTalent:CreateLevel(54)) -- explode ghoul
    bloodUtility:AddCooldown(-0.5, -0.8, 46585, nil, true, ERALIBTalent:CreateLevel(12)) -- summon ghoul
    bloodUtility:AddCooldown(-0.6, 1, 221699, nil, true, ERALIBTalent:Create(3, 3)) -- blood tap
    bloodUtility:AddCooldown(-0.96, 0.1, 194844, nil, true, ERALIBTalent:Create(7, 3)) -- bone storm
    bloodUtility:AddTrinket1Cooldown(1, -1.6)
    bloodUtility:AddTrinket2Cooldown(0, -1.6)

    local deathStrikeConsumer45 = combatPower:AddConsumer(45, 237517)
    --[[
    local deathStrikeConsumer45_ossuary = combatPower:AddConsumer(45, 237517)
    function deathStrikeConsumer45_ossuary:ComputeVisibility()
        return boneShieldAura.stacks < 5
    end
    local deathStrikeConsumer40_ossuary = combatPower:AddConsumer(40, 237517)
    function deathStrikeConsumer40_ossuary:ComputeVisibility()
        return boneShieldAura.stacks >= 5
    end
    ]]
    local damageWindow = ERACombatTankWindow:Create(timers, 200, 1, 5, 0, 4, 300, ERACombatOptions_IsSpecModuleActive(1, ERACombatOptions_TankWindow))
    local talent_improved_ds = ERALIBTalent:Create(6, 1)
    function damageWindow:Updated(t)
        local min = combatHealth.maxHealth * 0.07
        local h
        if (talent_improved_ds:PlayerHasTalent()) then
            h = 0.3 * self.currentDamage
        else
            h = 0.25 * self.currentDamage
        end
        if (min <= h) then
            combatHealth:SetHealing(h)
        else
            combatHealth:SetHealing(0)
        end
    end

    ERACombatFrames_DeathKnightCovenant(timers, 0, 2.6, -2, 0.6, utility, 0.5, 0.9, runes, talent_venthyr, talent_nightfae)
end

------------------------------------------------------------------------------------------------------------------------
---- FROST -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DeathKnightFrostSetup(cFrame, runes, talent_venthyr, talent_nightfae, talent_not_nightfae)
    local talent_sindragosa = ERALIBTalent:Create(7, 3)
    local talent_glacial_advance = ERALIBTalent:Create(6, 3)
    local talent_not_glacial_advance = ERALIBTalent:CreateNotTalent(6, 3)
    local talent_icy_veins = ERALIBTalent:Create(6, 2)

    local combatPower = ERACombatPower:Create(cFrame, -144, -22, 200, 12, 6, true, 0.2, 0.7, 1.0, 2)
    combatPower:AddConsumer(25, 237520, talent_not_glacial_advance)
    combatPower:AddConsumer(30, 537514, talent_glacial_advance)
    combatPower:AddConsumer(55, 537514, talent_glacial_advance)

    local timers = ERACombatTimersGroup:Create(cFrame, -111, 32, 1.5, 2)
    ERACombatFrames_DeathKnightSetupTimersAndRunes(timers, runes)

    timers:AddProc(timers:AddTrackedBuff(101568), nil, 0, 3.6, false) -- succor
    ERACombatFrames_DeathKnightFaFDisease(timers, 55095, 0, 2.6, 10)
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 194913, runes, talent_glacial_advance), nil, 0, 0.6, true, true) -- glacial advance
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 321995, runes, talent_icy_veins), nil, 0, 0.6, true, true) -- icy veins
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 196770, runes, ERALIBTalent:CreateLevel(19)), nil, -1, 0.6, true, true) -- winter
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 43265, runes, ERALIBTalent:CreateAnd(talent_not_nightfae, ERALIBTalent:CreateLevel(3))), nil, -2, 0.6, true, true) -- dnd
    local frozenChainsDisplay = timers:AddAuraIcon(timers:AddTrackedBuff(281209, ERALIBTalent:Create(1, 3)), -3, 0.6, nil)
    function frozenChainsDisplay:IconUpdatedAndShown()
        self.icon:SetAlpha(math.ceil(self.aura.stacks / 5) / 5)
    end
    function frozenChainsDisplay:ShouldShowWhenAbsent()
        return false
    end

    timers:AddKick(47528, 1, 0.6, ERALIBTalent:CreateLevel(7))

    timers:AddAuraBar(timers:AddTrackedBuff(51271), nil, 0.7, 0.7, 1.0) -- pof
    timers:AddAuraBar(timers:AddTrackedBuff(152279, talent_icy_veins), nil, 1.0, 1.0, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(152279, talent_sindragosa), nil, 0.0, 0.0, 1.0)

    local utility = ERACombatFrames_DeathKnightUtility(cFrame, 32, -128, 2, ERALIBTalent:Create(5, 2))
    utility:AddCooldown(0, -1.8, 48743, nil, true, ERALIBTalent:Create(5, 3)) -- death pact
    utility:AddCooldown(2.5, 0.9, 108194, nil, true, ERALIBTalent:Create(3, 2)) -- darth vader
    utility:AddCooldown(2.5, 0.9, 207167, nil, true, ERALIBTalent:Create(3, 3)) -- blind freeze

    local frostUtility = ERACombatUtilityFrame:Create(cFrame, -200, -133, 2)
    frostUtility:AddCooldown(-1.1, 1.1, 57330, nil, true, ERALIBTalent:Create(2, 3)) -- how
    frostUtility:AddCooldown(-2, 0, 46585, nil, true, ERALIBTalent:CreateLevel(12)) -- summon ghoul
    frostUtility:AddCooldown(-1, 0, 327574, nil, true, ERALIBTalent:CreateLevel(54)) -- explode ghoul
    frostUtility:AddCooldown(0, 0, 47568, nil, true, ERALIBTalent:CreateLevel(48)) -- rune weapon
    frostUtility:AddCooldown(1, 0, 51271, nil, true, ERALIBTalent:CreateLevel(29)) -- pof
    frostUtility:AddCooldown(-0.5, -0.9, 152279, nil, true, talent_sindragosa)
    frostUtility:AddCooldown(0.5, -0.9, 279302, nil, true, ERALIBTalent:CreateLevel(44)) -- frostwyrm
    frostUtility:AddTrinket1Cooldown(1.5, -0.9)
    frostUtility:AddTrinket2Cooldown(1, -1.8)

    ERACombatFrames_DeathKnightCovenant(timers, 0, 1.6, -2, 0.6, frostUtility, 2, 0, runes, talent_venthyr, talent_nightfae)
end

------------------------------------------------------------------------------------------------------------------------
---- UNHOLY ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DeathKnightUnholySetup(cFrame, runes, talent_venthyr, talent_nightfae, talent_not_nightfae)
    local talent_ranged_claws = ERALIBTalent:Create(1, 3)
    local talent_better_wounds = ERALIBTalent:Create(2, 1)
    local talent_better_disease = ERALIBTalent:Create(2, 2)
    local talent_normal_disease = ERALIBTalent:CreateNotTalent(2, 2)
    local talent_exec = ERALIBTalent:Create(4, 3)
    local talent_not_exec = ERALIBTalent:CreateNotTalent(4, 3)

    local combatPower = ERACombatPower:Create(cFrame, -144, -22, 200, 12, 6, true, 0.2, 0.7, 1.0, 3)
    ERAOutOfCombatStatusBars:Create(cFrame, 0, -44, 128, 22, 6, false, 0.2, 0.7, 1.0, true, 3)
    ERACombatHealth:Create(cFrame, -144, -101, 200, 22, 3):SetUnitID("pet")

    local timers = ERACombatTimersGroup:Create(cFrame, -111, 32, 1.5, 3)
    ERACombatFrames_DeathKnightSetupTimersAndRunes(timers, runes)

    timers:AddProc(timers:AddTrackedBuff(101568), nil, 0, 2.6, false) -- succor
    timers:AddAuraIcon(timers:AddTrackedDebuff(194310), 0, 0.6, nil) -- wounds
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 43265, runes, ERALIBTalent:CreateAnd(talent_not_nightfae, ERALIBTalent:CreateNotTalent(6, 3, 3))), nil, -1, 0.6, true, true) -- dnd
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 152280, runes, ERALIBTalent:CreateAnd(talent_not_nightfae, ERALIBTalent:Create(6, 3))), nil, -1, 0.6, true, true) -- defile
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 343294, runes, talent_exec), nil, -2, 0.6, true, true) -- exec
    local mosquitosTimer = ERACombatCooldownIgnoringRunes:create(timers, 115989, runes, ERALIBTalent:Create(2, 3))
    timers:AddCooldownIcon(mosquitosTimer, nil, -2, 0.6, true, true, talent_not_exec)
    timers:AddCooldownIcon(mosquitosTimer, nil, -3, 0.6, true, true, talent_exec)
    timers:AddKick(47528, 1, 0.6, ERALIBTalent:CreateLevel(7))

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        3,
        function(tracker)
            -- 1 frappe purulente consomme 4.5 runes et inflige :
            -- -- les dégâts de 1 frappe purulente : 1 * 1.16 * 0.7 (armure) * 1.2 (rang 2)
            -- -- les dégâts de 2.5 frappes du fléau/griffes des ombres
            -- -- les dégâts de 2.5 blessures purulentes : 2.5 * 0.23
            -- -- -- -- une blessure purulente donne 3 points de PR, donc 4/40 death coil : 2.5 * 3/40 * 0.503
            local mastery = (1 + GetMasteryEffect() / 100)
            local claw_or_strike
            if (talent_ranged_claws:PlayerHasTalent()) then
                claw_or_strike = 1.38 -- 2.5 * 0.46 * 1.2
            else
                -- 2.5 * (0.345 * 0.7 / mastery + 0.19)
                claw_or_strike = (0.60375 / mastery + 0.475) * 1.2
            end
            local wound_damage
            if (talent_better_wounds:PlayerHasTalent()) then
                wound_damage = 0.71875 + 0.2 * math.min(8, tracker.enemiesTracker:GetEnemiesCount())
            else
                wound_damage = 0.575
            end
            return (0.812 / mastery + claw_or_strike + wound_damage) / 4.5
        end
    )
    local diseaseNormalDOT =
        dotracker:AddDOT(
        191587,
        nil,
        0.3,
        1.0,
        0.2,
        0,
        function(dotDef, hasteMod)
            return 27
        end,
        function(dotDef, currentTarget)
            return 0.1 + ERACombatFrames_DeathKnightUnholyDiseaseExplosionOnDeath(dotracker, currentTarget), 1.125
        end,
        talent_normal_disease
    )
    local diseaseBetterDOT =
        dotracker:AddDOT(
        191587,
        nil,
        0.3,
        1.0,
        0.2,
        0,
        function(dotDef, hasteMod)
            return 13.5
        end,
        function(dotDef, currentTarget)
            return 0.1 + ERACombatFrames_DeathKnightUnholyDiseaseExplosionOnDeath(dotracker, currentTarget), 1.29375
        end,
        talent_better_disease
    )

    local utility = ERACombatFrames_DeathKnightUtility(cFrame, 32, -128, 3, ERALIBTalent:Create(5, 2))
    utility:AddCooldown(0, -1.8, 48743, nil, true, ERALIBTalent:Create(5, 3)) -- death pact
    utility:AddCooldown(2.5, 0.9, 108194, nil, true, ERALIBTalent:Create(3, 3)) -- darth vader
    utility:AddCooldown(3.5, 0.9, 47481, nil, true) -- gnaw

    local unholyUtility = ERACombatUtilityFrame:Create(cFrame, -222, -161, 3)
    unholyUtility:AddCooldown(-1, 0, 49206, nil, true, ERALIBTalent:Create(7, 2)) -- gargoyle
    unholyUtility:AddCooldown(-1, 0, 207289, nil, true, ERALIBTalent:Create(7, 3)) -- frenzy
    unholyUtility:AddCooldown(0, 0, 275699, nil, true, ERALIBTalent:CreateLevel(19)) -- apo
    unholyUtility:AddCooldown(1, 0, 63560, nil, true, ERALIBTalent:CreateLevel(32)) -- transformation
    unholyUtility:AddTrinket2Cooldown(-1.5, -0.8)
    unholyUtility:AddTrinket1Cooldown(-0.5, -0.8)
    unholyUtility:AddCooldown(0.5, -0.8, 46584, nil, true, ERALIBTalent:CreateLevel(12)).alphaWhenOffCooldown = 0.2 -- call pet
    unholyUtility:AddCooldown(1.5, -0.8, 327574, nil, true, ERALIBTalent:CreateLevel(54)) -- explode ghoul

    combatPower:AddConsumer(40, 136145)
    local epiConsumer = combatPower:AddConsumer(30, 136066)
    function epiConsumer:ComputeVisibility()
        return dotracker.enemiesTracker:GetEnemiesCount() > 1
    end

    ERACombatFrames_DeathKnightCovenant(timers, 0, 1.6, -1, 0.6, unholyUtility, 2, 0, runes, talent_venthyr, talent_nightfae)
end

function ERACombatFrames_DeathKnightUnholyDiseaseExplosionOnDeath(tracker, target)
    local cpt = 0
    for _, t in pairs(tracker.enemiesTracker.enemiesByGUID) do
        if (t ~= target and t.lifeExpectancy > target.lifeExpectancy + 2) then -- pénalité arbitraire de 2 secondes
            cpt = cpt + 1
        end
    end
    return cpt * 0.24
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DeathKnightCovenant(timers, xVenthyr, yVenthyr, xDnD, yDnD, utility, x, y, runes, talent_venthyr, talent_nightfae)
    utility:AddCovenantClassAbility(x, y, 312202, nil, nil, 315443)
    utility:AddCooldown(x, y, 311648, nil, false, talent_venthyr)
    timers:AddAuraBar(timers:AddTrackedDebuff(312202, ERALIBTalent:CreateKyrianOrSpellKnown(312202)), nil, 0.5, 1.0, 1.0)
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 311648, runes, talent_venthyr), nil, xVenthyr, yVenthyr, true, true)
    timers:AddCooldownIcon(ERACombatCooldownIgnoringRunes:create(timers, 324128, runes, talent_nightfae), nil, xDnD, yDnD, true, true)
end

function ERACombatFrames_DeathKnightUtility(cFrame, x, y, spec, walkTalent)
    local utility = ERACombatUtilityFrame:Create(cFrame, x, y, spec)
    utility:AddCooldown(0, 0, 48792, nil, true, ERALIBTalent:CreateLevel(38)) -- fortitude
    utility:AddCooldown(1, 0, 48707, nil, true, ERALIBTalent:CreateLevel(9)) -- ams
    utility:AddCooldown(2, 0, 51052, nil, true, ERALIBTalent:CreateLevel(47)) -- amz
    utility:AddCooldown(-0.5, -0.9, 49039, nil, true, ERALIBTalent:CreateLevel(33)) -- licheborne
    utility:AddRacial(0.5, -0.9)
    utility:AddWarlockHealthStone(1.5, -0.9)
    utility:AddWarlockPortal(2.5, -0.9)
    utility:AddCovenantGenericAbility(1.5, 0.9)
    utility:AddCooldown(2.5, 2.9, 49576, nil, true) -- grip
    utility:AddCooldown(2.5, 1.9, 48265, nil, true, ERALIBTalent:CreateLevel(42)) -- advance
    utility:AddCooldown(3.5, 1.9, 212552, nil, true, walkTalent)
    return utility
end

function ERACombatFrames_DeathKnightFaFDisease(timers, spellID, x, y, level)
    local diseaseTimer = timers:AddTrackedDebuff(spellID, ERALIBTalent:CreateLevel(level))
    local display = timers:AddAuraBar(diseaseTimer, nil, 1.0, 0.0, 0.0)
    function display:GetRemDurationOr0IfInvisible(t)
        local dur = self.aura.remDuration
        if (dur < timers.timerStandardDuration) then
            return dur
        else
            return 0
        end
    end
    timers:AddMissingAura(diseaseTimer, nil, x, y, true)
end

------------------------------------------------------------------------------------------------------------------------
-- fucking blizzard API considering spells are on cooldown when runes are not available --------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatCooldownIgnoringRunes = {}
ERACombatCooldownIgnoringRunes.__index = ERACombatCooldownIgnoringRunes
setmetatable(ERACombatCooldownIgnoringRunes, {__index = ERACombatTimer})

function ERACombatCooldownIgnoringRunes:create(group, spellID, runes, talent)
    local t = {}
    setmetatable(t, ERACombatCooldownIgnoringRunes)
    t:constructTimer(group, talent)
    t.spellID = spellID
    t.runes = runes
    t:updateKind()
    return t
end

function ERACombatCooldownIgnoringRunes:updateDurations(t)
    if (self.hasCharges) then
        local currentCharges, maxCharges, cooldownStart, cooldownDuration = GetSpellCharges(self.spellID)
        if (maxCharges) then
            self.currentCharges = currentCharges
            self.maxCharges = maxCharges
            self.totDuration = cooldownDuration
            if (currentCharges >= maxCharges) then
                self.remDuration = 0
                self.isAvailable = true
            else
                self.remDuration = cooldownDuration - (t - cooldownStart)
                self.isAvailable = currentCharges > 0
            end
            self.lastGoodUpdate = t
            self.lastGoodDuration = self.remDuration
            return
        end
    end
    local started, duration = GetSpellCooldown(self.spellID)
    if (started and started > 0) then
        self.currentCharges = 0
        local remDur = duration - (t - started)
        if (self.runes.availableRunes > 0 or self.runes.nextRuneDuration + 0.1 < remDur or not self.lastGoodUpdate) then
            if (duration <= self.group.totGCD + 0.5 and self.lastGoodUpdate) then
                self.isAvailable = true
                self:updateBasedOnLastGoodUpdate(t, remDur)
            else
                self.isAvailable = false
                self.totDuration = duration
                self.remDuration = remDur
                self.lastGoodUpdate = t
                self.lastGoodDuration = self.remDuration
            end
        else
            self.isAvailable = false
            self:updateBasedOnLastGoodUpdate(t, remDur)
        end
    else
        self.isAvailable = true
        self.totDuration = duration or 1
        self.remDuration = 0
        self.currentCharges = 1
        self.lastGoodUpdate = t
        self.lastGoodDuration = 0
    end
end
function ERACombatCooldownIgnoringRunes:updateBasedOnLastGoodUpdate(t, remDur)
    -- self.totDuration reste inchangé
    self.remDuration = self.lastGoodDuration - (t - self.lastGoodUpdate)
    if (self.remDuration < 0) then
        self.remDuration = 0
    elseif (self.remDuration > remDur) then
        self.remDuration = remDur
    end
end

function ERACombatCooldownIgnoringRunes:TalentCheck()
    self:updateKind()
    if (not self.talentActive) then
        self.currentCharges = 0
    end
end
function ERACombatCooldownIgnoringRunes:updateKind()
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

------------------------------------------------------------------------------------------------------------------------
---- RUNES -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DeathKnightSetupTimersAndRunes(timers, runes)
    function timers:PreUpdateCombat(t)
        runes:updateCombatBeforeTimers(t)
    end
end

ERARunes = {}
ERARunes.__index = ERARunes
setmetatable(ERARunes, {__index = ERACombatModule})

function ERARunes:Create(cFrame, combatHealth, ...)
    local ru = {}
    setmetatable(ru, ERARunes)

    ru.combatHealth = combatHealth

    -- frame
    ru.frame = CreateFrame("Frame", nil, UIParent, nil)
    ru.frame:SetSize(ERADK_RuneSize * 6, ERADK_RuneSize)
    ru.frame:SetPoint("CENTER", UIParent, "CENTER", -144, -88)

    ru.icons = {}
    ru.infos = {}
    for i = 1, 6 do
        -- rune : 1121021
        -- rune violette forte : 252272
        -- rune violette faible : 1323037
        local icon = ERAPieIcon:Create(ru.frame, "TOPRIGHT", ERADK_RuneSize, 252272)
        icon:SetOverlayAlpha(0.95)
        icon:Draw(-(i - 0.5) * ERADK_RuneSize, ERADK_RuneSize / 2)
        table.insert(ru.icons, icon)
        local info = {}
        info.remDur = 0
        info.totDur = 10
        table.insert(ru.infos, info)
    end

    ru.nextRuneDuration = 0
    ru.availableRunes = 0

    ru:construct(cFrame, 0.5, -1, false, ...)
    return ru
end

function ERARunes:SpecInactive(wasActive)
    self.combatHealth:SetHealing(0)
    self.frame:Hide()
end
function ERARunes:ResetToIdle()
    self.frame:Show()
end
function ERARunes:EnterIdle(fromCombat)
    if (not fromCombat) then
        self.frame:Show()
    end
end
function ERARunes:ExitIdle(toCombat)
    if (not toCombat) then
        self.frame:Hide()
    end
end
function ERARunes:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERARunes:ExitCombat(toIdle)
    if (not toIdle) then
        self.frame:Hide()
    end
end

function ERARunes:UpdateIdle(t)
    self:updateData(t)
    if (self.availableRunes < 6) then
        self:updateDisplay()
        self.frame:Show()
    else
        self.frame:Hide()
    end
end
function ERARunes:updateCombatBeforeTimers(t)
    self:updateData(t)
    self:updateDisplay()
end
function ERARunes:updateData(t)
    for i, info in ipairs(self.infos) do
        local start, duration, runeReady = GetRuneCooldown(i)
        if (start and start > 0 and not runeReady) then
            info.remDur = duration - (t - start)
            info.totDur = duration
        else
            info.remDur = 0
        end
    end
    table.sort(self.infos, ERARunes_sort)
    self.nextRuneDuration = self.infos[1].remDur
    self.availableRunes = 0
    for i, info in ipairs(self.infos) do
        if (info.remDur <= 0) then
            self.availableRunes = self.availableRunes + 1
        else
            break
        end
    end
end
function ERARunes_sort(r1, r2)
    return r1.remDur < r2.remDur
end
function ERARunes:updateDisplay()
    for i, info in ipairs(self.infos) do
        local icon = self.icons[i]
        if (info.remDur <= 0) then
            icon:SetIconTexture(1121021)
            icon:SetOverlayValue(0)
        else
            icon:SetIconTexture(1323037)
            icon:SetOverlayValue(info.remDur / info.totDur)
        end
    end
end
