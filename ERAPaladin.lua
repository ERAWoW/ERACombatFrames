function ERACombatFrames_PaladinSetup(cFrame)
    ERAPieIcon_BorderR = 1.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 1.0

    local holyActive = ERACombatOptions_IsSpecActive(1)
    local protectionActive = ERACombatOptions_IsSpecActive(2)
    local retributionActive = ERACombatOptions_IsSpecActive(3)

    ERAOutOfCombatStatusBars:Create(cFrame, -155, -66, 128, 22, 0, true, 0.1, 0.1, 1.0, false, holyActive, protectionActive, retributionActive)

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
    ERACombatPower:Create(cFrame, -210, -166, 155, 22, 0, false, 0.2, 0.2, 1.0, 1)
    ERACombatPointsUnitPower:Create(cFrame, -200, -111, 9, 5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, nil, 1)

    local grid = ERACombatGrid:Create(cFrame, -111, -8, "BOTTOMRIGHT", 1, 4987, "Magic", "Disease", "Poison")
    --, "Curse")
    grid:AddTrackedBuff(53563, nil) -- beacon
    grid:AddTrackedBuff(156910, nil, 1) -- beacon 2
    grid:AddTrackedBuff(287280, nil) -- glimmer

    local timers = ERACombatTimersGroup:Create(cFrame, -128, -88, 1.5, 1)

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

    local utility, tricksUtility = ERACombatFrames_Paladin_common_stuff(cFrame, timers, 100, -188, 128, 0, 1.5, 2.5, 498, 4987, false, 216331, 216331, 6, 2, ERALIBTalent:CreateLevel(41), 1)
    utility:AddCooldown(-0.5, 0, 31821, nil, true, ERALIBTalent:CreateLevel(39)) -- aura mastery

    --ERACombat_TimerBarDefaultSize = remember_default_bar_size
end

------------------------------------------------------------------------------------------------------------------------
---- PROTECTION --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PaladinProtectionSetup(cFrame)
    local health = ERACombatHealth:Create(cFrame, -177, -64, 155, 22, 2)
    local holyPower = ERACombatPointsUnitPower:Create(cFrame, -155, -36, 9, 5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, nil, 2)

    local timers = ERACombatTimersGroup:Create(cFrame, -123, -32, 1.5, 2)

    local consecration = ERACombatFrames_PaladinConsecrationTimer_create(timers, true)
    local consecrationCDTimer = timers:AddTrackedCooldown(26573)
    ERACombatFrames_PaladinConsecrationMissing:create(consecration, 0, 4, consecrationCDTimer)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(20271), nil, 0, 2, true, true) -- judgement
    timers:AddCooldownIcon(timers:AddTrackedCooldown(53595, ERALIBTalent:CreateNotTalent(1, 3)), 135891, 0, 1, true, true) -- normal hammer
    timers:AddCooldownIcon(timers:AddTrackedCooldown(204019, ERALIBTalent:Create(1, 3)), 135891, 0, 1, true, true) -- blessed hammer
    timers:AddCooldownIcon(timers:AddTrackedCooldown(31935), nil, 0, 0, true, true) -- avenger
    timers:AddKick(96231, 1, 0, ERALIBTalent:CreateLevel(27))

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

    local utility, tricksUtility, forebearance =
        ERACombatFrames_Paladin_common_stuff(cFrame, timers, 44, -166, 144, 0, 0, 3, 31850, 213644, false, -1, -1, 0, 0, ERALIBTalent:CreateNotTalent(4, 3, 41), 2)
    utility:AddCooldown(-0.5, 0, 86659, nil, true) -- king
    utility:AddCooldown(-1.5, 0, 327193, nil, true, ERALIBTalent:Create(2, 3)) -- reset shield
    ERACombatFrames_PaladinUtilityAffectedByForebearance(utility:AddCooldown(1, -0.9, 204018, nil, true, ERALIBTalent:Create(4, 3)), forebearance) -- alternative protection

    local sow = ERACombatFrames_PaladinProtectionShieldOrWOG:create(cFrame, -188, -101, health, shieldArmour, holyPower)

    local mana = ERACombatPower:Create(cFrame, -177, -155, 144, 22, 0, false, 0.2, 0.2, 1.0, 2)
    function mana:ShouldBeVisible(t)
        return self.currentPower / self.maxPower < 0.5 or t < sow.lastFlashHeal + 5
    end
end

ERACombatFrames_PaladinProtectionShieldOrWOG_IconSize = 22
ERACombatFrames_PaladinProtectionShieldOrWOG_BarWidth = 64
ERACombatFrames_PaladinProtectionShieldOrWOG_Duration = 9

ERACombatFrames_PaladinProtectionShieldOrWOG = {}
ERACombatFrames_PaladinProtectionShieldOrWOG.__index = ERACombatFrames_PaladinProtectionShieldOrWOG
setmetatable(ERACombatFrames_PaladinProtectionShieldOrWOG, {__index = ERACombatModule})

function ERACombatFrames_PaladinProtectionShieldOrWOG:create(cFrame, x, y, health, shieldArmourTimer, holyPower)
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
    sow.shieldArmourTimer = shieldArmourTimer
    sow.health = health
    sow.holyPower = holyPower
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
    local level = UnitLevel("player")

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
        local block = GetBlockChance() * ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(shieldStat, level) / 100
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
    local armorPctWithoutShield = ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(armorWithoutShield, level)
    local armorPctWithShield = ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(armorWithoutShield + shieldArmorAmount, level)

    local maxH = self.health.maxHealth
    local missingH = maxH - self.health.currentHealth
    local crit = GetCritChance() / 100
    local wog = 2.9 * GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100)
    local currentWOG = wog * (1 + 3 * missingH / maxH)
    local damageSavedByWOG = math.min(missingH, currentWOG) * (1 - crit) + crit * (math.min(missingH, 2 * currentWOG))
    local damageSavedByShield = damagePrevision * (armorPctWithShield - armorPctWithoutShield) + (1 + crit) * wog * 2.5 / 5 -- on considère un futur wog lancé à 50% de pv

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
end

function ERACombatFrames_PaladinProtectionShieldOrWOG_getArmorPct(stat, level)
    local value = C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(stat)
    if (not value) then
        value = C_PaperDollInfo.GetArmorEffectiveness(stat, level)
    end
    return value
end

------------------------------------------------------------------------------------------------------------------------
---- RETRIBUTION -------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PaladinRetributionSetup(cFrame)
    local talent_condemn = ERALIBTalent:Create(1, 3)

    ERACombatHealth:Create(cFrame, -155, -62, 128, 22, 3)

    ERACombatPointsUnitPower:Create(cFrame, -144, -33, 9, 5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, nil, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -111, -11, 1.5, 3)

    ERACombatFrames_Paladin_simple_consecration(timers, -0.7, -0.7)

    timers:AddProc(timers:AddTrackedBuff(326733, ERALIBTalent:Create(2, 3)), nil, 0, 3, true)
    timers:AddAuraIcon(timers:AddTrackedBuff(114250, ERALIBTalent:Create(6, 1)), -3.7, 0, nil)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(20271), nil, 0, 2, true, true) -- judgement
    timers:AddCooldownIcon(timers:AddTrackedCooldown(35395), 135891, 0, 1, true, true) -- crusader strike
    timers:AddCooldownIcon(timers:AddTrackedCooldown(184575, ERALIBTalent:CreateLevel(19)), nil, 0, 0, true, true) -- blade of justice
    timers:AddCooldownIcon(timers:AddTrackedCooldown(255937, ERALIBTalent:CreateLevel(39)), nil, -1.7, -0.7, true, true) -- wake of ashes
    timers:AddCooldownIcon(timers:AddTrackedCooldown(343721, ERALIBTalent:Create(7, 3)), nil, -2.7, -0.7, true, true) -- orbital strike

    timers:AddCooldownIcon(timers:AddTrackedCooldown(343527, talent_condemn), nil, -1.2, -1.44, true, true) -- condemn
    timers:AddAuraBar(timers:AddTrackedDebuff(343527, talent_condemn), nil, 0.6, 0.2, 1.0)

    ERACombatFrames_Paladin_seraph(timers, -2.2, -1.44)

    timers:AddKick(96231, 0.5, -1, ERALIBTalent:CreateLevel(27))

    local pullUtility = ERACombatUtilityFrame:Create(cFrame, 0, 128, 3)
    pullUtility:AddCooldown(-0.5, 0, 184575, nil, false, ERALIBTalent:CreateLevel(19)) -- blade of light
    pullUtility:AddCooldown(0.5, 0, 20271, nil, false) -- judgement

    local utility, tricksUtility = ERACombatFrames_Paladin_common_stuff(cFrame, timers, 32, -188, 144, 0, 0, 3, 184662, 213644, false, 231895, 231895, 7, 2, ERALIBTalent:CreateLevel(41), 3)
    utility:AddCooldown(-0.5, 0, 205191, nil, true, ERALIBTalent:Create(4, 3)) -- an eye for an eye
    tricksUtility:AddCooldown(0, 2, 183218, nil, true, ERALIBTalent:CreateLevel(18)) -- slow
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
    local consecrationBar = ERACombatFrames_PaladinConsecrationTimer_create(timers)
    local consecrationCDTimer = timers:AddTrackedCooldown(26573)
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
    xUtilityTricks,
    yUtilityTricks,
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
    utility:AddCooldown(1, 0.9, 31884, nil, true, talent_avenging)
    utility:AddCooldown(1, 0.9, avengerAlternativeSpellID, nil, true, talent_alternative_avenging)
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
    utility:AddMissingBuffAnyCaster(135893, -1.5, -1.8, ERALIBTalent:CreateLevel(21), 465, 32223, 183435)
    utility:AddCooldown(-0.5, -1.8, 62124, nil, true, ERALIBTalent:CreateLevel(14)).alphaWhenOffCooldown = 0.05 -- taunt
    utility:AddRacial(0.5, -1.8).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(1.5, -1.8, 10326, nil, true, ERALIBTalent:CreateLevel(24)).alphaWhenOffCooldown = 0.1 -- turn evil
    utility:AddWarlockHealthStone(2.5, -1.8)
    utility:AddWarlockPortal(3.5, -1.8)

    -- tricks/CC utility

    local tricksUtility = ERACombatUtilityFrame:Create(cFrame, xUtilityTricks, yUtilityTricks, spec)
    tricksUtility:AddCooldown(0, 1, 853, nil, true) -- stun hammer
    tricksUtility:AddCooldown(1, 1, 20066, nil, true, ERALIBTalent:Create(3, 2)) -- repent !
    tricksUtility:AddCooldown(1, 1, 115750, nil, true, ERALIBTalent:Create(3, 3)) -- blinding light
    tricksUtility:AddCooldown(0, 0, 190784, nil, true, ERALIBTalent:CreateLevel(17)) -- horse
    tricksUtility:AddCooldown(1, 0, 1044, nil, true, ERALIBTalent:CreateLevel(22)) -- freedom

    -- common talents
    local talent_double_holy = ERALIBTalent:Create(5, 2)
    timers:AddAuraBar(timers:AddTrackedBuff(105809, talent_double_holy), nil, 0.2, 0.7, 0.7)
    utility:AddCooldown(2, 0.9, 105809, nil, true, talent_double_holy)

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

    return utility, tricksUtility, forebearance
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

function ERACombatFrames_PaladinConsecrationTimer_create(timers, checkInside)
    local c = timers:AddTotemBar(1, 135926, 0.8, 0.8, 0.0)
    if (checkInside) then
        c.inside = timers:AddTrackedBuff(188370)
        function c:UpdatingDuration(t, remDuration)
            if (self.inside.stacks > 0) then
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
