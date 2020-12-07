function ERACombatFrames_MageSetup(cFrame)
    ERACombatGlobals_SpecID1 = 62
    ERACombatGlobals_SpecID2 = 63
    ERACombatGlobals_SpecID3 = 64

    local arcaneActive = ERACombatOptions_IsSpecActive(1)
    local fireActive = ERACombatOptions_IsSpecActive(2)
    local frostActive = ERACombatOptions_IsSpecActive(3)

    local enemies = ERACombatEnemiesTracker:Create(cFrame, 0.2, arcaneActive, fireActive, frostActive)
    local talent_rune = ERALIBTalent:Create(3, 3)
    local talent_necrolords = ERALIBTalent:CreateNecrolordsOrSpellKnown(324220)

    enemies.lastRuneCast = 0
    enemies.lastManaCast = 0
    enemies.AdditionalCLEU = function(t, evt, sourceGUY, targetGUY, spellID)
        if (evt == "SPELL_CAST_SUCCESS" and sourceGUY == enemies.playerGUID) then
            if (spellID == 116011 or spellID == 12042 or spellID == 190319 or spellID == 12472) then
                enemies.lastRuneCast = t
            elseif (spellID == 1449 or spellID == 30449) then
                enemies.lastManaCast = t
            end
        end
    end

    ERAOutOfCombatStatusBars:Create(cFrame, -144, -8, 128, 22, 0, true, 0.1, 0.1, 1.0, false, arcaneActive, fireActive, frostActive)
    ERACombatHealth:Create(cFrame, 32, -64, 111, 22, arcaneActive, fireActive, frostActive)
    local mana = ERACombatPower:Create(cFrame, -255, -88, 111, 22, 0, true, 0.2, 0.2, 1.0, fireActive, frostActive)
    function mana:ShouldBeVisible(t)
        local ratio = self.currentPower / self.maxPower
        return ratio < 1 and (ratio < 0.5 or t < enemies.lastManaCast + 5)
    end

    if (arcaneActive) then
        ERACombatFrames_MageArcaneSetup(cFrame, enemies, talent_rune, talent_necrolords)
    end
    if (fireActive) then
        ERACombatFrames_MageFireSetup(cFrame, enemies, talent_rune, talent_necrolords)
    end
    if (frostActive) then
        ERACombatFrames_MageFrostSetup(cFrame, enemies, talent_rune, talent_necrolords)
    end

    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- ARCANE ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MageArcaneSetup(cFrame, enemies, talent_rune, talent_necrolords)
    local talent_familiar = ERALIBTalent:Create(1, 3)

    ERACombatPower:Create(cFrame, -188, -26, 144, 22, 0, true, 0.2, 0.2, 1.0, 1)
    ERACombatPointsUnitPower:Create(cFrame, -166, -55, 16, 4, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, nil, 1)

    local timers = ERACombatTimersGroup:Create(cFrame, -121, -11, 1.5, 1)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(321507, ERALIBTalent:CreateLevel(33)), nil, 0, 1, true, true) -- magi
    timers:AddCooldownIcon(timers:AddTrackedCooldown(153626, ERALIBTalent:Create(6, 2)), nil, -0.3, 0, true, true) -- orb
    timers:AddCooldownIcon(timers:AddTrackedCooldown(157980, ERALIBTalent:Create(6, 3)), nil, -0.3, 0, true, true) -- supernova
    timers:AddCooldownIcon(timers:AddTrackedCooldown(44425), nil, -1.2, -0.6, true, true) -- barrage
    timers:AddCooldownIcon(timers:AddTrackedCooldown(108853), nil, -2.2, -0.6, true, true) -- fireblast

    timers:AddOffensiveDispellIcon(135729, 1, 2, true, ERALIBTalent:CreateLevel(39), "Magic")

    timers:AddAuraBar(timers:AddTrackedBuff(12042), nil, 0.6, 0.0, 1.0) -- arcane power
    timers:AddAuraBar(timers:AddTrackedDebuff(210824), nil, 1.0, 0.1, 0.6) -- magi
    ERACombatMageRuneBar_create(timers, talent_rune)

    timers:AddAuraBar(timers:AddTrackedDebuff(31589), nil, 0.4, 0.4, 0.4) -- slow

    timers:AddKick(2139, 2, 1, ERALIBTalent:CreateLevel(7))

    local utility = ERACombatFrames_MageUtility(cFrame, 1, 19)
    utility:AddCooldown(0, 0, 235450, nil, true, ERALIBTalent:CreateNotTalent(2, 1, 21)).alphaWhenOffCooldown = 0.5 -- barrière
    utility:AddCooldown(2, 0, 110959, nil, true, ERALIBTalent:CreateLevel(47)).alphaWhenOffCooldown = 0.5 -- invi
    local damageUtility = ERACombatUtilityFrame:Create(cFrame, -77, -177, 1)
    damageUtility:AddCooldown(-2.7, 0.7, 116011, nil, true, talent_rune)
    damageUtility:AddBagItem(-2, 0, 36799, 134132, true) -- mana gem
    damageUtility:AddCooldown(-1, 0, 12051, nil, true, ERALIBTalent:CreateLevel(27)) -- evocation
    damageUtility:AddCooldown(0, 0, 12042, nil, true, ERALIBTalent:CreateLevel(29)) -- unlimited power
    damageUtility:AddCooldown(1, 0, 205025, nil, true, ERALIBTalent:CreateLevel(42)) -- pom
    damageUtility:AddTrinket1Cooldown(-0.5, -0.9)
    damageUtility:AddTrinket2Cooldown(-1.5, -0.9)
    damageUtility:AddMissingBuff(damageUtility:AddTrackedBuff(210126, talent_familiar), nil, 1, -2, true, true, talent_familiar) -- familiar

    ERACombatMage_Covenant(timers, damageUtility, 0.5, -0.9, talent_necrolords)

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        enemies,
        1,
        function(tracker)
            return 0
        end
    )
    dotracker:AddDOT(
        114923,
        nil,
        0.0,
        1.0,
        0.8,
        0,
        function(dotDef, hasteMod)
            return 12
        end,
        function(dotDef, currentTarget)
            return 0, 0.17061
        end,
        ERALIBTalent:Create(4, 3),
        true,
        0.0,
        0.7,
        0.4
    )
end

------------------------------------------------------------------------------------------------------------------------
---- FIRE --------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--[[
    iginte :
    local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID, false, false, true, false, 1, amount = UnitDebuff("target", i, "PLAYER")
    spellID == 12654
]]
function ERACombatFrames_MageFireSetup(cFrame, enemies, talent_rune, talent_necrolords)
    local timers = ERACombatTimersGroup:Create(cFrame, -121, -11, 1.5, 2)
    ERACombatMageBurnIcon:create(timers, 0, 2, enemies)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(108853), nil, 0, 1, true, true) -- blast
    timers:AddCooldownIcon(timers:AddTrackedCooldown(257541, ERALIBTalent:CreateLevel(19)), nil, -0.8, 0.3, true, true) -- phenix
    timers:AddCooldownIcon(timers:AddTrackedCooldown(31661, ERALIBTalent:CreateLevel(27)), nil, -2, -0.3, true, true) -- dragon
    timers:AddCooldownIcon(timers:AddTrackedCooldown(157981, ERALIBTalent:Create(2, 3)), nil, -0.3, -0.5, true, true) -- wave
    timers:AddCooldownIcon(timers:AddTrackedCooldown(153561, ERALIBTalent:Create(7, 3)), nil, -1.2, -0.5, true, true) -- meteor

    timers:AddOffensiveDispellIcon(135729, 0, 3, true, ERALIBTalent:CreateLevel(39), "Magic")
    timers:AddKick(2139, 2, 1, ERALIBTalent:CreateLevel(7))

    ERACombatFrames_MageIgnite:create(cFrame)

    timers:AddAuraBar(timers:AddTrackedBuff(190319), nil, 1.0, 1.0, 0.0) -- combu
    ERACombatMageRuneBar_create(timers, talent_rune)

    local utility = ERACombatFrames_MageUtility(cFrame, 2, 58)
    utility:AddCooldown(0, 0, 235313, nil, true, ERALIBTalent:CreateLevel(21)).alphaWhenOffCooldown = 0.5 -- barrière
    utility:AddCooldown(2, 0, 66, nil, true, ERALIBTalent:CreateLevel(34)).alphaWhenOffCooldown = 0.5 -- invi
    local damageUtility = ERACombatUtilityFrame:Create(cFrame, -88, -166, 2)
    damageUtility:AddCooldown(0, 0, 190319, nil, true, ERALIBTalent:CreateLevel(29)) -- combu
    damageUtility:AddCooldown(-1, 0, 116011, nil, true, talent_rune)
    damageUtility:AddTrinket1Cooldown(0.5, -0.9)
    damageUtility:AddTrinket2Cooldown(-0.5, -0.9)

    ERACombatMage_Covenant(timers, damageUtility, 1, 0, talent_necrolords)
end

ERACombatMageBurnIcon = {}
ERACombatMageBurnIcon.__index = ERACombatMageBurnIcon
setmetatable(ERACombatMageBurnIcon, {__index = ERACombatTimersHintIcon})

function ERACombatMageBurnIcon:create(timers, x, y, enemies)
    local b = {}
    setmetatable(b, ERACombatMageBurnIcon)
    b.enemies = enemies
    b:construct(timers, 135827, x, y, false, ERALIBTalent:Create(1, 3))
    return b
end

function ERACombatMageBurnIcon:ComputeIsVisible(t)
    local currentTarget = self.enemies.currentTarget
    if (currentTarget) then
        local pct = currentTarget.currentHealth / UnitHealthMax("target")
        if (pct < 0.3) then
            self.icon:SetDesaturated(false)
            self.icon:SetMainText(nil)
            return true
        else
            local timeUntil30 = currentTarget.lifeExpectancy * (pct - 0.3) / pct
            if (timeUntil30 < 5) then
                self.icon:SetDesaturated(true)
                self.icon:SetMainText(math.floor(timeUntil30))
                return true
            else
                return false
            end
        end
    elseif (UnitExists("target")) then
        if (UnitHealth("target") / UnitHealthMax("target") < 0.3) then
            self.icon:SetDesaturated(false)
            self.icon:SetMainText(nil)
            return true
        else
            return false
        end
    else
        return false
    end
end

ERACombatFrames_MageIgnite = {}
ERACombatFrames_MageIgnite.__index = ERACombatFrames_MageIgnite
setmetatable(ERACombatFrames_MageIgnite, {__index = ERACombatFrames_PseudoResourceBar})

function ERACombatFrames_MageIgnite:create(cFrame)
    local ig = {}
    setmetatable(ig, ERACombatFrames_MageIgnite)
    ig:constructPseudoResource(cFrame, -144, -44, 100, 20, 2, 2)
    return ig
end

function ERACombatFrames_MageIgnite:GetMax(t)
    return 10
end
function ERACombatFrames_MageIgnite:GetValue(t)
    local value = 0
    for i = 1, 40 do
        local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID, _, _, _, _, _, amount = UnitDebuff("target", i, "PLAYER")
        if (spellID) then
            if (spellID == 12654) then
                value = 5 * amount * (1 + math.floor(expirationTime - t)) / GetSpellBonusDamage(3)
                break
            end
        else
            break
        end
    end
    return value
end

------------------------------------------------------------------------------------------------------------------------
---- FROST -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MageFrostSetup(cFrame, enemies, talent_rune, talent_necrolords)
    local talent_lonewolf = ERALIBTalent:Create(1, 2)
    local talent_pet = ERALIBTalent:CreateNotTalent(1, 2, 12)
    local talent_procs = ERALIBTalent:Create(4, 1)
    local talent_shatter = ERALIBTalent:Create(6, 2)

    local timers = ERACombatTimersGroup:Create(cFrame, -121, -11, 1.5, 3)

    local icicles = timers:AddTrackedBuff(205473)

    local blizzardDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(190356, ERALIBTalent:CreateLevel(14)), nil, 0, 1, true, true) -- blizzard
    function blizzardDisplay:ShouldShowMainIcon()
        local hasteMod = 1 / (1 + GetHaste() / 100)
        local crit = GetCritChance() / 100
        local castTime = 2 * hasteMod

        local dmgBlizzard = 0
        local blizzardTime = 8 * hasteMod
        local blizzardDPS = 1.15 / blizzardTime
        local blizzardEndCast = math.max(timers.occupied, self.cd.remDuration) + castTime
        for _, e in pairs(enemies.enemiesByGUID) do
            dmgBlizzard = dmgBlizzard + blizzardDPS * math.min(blizzardTime, math.max(0, e.lifeExpectancy - blizzardEndCast))
        end
        dmgBlizzard = dmgBlizzard * (1 + crit) / castTime

        local loneMultiplier
        if (talent_lonewolf:PlayerHasTalent()) then
            loneMultiplier = 1.25
        else
            loneMultiplier = 1
        end
        local cleaveModifier
        local lanceMainDamage
        local lanceCleaveFrozenDamage
        local lanceCleaveWeakDamage
        local frozenCrit = (1 + math.min(1, 0.5 + 1.5 * crit))
        if (talent_shatter:PlayerHasTalent()) then
            lanceMainDamage = 1.1907 * frozenCrit
            if (enemies:GetEnemiesCount() > 1) then
                cleaveModifier = 1.7325
                lanceCleaveFrozenDamage = 0.773955 * frozenCrit
                lanceCleaveWeakDamage = 0.2457 * (1 + crit)
            else
                cleaveModifier = 1.05
                lanceCleaveFrozenDamage = 0
                lanceCleaveWeakDamage = 0
            end
        else
            cleaveModifier = 1
            lanceMainDamage = 1.134 * frozenCrit
            lanceCleaveFrozenDamage = 0
            lanceCleaveWeakDamage = 0
        end
        local icicle = 0.22 * (1 + GetMasteryEffect() / 100) * (1 + crit) * cleaveModifier
        local dmgFrostbolt = 0.51 * (1 + crit) * loneMultiplier + icicle
        local flurryChance
        local fofChance
        if (talent_procs:PlayerHasTalent()) then
            fofChance = 0.18
            flurryChance = 0.36
        else
            fofChance = 0.15
            flurryChance = 0.3
        end
        dmgFrostbolt =
            (dmgFrostbolt + fofChance * (lanceMainDamage + lanceCleaveFrozenDamage) * loneMultiplier +
            flurryChance * (icicle + loneMultiplier * (1.22 * (1 + crit) + 2 * (lanceMainDamage + lanceCleaveWeakDamage)))) /
            (castTime + (fofChance * 1.5 + flurryChance * 4.5) * hasteMod)

        if (dmgBlizzard > dmgFrostbolt) then
            self.blizzardWorthCasting = true
            self.icon:SetAlpha(1)
        else
            self.blizzardWorthCasting = false
            if (self.cd.remDuration > 0) then
                self.icon:SetAlpha(0.4)
            else
                self.icon:SetAlpha(0.2)
            end
        end

        return true
    end
    function blizzardDisplay:OverrideTimerVisibility()
        return self.blizzardWorthCasting
    end

    timers:AddCooldownIcon(timers:AddTrackedCooldown(84714, ERALIBTalent:CreateLevel(38)), nil, -0.7, 0.3, true, true) -- orb
    timers:AddCooldownIcon(timers:AddTrackedCooldown(120, ERALIBTalent:CreateLevel(18)), nil, -1.7, 0.3, true, true) -- coc
    timers:AddCooldownIcon(timers:AddTrackedCooldown(257537, ERALIBTalent:Create(4, 3)), nil, -0.7, 3, true, true) -- ebon
    timers:AddCooldownIcon(timers:AddTrackedCooldown(157997, ERALIBTalent:Create(1, 3)), nil, 0, 2, true, true) -- ice nova
    timers:AddCooldownIcon(timers:AddTrackedCooldown(108853), nil, -2.7, 3, true, true) -- fireblast
    timers:AddCooldownIcon(timers:AddTrackedCooldown(153595, ERALIBTalent:Create(6, 3)), nil, -2.7, 0.3, true, true) -- comet
    timers:AddCooldownIcon(timers:AddTrackedCooldown(205021, ERALIBTalent:Create(7, 2)), nil, -1, -0.6, true, true) -- laser glace
    timers:AddAuraIcon(icicles, -1, -0.6, nil, ERALIBTalent:Create(7, 3))

    local flurryProcIcon = timers:AddAuraIcon(timers:AddTrackedDebuff(228358), -1.7, 3, nil)
    function flurryProcIcon:ShouldShowWhenAbsent()
        return false
    end

    timers:AddOffensiveDispellIcon(135729, 0, 3, true, ERALIBTalent:CreateLevel(39), "Magic")

    timers:AddAuraBar(timers:AddTrackedBuff(12472), nil, 0.6, 0.0, 1.0) -- icy veins
    ERACombatMageRuneBar_create(timers, talent_rune)

    timers:AddKick(2139, 2, 1, ERALIBTalent:CreateLevel(7))

    local utility = ERACombatFrames_MageUtility(cFrame, 3, 58)
    utility:AddCooldown(0, 0, 11426, nil, true, ERALIBTalent:CreateLevel(21)).alphaWhenOffCooldown = 0.5 -- barrière
    utility:AddCooldown(2, 0, 66, nil, true, ERALIBTalent:CreateLevel(34)).alphaWhenOffCooldown = 0.5 -- invi
    utility:AddCooldown(0, 2, 108839, nil, true, ERALIBTalent:Create(2, 3)) -- ice flows
    utility:AddCooldown(1, -2, 235219, nil, true, ERALIBTalent:CreateLevel(42)) -- reset

    local damageUtility = ERACombatUtilityFrame:Create(cFrame, -32, -177, 3)
    damageUtility:AddCooldown(-1, 0, 12472, nil, true, ERALIBTalent:CreateLevel(29)) -- icy veins
    damageUtility:AddCooldown(-2, 0, 116011, nil, true, talent_rune)
    damageUtility:AddCooldown(-1.5, -0.9, 31687, nil, true, talent_pet).alphaWhenOffCooldown = 0.2 -- summon pet
    damageUtility:AddCooldown(-0.5, -0.9, 33395, nil, true, talent_pet).showOnlyIfPetSpellKnown = true -- pet frost
    damageUtility:AddTrinket1Cooldown(0.5, 0.9)
    damageUtility:AddTrinket2Cooldown(-2.5, -0.9)

    ERACombatMage_Covenant(timers, damageUtility, 0, 0, talent_necrolords)
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MageUtility(cFrame, spec, alterTimeLevel)
    local utility = ERACombatUtilityFrame:Create(cFrame, 128, -64, spec)
    utility:AddCooldown(0, 1, 1953, nil, true, ERALIBTalent:CreateNotTalent(2, 2)).alphaWhenOffCooldown = 0.5 -- blink
    utility:AddCooldown(0, 1, 212653, nil, true, ERALIBTalent:Create(2, 2)).alphaWhenOffCooldown = 0.5 -- alternative blink
    --utility:AddCooldown(1, 1, 195676, nil, true).alphaWhenOffCooldown = 0.5 -- reblink
    utility:AddCooldown(1, 1, 342245, nil, true, ERALIBTalent:CreateLevel(alterTimeLevel)).alphaWhenOffCooldown = 0.5 -- alter time
    utility:AddCooldown(1, 0, 55342, nil, true, ERALIBTalent:CreateLevel(44)).alphaWhenOffCooldown = 0.4 -- mirror
    utility:AddCooldown(0, -1, 122, nil, true).alphaWhenOffCooldown = 0.4 -- nova
    utility:AddCooldown(1, -1, 45438, nil, true, ERALIBTalent:CreateLevel(22)).alphaWhenOffCooldown = 0.4 -- ib
    utility:AddCooldown(2, -1, 113724, nil, true, ERALIBTalent:Create(5, 3)).alphaWhenOffCooldown = 0.4 -- rof
    utility:AddWarlockHealthStone(-1, -1)
    utility:AddWarlockPortal(2, 1)
    utility:AddRacial(0, -2).alphaWhenOffCooldown = 0.4
    utility:AddMissingBuffAnyCaster(135932, 2, 1, nil, 1459) -- intel
    utility:AddCovenantGenericAbility(-1, -2)
    return utility
end

function ERACombatMageRuneBar_create(timers, talent_rune)
    local bar = timers:AddTotemBar(1, 609815, 0.2, 0.4, 0.8, talent_rune)
    bar.inside = timers:AddTrackedBuff(116014, talent_rune)
    function bar:UpdatingDuration(t, remDuration)
        if (self.inside.stacks > 0) then
            self.view:SetColor(0.2, 0.4, 0.8)
        else
            self.view:SetColor(1.0, 0.0, 0.0)
        end
        return remDuration
    end
end

function ERACombatMage_Covenant(timers, utility, x, y, talent_necrolords)
    utility:AddCovenantClassAbility(x, y, 307443, 314793, 314791, 324220)
    timers:AddAuraBar(timers:AddTrackedBuff(324220, talent_necrolords), nil, 0.1, 0.7, 0.4)
end
