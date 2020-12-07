function ERACombatFrames_PaladinSetup(cFrame)
    ERACombatGlobals_SpecID1 = 65
    ERACombatGlobals_SpecID2 = 66
    ERACombatGlobals_SpecID3 = 70

    ERAPieIcon_BorderR = 1.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 1.0

    local holyActive = ERACombatOptions_IsSpecActive(1)
    local protectionActive = ERACombatOptions_IsSpecActive(2)
    local retributionActive = ERACombatOptions_IsSpecActive(3)

    ERAOutOfCombatStatusBars:Create(cFrame, -155, -66, 128, 22, 0, true, 0.1, 0.1, 1.0, false, holyActive, protectionActive, retributionActive)

    ERACombatFrames_PaladinAuras:create(cFrame, 0, 256, holyActive, protectionActive, retributionActive)

    if (holyActive) then
        ERACombatFrames_PaladinHolySetup(cFrame)
    end
    if (protectionActive) then
        ERACombatFrames_PaladinProtectionSetup(cFrame)
    end
    if (retributionActive) then
        ERACombatFrames_PaladinRetributionSetup(cFrame)
    end

    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- HOLY --------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PaladinHolySetup(cFrame)
    --local remember_default_bar_size = ERACombat_TimerBarDefaultSize
    --ERACombat_TimerBarDefaultSize = 16

    local talent_prism = ERALIBTalent:Create(2, 3)
    local talent_delayedheal = ERALIBTalent:Create(1, 2)
    local talent_groundhammer = ERALIBTalent:Create(1, 3)
    local talent_groundhammer_or_delayedheal = ERALIBTalent:CreateOr(talent_delayedheal, talent_groundhammer)
    local talent_multibeacon = ERALIBTalent:Create(7, 3)
    local talent_neither_groundordelayed_nor_prism = ERALIBTalent:CreateNOR(talent_prism, talent_groundhammer_or_delayedheal)
    local talent_either_groundordelayed_or_prism = ERALIBTalent:CreateXOR(talent_prism, talent_groundhammer_or_delayedheal)
    local talent_groundordelayed_and_prism = ERALIBTalent:CreateAnd(talent_prism, talent_groundhammer_or_delayedheal)

    ERACombatHealth:Create(cFrame, -210, -141, 155, 22, 1)
    ERACombatPower:Create(cFrame, -210, -161, 155, 22, 0, false, 0.2, 0.2, 1.0, 1)
    ERACombatPointsUnitPower:Create(cFrame, -200, -111, 9, 5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, nil, 1)

    local grid = ERACombatGrid:Create(cFrame, -133, -8, "BOTTOMRIGHT", 1, 4987, "Magic", "Disease", "Poison")
    --, "Curse")
    -- spellID, position, priority, rC, gC, bC, rB, gB, bB, talent
    grid:AddTrackedBuff(53563, 0, 2, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, nil) -- beacon
    grid:AddTrackedBuff(156910, 0, 1, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, ERALIBTalent:Create(7, 2)) -- beacon 2
    grid:AddTrackedBuff(200025, 0, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, ERALIBTalent:Create(7, 3)) -- beacon 3
    grid:AddTrackedBuff(287280, 1, 1, 1.0, 1.0, 0.0, 1.0, 0.5, 0.0, nil) -- glimmer

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -88, 1.5, 1)

    ERACombatFrames_Paladin_simple_consecration(timers, 0.8, 0.5)

    local multibeaconTimer = timers:AddTrackedCooldown(200025, talent_multibeacon)
    timers:AddCooldownIcon(multibeaconTimer, nil, 0, 6, true, true, talent_groundordelayed_and_prism)
    timers:AddCooldownIcon(multibeaconTimer, nil, 0, 5, true, true, talent_either_groundordelayed_or_prism)
    timers:AddCooldownIcon(multibeaconTimer, nil, 0, 4, true, true, talent_neither_groundordelayed_nor_prism)
    local prismTimer = timers:AddTrackedCooldown(114165, talent_prism)
    timers:AddCooldownIcon(prismTimer, nil, 0, 5, true, true, talent_groundhammer_or_delayedheal)
    timers:AddCooldownIcon(prismTimer, nil, 0, 4, true, true, ERALIBTalent:CreateNot(talent_groundhammer_or_delayedheal))
    timers:AddCooldownIcon(timers:AddTrackedCooldown(223306, talent_delayedheal), nil, 0, 4, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(114158, talent_groundhammer), nil, 0, 4, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(20473), nil, 0, 3, true, true) -- shock
    timers:AddCooldownIcon(timers:AddTrackedCooldown(20271), nil, 0, 2, true, true) -- judgement
    timers:AddCooldownIcon(timers:AddTrackedCooldown(35395), 135891, 0, 1, true, true) -- crusader strike
    ERACombatFrames_Paladin_seraph(timers, 0, 0)

    local utility, burstUtility = ERACombatFrames_Paladin_common_stuff(cFrame, timers, 123, -188, -144, -222, 1.5, 2.5, 498, 4987, true, 216331, 216331, 6, 2, ERALIBTalent:CreateLevel(41), 1)
    utility:AddCooldown(-0.5, 0, 31821, nil, true, ERALIBTalent:CreateLevel(39)) -- aura mastery
    utility:AddCooldown(-1.5, 0, 214202, nil, true, ERALIBTalent:Create(4, 3)) -- rule of law

    --ERACombat_TimerBarDefaultSize = remember_default_bar_size
end

------------------------------------------------------------------------------------------------------------------------
---- PROTECTION --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PaladinProtectionSetup(cFrame)
    local health = ERACombatHealth:Create(cFrame, -200, -64, 155, 22, 2)
    local holyPower = ERACombatPointsUnitPower:Create(cFrame, -177, -36, 9, 5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, nil, 2)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -32, 1.5, 2)

    local consecrationCDTimer = timers:AddTrackedCooldown(26573)
    local consecration = ERACombatFrames_PaladinConsecrationTimer_create(timers, true, consecrationCDTimer)
    ERACombatFrames_PaladinConsecrationMissing:create(consecration, 0, 4, consecrationCDTimer)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(20271), nil, 0, 2, true, true) -- judgement
    timers:AddCooldownIcon(timers:AddTrackedCooldown(53595, ERALIBTalent:CreateNotTalent(1, 3)), 135891, 0, 1, true, true) -- normal hammer
    timers:AddCooldownIcon(timers:AddTrackedCooldown(204019, ERALIBTalent:Create(1, 3)), 135891, 0, 1, true, true) -- blessed hammer
    timers:AddCooldownIcon(timers:AddTrackedCooldown(31935), nil, 0, 0, true, true) -- avenger
    timers:AddKick(96231, 1, 1, ERALIBTalent:CreateLevel(27))

    local freeWOGlevel = ERALIBTalent:CreateLevel(48)
    local buildFreeWOG = timers:AddTrackedBuff(182104, freeWOGlevel)
    local freeWOG = timers:AddTrackedBuff(327510, freeWOGlevel)
    local buildFreeWOGDisplay = timers:AddAuraIcon(buildFreeWOG, -0.8, -0.3, nil)
    function buildFreeWOGDisplay:ShouldShowWhenAbsent()
        return freeWOG.remDuration <= 0
    end
    local freeWOGDisplay = timers:AddAuraIcon(freeWOG, -0.8, -0.3, 133192)
    function freeWOGDisplay:ShouldShowWhenAbsent()
        return false
    end

    ERACombatFrames_Paladin_seraph(timers, -1.8, -0.3)

    local shieldArmour = timers:AddTrackedBuff(132403)
    timers:AddAuraBar(shieldArmour, nil, 0.7, 0.5, 0.4)

    local pullUtility = ERACombatUtilityFrame:Create(cFrame, 0, 128, 2)
    pullUtility:AddCooldown(-0.5, 0, 31935, nil, false) -- avenger
    pullUtility:AddCooldown(0.5, 0, 20271, nil, false) -- judgement

    local utility, burstUtility, forebearance =
        ERACombatFrames_Paladin_common_stuff(cFrame, timers, 44, -166, -166, -166, 0, 3, 31850, 213644, false, -1, -1, 0, 0, ERALIBTalent:CreateNotTalent(4, 3, 41), 2)
    utility:AddCooldown(-0.5, 0, 86659, nil, true) -- king
    burstUtility:AddCooldown(0.5, -0.9, 327193, nil, true, ERALIBTalent:Create(2, 3)) -- reset shield
    ERACombatFrames_PaladinUtilityAffectedByForebearance(utility:AddCooldown(1, -0.9, 204018, nil, true, ERALIBTalent:Create(4, 3)), forebearance) -- alternative protection

    local sow = ERACombatFrames_PaladinProtectionShieldOrWOG:create(cFrame, -212, -101, health, shieldArmour, holyPower, freeWOG)

    local mana = ERACombatPower:Create(cFrame, -353, -60, 144, 22, 0, false, 0.2, 0.2, 1.0, 2)
    function mana:ShouldBeVisible(t)
        local ratio = self.currentPower / self.maxPower
        return ratio < 1 and (ratio < 0.5 or t < sow.lastFlashHeal + 5)
    end
end

ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize = 22
ERACombatFrames_PaladinProtectionShieldOrWOG_BarWidth = 64
ERACombatFrames_PaladinProtectionShieldOrWOG_Duration = 9

ERACombatFrames_PaladinProtectionShieldOrWOG = {}
ERACombatFrames_PaladinProtectionShieldOrWOG.__index = ERACombatFrames_PaladinProtectionShieldOrWOG
setmetatable(ERACombatFrames_PaladinProtectionShieldOrWOG, {__index = ERACombatModule})

function ERACombatFrames_PaladinProtectionShieldOrWOG:create(cFrame, x, y, health, shieldArmourTimer, holyPower, freeWOG)
    local sow = {}
    setmetatable(sow, ERACombatFrames_PaladinProtectionShieldOrWOG)
    sow:construct(cFrame, -1, 0.2, true, 2)

    -- affichage

    sow.frame = CreateFrame("Frame", nil, UIParent, nil)
    sow.frame:SetSize(ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize * 2 + ERACombatFrames_PaladinProtectionShieldOrWOG_BarWidth, ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize)
    sow.frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    sow.frame:Hide()

    sow.iconShield = ERASquareIcon:Create(sow.frame, "LEFT", ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize, 236265)
    sow.iconShield:Draw(ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize / 2, 0)
    sow.iconWOG = ERASquareIcon:Create(sow.frame, "RIGHT", ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize, 133192)
    sow.iconWOG:Draw(-ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize / 2, 0)

    local background = sow.frame:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", sow.frame, "TOPLEFT", ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize, 0)
    background:SetPoint("BOTTOMRIGHT", sow.frame, "BOTTOMRIGHT", -ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize, 0)
    background:SetColorTexture(0.0, 0.0, 0.0, 0.6)

    sow.tick = sow.frame:CreateLine(nil, "ARTWORK", "ERACombatTimersVerticalTick")

    -- calculs

    sow.playerGUID = UnitGUID("player")
    sow.playerLevel = UnitLevel("player")
    sow.shieldArmourTimer = shieldArmourTimer
    sow.health = health
    sow.holyPower = holyPower
    sow.freeWOG = freeWOG
    sow.firstLink = {}
    sow.firstLink.t = 0
    sow.firstLink.d = 0
    local prv = sow.firstLink
    for i = 1, 64 do
        local x = {}
        x.t = 0
        x.d = 0
        prv.nxt = x
        prv = x
    end
    prv.nxt = sow.firstLink
    sow.lastLink = sow.firstLink

    sow.lastFlashHeal = 0

    return sow
end

function ERACombatFrames_PaladinProtectionShieldOrWOG:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatFrames_PaladinProtectionShieldOrWOG:CheckTalents()
    self.playerLevel = UnitLevel("player")
end
function ERACombatFrames_PaladinProtectionShieldOrWOG:ResetToIdle()
    self.frame:Hide()
    self:resetData()
end
function ERACombatFrames_PaladinProtectionShieldOrWOG:EnterCombat(fromIdle)
    self.frame:Show()
    self.firstLink.t = GetTime()
end
function ERACombatFrames_PaladinProtectionShieldOrWOG:ExitCombat(toIdle)
    self.frame:Hide()
    self:resetData()
end
function ERACombatFrames_PaladinProtectionShieldOrWOG:resetData()
    self.lastLink = self.firstLink
    self.firstLink.d = 0
end

function ERACombatFrames_PaladinProtectionShieldOrWOG:CLEU(t)
    local _,
        evt,
        _,
        sourceGUY,
        _,
        _,
        _,
        destGUY,
        _,
        _,
        _,
        dmgIfSwing_spellIDIfSpell,
        _,
        schoolIfSwing_spellSchoolIfSpell,
        dmgIfSpell_blockedIfSwing,
        absorbIfSwing,
        schoolIfSpell,
        _,
        blockedIfSpell,
        absorbIfSpell = CombatLogGetCurrentEventInfo()
    if (evt == "SPELL_CAST_SUCCESS" and sourceGUY == self.playerGUID and dmgIfSwing_spellIDIfSpell == 19750) then
        self.lastFlashHeal = t
    end
    if (destGUY == self.playerGUID) then
        local damage
        if (evt == "SWING_DAMAGE") then
            if (schoolIfSwing_spellSchoolIfSpell == 1) then
                damage = dmgIfSwing_spellIDIfSpell
                if (dmgIfSpell_blockedIfSwing) then
                    damage = damage + dmgIfSpell_blockedIfSwing
                end
                if (absorbIfSwing) then
                    damage = damage + absorbIfSwing
                end
            else
                return
            end
        elseif (evt == "SPELL_DAMAGE" or evt == "SPELL_PERIODIC_DAMAGE") then
            if (schoolIfSpell == 1) then
                damage = dmgIfSpell_blockedIfSwing
                if (blockedIfSpell) then
                    damage = damage + blockedIfSpell
                end
                if (absorbIfSpell) then
                    damage = damage + absorbIfSpell
                end
            else
                return
            end
        else
            return
        end
        local _, effectiveArmor = UnitArmor("player")
        local armorpct = ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(effectiveArmor, UnitLevel("player"))
        local lk = self.lastLink.nxt
        if (lk == self.firstLink) then
            -- plus de place, on crée un maillon
            lk = {}
            lk.nxt = self.firstLink
            self.lastLink.nxt = lk
        end
        self.lastLink = lk
        lk.t = t
        lk.d = damage / (1 - armorpct)
    end
end

function ERACombatFrames_PaladinProtectionShieldOrWOG:UpdateCombat(t)
    while (true) do
        if (self.firstLink == self.lastLink) then
            break
        elseif (t - self.firstLink.t > ERACombatFrames_PaladinProtectionShieldOrWOG_Duration) then
            self.firstLink = self.firstLink.nxt
        else
            break
        end
    end
    local totalDamage = 0
    local totalWeight = 0
    local damageEventCount = 0
    local lk = self.firstLink
    while (true) do
        local weight = 1 - (t - lk.t) / ERACombatFrames_PaladinProtectionShieldOrWOG_Duration
        if (weight > 0) then
            weight = math.sqrt(weight + 0.07)
            totalDamage = totalDamage + lk.d * weight
            totalWeight = totalWeight + weight
            damageEventCount = damageEventCount + 1
        end
        if (lk == self.lastLink) then
            break
        else
            lk = lk.nxt
        end
    end
    local damagePrevision
    local shieldStat = GetShieldBlock()
    if (totalWeight > 0) then
        local block = GetBlockChance() * ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(shieldStat, self.playerLevel) / 100
        damagePrevision = damageEventCount * 4.5 * (totalDamage / totalWeight) / math.max(0.1, (t - self.firstLink.t)) * (1 - block)
    else
        damagePrevision = 0
    end

    local _, str = UnitStat("player", 1)
    local _, armorWithoutShield = UnitArmor("player")
    local shieldArmorAmount = 1.7 * str
    if (self.shieldArmourTimer.remDuration > 0) then
        armorWithoutShield = armorWithoutShield - shieldArmorAmount
    end
    local armorPctWithoutShield = ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(armorWithoutShield, self.playerLevel)
    local armorPctWithShield = ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(armorWithoutShield + shieldArmorAmount, self.playerLevel)

    local maxH = self.health.maxHealth
    local missingH = maxH - self.health.currentHealth
    local crit = GetCritChance() / 100
    local wog = 3.15 * GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
    local currentWOG = wog * (1 + 2.5 * missingH / maxH)
    local damageSavedByWOG = math.min(missingH, currentWOG) * (1 - crit) + crit * (math.min(missingH, 2 * currentWOG))
    local damageSavedByShield = damagePrevision * (armorPctWithShield - armorPctWithoutShield) + (1 + crit) * wog * 2.25 / 5 -- on considère un futur wog lancé à 50% de pv

    local tickPosition = damageSavedByWOG / (damageSavedByShield + damageSavedByWOG)
    if (damageSavedByWOG > damageSavedByShield) then
        self.iconShield:SetDesaturated(true)
        self.iconWOG:SetDesaturated(false)
        self.health:SetHealing(currentWOG)
        if (tickPosition > 0.95) then
            tickPosition = 0.95
        end
    else
        self.iconShield:SetDesaturated(false)
        self.iconWOG:SetDesaturated(true)
        self.health:SetHealing(0)
        if (tickPosition < 0.05) then
            tickPosition = 0.05
        end
    end
    tickPosition = tickPosition * ERACombatFrames_PaladinProtectionShieldOrWOG_BarWidth + ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize
    self.tick:SetStartPoint("TOPLEFT", self.frame, tickPosition, 0)
    self.tick:SetEndPoint("BOTTOMLEFT", self.frame, tickPosition, 0)
    if (self.freeWOG.remDuration > 0) then
        self.health.bar:SetPrevisionColor(0.5, 1.0, 1.0)
    else
        self.health.bar:SetPrevisionColor(0.5, 0.5, 1.0)
    end
end

function ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(stat, playerLevel)
    local value = C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(stat)
    if (not value) then
        value = C_PaperDollInfo.GetArmorEffectiveness(stat, playerLevel)
    end
    return value
end

------------------------------------------------------------------------------------------------------------------------
---- RETRIBUTION -------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PaladinRetributionSetup(cFrame)
    local talent_condemn = ERALIBTalent:Create(1, 3)
    local talent_orbitalstrike = ERALIBTalent:Create(7, 3)

    ERACombatHealth:Create(cFrame, -155, -62, 128, 22, 3)

    ERACombatPointsUnitPower:Create(cFrame, -144, -33, 9, 5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, nil, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -111, -11, 1.5, 3)

    ERACombatFrames_Paladin_simple_consecration(timers, -0.7, -0.7)

    timers:AddProc(timers:AddTrackedBuff(326733, ERALIBTalent:Create(2, 3)), nil, 0, 4, true)
    timers:AddAuraIcon(timers:AddTrackedBuff(114250, ERALIBTalent:Create(6, 1)), -3.7, 0, nil)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(20271), nil, 0, 2, true, true) -- judgement
    timers:AddCooldownIcon(timers:AddTrackedCooldown(35395), 135891, 0, 1, true, true) -- crusader strike
    timers:AddCooldownIcon(timers:AddTrackedCooldown(184575, ERALIBTalent:CreateLevel(19)), nil, 0, 0, true, true) -- blade of justice
    timers:AddCooldownIcon(timers:AddTrackedCooldown(255937, ERALIBTalent:CreateLevel(39)), nil, -1.7, -0.7, true, true) -- wake of ashes

    timers:AddAuraBar(timers:AddTrackedDebuff(343721, talent_orbitalstrike), nil, 0.0, 0.8, 1.0)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(343527, talent_condemn), nil, -2.7, -0.7, true, true) -- condemn
    timers:AddAuraBar(timers:AddTrackedDebuff(343527, talent_condemn), nil, 0.6, 0.2, 1.0)

    ERACombatFrames_Paladin_seraph(timers, 0.22, -0.88)

    timers:AddKick(96231, 1.5, 1, ERALIBTalent:CreateLevel(27))

    local pullUtility = ERACombatUtilityFrame:Create(cFrame, 0, 128, 3)
    pullUtility:AddCooldown(-0.5, 0, 184575, nil, false, ERALIBTalent:CreateLevel(19)) -- blade of light
    pullUtility:AddCooldown(0.5, 0, 20271, nil, false) -- judgement

    local utility, burstUtility = ERACombatFrames_Paladin_common_stuff(cFrame, timers, 64, -188, -166, -166, 0, 3, 184662, 213644, false, 231895, 231895, 7, 2, ERALIBTalent:CreateLevel(41), 3)
    utility:AddCooldown(-0.5, 0, 205191, nil, true, ERALIBTalent:Create(4, 3)) -- an eye for an eye
    utility:AddCooldown(1.5, 3.8, 183218, nil, true, ERALIBTalent:CreateLevel(18)) -- slow
    burstUtility:AddCooldown(0.5, -0.9, 343721, nil, true, talent_orbitalstrike)
end

------------------------------------------------------------------------------------------------------------------------
---- SHARED ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_Paladin_seraph(timers, x, y)
    local talent_seraph = ERALIBTalent:Create(5, 3)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(152262, talent_seraph), nil, x, y, true, true)
    timers:AddAuraBar(timers:AddTrackedBuff(152262, talent_seraph), nil, 1.0, 0.7, 0.7)
end

-- common avenging, execute, utility

function ERACombatFrames_Paladin_simple_consecration(timers, x, y)
    local consecrationCDTimer = timers:AddTrackedCooldown(26573)
    local consecrationBar = ERACombatFrames_PaladinConsecrationTimer_create(timers, false, consecrationCDTimer)
    local consecrationCDDisplay = timers:AddCooldownIcon(consecrationCDTimer, nil, x, y, false, true)
    function consecrationCDDisplay:ShouldShowMainIcon()
        if (self.cd.remDuration > 0) then
            self.icon:SetAlpha(0.5)
        else
            if (consecrationBar.remDuration > 0) then
                self.icon:SetAlpha(0.2)
            else
                self.icon:SetAlpha(1.0)
            end
        end
        return true
    end
end

function ERACombatFrames_Paladin_common_stuff(
    cFrame,
    timers,
    xUtility,
    yUtility,
    xBurst,
    yBurst,
    xHammerExecute,
    yHammerExecute,
    defenseID,
    dispellID,
    includeDispellMagic,
    avengerAlternativeSpellID,
    avengerAlternativeBuffID,
    avengerAlternativeTalentRow,
    avengerAlternativetalentColumn,
    talent_physicalprotection,
    spec)
    timers:AddAuraBar(timers:AddTrackedBuff(642), nil, 1, 1, 1)
    timers:AddAuraBar(timers:AddTrackedBuff(1022), nil, 0.7, 0.7, 0.7)

    local talent_avenging = ERALIBTalent:CreateNotTalent(avengerAlternativeTalentRow, avengerAlternativetalentColumn, 37)
    local talent_alternative_avenging = ERALIBTalent:Create(avengerAlternativeTalentRow, avengerAlternativetalentColumn)

    -- main utility

    local utility = ERACombatUtilityFrame:Create(cFrame, xUtility, yUtility, spec)
    utility:AddCooldown(0.5, 0, defenseID, nil, true, ERALIBTalent:CreateLevel(26)) -- defense
    utility:AddCooldown(1.5, 0, 6940, nil, true, ERALIBTalent:CreateLevel(32)) -- sacrifice
    if (includeDispellMagic) then
        utility:AddDefensiveDispellCooldown(2, -0.9, dispellID, nil, ERALIBTalent:CreateLevel(12), "Magic", "Poison", "Disease")
    else
        utility:AddDefensiveDispellCooldown(2, -0.9, dispellID, nil, ERALIBTalent:CreateLevel(12), "Poison", "Disease")
    end
    local forebearance = utility:AddDebuffAnyCasterIcon(utility:AddTrackedDebuffAnyCaster(25771), 132358, -2, -0.9, true, nil)
    forebearance.reverse = true
    forebearance.fade = false
    ERACombatFrames_PaladinUtilityAffectedByForebearance(utility:AddCooldown(-1, -0.9, 633, nil, true), forebearance) -- impo
    ERACombatFrames_PaladinUtilityAffectedByForebearance(utility:AddCooldown(0, -0.9, 642, nil, true), forebearance) -- divine shield
    ERACombatFrames_PaladinUtilityAffectedByForebearance(utility:AddCooldown(1, -0.9, 1022, nil, true, ERALIBTalent:CreateLevel(41)), forebearance) -- protection
    utility:AddCooldown(-0.5, -1.8, 62124, nil, true, ERALIBTalent:CreateLevel(14)).alphaWhenOffCooldown = 0.05 -- taunt
    utility:AddRacial(0.5, -1.8).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(1.5, -1.8, 10326, nil, true, ERALIBTalent:CreateLevel(24)).alphaWhenOffCooldown = 0.1 -- turn evil
    utility:AddWarlockHealthStone(2.5, -1.8)
    utility:AddWarlockPortal(3.5, -1.8)
    utility:AddBeltCooldown(-1.5, -1.8).alphaWhenOffCooldown = 0.3
    utility:AddCloakCooldown(-2.5, -1.8).alphaWhenOffCooldown = 0.3

    utility:AddCovenantGenericAbility(1, 0.9)

    utility:AddCooldown(1.5, 2.8, 853, nil, true) -- stun hammer
    utility:AddCooldown(2.5, 2.8, 20066, nil, true, ERALIBTalent:Create(3, 2)) -- repent !
    utility:AddCooldown(2.5, 2.8, 115750, nil, true, ERALIBTalent:Create(3, 3)) -- blinding light
    utility:AddCooldown(1.5, 1.8, 190784, nil, true, ERALIBTalent:CreateLevel(17)) -- horse
    utility:AddCooldown(2.5, 1.8, 1044, nil, true, ERALIBTalent:CreateLevel(22)) -- freedom

    local burstUtility = ERACombatUtilityFrame:Create(cFrame, xBurst, yBurst, spec)
    burstUtility:AddCooldown(0, 0, 31884, nil, true, talent_avenging)
    burstUtility:AddCooldown(0, 0, avengerAlternativeSpellID, nil, true, talent_alternative_avenging)
    burstUtility:AddTrinket1Cooldown(-0.5, -0.9)
    burstUtility:AddTrinket2Cooldown(-1.5, -0.9)

    burstUtility:AddCovenantClassAbility(1, 0, 304971, 316958, nil, 328204)
    --burstUtility:AddCooldown(1, 0, 328281, 3636846, true, ERALIBTalent_Nightfae).showOnlyIfSpellUsable = true
    --burstUtility:AddCooldown(1, 0, 328282, 3636844, true, ERALIBTalent_Nightfae).showOnlyIfSpellUsable = true
    --burstUtility:AddCooldown(1, 0, 328620, 3636845, true, ERALIBTalent_Nightfae).showOnlyIfSpellUsable = true
    --burstUtility:AddCooldown(1, 0, 328622, 3636843, true, ERALIBTalent_Nightfae).showOnlyIfSpellUsable = true
    local talent_nightfae =
        ERALIBTalent:CreateOr(
        ERALIBTalent:CreateNightfaeOrSpellKnown(328281),
        ERALIBTalent:CreateNightfaeOrSpellKnown(328282),
        ERALIBTalent:CreateNightfaeOrSpellKnown(328620),
        ERALIBTalent:CreateNightfaeOrSpellKnown(328622)
    )
    ERACombatFrames_PaladinNightfae(burstUtility, 328281, 3636846, 1, 0, talent_nightfae)
    ERACombatFrames_PaladinNightfae(burstUtility, 328282, 3636844, 1, 0, talent_nightfae)
    ERACombatFrames_PaladinNightfae(burstUtility, 328620, 3636845, 1, 0, talent_nightfae)
    ERACombatFrames_PaladinNightfae(burstUtility, 328622, 3636843, 1, 0, talent_nightfae)

    -- common talents
    local talent_double_holy = ERALIBTalent:Create(5, 2)
    timers:AddAuraBar(timers:AddTrackedBuff(105809, talent_double_holy), nil, 0.2, 0.7, 0.7)
    burstUtility:AddCooldown(-1, 0, 105809, nil, true, talent_double_holy)

    -- avenging wrath

    local avengingBuff = timers:AddTrackedBuff(31884, talent_avenging)
    timers:AddAuraBar(avengingBuff, nil, 1.0, 0.9, 0.4)
    local alternativeAvengingBuff = nil
    if (avengerAlternativeBuffID > 0) then
        alternativeAvengingBuff = timers:AddTrackedBuff(avengerAlternativeBuffID, talent_alternative_avenging)
        timers:AddAuraBar(alternativeAvengingBuff, nil, 1.0, 0.9, 0.4)
    end

    -- exec
    local iconHammerExecute = timers:AddCooldownIcon(timers:AddTrackedCooldown(24275, ERALIBTalent:CreateLevel(46)), nil, xHammerExecute, yHammerExecute, true, true)
    function iconHammerExecute:ShouldShowMainIcon()
        --[[
        local durWrath
        if (alternativeAvengingBuff and alternativeAvengingBuff.talentActive) then
            durWrath = alternativeAvengingBuff.remDuration
        else
            durWrath = avengingBuff.remDuration
        end
        if (durWrath > 0) then
            iconHammerExecute.hammerUsable = durWrath > iconHammerExecute.cd.remDuration
        else
            if (UnitExists("target")) then
                iconHammerExecute.hammerUsable = UnitHealth("target") / UnitHealthMax("target") < 0.2
            else
                iconHammerExecute.hammerUsable = false
            end
        end
        ]]
        iconHammerExecute.hammerUsable = IsUsableSpell(24275)
        if (iconHammerExecute.hammerUsable) then
            iconHammerExecute.icon:SetAlpha(1.0)
            return true
        elseif (iconHammerExecute.cd.remDuration > 0) then
            iconHammerExecute.icon:SetAlpha(0.5)
            return true
        else
            return false
        end
    end
    function iconHammerExecute:OverrideTimerVisibility()
        return iconHammerExecute.hammerUsable
    end

    return utility, burstUtility, forebearance
end
function ERACombatFrames_PaladinNightfae(utility, spellID, iconID, x, y, talent_nightfae)
    local cd = utility:AddCooldown(x, y, spellID, iconID, true, talent_nightfae)
    function cd:IconUpdatedAndShown(t)
        local type
        local id
        if (not self.slot) then
            self.slot = -1
            for s = 1, 72 do
                type, id = GetActionInfo(s)
                if (type == "spell" and (id == 328281 or id == 328282 or id == 328620 or id == 328622)) then
                    self.slot = s
                    break
                end
            end
        end
        if (self.slot > 0) then
            type, id = GetActionInfo(self.slot)
            if ((type ~= "spell" or id ~= self.spellID) and self.spell ~= 328281) then
                self.icon:Hide()
            end
        elseif (self.spellID ~= 328281) then
            self.icon:Hide()
        end
    end
end
function ERACombatFrames_PaladinUtilityAffectedByForebearance(icon, forebearance)
    function icon:IconUpdatedAndShown(t)
        if (self.remDuration > 0 or forebearance.aura.remDuration <= 0) then
            self.icon:SetVertexColor(1, 1, 1, 1)
        else
            self.icon:SetVertexColor(1, 0, 0, 1)
        end
    end
end

-- consecration

function ERACombatFrames_PaladinConsecrationTimer_create(timers, checkInside, consecrationCD)
    local c = timers:AddTotemBar(1, 135926, 0.8, 0.8, 0.0)
    c.consecrationCD = consecrationCD
    if (checkInside) then
        c.inside = timers:AddTrackedBuff(188370)
        function c:UpdatingDuration(t, remDuration)
            if (self.consecrationCD.remDuration > 0) then
                if (self.inside.stacks > 0) then
                    self.view:SetColor(0.6, 0.6, 0.0)
                else
                    self.view:SetColor(0.6, 0.1, 0.0)
                end
            else
                if (self.inside.stacks > 0) then
                    self.view:SetColor(0.9, 0.9, 0.0)
                else
                    self.view:SetColor(1.0, 0.0, 0.0)
                end
            end
            return remDuration
        end
    else
        function c:UpdatingDuration(t, remDuration)
            if (self.consecrationCD.remDuration > 0) then
                self.view:SetColor(0.8, 0.8, 0.0)
            else
                self.view:SetColor(1.0, 0.0, 0.0)
            end
            return remDuration
        end
    end
    return c
end

ERACombatFrames_PaladinConsecrationMissing = {}
ERACombatFrames_PaladinConsecrationMissing.__index = ERACombatFrames_PaladinConsecrationMissing
setmetatable(ERACombatFrames_PaladinConsecrationMissing, ERACombatTimersHintIcon)

function ERACombatFrames_PaladinConsecrationMissing:create(bar, x, y, ccd)
    local cm = {}
    setmetatable(cm, ERACombatFrames_PaladinConsecrationMissing)
    cm:construct(bar.group, 135926, x, y, true)
    cm.bar = bar
    cm.ccd = ccd
    return cm
end

function ERACombatFrames_PaladinConsecrationMissing:ComputeIsVisible(t)
    return self.ccd.remDuration <= 0 and self.bar.remDuration <= 0
end

------------------------------------------------------------------------------------------------------------------------
---- AURAS -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatFrames_PaladinAuras = {}
ERACombatFrames_PaladinAuras.__index = ERACombatFrames_PaladinAuras
setmetatable(ERACombatFrames_PaladinAuras, {__index = ERACombatModule})

function ERACombatFrames_PaladinAuras:create(cFrame, x, y, ...)
    local a = {}
    setmetatable(a, ERACombatFrames_PaladinAuras)
    a:construct(cFrame, 0.5, 0.5, false, ...)

    a.frame = CreateFrame("Frame", nil, UIParent, nil)
    a.frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    a.frame:SetSize(128, 128)
    a.icon = ERASquareIcon:Create(a.frame, "CENTER", 64, 135893)
    a.icon:Draw(0, 0)
    a.icon:Hide()
    a.frame:Hide()
    a.active = false

    a.level = 0
    a.aurasByID = {}
    a.crusader = a:makeAura(32223, 135890, 21)
    a.devotion = a:makeAura(465, 135893, 28)
    a.retribution = a:makeAura(183435, 135889, 38)
    a.concentration = a:makeAura(317920, 135933, 52)
    a.paladins = {}
    a.groupChange = 0
    a.inGroup = false

    a.events = {}
    function a.events:GROUP_ROSTER_UPDATE()
        a:updateMembers()
    end
    function a.events:GROUP_JOINED()
        a:updateMembers()
    end
    function a.events:GROUP_LEFT()
        a:updateMembers()
    end
    a.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            a.events[event](self, ...)
        end
    )

    return a
end
function ERACombatFrames_PaladinAuras:makeAura(id, icon, level)
    local a = {}
    a.active = false
    a.level = level
    a.id = id
    a.icon = icon
    self.aurasByID[id] = a
    return a
end

function ERACombatFrames_PaladinAuras:CheckTalents()
    self.level = UnitLevel("player")
    if (self.level < 21) then
        self.active = false
        self.frame:Hide()
    else
        self.active = true
        self.frame:Show()
    end
end
function ERACombatFrames_PaladinAuras:SpecInactive(wasActive)
    self.frame:Hide()
end

function ERACombatFrames_PaladinAuras:EnterVehicle(fromCombat)
    self.frame:Hide()
end
function ERACombatFrames_PaladinAuras:ExitVehicle(toCombat)
    self.frame:Show()
end

function ERACombatFrames_PaladinAuras:ResetToIdle()
    self:updateMembers()
end

function ERACombatFrames_PaladinAuras:updateMembers()
    if (IsInGroup()) then
        self.inGroup = true
        local t = GetTime()
        if (self.groupChange) then
            self.groupChange = math.max(self.groupChange, t - 2.5)
        else
            self.groupChange = t
        end
    else
        self.inGroup = false
        self.icon:StopBeam()
        self.groupChange = nil
        self.paladins = {}
    end
end

function ERACombatFrames_PaladinAuras:UpdateCombat(t)
    self:update(t, true)
end
function ERACombatFrames_PaladinAuras:UpdateIdle(t)
    self:update(t, false)
end
function ERACombatFrames_PaladinAuras:update(t, combat)
    if (self.active) then
        for _, v in pairs(self.aurasByID) do
            v.active = false
            v.byPlayer = false
            v.byOtherPaladin = false
        end
        local activeCount = 0
        local oneByPlayer = false
        for i = 1, 40 do
            local _, _, stacks, _, durAura, expirationTime, source, _, _, spellID = UnitBuff("player", i)
            if (spellID) then
                local a = self.aurasByID[spellID]
                if (a ~= nil) then
                    if (not a.active) then
                        activeCount = activeCount + 1
                        a.active = true
                    end
                    if (source == "player") then
                        a.byPlayer = true
                        oneByPlayer = true
                    end
                end
            else
                break
            end
        end

        if (self.groupChange) then
            if (self.groupChange + 3 <= t) then
                self.icon:Hide()
                return
            else
                self.groupChange = nil
                self.paladins = {}
                if (IsInGroup()) then
                    self.inGroup = true
                    self.icon:Beam()
                    local prefix
                    local maxi = GetNumGroupMembers()
                    if (IsInRaid()) then
                        prefix = "raid"
                    else
                        prefix = "party"
                    end
                    for i = 1, maxi do
                        local unit = prefix .. i
                        if (not UnitIsUnit(unit, "player")) then
                            local _, _, classID = UnitClass(unit)
                            if (classID == 2) then
                                table.insert(self.paladins, unit)
                            end
                        end
                    end
                else
                    self.inGroup = false
                    self.icon:StopBeam()
                end
            end
        end

        local pCount = 1
        for _, p in ipairs(self.paladins) do
            if (UnitInRange(p)) then
                pCount = pCount + 1
                for i = 1, 40 do
                    local _, _, stacks, _, durAura, expirationTime, source, _, _, spellID = UnitBuff(p, i)
                    if (spellID) then
                        local a = self.aurasByID[spellID]
                        if (a ~= nil and source == p) then
                            a.byOtherPaladin = true
                        end
                    else
                        break
                    end
                end
            end
        end

        if (IsMounted()) then
            if (self.crusader.active) then
                if (self.crusader.byPlayer) then
                    self.icon:Hide()
                    return
                end
            else
                self.icon:SetIconTexture(self.crusader.icon)
                self.icon:Show()
                return
            end
        end
        if (oneByPlayer) then
            -- ici, notre propre aura du croisé n'est pas active, ou pas utile
            if (self.retribution.active and self.retribution.byPlayer) then
                if (self.inGroup) then
                    self.icon:Hide()
                else
                    self.icon:SetIconTexture(self.devotion.icon)
                    self.icon:Show()
                end
            else
                local missingAura
                if (self.level >= self.retribution.level) then
                    missingAura = self.retribution
                else
                    missingAura = nil
                end
                local availableAura = self.crusader.byPlayer and combat
                missingAura, availableAura = self:computeAura(self.concentration, missingAura, availableAura)
                missingAura, availableAura = self:computeAura(self.devotion, missingAura, availableAura)
                if (missingAura and availableAura) then
                    self.icon:SetIconTexture(missingAura.icon)
                    self.icon:Show()
                else
                    self.icon:Hide()
                end
            end
        else
            self.icon:SetIconTexture(self.devotion.icon)
            self.icon:Show()
        end
    end
end
function ERACombatFrames_PaladinAuras:computeAura(a, missing, available)
    if (self.level >= a.level) then
        if (a.active) then
            if (a.byPlayer and a.byOtherPaladin) then
                return missing, true
            else
                return missing, available
            end
        else
            return a, available
        end
    else
        return missing, available
    end
end
