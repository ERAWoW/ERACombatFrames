-- TODO
-- defensive dispells à tester

ERACombatUtilityFrame_IconSize = 64
--44
ERACombatUtilityFrame_IconSpacing = 4
ERACombatUtilityFrame_LongCooldownThreshold = 30

ERACombatUtilityFrame = {}
ERACombatUtilityFrame.__index = ERACombatUtilityFrame
setmetatable(ERACombatUtilityFrame, {__index = ERACombatModule})

function ERACombatUtilityFrame:AddCooldown(x, y, spellID, iconID, showInCombat, talent)
    return ERACombatUtilityCooldown:create(self, x, y, spellID, iconID, showInCombat, talent)
end
function ERACombatUtilityFrame:AddDebuffAnyCasterIcon(aura, iconID, x, y, showInCombat, talent)
    return ERACombatUtilityDebuffAnyCaster:create(aura, iconID, x, y, showInCombat, talent)
end
function ERACombatUtilityFrame:AddBuffIcon(aura, iconID, x, y, showInCombat, talent)
    return ERACombatUtilityBuff:create(aura, iconID, x, y, showInCombat, talent)
end
function ERACombatUtilityFrame:AddMissingBuffAnyCaster(iconID, x, y, talent, ...)
    return ERACombatUtilityMissingBuffAnyCaster:create(self, iconID, x, y, talent, ...)
end
function ERACombatUtilityFrame:AddMissingBuff(aura, iconID, x, y, showInCombat, beam, talent, ...)
    return ERACombatUtilityMissingAura:create(aura, iconID, x, y, showInCombat, beam, talent, ...)
end
function ERACombatUtilityFrame:AddTrackedBuff(spellID, talent)
    return ERACombatUtilityBuffTracker:create(self, spellID, talent)
end
function ERACombatUtilityFrame:AddTrackedDebuffAnyCaster(spellID, talent)
    return ERACombatUtilityDebuffAnyCasterTracker:create(self, spellID, talent)
end

function ERACombatUtilityFrame:AddDefensiveDispellCooldown(x, y, spellID, iconID, talent, ...)
    local c = ERACombatUtilityDefensiveDispellCooldown:create(self, x, y, spellID, iconID, talent, ...)
    self.watchDefensiveDispell = true
    for _, dt in ipairs {...} do
        local array = self.defensiveDispells[dt]
        if (not array) then
            array = {}
            self.defensiveDispells[dt] = array
        end
        table.insert(array, c)
    end
    return c
end

function ERACombatUtilityFrame:AddRacial(x, y)
    local _, _, r = UnitRace("player")
    local spellID = nil
    if (r == 1 or r == 33) then -- human
        spellID = 59752
    elseif (r == 2) then -- orc
        spellID = 33697
    elseif (r == 3) then -- dwarf
        spellID = 20594
    elseif (r == 4) then -- night elf
        spellID = 58984
    elseif (r == 5) then -- undead
        spellID = 7744
    elseif (r == 6) then -- tauren
        spellID = 20549
    elseif (r == 7) then -- gnome
        spellID = 20589
    elseif (r == 8) then -- troll
        spellID = 26297
    elseif (r == 9) then -- goblin
        spellID = 69070
    elseif (r == 10) then -- blood elf
        spellID = 202719
    elseif (r == 11) then -- draenei
        spellID = 59542 -- (paladin)
    elseif (r == 22) then -- worgen
        spellID = 68992
    elseif (r == 24 or r == 25 or r == 26) then -- pandaren
        spellID = 107079
    elseif (r == 27) then -- nightborne
        spellID = 260364
    elseif (r == 28) then -- highmountain
        spellID = 255654
    elseif (r == 29) then -- void elf
        spellID = 256948
    elseif (r == 30) then -- lightforged
        spellID = 255647
    elseif (r == 31) then -- zandalari
        spellID = 291944
    elseif (r == 32) then -- kul tiran
        spellID = 287712
    elseif (r == 34) then -- dark iron
        spellID = 265221
    elseif (r == 35) then -- vulpera
        spellID = 312411
    elseif (r == 36) then -- mag'har
        spellID = 274738
    elseif (r == 37) then -- mechagnome
        spellID = 312924
    end
    if (spellID) then
        return self:AddCooldown(x, y, spellID, nil, true)
    else
        return nil
    end
end

function ERACombatUtilityFrame:AddWarlockHealthStone(x, y, warningIfMissing)
    return self:AddBagItem(x, y, 5512, 538745, warningIfMissing)
end
function ERACombatUtilityFrame:AddWarlockPortal(x, y)
    local d = self:AddDebuffAnyCasterIcon(self:AddTrackedDebuffAnyCaster(113942, nil), nil, x, y, true, nil)
    d.reverse = true
    d.fade = true
    return d
end
function ERACombatUtilityFrame:AddBagItem(x, y, itemID, iconID, warningIfMissing)
    return ERACombatUtilityBagItem:create(self, x, y, itemID, iconID, warningIfMissing)
end

function ERACombatUtilityFrame:Create(cFrame, x, y, ...)
    local f = {}
    setmetatable(f, ERACombatUtilityFrame)

    f.mustUpdateSpells = true

    f.frame = CreateFrame("Frame", nil, UIParent, nil)
    f.frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    f.frame:SetSize(512, 512)

    f.icons = {}
    f.activeIcons = {}
    f.buffs = {}
    f.activeBuffs = {}
    f.hasTrackedBuffs = false
    f.debuffsAny = {}
    f.activeDebuffsAny = {}
    f.hasTrackedDebuffsAny = false
    f.hasTrackedMissingBuffsAny = false
    f.trackedMissingBuffsAny = {}
    f.last_calc_missing_buff_any = 0
    f.defensiveDispells = {}
    f.bagItems = {}

    f.events = {}
    function f.events:BAG_UPDATE()
        for _, i in ipairs(f.bagItems) do
            i:bagUpdateOrReset()
        end
    end
    f.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            f.events[event](self, ...)
        end
    )

    f:construct(cFrame, 0.2, 0.1, false, ...)
    return f
end

function ERACombatUtilityFrame:UpdateAfterReset(t)
    for _, i in ipairs(self.activeIcons) do
        i:updateAfterReset(t)
    end
end

function ERACombatUtilityFrame:ResetToIdle()
    self.frame:Show()
    for k, v in pairs(self.events) do
        self.frame:RegisterEvent(k)
    end
    for _, i in ipairs(self.bagItems) do
        i:bagUpdateOrReset()
    end
end
function ERACombatUtilityFrame:EnterCombat()
    for i, c in ipairs(self.icons) do
        c:enterCombat()
    end
end
function ERACombatUtilityFrame:EnterVehicle()
    self.frame:Hide()
end
function ERACombatUtilityFrame:ExitVehicle()
    self.frame:Show()
end
function ERACombatUtilityFrame:SpecInactive(wasActive)
    if (wasActive) then
        self.frame:Hide()
        self.frame:UnregisterAllEvents()
    end
end
function ERACombatUtilityFrame:CheckTalents()
    self.activeBuffs = {}
    self.hasTrackedBuffs = false
    for _, b in ipairs(self.buffs) do
        if (b:checkTalents()) then
            self.activeBuffs[b.spellID] = b
            self.hasTrackedBuffs = true
        end
    end
    self.activeDebuffsAny = {}
    self.hasTrackedDebuffsAny = false
    for _, d in ipairs(self.debuffsAny) do
        if (d:checkTalents()) then
            self.activeDebuffsAny[d.spellID] = d
            self.hasTrackedDebuffsAny = true
        end
    end
    self.activeIcons = {}
    for _, c in ipairs(self.icons) do
        if (c:checkTalentsOrHide()) then
            table.insert(self.activeIcons, c)
        end
    end
end

function ERACombatUtilityFrame:UpdateIdle(t)
    self:updateData(t)
    for i, c in ipairs(self.activeIcons) do
        c:updateIdle(t)
    end
end

function ERACombatUtilityFrame_updateAura(aura, t, stacks, durAura, expirationTime)
    local auraRemDuration
    if (expirationTime and expirationTime > 0) then
        auraRemDuration = expirationTime - t
    else
        auraRemDuration = 4096
    end
    if ((not durAura) or auraRemDuration > durAura) then
        durAura = auraRemDuration
    end
    if (not (stacks and stacks > 0)) then
        stacks = 1
    end
    aura:auraFound(auraRemDuration, durAura, stacks)
end
function ERACombatUtilityFrame:updateData(t)
    if (self.mustUpdateSpells) then
        self.mustUpdateSpells = false
        self:CheckTalents()
    end

    if (self.watchDefensiveDispell) then
        for i = 1, 40 do
            local _, _, _, debuffType, _, _, _, canStealOrPurge, _, spellID = UnitDebuff("player", i)
            if (spellID) then
                if (debuffType) then
                    local c = self.defensiveDispells[debuffType]
                    if (c ~= nil) then
                        for _, dd in ipairs(c) do
                            dd.playerDispellable = true
                        end
                    end
                end
            else
                break
            end
        end
    end

    if (self.hasTrackedDebuffsAny) then
        for i = 1, 40 do
            local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitDebuff("player", i)
            if (spellID) then
                local b = self.activeDebuffsAny[spellID]
                if (b ~= nil) then
                    ERACombatUtilityFrame_updateAura(b, t, stacks, durAura, expirationTime)
                end
            else
                break
            end
        end
        for k, v in pairs(self.activeDebuffsAny) do
            v:updateAura(t)
        end
    end
    if (self.hasTrackedBuffs) then
        for i = 1, 40 do
            local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitBuff("player", i, "PLAYER")
            if (spellID) then
                local b = self.activeBuffs[spellID]
                if (b ~= nil) then
                    ERACombatUtilityFrame_updateAura(b, t, stacks, durAura, expirationTime)
                end
            else
                break
            end
        end
        for k, v in pairs(self.activeBuffs) do
            v:updateAura(t)
        end
    end
    if (self.hasTrackedMissingBuffsAny) then
        if (t - self.last_calc_missing_buff_any > 0.5) then
            self.updatingMissingBuffsAny = true
            self.last_calc_missing_buff_any = t
            for i = 1, 40 do
                local _, _, _, _, _, expirationTime, _, _, _, spellID = UnitBuff("player", i)
                if (spellID) then
                    local b = self.trackedMissingBuffsAny[spellID]
                    if (b ~= nil) then
                        b.found = true
                    end
                else
                    break
                end
            end
        else
            self.updatingMissingBuffsAny = false
        end
    end
end

function ERACombatUtilityFrame:UpdateCombat(t)
    self:updateData(t)
    for i, c in ipairs(self.activeIcons) do
        c:updateCombat(t)
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- AURA DEFINITION -----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityAuraTracker = {}
ERACombatUtilityAuraTracker.__index = ERACombatUtilityAuraTracker

function ERACombatUtilityAuraTracker:construct(owner, spellID, talent)
    self.talent = talent
    self.spellID = spellID
    self.owner = owner
end

function ERACombatUtilityAuraTracker:checkTalents()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.totDuration = 1.0
        self.remDuration = 0.0
        self.stacks = 0
        return false
    else
        return true
    end
end

function ERACombatUtilityAuraTracker:auraFound(auraRemDuration, durAura, stacks)
    if (self.found) then
        if (self.totDuration < auraRemDuration) then
            self.totDuration = durAura
            self.remDuration = auraRemDuration
            self.stacks = stacks
        end
    else
        self.found = true
        self.totDuration = durAura
        self.remDuration = auraRemDuration
        self.stacks = stacks
    end
end

function ERACombatUtilityAuraTracker:updateAura(t)
    if (self.found) then
        self.found = false
    else
        self.totDuration = 1.0
        self.remDuration = 0.0
        self.stacks = 0
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- BUFF DEFINITION -----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityBuffTracker = {}
ERACombatUtilityBuffTracker.__index = ERACombatUtilityBuffTracker
setmetatable(ERACombatUtilityBuffTracker, {__index = ERACombatUtilityAuraTracker})

function ERACombatUtilityBuffTracker:create(owner, spellID, talent)
    local bt = {}
    setmetatable(bt, ERACombatUtilityBuffTracker)
    bt:construct(owner, spellID, talent)
    table.insert(owner.buffs, bt)
    return bt
end

--------------------------------------------------------------------------------------------------------------------------------
---- DEBUFF DEFINITION ---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityDebuffAnyCasterTracker = {}
ERACombatUtilityDebuffAnyCasterTracker.__index = ERACombatUtilityDebuffAnyCasterTracker
setmetatable(ERACombatUtilityDebuffAnyCasterTracker, {__index = ERACombatUtilityAuraTracker})

function ERACombatUtilityDebuffAnyCasterTracker:create(owner, spellID, talent)
    local bt = {}
    setmetatable(bt, ERACombatUtilityDebuffAnyCasterTracker)
    bt:construct(owner, spellID, talent)
    table.insert(owner.debuffsAny, bt)
    return bt
end

--------------------------------------------------------------------------------------------------------------------------------
---- ABSTRACT ICON -------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityIcon = {}
ERACombatUtilityIcon.__index = ERACombatUtilityIcon

function ERACombatUtilityIcon:construct(owner, x, y, iconID, frameLevel, showInCombat, talent)
    table.insert(owner.icons, self)
    self.showInCombat = showInCombat
    self.owner = owner
    self.talent = talent
    self.icon = ERAPieIcon:Create(owner.frame, "CENTER", ERACombatUtilityFrame_IconSize, iconID)
    self.icon:Draw(x * (ERACombatUtilityFrame_IconSize + ERACombatUtilityFrame_IconSpacing), y * (ERACombatUtilityFrame_IconSize + ERACombatUtilityFrame_IconSpacing), false)
    self.icon:Hide()
    self.icon.frame:SetFrameLevel(frameLevel)
end

function ERACombatUtilityIcon:updateAfterReset(t)
end

function ERACombatUtilityIcon:checkTalentsOrHide()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.icon:Hide()
        return false
    else
        self:talentOK()
        return true
    end
end
function ERACombatUtilityIcon:talentOK()
end
function ERACombatUtilityIcon:enterCombat()
    if (not self.showInCombat) then
        self.icon:Hide()
    end
end

-- abstract function ERACombatUtilityIcon:updateIdle(t)

function ERACombatUtilityIcon:updateCombat(t)
    if (self.showInCombat) then
        self:doUpdateCombat(t)
    end
end
-- abstract function ERACombatUtilityIcon:doUpdateCombat(t)

--------------------------------------------------------------------------------------------------------------------------------
---- COOLDOWN ICON -------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityCooldownBase = {}
ERACombatUtilityCooldownBase.__index = ERACombatUtilityCooldownBase
setmetatable(ERACombatUtilityCooldownBase, {__index = ERACombatUtilityIcon})

function ERACombatUtilityCooldownBase:constructBase(owner, x, y, spellID, iconID, showInCombat, talent)
    self.iconID = iconID
    if (not iconID) then
        _, _, iconID = GetSpellInfo(spellID)
    end
    self:construct(owner, x, y, iconID, 0, showInCombat, talent)
    self.spellID = spellID
    self.totDuration = 1
    self.remDuration = 0
    self.isAvailable = false
    self:updateKind()
end

function ERACombatUtilityCooldownBase:updateAfterReset(t)
    self:updateKind()
    self:updateIconCooldownTexture()
end

function ERACombatUtilityCooldownBase:updateIconCooldownTexture()
    if (not self.iconID) then
        local _, _, iconID = GetSpellInfo(self.spellID)
        self.icon:SetIconTexture(iconID, true)
    end
end

function ERACombatUtilityCooldownBase:talentOK()
    self:updateKind()
    self:updateIconCooldownTexture()
end

function ERACombatUtilityCooldownBase:updateKind()
    local currentCharges, maxCharges = GetSpellCharges(self.spellID)
    if (maxCharges and maxCharges > 1) then
        self.currentCharges = currentCharges
        self.maxCharges = maxCharges
        self.hasCharges = true
    else
        self.icon:SetSecondaryText(nil)
        self.currentCharges = 0
        self.maxCharges = 1
        self.hasCharges = false
    end
end

-- normal cd

ERACombatUtilityCooldown = {}
ERACombatUtilityCooldown.__index = ERACombatUtilityCooldown
setmetatable(ERACombatUtilityCooldown, {__index = ERACombatUtilityCooldownBase})

function ERACombatUtilityCooldown:create(owner, x, y, spellID, iconID, showInCombat, talent)
    local c = {}
    setmetatable(c, ERACombatUtilityCooldown)
    c:constructBase(owner, x, y, spellID, iconID, showInCombat, talent)
    c.alphaWhenOffCooldown = 0.9
    c.alphaWhenOnShortCooldown = 1.0
    c.alphaWhenOnLongCooldown = 0.5
    return c
end

function ERACombatUtilityCooldown:updateIdle(t)
    if (self.showOnlyIfPetSpellKnown and not IsSpellKnown(self.spellID, true)) then
        self.icon:Hide()
    else
        ERACombatCooldown_Update(self, t, 2)
        if (self.hasCharges) then
            if (self.currentCharges > 0) then
                if (self.remDuration <= 0 or self.currentCharges >= self.maxCharges) then
                    self.icon:Hide()
                else
                    self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                    ERACombatCooldownIcon_SetSaturatedAndChargesText(self, self)
                    self:showIcon(t)
                end
            else
                self.icon:SetDesaturated(true)
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetSecondaryText(nil)
                self.icon:SetMainText(math.floor(self.remDuration))
                self:showIcon(t)
            end
        else
            self.icon:SetDesaturated(self.remDuration > ERACombatUtilityFrame_LongCooldownThreshold)
            if (self.remDuration > 0) then
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetMainText(math.floor(self.remDuration))
                self:showIcon(t)
            else
                self.icon:Hide()
            end
        end
    end
end

function ERACombatUtilityCooldown:showIcon(t)
    if (self.remDuration > ERACombatUtilityFrame_LongCooldownThreshold) then
        self.icon:SetAlpha(self.alphaWhenOnLongCooldown)
    elseif (self.remDuration > 0) then
        self.icon:SetAlpha(self.alphaWhenOnShortCooldown)
    elseif (self.alphaWhenOffCooldown > 0) then
        self.icon:SetAlpha(self.alphaWhenOffCooldown)
    else
        self.icon:Hide()
        return
    end
    self.icon:Show()
    self:IconUpdatedAndShown(t)
end
function ERACombatUtilityCooldown:IconUpdatedAndShown(t)
end

function ERACombatUtilityCooldown:doUpdateCombat(t)
    if (self.showOnlyIfPetSpellKnown and not IsSpellKnown(self.spellID, true)) then
        self.icon:Hide()
    else
        ERACombatCooldown_Update(self, t, 2)
        if (self.hasCharges) then
            if (self.currentCharges > 0) then
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                ERACombatCooldownIcon_SetSaturatedAndChargesText(self, self)
            else
                self.icon:SetDesaturated(true)
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetSecondaryText(nil)
                self.icon:SetMainText(math.floor(self.remDuration))
            end
        else
            self.icon:SetDesaturated(self.remDuration > 30)
            if (self.remDuration > 0) then
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetMainText(math.floor(self.remDuration))
            else
                self.icon:SetOverlayValue(0)
                self.icon:SetMainText(nil)
            end
        end
        self:showIcon()
    end
end

-- dispell cooldown

ERACombatUtilityDefensiveDispellCooldown = {}
ERACombatUtilityDefensiveDispellCooldown.__index = ERACombatUtilityDefensiveDispellCooldown
setmetatable(ERACombatUtilityDefensiveDispellCooldown, {__index = ERACombatUtilityCooldownBase})

function ERACombatUtilityDefensiveDispellCooldown:create(owner, x, y, spellID, iconID, talent)
    local c = {}
    setmetatable(c, ERACombatUtilityDefensiveDispellCooldown)
    c:constructBase(owner, x, y, spellID, iconID, true, talent)
    return c
end

function ERACombatUtilityDefensiveDispellCooldown:updateIdle(t)
    if (self.showOnlyIfPetSpellKnown and not IsSpellKnown(self.spellID, true)) then
        self.icon:Hide()
    else
        if (self:update_return_onCD_or_dispellable(t)) then
            self.icon:Show()
        else
            self.icon:Hide()
        end
    end
end

function ERACombatUtilityDefensiveDispellCooldown:update_return_onCD_or_dispellable(t)
    ERACombatCooldown_Update(self, t, 2)
    if (self.playerDispellable) then
        self.playerDispellable = false
        self.icon:SetAlpha(1.0)
        if (self.hasCharges) then
            if (self.currentCharges > 0) then
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                ERACombatCooldownIcon_SetSaturatedAndChargesText(self, self)
                self.icon:Beam()
            else
                self.icon:SetDesaturated(false)
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetSecondaryText(nil)
                self.icon:SetMainText(math.floor(self.remDuration))
                self.icon:StopBeam()
            end
        else
            self.icon:SetDesaturated(self.remDuration > 16)
            if (self.remDuration > 0) then
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetMainText(math.floor(self.remDuration))
                self.icon:StopBeam()
            else
                self.icon:SetOverlayValue(0)
                self.icon:SetMainText(nil)
                self.icon:Beam()
            end
        end
        return true
    else
        self.icon:StopBeam()
        if (self.hasCharges) then
            if (self.currentCharges <= 0) then
                self.icon:SetAlpha(0.5)
                self.icon:SetDesaturated(false)
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetSecondaryText(nil)
                self.icon:SetMainText(math.floor(self.remDuration))
                return true
            elseif (self.currentCharges < self.maxCharges) then
                self.icon:SetAlpha(0.5)
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                ERACombatCooldownIcon_SetSaturatedAndChargesText(self, self)
                return true
            else
                self.icon:SetOverlayValue(0)
                ERACombatCooldownIcon_SetSaturatedAndChargesText(self, self)
                return false
            end
        else
            self.icon:SetDesaturated(self.remDuration > 16)
            if (self.remDuration > 0) then
                self.icon:SetAlpha(0.5)
                self.icon:SetOverlayValue(self.remDuration / self.totDuration)
                self.icon:SetMainText(math.floor(self.remDuration))
                return true
            else
                self.icon:SetOverlayValue(0)
                self.icon:SetMainText(nil)
                return false
            end
        end
    end
end

function ERACombatUtilityDefensiveDispellCooldown:doUpdateCombat(t)
    if (self.showOnlyIfPetSpellKnown and not IsSpellKnown(self.spellID, true)) then
        self.icon:Hide()
    else
        if (not self:update_return_onCD_or_dispellable(t)) then
            self.icon:SetAlpha(0.1)
        end
        self.icon:Show()
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- AURA ICON -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityAura = {}
ERACombatUtilityAura.__index = ERACombatUtilityAura
setmetatable(ERACombatUtilityAura, {__index = ERACombatUtilityIcon})

function ERACombatUtilityAura:constructAura(aura, iconID, x, y, showInCombat, talent)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(aura.spellID)
    end
    if (talent) then
        if (aura.talent) then
            talent = ERALIBTalent:CreateAnd(talent, aura.talent)
        end
    else
        talent = aura.talent
    end
    self:construct(aura.owner, x, y, iconID, 1, showInCombat, talent)
    self.aura = aura
end

function ERACombatUtilityAura:updateIdle(t)
    self:update(t)
end
function ERACombatUtilityAura:doUpdateCombat(t)
    self:update(t)
end

--------------------------------------------------------------------------------------------------------------------------------
---- BUFF ICON -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityBuff = {}
ERACombatUtilityBuff.__index = ERACombatUtilityBuff
setmetatable(ERACombatUtilityBuff, {__index = ERACombatUtilityAura})

function ERACombatUtilityBuff:create(aura, iconID, x, y, showInCombat, talent)
    local c = {}
    setmetatable(c, ERACombatUtilityBuff)
    c:constructAura(aura, iconID, x, y, showInCombat, talent)
    return c
end

function ERACombatUtilityBuff:update(t)
    if (self.aura.remDuration > 0) then
        if (self:ShouldShowBuffIcon()) then
            self.icon:SetOverlayValue(1 - self.aura.remDuration / self.aura.totDuration)
            self.icon:SetMainText(math.floor(self.aura.remDuration))
            if (self.aura.stacks > 1) then
                self.icon:SetSecondaryText(self.aura.stacks)
            else
                self.icon:SetSecondaryText(nil)
            end
            self.icon:Show()
        else
            self.icon:Hide()
        end
    else
        self.icon:Hide()
    end
end
function ERACombatUtilityBuff:ShouldShowBuffIcon()
    return true
end

--------------------------------------------------------------------------------------------------------------------------------
---- DEBUFF ICON ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityDebuffAnyCaster = {}
ERACombatUtilityDebuffAnyCaster.__index = ERACombatUtilityDebuffAnyCaster
setmetatable(ERACombatUtilityDebuffAnyCaster, {__index = ERACombatUtilityAura})

function ERACombatUtilityDebuffAnyCaster:create(aura, iconID, x, y, showInCombat, talent)
    local c = {}
    setmetatable(c, ERACombatUtilityDebuffAnyCaster)
    c:constructAura(aura, iconID, x, y, showInCombat, talent)
    c.lastPresent = nil
    c.lastDuration = nil
    return c
end

function ERACombatUtilityDebuffAnyCaster:update(t)
    if (self.ShouldShowDebuffIcon()) then
        if (self.aura.remDuration > 0) then
            self.lastPresent = t
            self.lastDuration = self.aura.totDuration
            if (self.reverse) then
                self.icon:SetOverlayValue(self.aura.remDuration / self.aura.totDuration)
            else
                self.icon:SetOverlayValue(1 - self.aura.remDuration / self.aura.totDuration)
            end
            self.icon:SetMainText(math.floor(self.aura.remDuration))
            if (self.aura.stacks > 1) then
                self.icon:SetSecondaryText(self.aura.stacks)
            else
                self.icon:SetSecondaryText(nil)
            end
            self.icon:SetAlpha(1)
            self.icon:Show()
        else
            if (self.fade and self.lastPresent and self.lastDuration) then
                if ((not self.owner.cFrame.inCombat) or t - self.lastPresent > math.min(16, 0.3 * self.lastDuration)) then
                    self.lastPresent = nil
                    self.icon:Hide()
                else
                    self.icon:SetAlpha(0.5)
                    self.icon:SetOverlayValue(0)
                    self.icon:SetMainText(nil)
                    self.icon:SetSecondaryText(nil)
                    self.icon:Show()
                end
            else
                self.icon:Hide()
            end
        end
    else
        self.icon:Hide()
    end
end
function ERACombatUtilityDebuffAnyCaster:ShouldShowDebuffIcon()
    return true
end

--------------------------------------------------------------------------------------------------------------------------------
---- BAG ITEM ------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityBagItem = {}
ERACombatUtilityBagItem.__index = ERACombatUtilityBagItem
setmetatable(ERACombatUtilityBagItem, ERACombatUtilityIcon)

function ERACombatUtilityBagItem:create(utility, x, y, itemID, iconID, warningIfMissing)
    local s = {}
    setmetatable(s, ERACombatUtilityBagItem)
    s:construct(utility, x, y, iconID, 0, true)
    s.totDuration = 1
    s.remDuration = 0
    s.alphaWhenOffCooldown = 0.9
    s.alphaWhenOnShortCooldown = 1.0
    s.alphaWhenOnLongCooldown = 0.5
    s.itemID = itemID
    s.warningIfMissing = warningIfMissing
    s.bagID = -1
    s.slot = -1
    table.insert(utility.bagItems, s)
    return c
end

function ERACombatUtilityBagItem:bagUpdateOrReset()
    self.bagID = -1
    self.slot = -1
    for i = 0, NUM_BAG_SLOTS do
        local cpt = GetContainerNumSlots(i)
        for j = 1, cpt do
            local id = GetContainerItemID(i, j)
            if (id == self.itemID) then
                self.bagID = i
                self.slot = j
                break
            end
        end
        if (self.bagID > 0) then
            break
        end
    end
end

function ERACombatUtilityBagItem:updateIdle(t)
    self:updateDurations(t)
    if (self.stacks > 0) then
        self:clearWarningMissing()
        if (self.remDuration > 0) then
            self:updateShowIcon()
        else
            self.icon:Hide()
        end
    else
        if (self.warningIfMissing) then
            self:showMissingWarning()
        else
            self.icon:Hide()
        end
    end
end
function ERACombatUtilityBagItem:updateShowIcon()
    self.icon:SetSecondaryText(self.stacks)
    self.icon:SetMainText(math.floor(self.remDuration))
    self.icon:SetOverlayValue(self.remDuration / self.totDuration)
    if (self.remDuration > ERACombatUtilityFrame_LongCooldownThreshold) then
        self.icon:SetDesaturated(true)
        self.icon:SetAlpha(self.alphaWhenOnLongCooldown)
    else
        self.icon:SetDesaturated(false)
        self.icon:SetAlpha(self.alphaWhenOnShortCooldown)
    end
    self.icon:Show()
end
function ERACombatUtilityBagItem:doUpdateCombat(t)
    self:updateDurations(t)
    if (self.stacks > 0) then
        self:clearWarningMissing()
        if (self.remDuration > 0) then
            self:updateShowIcon()
        else
            self.icon:SetSecondaryText(self.stacks)
            self.icon:SetMainText(nil)
            self.icon:SetOverlayValue(0)
            self.icon:SetDesaturated(false)
            self.icon:SetAlpha(self.alphaWhenOffCooldown)
            self.icon:Show()
        end
    else
        if (self.warningIfMissing) then
            self:showMissingWarning()
        else
            self.icon:Hide()
        end
    end
end
function ERACombatUtilityBagItem:updateDurations(t)
    if (self.bagID >= 0) then
        local start, duration = GetContainerItemCooldown(self.bagID, self.slot)
        if (start and start > 0) then
            self.remDuration = (start + duration) - t
            self.totDuration = duration
        else
            self.remDuration = 0
            self.totDuration = duration
        end
        self.stacks = GetItemCount(self.itemID, false, true)
    else
        self.remDuration = 0
        self.totDuration = 1
        self.stacks = 0
    end
end
function ERACombatUtilityBagItem:clearWarningMissing()
    self.icon:SetVertexColor(1, 1, 1, 1)
end
function ERACombatUtilityBagItem:showMissingWarning()
    self.icon:SetVertexColor(1, 0, 0, 1)
    self.icon:SetSecondaryText("0")
    self.icon:SetMainText(nil)
    self.icon:SetOverlayValue(0)
    self.icon:SetDesaturated(false)
    self.icon:SetAlpha(1)
    self.icon:Show()
end

--------------------------------------------------------------------------------------------------------------------------------
---- MISSING BUFF --------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityMissingAura = {}
ERACombatUtilityMissingAura.__index = ERACombatUtilityMissingAura
setmetatable(ERACombatUtilityMissingAura, {__index = ERACombatUtilityIcon})

function ERACombatUtilityMissingAura:create(aura, iconID, x, y, showInCombat, beam, talent, ...)
    local mi = {}
    setmetatable(mi, ERACombatUtilityMissingAura)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(aura.spellID)
    end
    mi:construct(aura.owner, x, y, iconID, 1, showInCombat, talent)
    mi.aura = aura
    mi.additional = {}
    for _, additional in ipairs {...} do
        table.insert(mi.additional, additional)
    end
    mi.beam = beam
    if (beam) then
        mi.icon:Beam()
    end
    return mi
end

function ERACombatUtilityMissingAura:updateIdle(t)
    self:update(t)
end
function ERACombatUtilityMissingAura:doUpdateCombat(t)
    self:update(t)
end
function ERACombatUtilityMissingAura:update(t)
    if (self.aura.remDuration > 0 or self.aura.stacks > 0) then
        self.icon:Hide()
        return
    end
    for _, a in ipairs(self.additional) do
        if (a.remDuration > 0 or a.stacks > 0) then
            self.icon:Hide()
            return
        end
    end
    if (UnitIsDeadOrGhost("player")) then
        self.icon:Hide()
    else
        self.icon:Show()
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- MISSING BUFF ANY CASTER ---------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatUtilityMissingBuffAnyCaster = {}
ERACombatUtilityMissingBuffAnyCaster.__index = ERACombatUtilityMissingBuffAnyCaster
setmetatable(ERACombatUtilityMissingBuffAnyCaster, {__index = ERACombatUtilityIcon})

function ERACombatUtilityMissingBuffAnyCaster:create(owner, iconID, x, y, talent, ...)
    local mi = {}
    setmetatable(mi, ERACombatUtilityMissingBuffAnyCaster)
    mi:construct(owner, x, y, iconID, 1, true, talent)
    mi.icon:Beam()
    for _, id in ipairs {...} do
        owner.hasTrackedMissingBuffsAny = true
        owner.trackedMissingBuffsAny[id] = mi
    end
    return mi
end

function ERACombatUtilityMissingBuffAnyCaster:updateIdle(t)
    self:update(t)
end
function ERACombatUtilityMissingBuffAnyCaster:doUpdateCombat(t)
    self:update(t)
end
function ERACombatUtilityMissingBuffAnyCaster:update(t)
    if (self.owner.updatingMissingBuffsAny) then
        if (self.found) then
            self.found = false
            self.icon:Hide()
        else
            self.icon:Show()
        end
    end
end
