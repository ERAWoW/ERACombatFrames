-- TODO
-- unifier fury et pain pour Shadowlands

function ERACombatFrames_DemonHunterSetup(cFrame)
    local havocActive = ERACombatOptions_IsSpecActive(1)
    local vengeanceActive = ERACombatOptions_IsSpecActive(2)

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 26, 17, false, 0.8, 0.1, 0.8, false, havocActive, vengeanceActive)

    local enemies = ERACombatEnemies:Create(cFrame, havocActive, vengeanceActive)

    if (havocActive) then
        ERACombatFrames_DemonHunterHavocSetup(cFrame, enemies)
    end
    if (vengeanceActive) then
        ERACombatFrames_DemonHunterVengeanceSetup(cFrame, enemies)
    end

    -- pack
    --function cFrame:UpdateCombat(t, elapsed)
    --end
    cFrame:Pack()
end

------------------------------------------------------------------------------------------------------------------------
---- HAVOC -------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- TODO
-- TC pour savoir à partir de combien de cibles il faut Fel Rush

function ERACombatFrames_DemonHunterHavocSetup(cFrame, enemies)
    local talent_demonBlades = ERALIBTalent:Create(2, 3)
    local talent_bladetempest = ERALIBTalent:Create(3, 3)
    local talent_cheapDance = ERALIBTalent:Create(5, 2)
    local talent_expensiveDance = ERALIBTalent:CreateNotTalent(5, 2, 12)
    local talent_essence = ERALIBTalent:Create(5, 3)
    local talent_momentum = ERALIBTalent:Create(7, 2)
    local talent_barrage = ERALIBTalent:Create(7, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -101, -11, 1.5, 1)
    timers.watchDispellableMagic = true

    ERACombatHealth:Create(cFrame, -188, -64, 166, 22, 1)

    local fury = ERACombatPower:Create(cFrame, -188, -26, 166, 22, 17, true, 0.8, 0.1, 0.8, 1)

    local consumer_00000_00000_chaos = fury:AddConsumer(40, 1305152)
    local consumer_00000_expen_00000 = fury:AddConsumer(35, 1305149, talent_expensiveDance)
    local consumer_00000_cheap_00000 = fury:AddConsumer(15, 1305149, talent_cheapDance)
    local consumer_eyesb_00000_00000 = fury:AddConsumer(30, 1305156)
    local consumer_eyesb_expen_00000 = fury:AddConsumer(65, 1305156, talent_expensiveDance)
    local consumer_eyesb_cheap_00000 = fury:AddConsumer(45, 1305156, talent_cheapDance)
    local consumer_00000_expen_chaos = fury:AddConsumer(75, 1305152, talent_expensiveDance)
    local consumer_00000_cheap_chaos = fury:AddConsumer(55, 1305152, talent_cheapDance)
    local consumer_eyesb_00000_chaos = fury:AddConsumer(70, 1305152)
    local consumer_eyesb_expen_chaos = fury:AddConsumer(105, 1305152, talent_expensiveDance)
    local consumer_eyesb_cheap_chaos = fury:AddConsumer(85, 1305152, talent_cheapDance)
    local consumers = {
        consumer_00000_00000_chaos,
        consumer_00000_expen_00000,
        consumer_00000_cheap_00000,
        consumer_eyesb_00000_00000,
        consumer_eyesb_expen_00000,
        consumer_eyesb_cheap_00000,
        consumer_00000_expen_chaos,
        consumer_00000_cheap_chaos,
        consumer_eyesb_00000_chaos,
        consumer_eyesb_expen_chaos,
        consumer_eyesb_cheap_chaos
    }
    for i, c in ipairs(consumers) do
        function c:ComputeVisibility()
            return c.computedVisible
        end
        function c:ComputeIconVisibility()
            return c.computedIconVisible
        end
    end

    local danceTimer = timers:AddTrackedCooldown(188499, ERALIBTalent:CreateLevel(12))
    local eyesTimer = timers:AddTrackedCooldown(198013, ERALIBTalent:CreateLevel(11))
    local bladestormTimer = timers:AddTrackedCooldown(342817, talent_bladetempest)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(295373), nil, 0, 2, true, true) -- azerite 1

    timers:AddCooldownIcon(timers:AddTrackedCooldown(232893, ERALIBTalent:Create(1, 3)), nil, -0.7, 0.5, true, true) -- fel blade

    local danceTimerDisplay = timers:AddCooldownIcon(danceTimer, nil, 0, 1, true, true)
    function danceTimerDisplay:OverrideTimerVisibility()
        if (danceTimer.remDuration > 0 or enemies:GetCount() > 1 or talent_cheapDance:PlayerHasTalent()) then
            danceTimerDisplay.icon:SetAlpha(1.0)
            return true
        else
            danceTimerDisplay.icon:SetAlpha(0.3)
            return false
        end
    end

    timers:AddCooldownIcon(eyesTimer, nil, 0, 0, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(258860, talent_essence), nil, 0.5, -0.8, true, true) -- fel essence
    timers:AddCooldownIcon(timers:AddTrackedCooldown(258920), nil, -0.5, -0.8, true, true) -- immo
    timers:AddCooldownIcon(bladestormTimer, nil, -2.5, -0.8, true, true) -- blade tempest

    local glaiveTimerDisplay = timers:AddCooldownIcon(timers:AddTrackedCooldown(185123), nil, -1.5, -0.8, true, true)
    function glaiveTimerDisplay:OverrideTimerVisibility()
        return enemies:GetCount() > 2 or talent_demonBlades:PlayerHasTalent()
    end

    local rushTimer = timers:AddTrackedCooldown(195072)
    local rushTimerDisplay = timers:AddCooldownIcon(rushTimer, nil, 2.5, 1, true, true)
    function rushTimerDisplay:OverrideTimerVisibility()
        return enemies:GetCount() > 2 or talent_momentum:PlayerHasTalent()
    end
    timers:AddCooldownIcon(timers:AddTrackedCooldown(198793), nil, 2.5, 0, false, false) -- retreat

    timers:AddOffensiveDispellCooldown(278326, 2.5, -1, ERALIBTalent:CreateLevel(17), "Magic")
    timers:AddKick(183752, 2.5, 2)

    timers:AddAuraBar(timers:AddTrackedBuff(162264), nil, 0.0, 0.7, 0.0) -- metamorphosis
    timers:AddAuraBar(timers:AddTrackedDebuff(320338, talent_essence), nil, 1.0, 0.5, 0.6) -- essence shadowlands
    timers:AddAuraBar(timers:AddTrackedBuff(208628, talent_momentum), nil, 0.7, 0.6, 0.0) -- momentum

    local utility = ERACombatUtilityFrame:Create(cFrame, -128, -188, 1)

    utility:AddTrinket2Cooldown(-3, 0)
    utility:AddTrinket1Cooldown(-2, 0)

    utility:AddCooldown(-1, 0, 191427, nil, true)
    local metaUtilityBuff = utility:AddBuffIcon(utility:AddTrackedBuff(162264), 237558, -1, 0, true)
    function metaUtilityBuff:ShouldShowBuffIcon()
        return metaUtilityBuff.aura.totDuration > 8.1
    end

    utility:AddCooldown(0, 0, 179057, nil, true).alphaWhenOffCooldown = 0.6 -- nova
    utility:AddCooldown(1, 0, 211881, nil, true, ERALIBTalent:Create(6, 3)) -- fel stun
    utility:AddCooldown(2, 0, 258925, nil, true, talent_barrage) -- fel barrage
    utility:AddCooldown(3, 0, 195072, nil, false) -- fel rush out of combat
    utility:AddCooldown(4, 0, 198793, nil, false) -- fel retreat out of combat

    utility:AddWarlockPortal(2, -1)
    utility:AddRacial(1, -1).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(0, -1, 217832, nil, true, ERALIBTalent:CreateLevel(34)).alphaWhenOffCooldown = 0.2 -- prison
    utility:AddCooldown(-1, -1, 185245, nil, true).alphaWhenOffCooldown = 0.2 -- taunt
    utility:AddCooldown(-2, -1, 188501, nil, true).alphaWhenOffCooldown = 0.15 -- vision
    utility:AddCloakCooldown(-0.5, -1.8).alphaWhenOffCooldown = 0.3
    utility:AddBeltCooldown(0.5, -1.8).alphaWhenOffCooldown = 0.3

    local defensiveCooldowns = ERACombatUtilityFrame:Create(cFrame, 144, -55, 1)
    defensiveCooldowns:AddCooldown(0, 1, 196555, nil, true, ERALIBTalent:Create(4, 3)).alphaWhenOffCooldown = 0.7 -- netherwalk
    defensiveCooldowns:AddCooldown(0, 0, 196718, nil, true, ERALIBTalent:CreateLevel(39)).alphaWhenOffCooldown = 0.7 -- darnkess
    defensiveCooldowns:AddCooldown(0, -1, 198589, nil, true, ERALIBTalent:CreateLevel(21)).alphaWhenOffCooldown = 0.7 -- veil
    defensiveCooldowns:AddWarlockHealthStone(0, -2)

    function fury:PreUpdateCombat(t)
        local cheap = talent_cheapDance:PlayerHasTalent()

        local furyPerSecond  -- multiplicateur de 0.7 pour avoir de la marge
        local hasteMod = 1 / (1 + GetHaste() / 100)
        if (talent_demonBlades:PlayerHasTalent()) then
            furyPerSecond = 7.38 * hasteMod * 0.7
        else
            furyPerSecond = 16 * hasteMod * 0.7
        end

        local danceVisible
        if (enemies:GetCount() > 1 or cheap) then
            local danceCost
            if (cheap) then
                danceCost = 15
            else
                danceCost = 35
            end
            danceVisible = danceTimer.remDuration <= 3 or fury.currentPower + danceTimer.remDuration * furyPerSecond <= danceCost
        else
            danceVisible = false
        end

        local eyesVisible = eyesTimer.remDuration <= 4 or fury.currentPower + eyesTimer.remDuration * furyPerSecond <= 30

        for i, c in ipairs(consumers) do
            c.computedVisible = false
            c.computedIconVisible = false
        end
        if (danceVisible) then
            local chaosVisible = danceTimer.remDuration > 1.5 * hasteMod * 0.8 + timers.remGCD
            if (eyesVisible) then
                if (cheap) then
                    consumer_00000_cheap_00000.computedVisible = true
                    consumer_00000_cheap_00000.computedIconVisible = danceTimer.remDuration <= 1.5
                    consumer_eyesb_cheap_00000.computedVisible = true
                    consumer_eyesb_cheap_00000.computedIconVisible = eyesTimer.remDuration <= 1.5
                    consumer_eyesb_cheap_chaos.computedVisible = true
                    consumer_eyesb_cheap_chaos.computedIconVisible = chaosVisible and fury.currentPower >= 85
                else
                    consumer_00000_expen_00000.computedVisible = true
                    consumer_00000_expen_00000.computedIconVisible = danceTimer.remDuration <= 1.5
                    consumer_eyesb_expen_00000.computedVisible = true
                    consumer_eyesb_expen_00000.computedIconVisible = eyesTimer.remDuration <= 1.5
                    consumer_eyesb_expen_chaos.computedVisible = true
                    consumer_eyesb_expen_chaos.computedIconVisible = chaosVisible and fury.currentPower >= 105
                end
            else
                if (cheap) then
                    consumer_00000_cheap_00000.computedVisible = true
                    consumer_00000_cheap_00000.computedIconVisible = danceTimer.remDuration <= 1.5
                    consumer_00000_cheap_chaos.computedVisible = true
                    consumer_00000_cheap_chaos.computedIconVisible = chaosVisible and fury.currentPower >= 55
                else
                    consumer_00000_expen_00000.computedVisible = true
                    consumer_00000_expen_00000.computedIconVisible = danceTimer.remDuration <= 1.5
                    consumer_00000_expen_chaos.computedVisible = true
                    consumer_00000_expen_chaos.computedIconVisible = chaosVisible and fury.currentPower >= 75
                end
            end
        else
            if (eyesVisible) then
                consumer_eyesb_00000_00000.computedVisible = true
                consumer_eyesb_00000_00000.computedIconVisible = eyesTimer.remDuration <= 1.5
                consumer_eyesb_00000_chaos.computedVisible = true
                consumer_eyesb_00000_chaos.computedIconVisible = fury.currentPower >= 70
            else
                consumer_00000_00000_chaos.computedVisible = true
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
---- VENGEANCE ---------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatSoulFragments = {}
ERACombatSoulFragments.__index = ERACombatSoulFragments
setmetatable(ERACombatSoulFragments, {__index = ERACombatPoints})

function ERACombatSoulFragments:Create(cFrame, x, y, souls)
    local p = {}
    setmetatable(p, ERACombatSoulFragments)
    p:ConstructPoints(cFrame, x, y, 5, 0.0, 0.7, 0.0, 0.4, 0.0, 1.0, nil, 2)
    p.souls = souls
    return p
end

function ERACombatSoulFragments:GetCurrentPoints(t)
    if (self.cFrame.inCombat) then
        return self.souls.stacks
    else
        return 0
    end
end

function ERACombatFrames_DemonHunterVengeanceSetup(cFrame, enemies)
    local talent_puke = ERALIBTalent:CreateLevel(11)
    local talent_felblade = ERALIBTalent:Create(1, 3)
    local talent_fracture = ERALIBTalent:Create(4, 3)
    local talent_not_fracture = ERALIBTalent:CreateNotTalent(4, 3)
    local talent_bomb = ERALIBTalent:Create(3, 3)

    local timers = ERACombatTimersGroup:Create(cFrame, -123, -11, 1.5, 2)
    timers.watchDispellableMagic = true
    local souls = timers:AddTrackedBuff(203981)

    local combatHealth = ERACombatHealth:Create(cFrame, -224, -60, 177, 26, 2)

    local fury = ERACombatPower:Create(cFrame, -224, -28, 177, 20, 18, true, 0.8, 0.1, 0.8, 2)
    fury:AddConsumer(30, 1344653)
    fury:AddConsumer(60, 1344653)
    fury:AddConsumer(90, 1344653)

    local damageWindow = ERACombatTankWindow:Create(timers, 200, 2, 5, 0, 4, 300, ERACombatOptions_IsSpecModuleActive(2, ERACombatOptions_TankWindow))
    function damageWindow:Updated(t)
        local ap = UnitAttackPower("player")
        local versa = 1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100
        local soulcount = math.max(2, souls.stacks)
        combatHealth:SetHealing((0.5 * ap * (1 + soulcount) + soulcount * 0.06 * damageWindow.currentDamage) * versa)
    end

    local felBladeTimer = timers:AddTrackedCooldown(232893, talent_felblade)
    timers:AddCooldownIcon(felBladeTimer, nil, 0, 2, true, true, talent_fracture)
    timers:AddCooldownIcon(felBladeTimer, nil, 0, 1, true, true, talent_not_fracture)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(263642, talent_fracture), nil, 0, 1, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(258920), nil, 0, 0, true, true) -- immo
    timers:AddCooldownIcon(timers:AddTrackedCooldown(203720), nil, -0.77, 0.5, true, true) -- fel spikes
    timers:AddCooldownIcon(timers:AddTrackedCooldown(204021), nil, -0.77, -0.5, true, true) -- fel brand
    timers:AddCooldownIcon(timers:AddTrackedCooldown(189110), nil, 3, 1, true, true) -- fel jump
    timers:AddCooldownIcon(timers:AddTrackedCooldown(204596, ERALIBTalent:CreateLevel(12)), nil, 3, 0, true, true) -- fel flame sigil
    timers:AddKick(183752, 2.5, 2)
    timers:AddOffensiveDispellCooldown(278326, 3.25, 1.5, ERALIBTalent:CreateLevel(17), "Magic")

    --timers:AddCooldownIcon(timers:AddTrackedCooldown(204157), nil, -1.2, -1.8, true, true) -- fel glaive ; pas la peine il a un cd de 3 secondes

    timers:AddAuraBar(timers:AddTrackedBuff(187827), nil, 0.0, 0.7, 0.0) -- metamorphosis
    timers:AddAuraBar(timers:AddTrackedBuff(203819), nil, 0.8, 0.8, 0.0) -- spikes
    local bombTimer = timers:AddTrackedDebuff(247456, talent_bomb)
    local bombTimerDisplay = timers:AddAuraBar(bombTimer, nil, 1.0, 0.0, 0.2)
    function bombTimerDisplay:GetRemDurationOr0IfInvisible()
        if (bombTimer.remDuration <= 7.5) then
            return bombTimer.remDuration
        else
            return 0
        end
    end
    timers:AddMissingAura(bombTimer, nil, 0, 3, true)
    timers:AddAuraBar(timers:AddTrackedDebuff(207771), nil, 0.7, 1.0, 0.8) -- brand

    local utility = ERACombatUtilityFrame:Create(cFrame, -128, -222, 2)

    utility:AddTrinket2Cooldown(-1.5, 0.88)
    utility:AddTrinket1Cooldown(-0.5, 0.88)
    utility:AddCooldown(0.5, 0.88, 263648, nil, true, ERALIBTalent:Create(6, 3)).alphaWhenOffCooldown = 1 -- fel barrier
    utility:AddCooldown(1.5, 0.88, 212084, nil, true, talent_puke).alphaWhenOffCooldown = 1 -- fel puke
    utility:AddCooldown(2.5, 0.88, 320341, nil, true, ERALIBTalent:Create(7, 3)).alphaWhenOffCooldown = 1 -- fel extraction

    utility:AddCooldown(1, 0, 187827, nil, true)
    local metaUtilityBuff = utility:AddBuffIcon(utility:AddTrackedBuff(187827), 237558, 0, 0, true)
    function metaUtilityBuff:ShouldShowBuffIcon()
        return true or metaUtilityBuff.aura.remDuration > 6.1
    end

    utility:AddRacial(0, 0).alphaWhenOffCooldown = 0.4
    utility:AddCooldown(2, 0, 202137, nil, true, ERALIBTalent:CreateLevel(39)).alphaWhenOffCooldown = 0.5 -- sigil silence
    utility:AddCooldown(3, 0, 207684, nil, true, ERALIBTalent:CreateLevel(33)).alphaWhenOffCooldown = 0.5 -- sigil misery
    utility:AddCooldown(4, 0, 202138, nil, true, ERALIBTalent:Create(5, 3)).alphaWhenOffCooldown = 0.5 -- sigil chains
    utility:AddWarlockHealthStone(5, 0)
    utility:AddWarlockPortal(6, 0)

    utility:AddCloakCooldown(-1, -1).alphaWhenOffCooldown = 0.3
    utility:AddBeltCooldown(0, -1).alphaWhenOffCooldown = 0.3
    utility:AddCooldown(1, -1, 185245, nil, true).alphaWhenOffCooldown = 0.2 -- taunt
    utility:AddCooldown(2, -1, 217832, nil, true, ERALIBTalent:CreateLevel(34)).alphaWhenOffCooldown = 0.2 -- prison
    utility:AddCooldown(3, -1, 188501, nil, true).alphaWhenOffCooldown = 0.1 -- vision

    ERACombatSoulFragments:Create(cFrame, -200, -88, souls)

    local pukeTimer = timers:AddTrackedCooldown(212084, talent_puke)
    local pukeConsumer = fury:AddConsumer(50, 1450143)
    function pukeConsumer:ComputeVisibility()
        return pukeTimer.remDuration <= 3
    end
    function pukeConsumer:ComputeIconVisibility()
        return pukeTimer.remDuration <= 0
    end
end
