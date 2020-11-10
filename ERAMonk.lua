-- TODO
-- tout

function ERACombatFrames_MonkSetup(cFrame)
    ERAPieIcon_BorderR = 0.0
    ERAPieIcon_BorderG = 1.0
    ERAPieIcon_BorderB = 0.8

    local bmActive = ERACombatOptions_IsSpecActive(1)
    local mwActive = ERACombatOptions_IsSpecActive(2)
    local wwActive = ERACombatOptions_IsSpecActive(3)

    ERAOutOfCombatStatusBars:Create(cFrame, -155, -66, 128, 22, 3, true, 1, 1, 0, false, bmActive, wwActive)
    ERAOutOfCombatStatusBars:Create(cFrame, -155, -66, 128, 22, 0, true, 0.1, 0.1, 1.0, false, mwActive)

    if (bmActive) then
        ERACombatFrames_MonkBrewmasterSetup(cFrame)
    end
    if (mwActive) then
        ERACombatFrames_MonkMistweaverSetup(cFrame)
    end
    if (wwActive) then
        ERACombatFrames_MonkWindwalkerSetup(cFrame)
    end

    cFrame:Pack()

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
end

------------------------------------------------------------------------------------------------------------------------
---- BM ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkBrewmasterSetup(cFrame)
    local nrg = ERACombatPower:Create(cFrame, -166, -28, 155, 22, 3, false, 1.0, 1.0, 0.0, 1)
    local tigerPalmConsumer = nrg:AddConsumer(25, 606551)
    nrg:AddConsumer(40, 594274)
    nrg:AddConsumer(65, 606551)

    local health = ERACombatHealth:Create(cFrame, -166, -55, 155, 22, 1)

    local timers = ERACombatTimersGroup:Create(cFrame, -89, 32, 1, 1)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(205523), nil, -1, 0.5, true, false) -- bok
    timers:AddCooldownIcon(timers:AddTrackedCooldown(322101), nil, -2, 0.5, true, false) -- EH

    local utility = ERACombatFrames_MonkUtility(cFrame, 1, 128, -32)

    local bmUtility = ERACombatUtilityFrame:Create(cFrame, -128, -144, 1)
end

------------------------------------------------------------------------------------------------------------------------
---- MW ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkMistweaverSetup(cFrame)
    ERACombatHealth:Create(cFrame, -166, -91, 166, 22, 2)
    ERACombatPower:Create(cFrame, -166, -111, 166, 22, 0, false, 0.1, 0.1, 1.0, 2)

    local grid = ERACombatGrid:Create(cFrame, -111, 8, "BOTTOMRIGHT", 2, 4987, "Magic", "Disease", "Poison")

    local timers = ERACombatTimersGroup:Create(cFrame, -111, -64, 1.5, 2)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(107428), nil, 0, 3, true, false) -- rsk
    timers:AddCooldownIcon(timers:AddTrackedCooldown(100784), nil, 0, 2, true, false) -- bok
    timers:AddCooldownIcon(timers:AddTrackedCooldown(322101), nil, 0, 1, true, false) -- EH
    local utility = ERACombatFrames_MonkUtility(cFrame, 2, 128, -32)
    local defensive = ERACombatFrames_MonkDefensiveUtility(cFrame, 2, 0, -128)
end

------------------------------------------------------------------------------------------------------------------------
---- WW ----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkWindwalkerSetup(cFrame)
    ERACombatPointsUnitPower:Create(cFrame, -144, -28, 12, 5, 1.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil, 3)

    local nrg = ERACombatPower:Create(cFrame, -155, -51, 155, 22, 3, false, 1.0, 1.0, 0.0, 3)
    local tigerPalmConsumer = nrg:AddConsumer(50, 606551)

    local health = ERACombatHealth:Create(cFrame, -155, -77, 155, 22, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -89, 32, 1, 3)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(107428), nil, -1, 0.5, true, false) -- rsk
    timers:AddCooldownIcon(timers:AddTrackedCooldown(113656), nil, -2, 0.5, true, false) -- fof
    timers:AddCooldownIcon(timers:AddTrackedCooldown(115098, ERALIBTalent:Create(1, 2)), nil, -3, 0.5, true, false)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(322101), nil, -4, 0.5, true, false) -- EH

    local utility = ERACombatFrames_MonkUtility(cFrame, 3, 128, -32)
    local defensive = ERACombatFrames_MonkDefensiveUtility(cFrame, 3, 0, -128)
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_MonkUtility(cFrame, spec, x, y)
    local utility = ERACombatUtilityFrame:Create(cFrame, x, y, spec)
    utility:AddCooldown(0, 1, 109132, nil, true, nil) -- roll
    utility:AddCooldown(0, 0, 119381, nil, true, nil).alphaWhenOffCooldown = 0.6 -- leg sweep
    local tod = utility:AddCooldown(0, -1, 322109, nil, true, nil) -- tod
    function tod:IconUpdatedAndShown(t)
        if (self.remDuration <= 0) then
            if (IsUsableSpell(322109)) then
                self.icon:SetAlpha(1)
            else
                self.icon:SetAlpha(0.2)
            end
        end
    end

    utility:AddCooldown(0, -2, 115546, nil, true, nil).alphaWhenOffCooldown = 0.2 -- taunt

    utility:AddWarlockPortal(0.8, 0.5)
    utility:AddRacial(0.8, -0.5).alphaWhenOffCooldown = 0.4

    return utility
end

function ERACombatFrames_MonkDefensiveUtility(cFrame, spec, x, y)
    local utility = ERACombatUtilityFrame:Create(cFrame, x, y, spec)
    utility:AddWarlockHealthStone(1, 0)
    return utility
end
