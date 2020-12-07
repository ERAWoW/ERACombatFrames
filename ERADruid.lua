-- TODO
-- prendre en compte l'écart d'nrj entre morsure et rip
-- prendre en compte la maîtrise pour le calcul des dégâts de rake et thrash
-- prendre en compte étripage
-- éclipse pour affinité moonkin
-- vérifier le scaling des hots pour le score flourish

--[[
    #showtooltip
/cast [talent:1/2][@mouseover,exists,help,nodead][exists,help,nodead][@player] Nourrir;[talent:1/3][@mouseover,exists,help,nodead][exists,help,nodead][@player] Protection cénarienne
]]
function ERACombatFrames_DruidSetup(cFrame)
    ERACombatGlobals_SpecID1 = 102
    ERACombatGlobals_SpecID2 = 103
    ERACombatGlobals_SpecID3 = 104
    ERACombatGlobals_SpecID4 = 105

    ERAPieIcon_BorderR = 0.7
    ERAPieIcon_BorderG = 0.6
    ERAPieIcon_BorderB = 0.1

    local moonkinActive = ERACombatOptions_IsSpecActive(1)
    local catActive = ERACombatOptions_IsSpecActive(2)
    local bearActive = ERACombatOptions_IsSpecActive(3)
    local treeActive = ERACombatOptions_IsSpecActive(4)

    local restorationAffinity = ERACombatUtilityFrame:Create(cFrame, -144, -222, moonkinActive, catActive, bearActive)
    restorationAffinity:AddCooldown(-1, 0, 18562, nil, true, ERALIBTalent:Create(3, 3)) -- swiftmend
    restorationAffinity:AddCooldown(0, 0, 48438, nil, true, ERALIBTalent:Create(3, 3)) -- wild growth

    if (moonkinActive) then
        ERACombatFrames_DruidMoonkinSetup(cFrame)
    end
    if (catActive) then
        ERACombatFrames_DruidCatSetup(cFrame)
    end
    if (bearActive) then
        ERACombatFrames_DruidBearSetup(cFrame)
    end
    if (treeActive) then
        ERACombatFrames_DruidTreeSetup(cFrame)
    end
    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- BALANCE -----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DruidMoonkinSetup(cFrame)
    local talent_alignment = ERALIBTalent:CreateNotTalent(5, 3, 39)
    local talent_incarnation = ERALIBTalent:Create(5, 3)
    local talent_twinmoons = ERALIBTalent:Create(6, 2)
    local talent_singlemoon = ERALIBTalent:CreateNotTalent(6, 2)
    local talent_moon_phases = ERALIBTalent:Create(7, 3)

    ERAOutOfCombatStatusBars:Create(cFrame, -128, -36, 128, 22, 8, false, 0.8, 0.5, 1.0, false, 1) -- lunar 8
    ERACombatHealth:Create(cFrame, -177, -48, 166, 22, 1)

    local lunar = ERACombatPower:Create(cFrame, -177, -22, 166, 22, 8, true, 0.8, 0.5, 1.0, 1)
    --lunar.bar:SetBorderColor(0.7, 0.4, 1)
    lunar:AddConsumer(30, 135730)
    lunar:AddConsumer(50, 236168)

    ERACombatFrames_DruidMoonkinEclipseIcons:create(cFrame, -66, 44)

    local timers = ERACombatTimersGroup:Create(cFrame, -123, 0, 1.5, 1)

    timers:AddAuraBar(timers:AddTrackedBuff(191034), nil, 0.5, 0.8, 1.0) -- starfall

    local alignmentTimer = timers:AddTrackedBuff(194223, talent_alignment)
    timers:AddAuraBar(alignmentTimer, nil, 1.0, 0.0, 0.0)
    local incarnationTimer = timers:AddTrackedBuff(102560, talent_incarnation)
    timers:AddAuraBar(incarnationTimer, nil, 1.0, 0.0, 0.0)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(202425, ERALIBTalent:Create(1, 2)), nil, 0, 1, false, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(205636, ERALIBTalent:Create(1, 3)), nil, 0, 1, false, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(202770, ERALIBTalent:Create(7, 2)), nil, 0, 0, true, true)
    local moonPhasesDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(274281, talent_moon_phases), nil, 0, 0, true, true)
    function moonPhasesDisplay:ShouldShowMainIcon()
        local _, _, iconID = GetSpellInfo(274281)
        self.icon:SetIconTexture(iconID)
        return true
    end
    --timers:AddCooldownIcon(timers:AddTrackedCooldown(274282, talent_moon_phases), nil, 0, 0, true, true)
    --timers:AddCooldownIcon(timers:AddTrackedCooldown(274283, talent_moon_phases), nil, 0, 0, true, true)
    timers:AddKick(78675, 1, 0, ERALIBTalent:CreateLevel(26))
    timers:AddOffensiveDispellCooldown(2908, 1, -1, ERALIBTalent:CreateLevel(41), "Enrage")

    local lunarEclipseDisplay = timers:AddAuraBar(timers:AddTrackedBuff(48518), nil, 0.0, 0.0, 1.0)
    ERACombatFrames_DruidMoonkinEclipseAuraBarSetup(lunarEclipseDisplay, alignmentTimer, incarnationTimer)
    local solarEclipseDisplay = timers:AddAuraBar(timers:AddTrackedBuff(48517), nil, 1.0, 1.0, 0.0)
    ERACombatFrames_DruidMoonkinEclipseAuraBarSetup(solarEclipseDisplay, alignmentTimer, incarnationTimer)

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        1,
        function(tracker)
            local cpt = tracker.enemiesTracker:GetEnemiesCount()
            if (cpt > 1) then
                --0.765*(1+(cpt-1)/3)*1.5/2.25
                return 0.51 * (1 + (cpt - 1) / 3)
            else
                return 0.6
            end
        end
    )
    local moonDOT =
        dotracker:AddDOT(
        164812,
        nil,
        0.0,
        0.0,
        1.0,
        0,
        function(dotDef, hasteMod)
            return 22
        end,
        function(dotDef, currentTarget)
            return 0.2, 1.9
        end,
        talent_singlemoon
    )
    local moonDOTtwin =
        dotracker:AddDOT(
        164812,
        nil,
        0.0,
        0.0,
        1.0,
        0,
        function(dotDef, hasteMod)
            return 22
        end,
        function(dotDef, currentTarget)
            return 0.2, 1.9, 1, true
        end,
        talent_twinmoons
    )
    local sunDOT =
        dotracker:AddDOT(
        164815,
        nil,
        1.0,
        1.0,
        0.0,
        0,
        function(dotDef, hasteMod)
            return 18
        end,
        function(dotDef, currentTarget)
            return 0.2, 1.56, -1, false
        end
    )
    local flareDOT =
        dotracker:AddDOT(
        202347,
        nil,
        1.0,
        1.0,
        1.0,
        1.5,
        function(dotDef, hasteMod)
            return 24
        end,
        function(dotDef, currentTarget)
            return 0.125, 1.05
        end,
        ERALIBTalent:Create(6, 3)
    )

    local moonUtility = ERACombatUtilityFrame:Create(cFrame, -188, -111, 1)
    moonUtility:AddTrinket2Cooldown(-2, 0)
    moonUtility:AddTrinket1Cooldown(-1, 0)
    moonUtility:AddCooldown(0, 0, 194223, nil, true, talent_alignment)
    moonUtility:AddBuffIcon(moonUtility:AddTrackedBuff(194223, talent_alignment), 613074, 0, 0, false)
    moonUtility:AddCooldown(0, 0, 102560, nil, true, talent_incarnation)
    moonUtility:AddBuffIcon(moonUtility:AddTrackedBuff(102560, talent_incarnation), 613074, 0, 0, false)
    ERACombatFrames_DruidCovenantClass(timers, moonUtility, 1, 0)

    local utility = ERACombatFrames_DruidCommonUtility(cFrame, timers, 188, -220, 1, 132469, 28, 2782, "Curse", "Poison")
    ERACombatFrames_DruidCatAffinityCC(utility, ERALIBTalent:Create(3, 1))
    ERACombatFrames_DruidBearAffinityCC(utility, ERALIBTalent:Create(3, 2))
    ERACombatFrames_DruidTreeAffinityCC(utility, ERALIBTalent:Create(3, 3))
end

function ERACombatFrames_DruidMoonkinEclipseAuraBarSetup(bar, alignmentTimer, incarnationTimer)
    function bar:GetRemDurationOr0IfInvisible(t)
        if (alignmentTimer.remDuration > 0 or incarnationTimer.remDuration > 0) then
            return 0
        end
        return self.aura.remDuration
    end
end

ERACombatFrames_DruidMoonkinEclipseIcons_size = 32

ERACombatFrames_DruidMoonkinEclipseIcons = {}
ERACombatFrames_DruidMoonkinEclipseIcons.__index = ERACombatFrames_DruidMoonkinEclipseIcons
setmetatable(ERACombatFrames_DruidMoonkinEclipseIcons, {__index = ERACombatModule})

function ERACombatFrames_DruidMoonkinEclipseIcons:create(cFrame, x, y)
    local ec = {}
    setmetatable(ec, ERACombatFrames_DruidMoonkinEclipseIcons)
    ec:construct(cFrame, -1, 0.1, false, 1)

    ec.frame = CreateFrame("Frame", nil, UIParent, nil)
    ec.frame:SetSize(ERACombatFrames_DruidMoonkinEclipseIcons_size, 2 * ERACombatFrames_DruidMoonkinEclipseIcons_size)
    ec.frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    ec.frame:Hide()

    ec.iconWrath = ERASquareIcon:Create(ec.frame, "CENTER", ERACombatFrames_DruidMoonkinEclipseIcons_size, 535045)
    ec.iconWrath:Draw(0, ERACombatFrames_DruidMoonkinEclipseIcons_size / 2)
    ec.iconStarfire = ERASquareIcon:Create(ec.frame, "CENTER", ERACombatFrames_DruidMoonkinEclipseIcons_size, 135753)
    ec.iconStarfire:Draw(0, -ERACombatFrames_DruidMoonkinEclipseIcons_size / 2)

    ec.wrathSlot = -1
    ec.StarfireSolt = -1
    ec:updateSlots()

    return ec
end
function ERACombatFrames_DruidMoonkinEclipseIcons:updateSlots()
    self:parseSlotRange(109, 120)
    self:parseSlotRange(1, 72)
end
function ERACombatFrames_DruidMoonkinEclipseIcons:parseSlotRange(s1, sn)
    if (self.wrathSlot >= 0 and self.StarfireSolt >= 0) then
        return
    end
    for s = s1, sn do
        actionType, id = GetActionInfo(s)
        if (actionType == "spell") then
            if (self.wrathSlot < 0 and id == 190984) then
                self.wrathSlot = s
            end
            if (self.StarfireSolt < 0 and id == 194153) then
                self.StarfireSolt = s
            end
            if (self.wrathSlot >= 0 and self.StarfireSolt >= 0) then
                return
            end
        end
    end
end

function ERACombatFrames_DruidMoonkinEclipseIcons:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatFrames_DruidMoonkinEclipseIcons:ResetToIdle()
    self.frame:Hide()
    self:updateSlots()
end
function ERACombatFrames_DruidMoonkinEclipseIcons:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERACombatFrames_DruidMoonkinEclipseIcons:ExitCombat(toIdle)
    self.frame:Hide()
end

function ERACombatFrames_DruidMoonkinEclipseIcons:UpdateCombat(t)
    self:updateIcon(self.iconWrath, self.wrathSlot)
    self:updateIcon(self.iconStarfire, self.StarfireSolt)
end
function ERACombatFrames_DruidMoonkinEclipseIcons:updateIcon(iconFrame, slot)
    if (slot >= 0) then
        local count = GetActionCount(slot)
        if (count and count > 0) then
            if (count == 1) then
                iconFrame:SetMainText("X")
            elseif (count == 2) then
                iconFrame:SetMainText("XX")
            else
                iconFrame:SetMainText(count)
            end
            iconFrame:Show()
        else
            iconFrame:Hide()
        end
    else
        iconFrame:Hide()
    end
end

------------------------------------------------------------------------------------------------------------------------
---- FERAL -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DruidCatSetup(cFrame)
    local remember_default_bar_size = ERACombat_TimerBarDefaultSize
    ERACombat_TimerBarDefaultSize = 16

    local talent_sabertooth = ERALIBTalent:Create(1, 2)
    local talent_incarnation = ERALIBTalent:Create(5, 3)
    local talent_berzerk = ERALIBTalent:CreateNotTalent(5, 3, 34)
    local talent_slash = ERALIBTalent:Create(6, 2)
    local talent_bloodtalons = ERALIBTalent:Create(7, 2)

    ERAOutOfCombatStatusBars:Create(cFrame, -144, 0, 128, 22, 3, true, 1.0, 1.0, 0.0, false, 2) -- energy 3

    local timers = ERACombatTimersGroup:Create(cFrame, -101, 0, 1.0, 2)

    ERACombatHealth:Create(cFrame, -177, -80, 177, 26, 2)

    local nrg = ERACombatPower:Create(cFrame, -177, -22, 177, 26, 3, false, 1.0, 1.0, 0.0, 2)
    nrg.bar:SetBorderColor(1, 0.6, 0.2)
    nrg:AddConsumer(50, 132127)

    ERACombatPointsUnitPower:Create(cFrame, -144, -55, 4, 5, 1.0, 1.0, 1.0, 1.0, 0.1, 0.0, nil, 2)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(274837, ERALIBTalent:Create(7, 3)), nil, 0, -1, true, true)

    local furyTimer = timers:AddTrackedBuff(5217)
    timers:AddAuraBar(furyTimer, nil, 1.0, 1.0, 0.0) -- fury
    timers:AddCooldownIcon(timers:AddTrackedCooldown(5217, ERALIBTalent:CreateLevel(12)), nil, 0, 0, true, false) -- fury

    timers:AddCooldownIcon(timers:AddTrackedCooldown(202028, talent_slash), nil, 0, 1, true, true) -- slash

    local bloodTalonsTimer = timers:AddTrackedBuff(145152, talent_bloodtalons)
    local bloodTalonsDisplay = timers:AddAuraIcon(bloodTalonsTimer, 0, 2, nil)
    function bloodTalonsDisplay:ShouldShowWhenAbsent()
        return false
    end

    timers:AddKick(106839, 2, 1, ERALIBTalent:CreateLevel(26))
    timers:AddOffensiveDispellCooldown(2908, 0, -2, ERALIBTalent:CreateLevel(41), "Enrage")

    local roarTimer = timers:AddTrackedBuff(52610, ERALIBTalent:Create(5, 2))
    local roarDisplay = timers:AddAuraBar(roarTimer, nil, 0.9, 0.5, 0.0)
    function roarDisplay:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration <= self.aura.totDuration * 0.3) then
            self.view:SetIconAlpha(1.0)
        else
            self.view:SetIconAlpha(0.5)
        end
        return self.aura.remDuration
    end
    timers:AddMissingAura(roarTimer, nil, 0, 2, false)

    local berzerkTimer = timers:AddTrackedBuff(106951, talent_berzerk)
    local incarnationTimer = timers:AddTrackedBuff(102543, talent_incarnation)
    timers:AddAuraBar(berzerkTimer, nil, 1.0, 0.0, 0.0)
    timers:AddAuraBar(incarnationTimer, nil, 1.0, 0.0, 0.0)

    local catUtility = ERACombatUtilityFrame:Create(cFrame, -188, -144, 2)
    ERACombatFrames_DruidCovenantClass(timers, catUtility, 1, 0)
    catUtility:AddCooldown(0, 0, 106951, nil, true, talent_berzerk)
    catUtility:AddBuffIcon(catUtility:AddTrackedBuff(106951, talent_berzerk), 613074, 0, 0, false)
    catUtility:AddCooldown(0, 0, 102543, nil, true, talent_incarnation)
    catUtility:AddBuffIcon(catUtility:AddTrackedBuff(102543, talent_incarnation), 613074, 0, 0, false)
    catUtility:AddCooldown(-1, 0, 61336, nil, true, ERALIBTalent:CreateLevel(32)) -- survival instincts
    catUtility:AddTrinket1Cooldown(0.5, -0.8)
    catUtility:AddTrinket2Cooldown(-0.5, -0.8)

    local snapshot = function(target, instance, isRefresh)
        instance.appliedWithFury = furyTimer.remDuration > 0
        instance.appliedWithBloodTalons = bloodTalonsTimer.remDuration > 0
    end

    local snapshotFuryText = function(dotDef, currentTarget)
        if (dotDef.remDurationOnCurrentTarget > 0) then
            local instance = currentTarget:GetDOTInstance(dotDef)
            if (instance.appliedWithFury) then
                dotDef.barOnCurrentTarget:SetText("+")
            else
                dotDef.barOnCurrentTarget:SetText(nil)
            end
        else
            dotDef.barOnCurrentTarget:SetText(nil)
        end
    end

    function snapshotMultiplier(fury, talons)
        local m
        if (fury) then
            m = 1.15
        else
            m = 1.0
        end
        if (talons) then
            m = m * 1.3
        end
        return m
    end

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        2,
        function(tracker)
            local crit = GetCritChance() / 100
            -- 0.00966 = 0.46 (46% AP) * 1.2 (+20% contre les cibles qui saignent) * 0.7 (armure cible 30%) / 40 (40 nrj)
            if (berzerkTimer.remDuration > 0 or incarnationTimer.remDuration > 0) then
                return (1 + 2 * crit) * 1.6 * 0.00966
            else
                return (1 + crit) * 0.00966
            end
        end
    )

    local rakeDOT =
        dotracker:AddDOT(
        155722,
        nil,
        0.7,
        0.6,
        0.3,
        0,
        function(dotDef, hasteMod)
            return 15
        end,
        function(dotDef, currentTarget)
            snapshotFuryText(dotDef, currentTarget)
            local critAndEnergyMultiplier = (1 + GetCritChance() / 100) / 35
            return critAndEnergyMultiplier * 0.18225, critAndEnergyMultiplier * 0.77805
        end
    )
    rakeDOT.applied = snapshot
    function rakeDOT:DrawnUnknownTarget()
        self.barOnCurrentTarget:SetText(nil)
    end

    local moonDOT =
        dotracker:AddDOT(
        164812,
        nil,
        0.0,
        0.1,
        0.8,
        0,
        function(dotDef, hasteMod)
            return 16
        end,
        function(dotDef, currentTarget)
            local critAndEnergyMultiplier = (1 + GetCritChance() / 100) / 30
            return critAndEnergyMultiplier * 0.2, critAndEnergyMultiplier * 1.4
        end,
        ERALIBTalent:Create(1, 3)
    )

    local thrashDOT =
        dotracker:AddDOT(
        106830,
        nil,
        0.5,
        1.0,
        0.2,
        0,
        function(dotDef, hasteMod)
            return 15
        end,
        function(dotDef, currentTarget)
            snapshotFuryText(dotDef, currentTarget)
            local critAndEnergyMultiplier = (1 + GetCritChance() / 100) / 40
            return critAndEnergyMultiplier * 0.055, critAndEnergyMultiplier * 0.175, -1, true
        end
    )
    thrashDOT.applied = snapshot
    function thrashDOT:DrawnUnknownTarget()
        self.barOnCurrentTarget:SetText(nil)
    end

    local ripDOT =
        dotracker:AddDOT(
        1079,
        nil,
        1.0,
        0.0,
        0.0,
        0,
        function(dotDef, hasteMod)
            return 24
        end,
        function(dotDef, currentTarget)
            if (dotDef.remDurationOnCurrentTarget > 0) then
                local instance = currentTarget:GetDOTInstance(dotDef)
                if (dotDef.remDurationOnCurrentTarget > 24 * 0.3) then
                    if (instance.appliedWithFury) then
                        if (instance.appliedWithBloodTalons) then
                            dotDef.barOnCurrentTarget:SetText("+++ " .. math.floor(dotDef.remDurationOnCurrentTarget))
                        else
                            dotDef.barOnCurrentTarget:SetText("+ " .. math.floor(dotDef.remDurationOnCurrentTarget))
                        end
                    else
                        if (instance.appliedWithBloodTalons) then
                            dotDef.barOnCurrentTarget:SetText("++ " .. math.floor(dotDef.remDurationOnCurrentTarget))
                        else
                            dotDef.barOnCurrentTarget:SetText(math.floor(dotDef.remDurationOnCurrentTarget))
                        end
                    end
                else
                    local appliedMultiplier = snapshotMultiplier(instance.appliedWithFury, instance.appliedWithBloodTalons)
                    local currentMultiplier = snapshotMultiplier(furyTimer.remDuration > 0, bloodTalonsTimer.remDuration > 0)
                    if (appliedMultiplier > currentMultiplier) then
                        if (instance.appliedWithFury) then
                            if (instance.appliedWithBloodTalons) then
                                dotDef.barOnCurrentTarget:SetText("+++")
                            else
                                dotDef.barOnCurrentTarget:SetText("+")
                            end
                        else
                            dotDef.barOnCurrentTarget:SetText("++")
                        end
                    else
                        dotDef.barOnCurrentTarget:SetText(">")
                    end
                end
            else
                dotDef.barOnCurrentTarget:SetText(nil)
            end
            return 0, 1.68 * (1 + GetCritChance() / 100)
        end
    )
    ripDOT.applied = snapshot
    ripDOT.overrideFillerDamage = function()
        -- écart de 20 énergie
        -- 20 nrj, c'est un demi-point de combo (+1 si critique) => 0.5*(1+c)
        -- 0.5*(1+c) points, ça consomme aussi (0.5*(1+c)/5)*50 nrj pour la morsure
        -- (0.5*(1+c)/5)*50 nrj, c'est aussi (1+c)*[(0.5*(1+c)/5)*50]/40 points de combo
        -- on finira le calcul plus tard
        -- 1.37592 = 0.9828 (scaling AP de morsure) * 2 (double dégâts pour 50 nrj) * 0.7 (armure 30%)
        -- moins les dégâts de Shred vus plus haut :
        -- 0.1932 = 0.46 (46% AP) * 1.2 (+20% contre les cibles qui saignent) * 0.7 (armure cible 30%) / 2 (20 nrj au lieu de 40)
        local crit = GetCritChance() / 100
        if (berzerkTimer.remDuration > 0 or incarnationTimer.remDuration > 0) then
            return 1.37592 * (1 + crit) - (1 + 2 * crit) * 0.1932
        else
            return 1.37592 * (1 + crit) - (1 + crit) * 0.1932
        end
    end
    function ripDOT:DrawnUnknownTarget()
        self.barOnCurrentTarget:SetText(nil)
    end

    local utility = ERACombatFrames_DruidCommonUtility(cFrame, timers, 144, -200, 2, 22570, 28, 2782, "Curse", "Poison")
    ERACombatFrames_DruidMoonAffinityCC(utility, ERALIBTalent:Create(3, 1))
    ERACombatFrames_DruidBearAffinityCC(utility, ERALIBTalent:Create(3, 2))
    ERACombatFrames_DruidTreeAffinityCC(utility, ERALIBTalent:Create(3, 3))

    ERACombat_TimerBarDefaultSize = remember_default_bar_size
end

------------------------------------------------------------------------------------------------------------------------
---- GUARDIAN ----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DruidBearSetup(cFrame)
    local talent_incarnation = ERALIBTalent:Create(5, 3)
    local talent_berzerk = ERALIBTalent:CreateNotTalent(5, 3, 34)
    local talent_maim = ERALIBTalent:Create(7, 2)

    ERAOutOfCombatStatusBars:Create(cFrame, -128, 0, 128, 22, 1, false, 1.0, 0.0, 0.0, false, 3) -- rage 1

    local timers = ERACombatTimersGroup:Create(cFrame, -123, 0, 1.5, 3)

    local thrashBleedTimer = timers:AddTrackedDebuff(192090)

    timers:AddAuraBar(timers:AddTrackedBuff(192081), nil, 0.7, 0.4, 0.0) -- ironfur
    timers:AddAuraBar(timers:AddTrackedBuff(22812), nil, 1.0, 1.0, 0.0) -- barkskin
    timers:AddAuraBar(timers:AddTrackedBuff(61336), nil, 0.4, 0.8, 0.8) -- survival

    timers:AddCooldownIcon(timers:AddTrackedCooldown(33917), nil, 0, 2, true, true) -- mangle
    timers:AddCooldownIcon(timers:AddTrackedCooldown(77758), nil, 0, 1, true, true, ERALIBTalent:CreateLevel(11)) -- thrash
    timers:AddCooldownIcon(timers:AddTrackedCooldown(22842), nil, 0, 0, true, false, ERALIBTalent:CreateLevel(21)) -- regen

    timers:AddCooldownIcon(timers:AddTrackedCooldown(155835, ERALIBTalent:Create(1, 3)), nil, -0.72, -0.5, true, false) -- bristle
    local pulverizeDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(80313, ERALIBTalent:Create(7, 3)), nil, -0.72, 0.5, true, false) -- pulverize
    pulverizeDisplay.overrideSecondaryText = function()
        local s = thrashBleedTimer.stacks
        if (s == 0) then
            return nil
        elseif (s == 1) then
            return "¤"
        elseif (s == 2) then
            return "¤¤"
        elseif (s == 3) then
            return "¤¤¤"
        else
            return s
        end
        return thrashBleedTimer.stacks
    end
    local maimDisplay = timers:AddAuraIcon(timers:AddTrackedBuff(135286, talent_maim), -0.72, 0.5, nil, nil)
    function maimDisplay:ShouldShowWhenAbsent()
        return false
    end
    timers:AddAuraBar(timers:AddTrackedDebuff(135601, talent_maim), nil, 1.0, 0.2, 0.7)

    timers:AddKick(106839, 0, 3, ERALIBTalent:CreateLevel(26))
    timers:AddOffensiveDispellCooldown(2908, -0.7, -1.5, ERALIBTalent:CreateLevel(41), "Enrage")

    local berzerkTimer = timers:AddTrackedBuff(50334, talent_berzerk)
    local incarnationTimer = timers:AddTrackedBuff(102558, talent_incarnation)
    timers:AddAuraBar(berzerkTimer, nil, 1.0, 0.0, 0.0)
    timers:AddAuraBar(incarnationTimer, nil, 1.0, 0.0, 0.0)

    local bearUtility = ERACombatUtilityFrame:Create(cFrame, -234, -111, 3)
    ERACombatFrames_DruidCovenantClass(timers, bearUtility, 1, 0)
    bearUtility:AddCooldown(0, 0, 50334, nil, true, talent_berzerk)
    bearUtility:AddBuffIcon(bearUtility:AddTrackedBuff(50334, talent_berzerk), 613074, 0, 0, false)
    bearUtility:AddCooldown(0, 0, 102558, nil, true, talent_incarnation)
    bearUtility:AddBuffIcon(bearUtility:AddTrackedBuff(102558, talent_incarnation), 613074, 0, 0, false)
    bearUtility:AddCooldown(-1, 0, 61336, nil, true, ERALIBTalent:CreateLevel(32)) -- survival instincts
    bearUtility:AddTrinket1Cooldown(0.5, -0.8)
    bearUtility:AddTrinket2Cooldown(-0.5, -0.8)

    local rage = ERACombatPower:Create(cFrame, -212, -22, 155, 22, 1, true, 1.0, 0.0, 0.0, 3)
    rage:AddConsumer(40, 1378702)
    ERACombatHealth:Create(cFrame, -212, -51, 155, 22, 3)

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        3,
        function(tracker)
            local crit = GetCritChance() / 100
            -- 0.5 (50% AP) * 0.7 (armure cible 30%)
            return 0.35 * tracker.enemiesTracker:GetEnemiesCount()
        end
    )
    local moonDOT =
        dotracker:AddDOT(
        164812,
        nil,
        0.0,
        0.1,
        0.8,
        0,
        function(dotDef, hasteMod)
            return 16
        end,
        function(dotDef, currentTarget)
            return 0.22, 1.7
        end
    )

    local utility = ERACombatFrames_DruidCommonUtility(cFrame, timers, 177, -177, 3, 99, 28, 2782, "Curse", "Poison")
    ERACombatFrames_DruidMoonAffinityCC(utility, ERALIBTalent:Create(3, 1))
    ERACombatFrames_DruidCatAffinityCC(utility, ERALIBTalent:Create(3, 2))
    ERACombatFrames_DruidTreeAffinityCC(utility, ERALIBTalent:Create(3, 3))
end

------------------------------------------------------------------------------------------------------------------------
---- RESTO -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_DruidTreeSetup(cFrame)
    local remember_default_bar_size = ERACombat_TimerBarDefaultSize
    ERACombat_TimerBarDefaultSize = 16

    local talent_moonkin = ERALIBTalent:Create(3, 1)
    local talent_incarnation = ERALIBTalent:Create(5, 3)
    local talent_rejuv2 = ERALIBTalent:Create(7, 2)
    local talent_boosthots = ERALIBTalent:Create(7, 3)
    local talent_incarnation_with_boosthots = ERALIBTalent:CreateAnd(talent_incarnation, talent_boosthots)
    local talent_incarnation_without_boosthots = ERALIBTalent:CreateAnd(talent_incarnation, ERALIBTalent:CreateNot(talent_boosthots))

    ERAOutOfCombatStatusBars:Create(cFrame, -128, -64, 128, 22, 0, true, 0.1, 0.1, 1.0, false, 4) -- mana 0

    local grid = ERACombatGrid:Create(cFrame, -144, -16, "BOTTOMRIGHT", 4, 88423, "Magic", "Curse", "Poison")
    -- spellID, position, priority, rC, gC, bC, rB, gB, bB, talent
    local lifeBloomDefinition = grid:AddTrackedBuff(33763, 0, 1, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, nil)
    local regrowthDefinition = grid:AddTrackedBuff(8936, 1, 1, 0.0, 0.8, 0.0, 0.0, 1.0, 0.0, nil)
    local rejuvDefinition = grid:AddTrackedBuff(774, 2, 1, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, nil)
    local rejuv2Definition = grid:AddTrackedBuff(155777, 2, 1, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, talent_rejuv2)
    local rejuvBothDefinition = grid:AddTrackedBuff(1, 2, 1, 1.0, 0.5, 0.0, 0.0, 0.8, 0.0, talent_rejuv2)
    ERACombatFrames_DruidRestoRejuv(rejuvDefinition, rejuv2Definition)
    ERACombatFrames_DruidRestoRejuv(rejuv2Definition, rejuvDefinition)
    function rejuvBothDefinition:updateDisplay(instance)
        local i1 = instance.unitframe:GetAura(rejuvDefinition)
        local i2 = instance.unitframe:GetAura(rejuv2Definition)
        if (i1.remDuration > 0 and i2.remDuration > 0) then
            local i
            if (i1.remDuration > i2.remDuration) then
                i = i2
            else
                i = i1
            end
            ERAPieControl_SetOverlayValue(instance, 1 - i.remDuration / i.totDuration)
            i.text:SetText("X")
            instance:show()
        else
            instance:hide()
        end
    end
    local growthDefinition = grid:AddTrackedBuff(48438, 3, 1, 0.5, 1.0, 0.5, 1.0, 1.0, 1.0)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -99, 1.5, 4)

    local moonfire = timers:AddAuraBar(timers:AddTrackedDebuff(164812), nil, 0.0, 0.0, 1.0)
    function moonfire:GetRemDurationOr0IfInvisible(t)
        self.view:SetIconVisibility(self.aura.remDuration <= 4.8)
        return self.aura.remDuration
    end
    local sunfire = timers:AddAuraBar(timers:AddTrackedDebuff(164815), nil, 1.0, 1.0, 0.0)
    function sunfire:GetRemDurationOr0IfInvisible(t)
        self.view:SetIconVisibility(self.aura.remDuration <= 3.6)
        return self.aura.remDuration
    end

    ERACombatFrames_DruidRestoHOT(timers, grid, 774, 4.5, 0.0, 1.0, 0.2, nil) -- rejuv
    ERACombatFrames_DruidRestoHOT(timers, grid, 155777, 4.5, 0.0, 1.0, 0.2, talent_rejuv2) -- rejuv2
    ERACombatFrames_DruidRestoHOT(timers, grid, 8936, 3.6, 0.0, 0.5, 0.2, nil) -- regrowth
    local lifebloomTimer = ERACombatFrames_DruidRestoHOT(timers, grid, 33763, 4.5, 0.0, 1.0, 1.0, ERALIBTalent:CreateLevel(21))

    timers:AddCooldownIcon(timers:AddTrackedCooldown(18562, ERALIBTalent:CreateLevel(11)), nil, 0, 4, true, true) -- swiftmend
    timers:AddCooldownIcon(timers:AddTrackedCooldown(48438, ERALIBTalent:CreateLevel(34)), nil, 0, 3, true, true) -- wild growth
    timers:AddCooldownIcon(timers:AddTrackedCooldown(102351, ERALIBTalent:Create(1, 3)), nil, 0, 2, true, true) -- cenarion ward

    local starsurgeDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(197626, talent_moonkin), nil, 0, 1, true, true)
    local moonkinForm = timers:AddTrackedBuff(197625, talent_moonkin)
    function starsurgeDisplay:ShouldShowMainIcon()
        return self.cd.remDuration > 0 or moonkinForm.stacks > 0
    end

    timers:AddOffensiveDispellCooldown(2908, 1, 1, ERALIBTalent:CreateLevel(41), "Enrage")

    local incarnationTimer = timers:AddTrackedBuff(33891, talent_incarnation)
    timers:AddAuraBar(incarnationTimer, nil, 1.0, 0.0, 0.0)

    ERACombatHealth:Create(cFrame, -202, -111, 166, 22, 4)
    ERACombatPower:Create(cFrame, -202, -133, 166, 22, 0, false, 0.1, 0.1, 1.0, 4)

    local utility = ERACombatFrames_DruidCommonUtility(cFrame, timers, 188, -177, 4, 102793, 28, 88423, "Magic", "Curse", "Poison")
    ERACombatFrames_DruidMoonAffinityCC(utility, ERALIBTalent:Create(3, 1))
    ERACombatFrames_DruidCatAffinityCC(utility, ERALIBTalent:Create(3, 2))
    ERACombatFrames_DruidBearAffinityCC(utility, ERALIBTalent:Create(3, 3))

    local treeUtility = ERACombatUtilityFrame:Create(cFrame, -88, -199, 4)
    ERACombatFrames_DruidCovenantClass(timers, treeUtility, 1, 0)
    treeUtility:AddCooldown(0, 0, 102342, nil, true, ERALIBTalent:CreateLevel(12)) -- ironbark
    treeUtility:AddCooldown(-1, 0, 740, nil, true, ERALIBTalent:CreateLevel(37)) -- tranqui
    local flourish = treeUtility:AddCooldown(-2, 0, 197721, nil, true, talent_boosthots)
    function flourish:IconUpdatedAndShown(t)
        local score =
            #(lifeBloomDefinition.instances) * 0.22 + #(regrowthDefinition.instances) * 0.15 + #(rejuvDefinition.instances) * 0.31 + #(rejuv2Definition.instances) * 0.31 +
            #(growthDefinition.instances) * 0.594
        self.icon:SetSecondaryText(math.floor(score * 10) / 10)
    end
    local incarnationBuff = treeUtility:AddTrackedBuff(117679, talent_incarnation)
    treeUtility:AddCooldown(-3, 0, 33891, nil, true, talent_incarnation_with_boosthots)
    treeUtility:AddCooldown(-2, 0, 33891, nil, true, talent_incarnation_without_boosthots)
    treeUtility:AddBuffIcon(incarnationBuff, 613074, -3, 0, true, talent_incarnation_with_boosthots)
    treeUtility:AddBuffIcon(incarnationBuff, 613074, -2, 0, true, talent_incarnation_without_boosthots)
    treeUtility:AddCooldown(-0.5, -0.8, 132158, nil, true, ERALIBTalent:CreateLevel(58)) -- swiftness
    treeUtility:AddCooldown(-1.5, -0.8, 203651, nil, true, ERALIBTalent:Create(6, 3))
    treeUtility:AddTrinket1Cooldown(-2.5, -0.8)
    treeUtility:AddTrinket2Cooldown(-3.5, -0.8)

    ERACombatFrames_DruidLifebloomMissing:create(timers, lifebloomTimer, lifeBloomDefinition, 0, 5)

    local effloLevel = ERALIBTalent:CreateLevel(39)
    local efflo = ERACombatFrames_DruidEfflorescenceTimer_create(timers, effloLevel)
    ERACombatFrames_DruidEfflorescenceMissing:create(timers, efflo, 1.7, 2)

    ERACombat_TimerBarDefaultSize = remember_default_bar_size
end

-- grid rejuv

function ERACombatFrames_DruidRestoRejuv(aura, other)
    function aura:updateDisplay(instance)
        local otherInstance = instance.unitframe:GetAura(other)
        if (otherInstance.remDuration > 0) then
            instance:hide()
        else
            self:updateDisplayDefault(instance)
        end
    end
end

-- personal hots

function ERACombatFrames_DruidRestoHOT(timers, grid, spellID, pandemic, r, g, b, talent)
    local timer = timers:AddTrackedBuff(spellID, talent)
    local display = timers:AddAuraBar(timer, nil, r, g, b)
    function display:GetRemDurationOr0IfInvisible(t)
        if (grid.isSolo) then
            self.view:SetIconVisibility(self.aura.remDuration <= pandemic)
            return math.max(0.001, self.aura.remDuration)
        else
            return 0
        end
    end
    return timer
end

-- lifebloom

ERACombatFrames_DruidLifebloomMissing = {}
ERACombatFrames_DruidLifebloomMissing.__index = ERACombatFrames_DruidLifebloomMissing
setmetatable(ERACombatFrames_DruidLifebloomMissing, ERACombatTimersHintIcon)

function ERACombatFrames_DruidLifebloomMissing:create(timers, bloomtimer, bloomdef, x, y)
    local m = {}
    setmetatable(m, ERACombatFrames_DruidLifebloomMissing)
    m:construct(timers, 134206, x, y, false)
    m.bloomtimer = bloomtimer
    m.bloomdef = bloomdef
    return m
end

function ERACombatFrames_DruidLifebloomMissing:ComputeIsVisible(t)
    return self.bloomtimer.talentActive and self.bloomtimer.remDuration <= 0 and #(self.bloomdef.instances) == 0
end

-- efflo

function ERACombatFrames_DruidEfflorescenceTimer_create(timers, effloLevel)
    local bar = timers:AddTotemBar(1, 134222, 1.0, 0.8, 0.6, effloLevel)
    function bar:UpdatingDuration(t, remDuration)
        if (remDuration < 5) then
            return remDuration
        else
            return 0
        end
    end
    return bar
end

ERACombatFrames_DruidEfflorescenceMissing = {}
ERACombatFrames_DruidEfflorescenceMissing.__index = ERACombatFrames_DruidEfflorescenceMissing
setmetatable(ERACombatFrames_DruidEfflorescenceMissing, ERACombatTimersHintIcon)

function ERACombatFrames_DruidEfflorescenceMissing:create(timers, effloTimer, x, y, effloLevel)
    local cm = {}
    setmetatable(cm, ERACombatFrames_DruidEfflorescenceMissing)
    cm:construct(timers, 134222, x, y, false, effloLevel)
    cm.effloTimer = effloTimer
    return cm
end

function ERACombatFrames_DruidEfflorescenceMissing:ComputeIsVisible(t)
    return not self.effloTimer.haveTotem
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
ERACombatFrames_DruidAffinityCCx = -2
ERACombatFrames_DruidAffinityCCy = 0
function ERACombatFrames_DruidMoonAffinityCC(utility, talent)
    utility:AddCooldown(ERACombatFrames_DruidAffinityCCx, ERACombatFrames_DruidAffinityCCy, 132469, nil, true, talent)
end
function ERACombatFrames_DruidCatAffinityCC(utility, talent)
    utility:AddCooldown(ERACombatFrames_DruidAffinityCCx, ERACombatFrames_DruidAffinityCCy, 22570, nil, true, talent)
end
function ERACombatFrames_DruidBearAffinityCC(utility, talent)
    utility:AddCooldown(ERACombatFrames_DruidAffinityCCx, ERACombatFrames_DruidAffinityCCy, 99, nil, true, talent)
end
function ERACombatFrames_DruidTreeAffinityCC(utility, talent)
    utility:AddCooldown(ERACombatFrames_DruidAffinityCCx, ERACombatFrames_DruidAffinityCCy, 102793, nil, true, talent)
end
function ERACombatFrames_DruidCommonUtility_how(talent, spellID, utility, timers, x, y)
    utility:AddBuffIcon(utility:AddTrackedBuff(spellID, talent), 136038, x, y, true)
    timers:AddAuraBar(timers:AddTrackedBuff(spellID, talent), nil, 0.7, 1.0, 0.3)
end
function ERACombatFrames_DruidCommonUtility(cFrame, timers, x, y, spec, nativeIncapacitateID, nativeIncapacitateLevel, dispellID, ...)
    local talent_how = ERALIBTalent:Create(4, 3)

    local utility = ERACombatUtilityFrame:Create(cFrame, x, y, spec)

    utility:AddCovenantGenericAbility(-0.5, 2.4)

    utility:AddDefensiveDispellCooldown(0, 1.6, dispellID, nil, ERALIBTalent:CreateLevel(19), ...)
    utility:AddCooldown(-1, 1.6, 22812, nil, true, ERALIBTalent:CreateLevel(24)) -- barkskin

    utility:AddCooldown(-1.5, 0.8, 108238, nil, true, ERALIBTalent:Create(2, 2)) -- heal
    utility:AddCooldown(-1.5, 0.8, 102401, 538771, true, ERALIBTalent:Create(2, 3)) -- charge
    utility:AddCooldown(-0.5, 0.8, 1850, nil, true, ERALIBTalent:CreateNotTalent(2, 1, 6)) -- cat run
    utility:AddCooldown(-0.5, 0.8, 252216, nil, true, ERALIBTalent:Create(2, 1)) -- cat run talent
    utility:AddCooldown(0.5, 0.8, 77764, nil, true, ERALIBTalent:CreateLevel(43)) -- roar run

    utility:AddCooldown(-1, 0, nativeIncapacitateID, nil, true, ERALIBTalent:CreateLevel(nativeIncapacitateLevel))

    local row4x = 0
    local row4y = 0
    utility:AddCooldown(row4x, row4y, 5211, nil, true, ERALIBTalent:Create(4, 1)) -- bash
    utility:AddCooldown(row4x, row4y, 102359, nil, true, ERALIBTalent:Create(4, 2)) -- roots everywhere
    utility:AddCooldown(row4x, row4y, 319454, nil, true, talent_how)
    ERACombatFrames_DruidCommonUtility_how(talent_how, 108291, utility, timers, row4x, row4y)
    ERACombatFrames_DruidCommonUtility_how(talent_how, 108292, utility, timers, row4x, row4y)
    ERACombatFrames_DruidCommonUtility_how(talent_how, 108293, utility, timers, row4x, row4y)
    ERACombatFrames_DruidCommonUtility_how(talent_how, 108294, utility, timers, row4x, row4y)

    utility:AddRacial(-1.5, -0.8)
    utility:AddWarlockHealthStone(0.5, -0.8)
    utility:AddWarlockPortal(1.5, -0.8)

    utility:AddCooldown(-1, -1.6, 6795, nil, true, ERALIBTalent:CreateLevel(14)).alphaWhenOffCooldown = 0.1 -- taunt

    return utility
end

function ERACombatFrames_DruidCovenantClass(timers, utility, x, y)
    utility:AddCovenantClassAbility(1, 0, 338142, 323546, 323764, 325727, 326434)
    timers:AddAuraBar(timers:AddTrackedBuff(323546, ERALIBTalent:CreateVenthyrOrSpellKnown(323546)), nil, 0.7, 0.0, 0.0)
end

------------------------------------------------------------------------------------------------------------------------
---- MACROS ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--[[

affbear
#showtooltip
/cast [talent:3/1] Typhon
/cast [talent:3/3] Vortex d’Ursol

affcat
#showtooltip
/cast [talent:3/1] Typhon
/cast [talent:3/2] Rugissement incapacitant
/cast [talent:3/3] Vortex d’Ursol

afftree
#showtooltip
/cast [talent:3/1] Typhon
/cast [talent:3/3] Rugissement incapacitant

affmoonkin
#showtooltip
/cast [talent:3/2] Rugissement incapacitant
/cast [talent:3/3] Vortex d’Ursol

dispell
#showtooltip
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Soins naturels

cenarion
#showtooltip
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Protection cénarienne

ironbark
#showtooltip
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Ecorcefer

lifebloom
#showtooltip
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Fleur de vie

moonrow1
#showtooltip
/cast [talent:1/2] Guerrier d’Elune
/cast [talent:1/3] Force de la nature(Talent)

regrowth
#showtooltip
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Rétablissement

rejuv
#showtooltip
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Récupération

row2
#showtooltip
/cast [talent:2/2] Renouveau;[talent:2/3] Charge sauvage

swiftmend
#showtooltip
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Prompte guérison


]]
