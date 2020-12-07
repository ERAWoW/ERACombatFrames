function ERACombatFrames_RogueSetup(cFrame)
    ERACombatGlobals_SpecID1 = 259
    ERACombatGlobals_SpecID2 = 260
    ERACombatGlobals_SpecID3 = 261

    local assaActive = ERACombatOptions_IsSpecActive(1)
    local outlawActive = ERACombatOptions_IsSpecActive(2)
    local subActive = ERACombatOptions_IsSpecActive(4)

    ERAOutOfCombatStatusBars:Create(cFrame, -144, 0, 128, 22, 3, true, 1.0, 1.0, 0.0, false, assaActive, outlawActive, subActive) -- energy 3
    local combo = ERACombatPointsUnitPower:Create(cFrame, -144, -55, 4, 5, 1.0, 1.0, 1.0, 1.0, 0.1, 0.0, nil, assaActive, subActive)

    if (assaActive) then
    end
    if (outlawActive) then
        ERACombatFrames_RogueOutlawSetup(cFrame)
    end
    if (subActive) then
    end

    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- OUTLAW ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_RogueOutlawSetup(cFrame)
    local talent_5points = ERALIBTalent:CreateNotTalent(3, 2)
    local talent_6points = ERALIBTalent:Create(3, 2)
    ERACombatHealth:Create(cFrame, -177, -80, 177, 26, 2)

    local combo = {}
    combo.points = 0
    combo.isMax = false
    local combo5 = ERACombatPointsUnitPower:Create(cFrame, -144, -55, 4, 5, 1.0, 1.0, 1.0, 1.0, 0.1, 0.0, talent_5points, 2)
    function combo5:PointsUpdated(t)
        combo.points = self.currentPoints
        combo.isMax = self.currentPoints >= 5
    end
    local combo6 = ERACombatPointsUnitPower:Create(cFrame, -177, -55, 4, 5, 1.0, 1.0, 1.0, 1.0, 0.1, 0.0, talent_6points, 2)
    function combo6:PointsUpdated(t)
        combo.points = self.currentPoints
        combo.isMax = self.currentPoints >= 6
    end

    local timers = ERACombatTimersGroup:Create(cFrame, -101, 32, 1.0, 2)

    local sliceTimer = timers:AddTrackedBuff(315496)
    local pistolProcTimer = timers:AddTrackedBuff(195627)
    local bigPistolCooldown = timers:AddTrackedCooldown(315341)

    local nrg = ERACombatPower:Create(cFrame, -177, -22, 177, 26, 3, false, 1.0, 1.0, 0.0, 2)
    nrg.bar:SetBorderColor(1, 0.6, 0.2)

    local fillerConsumer = nrg:AddConsumer(45, 136189)
    function fillerConsumer:ComputeVisibility()
        return pistolProcTimer.remDuration <= 0 and not combo.isMax
    end

    local pistolConsumer = nrg:AddConsumer(20, 1373908)
    function pistolConsumer:ComputeVisibility()
        return pistolProcTimer.remDuration > 0 and not combo.isMax
    end
    function pistolConsumer:ComputeIconVisibility()
        return pistolProcTimer.remDuration > 0 and not combo.isMax
    end

    local comboConsumer35 = nrg:AddConsumer(35, 236286)
    function comboConsumer35:ComputeVisibility()
        return combo.isMax
    end
    local comboConsumer25 = nrg:AddConsumer(25, 132306)
    function comboConsumer25:ComputeVisibility()
        return combo.isMax and (bigPistolCooldown.remDuration <= 0 or sliceTimer.remDuration < 7)
    end

    local sliceDisplay = timers:AddAuraBar(sliceTimer, nil, 1.0, 0.5, 0.0)
    function sliceDisplay:GetRemDurationOr0IfInvisible(t)
        local r = self.aura.remDuration
        if (r > timers.timerStandardDuration) then
            self.view:SetText(math.floor(r))
        else
            self.view:SetText(nil)
        end
        return r
    end

    timers:AddAuraBar(timers:AddTrackedBuff(13877), nil, 0.6, 1.0, 0.2) -- blade dance

    timers:AddCooldownIcon(timers:AddTrackedCooldown(315508), nil, -3, 0.6, true, true, nil) -- roll
    timers:AddCooldownIcon(bigPistolCooldown, nil, -2, 0.6, true, true, nil)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(13877), nil, -1, 0.6, true, true, nil) -- blade dance
    timers:AddKick(1766, 0, 1.6)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(196937, ERALIBTalent:Create(1, 3)), nil, 0, 0.6, true, true, nil) -- ghost strike
    timers:AddCooldownIcon(timers:AddTrackedCooldown(137619, ERALIBTalent:Create(3, 3)), nil, 0, -0.4, true, true, nil) -- mark

    local defUtility = ERACombatFrames_RogueDefensiveUtility(cFrame, 2)
    local mobUtility = ERACombatFrames_RogueMobilityUtility(cFrame, 2)
    mobUtility:AddCooldown(0, 1, 195457, nil, true) -- harpoon
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_RogueDefensiveUtility(cFrame, spec)
    local utility = ERACombatUtilityFrame:Create(cFrame, 0, -144, spec)
    utility:AddCooldown(-1, 0, 1966, nil, true) -- feinte
    utility:AddCooldown(0, 0, 185311, nil, true) -- potion
    utility:AddCooldown(1, 0, 5277, nil, true) -- evasion
    utility:AddCooldown(2, 0, 1856, nil, true) -- vanish
    utility:AddMissingBuffAnyCaster(132274, 1, -1, nil, 3408)
    utility:AddMissingBuffAnyCaster(132273, 2, -1, nil, 315584)
    return utility
end

function ERACombatFrames_RogueMobilityUtility(cFrame, spec)
    local utility = ERACombatUtilityFrame:Create(cFrame, 144, 0, spec)
    utility:AddCooldown(0, 0, 408, nil, true) -- stun
    utility:AddCooldown(0, -1, 2983, nil, true) -- sprint
    return utility
end
