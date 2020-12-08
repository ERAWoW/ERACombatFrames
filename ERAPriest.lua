function ERACombatFrames_PriestSetup(cFrame)
    ERACombatGlobals_SpecID1 = 256
    ERACombatGlobals_SpecID2 = 257
    ERACombatGlobals_SpecID3 = 258

    local discActive = ERACombatOptions_IsSpecActive(1)
    local shadowActive = ERACombatOptions_IsSpecActive(3)

    local kyrian_talent = ERALIBTalent:CreateKyrianOrSpellKnown(325013)

    if (discActive) then
        ERACombatFrames_PriestDisciplineSetup(cFrame, kyrian_talent)
    end
    if (shadowActive) then
        ERACombatFrames_PriestShadowSetup(cFrame, kyrian_talent)
    end

    cFrame:Pack()
end

--[[
#showtooltip
/cast [talent:5/1]truc;[talent:5/2]machin

#showtooltip
/cqs
/cast [@mouseover,exists,help,nodead][exists,help,nodead][@player] Guérison de l'ombre

#showtooltip
/cast [@mouseover,exists,help,nodead][exists,nodead][@player] Pénitence
]]
------------------------------------------------------------------------------------------------------------------------
---- DISCI -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PriestDisciplineSetup(cFrame, kyrian_talent)
    local talent_schism = ERALIBTalent:Create(1, 3)
    local talent_mindblender = ERALIBTalent:Create(3, 2)
    local talent_not_mindblender = ERALIBTalent:CreateNotTalent(3, 2, 20)
    local talent_ptw = ERALIBTalent:Create(6, 1)
    local talent_swp = ERALIBTalent:CreateNotTalent(6, 1)

    ERAOutOfCombatStatusBars:Create(cFrame, -111, -44, 128, 22, 0, true, 0.1, 0.1, 1.0, false, 1) -- mana 0

    ERACombatHealth:Create(cFrame, -202, -60, 166, 22, 1)
    ERACombatPower:Create(cFrame, -202, -84, 166, 22, 0, false, 0.1, 0.1, 1.0, 1)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -44, 1.5, 1)

    ERACombatFrames_PriestKyrian(timers, 0.8, 3.5, kyrian_talent)

    timers:AddOffensiveDispellIcon(3163628, 1, 4.5, false, ERALIBTalent:CreateLevel(24), "Magic")

    ERACombatFrames_PriestSWD(timers, 0, 1)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(8092), nil, 0, 2, true, true) -- mind blast

    timers:AddCooldownIcon(timers:AddTrackedCooldown(129250, ERALIBTalent:Create(3, 3)), nil, 0, 3, true, true)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(110744, ERALIBTalent:Create(6, 2)), nil, -0.8, 4.5, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(120517, ERALIBTalent:Create(6, 3)), nil, -0.8, 4.5, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(47540, ERALIBTalent:CreateLevel(11)), nil, 0, 4, true, true) -- penance
    timers:AddCooldownIcon(timers:AddTrackedCooldown(194509, ERALIBTalent:CreateLevel(23)), nil, 0, 5, true, true) -- radiance
    timers:AddCooldownIcon(timers:AddTrackedCooldown(314867, ERALIBTalent:Create(5, 3)), nil, 0.8, 4.5, true, true) -- covenant

    timers:AddCooldownIcon(timers:AddTrackedCooldown(214621, talent_schism), nil, -0.8, 3.5, true, true)
    timers:AddAuraBar(timers:AddTrackedDebuff(214621, talent_schism), nil, 0.7, 0.2, 0.8)

    timers:AddAuraBar(timers:AddTrackedBuff(47536), nil, 1.0, 1.0, 1.0)
    local swpDisplay = timers:AddAuraBar(timers:AddTrackedDebuff(589, talent_swp), nil, 0.9, 0.6, 0.0)
    function swpDisplay:GetRemDurationOr0IfInvisible(t)
        self.view:SetIconVisibility(self.aura.remDuration <= 4.8)
        return self.aura.remDuration
    end
    local ptwDisplay = timers:AddAuraBar(timers:AddTrackedDebuff(204213, talent_ptw), nil, 0.9, 0.6, 0.0)
    function ptwDisplay:GetRemDurationOr0IfInvisible(t)
        self.view:SetIconVisibility(self.aura.remDuration <= 6)
        return self.aura.remDuration
    end

    local utility = ERACombatFrames_PriestUtility(cFrame, 128, -128, 1, nil)
    utility:AddDefensiveDispellCooldown(0.5, 0.9, 527, nil, ERALIBTalent:CreateLevel(18), "Magic", "Disease")
    utility:AddCooldown(-0.5, 0.9, 204263, nil, true, ERALIBTalent:Create(4, 3)).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(-2, 0, 121536, nil, true, ERALIBTalent:Create(2, 3)).alphaWhenOffCooldown = 0.4

    local grid = ERACombatGrid:Create(cFrame, -177, 44, "BOTTOMRIGHT", 1, 527, "Magic", "Disease")
    -- spellID, position, priority, rC, gC, bC, rB, gB, bB, talent
    local expiation = grid:AddTrackedBuff(194384, 1, 1, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, nil)
    grid:AddTrackedBuff(17, 0, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, nil) -- boubou
    grid:AddTrackedDebuff(6788, 2, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, nil) -- pas boubou

    local disciUtility = ERACombatUtilityFrame:Create(cFrame, -222, -144, 1)
    disciUtility:AddCooldown(1, 0, 200174, nil, true, talent_mindblender)
    disciUtility:AddCooldown(1, 0, 132603, nil, true, talent_not_mindblender)
    disciUtility:AddCooldown(0, 0, 33206, nil, true, ERALIBTalent:CreateLevel(38)) -- pain sup
    disciUtility:AddCooldown(-1, 0, 62618, nil, true, ERALIBTalent:CreateLevel(44)) -- barrier
    disciUtility:AddCooldown(-2, 0, 10060, nil, true, ERALIBTalent:CreateLevel(58)) -- infu
    disciUtility:AddCovenantClassAbility(1.5, -0.9, 325013, 323673, 327661, 324724)
    disciUtility:AddCooldown(0.5, -0.9, 47536, nil, true, ERALIBTalent:CreateNotTalent(7, 2)) -- rapture
    disciUtility:AddCooldown(0.5, -0.9, 109964, nil, true, ERALIBTalent:Create(7, 2)) -- spirit shell
    local evangelismDisplay = disciUtility:AddCooldown(-0.5, -0.9, 246287, nil, true, ERALIBTalent:Create(7, 3))
    function evangelismDisplay:IconUpdatedAndShown(t)
        self.icon:SetSecondaryText(#(expiation.instances))
    end
    disciUtility:AddTrinket1Cooldown(-1.5, 0.9)
    disciUtility:AddTrinket2Cooldown(-2.5, 0.9)
end

------------------------------------------------------------------------------------------------------------------------
---- SHADOW ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PriestShadowSetup(cFrame, kyrian_talent)
    local talent_vampiric_instant_damage = ERALIBTalent:Create(1, 3)
    local talent_mindbomb = ERALIBTalent:Create(4, 2)
    local talent_not_mindbomb = ERALIBTalent:CreateNotTalent(4, 2)
    local talent_shadowcrash = ERALIBTalent:Create(5, 3)
    local talent_damn = ERALIBTalent:Create(6, 1)
    local talent_torrent = ERALIBTalent:Create(6, 3)
    local talent_mindblender = ERALIBTalent:Create(6, 2)
    local talent_not_mindblender = ERALIBTalent:CreateNotTalent(6, 2, 20)
    local talent_madness = ERALIBTalent:Create(7, 3)

    local oocbars = ERAOutOfCombatStatusBars:Create(cFrame, -111, -32, 111, 22, 13, false, 0.5, 0.0, 1.0, false, 3) -- insanity 13
    oocbars.power:SetBorderColor(0.4, 0.4, 1.0)

    local timers = ERACombatTimersGroup:Create(cFrame, -121, -11, 1.5, 3)

    ERACombatHealth:Create(cFrame, -200, -60, 123, 22, 3)
    local insanity = ERACombatPower:Create(cFrame, -200, -32, 123, 22, 1, false, 0.5, 0.0, 1.0, 3)
    insanity.bar:SetBorderColor(0.4, 0.4, 1.0)
    insanity:AddConsumer(50, 252997)
    local aoeConsumer = insanity:AddConsumer(35, 1022950, ERALIBTalent:Create(3, 3))
    function aoeConsumer:ComputeVisibility()
        return timers.channelingSpellID == 48045
    end

    timers:AddChannelInfo(15407, 0.75)
    timers:AddChannelInfo(48045, 0.75)

    local voidFormTimer = timers:AddTrackedBuff(194249)

    timers:AddAuraBar(voidFormTimer, nil, 1.0, 0.0, 1.0)
    timers:AddAuraBar(timers:AddTrackedBuff(193223, talent_madness), nil, 1.0, 0.0, 0.0)

    local vampiricInstantDamageUnavailable = timers:AddTrackedDebuffOnPlayer(341291, talent_vampiric_instant_damage)
    local vampiricInstantDamageTimer = timers:AddTrackedBuff(341282, talent_vampiric_instant_damage)
    --timers:AddProc(vampiricInstantDamageTimer, nil, 0, 4, true)
    timers:AddAuraBar(vampiricInstantDamageTimer, nil, 0.6, 0.1, 1.0).view:SetSize(16)
    timers:AddMissingAura(vampiricInstantDamageUnavailable, 135978, 0, 4, false)
    local vampiricInstantDamageUnavailableDisplay = timers:AddAuraBar(vampiricInstantDamageUnavailable, nil, 0.6, 0.8, 0.1)
    vampiricInstantDamageUnavailableDisplay.view:SetSize(16)
    function vampiricInstantDamageUnavailableDisplay:GetRemDurationOr0IfInvisible(t)
        if (vampiricInstantDamageTimer.remDuration <= 0) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    ERACombatFrames_PriestSWD(timers, 0, 3)

    timers:AddOffensiveDispellIcon(3163628, 1, 1, false, nil, "Magic")

    ERACombatFrames_PriestKyrian(timers, 0.7, 2.5, kyrian_talent)

    local mindBlastTimer = timers:AddTrackedCooldown(8092)
    mindBlastTimer.mustAlwaysUpdateKind = true
    timers:AddCooldownIcon(mindBlastTimer, nil, 0, 2, true, true)

    local voidBoltDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(205448, ERALIBTalent:CreateLevel(23)), nil, 0, 1, true, true)
    function voidBoltDisplay:OverrideTimerVisibility()
        return voidFormTimer.stacks > 0
    end
    function voidBoltDisplay:ShouldShowMainIcon()
        return voidFormTimer.stacks > 0
    end
    local voidEruptionDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(228260, ERALIBTalent:CreateLevel(23)), nil, 0, 1, true, true)
    function voidEruptionDisplay:OverrideTimerVisibility()
        return voidFormTimer.stacks <= 0
    end
    function voidEruptionDisplay:ShouldShowMainIcon()
        return voidFormTimer.stacks <= 0
    end

    timers:AddCooldownIcon(timers:AddTrackedCooldown(342834, talent_shadowcrash), nil, 0, 0, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(341374, talent_damn), nil, -0.77, 0.5, true, true)
    local torrentTimer = timers:AddTrackedCooldown(263165, talent_torrent)
    timers:AddCooldownIcon(torrentTimer, nil, -0.77, 0.5, true, true)

    timers:AddKick(15487, 1, 0, ERALIBTalent:CreateLevel(29))

    --[[
    local devouringTimer = timers:AddTrackedDebuff(335467)
    local devouringDisplay = timers:AddAuraBar(devouringTimer, nil, 0.1, 0.7, 0.3, talent_torrent)
    function devouringDisplay:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration > torrentTimer.remDuration + 0.2) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    ]]
    local utility = ERACombatFrames_PriestUtility(cFrame, 111, -144, 3, talent_not_mindbomb)
    utility:AddDefensiveDispellCooldown(1.5, 0.9, 213634, nil, ERALIBTalent:CreateLevel(18), "Disease")
    utility:AddCooldown(0, 0, 205369, nil, true, talent_mindbomb).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(0.5, 0.9, 64044, nil, true, ERALIBTalent:Create(4, 3)).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(-0.5, 0.9, 47585, nil, true, ERALIBTalent:CreateLevel(16)).alphaWhenOffCooldown = 0.4 -- dispersion
    utility:AddCooldown(-2, 0, 15286, nil, true, ERALIBTalent:CreateLevel(25)).alphaWhenOffCooldown = 0.3 -- embrace

    local shadowUtility = ERACombatUtilityFrame:Create(cFrame, -188, -122, 3)
    shadowUtility:AddCovenantClassAbility(1, 0, 325013, 323673, 327661, 324724)
    shadowUtility:AddCooldown(0, 0, 200174, nil, true, talent_mindblender)
    shadowUtility:AddCooldown(0, 0, 132603, nil, true, talent_not_mindblender)
    shadowUtility:AddCooldown(-1, 0, 319952, nil, true, talent_madness)
    shadowUtility:AddBuffIcon(shadowUtility:AddTrackedBuff(193223, talent_madness), 136221, -1, 0, false)
    shadowUtility:AddCooldown(0.5, -0.9, 10060, nil, true, ERALIBTalent:CreateLevel(58)) -- infu
    shadowUtility:AddTrinket1Cooldown(-0.5, -0.9)
    shadowUtility:AddTrinket2Cooldown(-1.5, -0.9)
    shadowUtility:AddMissingBuff(shadowUtility:AddTrackedBuff(232698), iconID, -2, 0, true, true, ERALIBTalent:CreateLevel(12), shadowUtility:AddTrackedBuff(194249))

    local dotracker =
        ERACombatDOTracker:Create(
        timers,
        nil,
        3,
        function(tracker)
            local cpt = tracker.enemiesTracker:GetEnemiesCount()
            if (cpt > 1) then
                return cpt * 0.29648
            else
                return 0.5048
            end
        end
    )

    local swpDOT =
        dotracker:AddDOT(
        589,
        nil,
        0.9,
        0.6,
        0.0,
        0,
        function(dotDef, hasteMod)
            return 16
        end,
        function(dotDef, currentTarget)
            return 0.1292, 0.76704
        end
    )

    local vtDOT =
        dotracker:AddDOT(
        34914,
        nil,
        0.7,
        0.2,
        1.0,
        1.5,
        function(dotDef, hasteMod)
            return 21
        end,
        function(dotDef, currentTarget)
            return 0, 1.59
        end
    )
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_PriestKyrian(timers, x, y, talent)
    local boonAura = timers:AddTrackedBuff(325013, talent)
    timers:AddAuraBar(boonAura, nil, 0.4, 0.8, 1.0)
    local blastDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(325283, talent), 3528286, x, y, true, true)
    function blastDisplay:ShouldShowMainIcon()
        return boonAura.remDuration > 0
    end
    function blastDisplay:OverrideTimerVisibility()
        return boonAura.remDuration > 0
    end
end

function ERACombatFrames_PriestSWD(timers, x, y)
    local swdTimer = timers:AddTrackedCooldown(32379, ERALIBTalent:CreateLevel(14))
    local swdDisplay = timers:AddCooldownIcon(swdTimer, nil, x, y, true, true)
    function swdDisplay:OverrideTimerVisibility()
        if (UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") < 0.2) then
            self.icon:SetAlpha(1.0)
            return true
        else
            self.icon:SetAlpha(0.3)
            return false
        end
    end
end

function ERACombatFrames_PriestUtility(cFrame, x, y, spec, psyTalent)
    local utility = ERACombatUtilityFrame:Create(cFrame, x, y, spec)
    utility:AddCooldown(-1, 0, 586, nil, true).alphaWhenOffCooldown = 0.4 -- fade
    utility:AddCooldown(0, 0, 8122, nil, true, psyTalent).alphaWhenOffCooldown = 0.4 -- psy scream
    utility:AddCooldown(1, 0, 32375, nil, true, ERALIBTalent:CreateLevel(42)).alphaWhenOffCooldown = 0.4 -- mass dispell
    utility:AddWarlockHealthStone(3, 0)
    utility:AddWarlockPortal(4, 0)
    utility:AddMissingBuffAnyCaster(135987, 4, 0, nil, 21562)
    utility:AddCovenantGenericAbility(-2.5, -0.9)
    utility:AddCooldown(-1.5, -0.9, 19236, nil, true).alphaWhenOffCooldown = 0.4 -- desperate prayer
    utility:AddRacial(-0.5, -0.9)
    utility:AddCooldown(0.5, -0.9, 73325, nil, true, ERALIBTalent:CreateLevel(49)).alphaWhenOffCooldown = 0.4 -- leap
    return utility
end
