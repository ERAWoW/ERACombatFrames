-- TODO
-- tout

function ERACombatFrames_MonkSetup(cFrame)
    --[[
    ------------------------------------------------------------------------------------------------------------------------
    ---- BM ----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------

    local idleBarsBM = ERAOutOfCombatStatusBars:Create(cFrame, 0, -128, 222, 16, 3, true, 1.0, 1.0, 0.0, false, 1)
    local combatHealthBM = ERACombatHealth:Create(cFrame, 0, -128, 32, 222, 1)
    local combatEnergyBM = ERACombatPower:Create(cFrame, -256, -77, 22, 222, 3, false, 1.0, 1.0, 0.0, 1)
    local kegSmashConsumer = combatEnergyBM:AddConsumer(40, 594274)

    local bm = ERACombatTimersGroup:Create(cFrame, -128, -32, 1, 1)

    bm:AddCooldownIcon(bm:AddTrackedCooldown(205523), nil, 0, 0, true, true) -- blackout kick

    local bm_kegSmashCD = bm:AddTrackedCooldown(121253)
    local bm_kegSmashTimer = bm:AddCooldownIcon(bm_kegSmashCD, nil, 0, 1, true, true)
    function bm_kegSmashTimer:TimerIconDrawn(icon)
        if (kegSmashConsumer.kegPriority) then
            icon:Beam()
        else
            icon:StopBeam()
        end
    end
    function kegSmashConsumer:ComputeIconVisibility()
        self.kegPriority = combatEnergyBM.currentPower - 25 + 10 * (1 + GetHaste() / 100) * bm_kegSmashCD.remDuration <= 40
        return self.kegPriority
    end

    local shuffle = bm:AddTrackedBuff(215479)
    bm:AddAuraBar(shuffle, 0.3, 1.0, 0.7)
    bm:AddMissingAura(shuffle, nil, 1, 0, true)

    ERACombatTankWindow:Create(bm, 256, 1, 5, 0, 0, 256)

    local bmUtility = ERACombatUtilityFrame:Create(cFrame, -256, -256, 1)
    bmUtility:AddCooldown(0, 0, 115098, nil, true, nil) -- chi wave
    bmUtility:AddCooldown(1, 0, 115008, nil, true, nil) -- chi torpedo

    ------------------------------------------------------------------------------------------------------------------------
    ---- MW ----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------

    local mw = ERACombatTimersGroup:Create(cFrame, -128, -32, 1.5, 2)

    mw:AddCooldownIcon(mw:AddTrackedCooldown(115151), nil, 0, 0, true, true) -- renewing mist
    mw:AddCooldownIcon(mw:AddTrackedCooldown(107428), nil, 0, 1, true, true) -- rsk

    mw:AddAuraBar(mw:AddTrackedBuff(119611), 0.3, 1.0, 0.7) -- rénov

    local grid = ERACombatGrid:Create(cFrame, 0, 0, "BOTTOMLEFT", 2, 115450, "Magic", "Disease", "Poison")
    --, "Curse")
    grid:AddTrackedBuff(119611, nil) -- rénov
    grid:AddTrackedBuff(124682, nil) -- enveloping

    ------------------------------------------------------------------------------------------------------------------------
    ---- WW ----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------

    local wwChi = ERACombatPointsUnitPower:Create(cFrame, 0, 0, 12, 6, 1.0, 1.0, 1.0, 0.1, 1.0, 0.8, nil, 3)

    ------------------------------------------------------------------------------------------------------------------------
    ---- PACK --------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------

    function cFrame:UpdateCombat(t, elapsed)
    end
    ]]
    cFrame:Pack()
end
