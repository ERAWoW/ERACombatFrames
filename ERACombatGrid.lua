-- TODO
-- dispells à tester
-- adapter Backdrop à l'API shadowlands sur playerframe et sa dispellMark
-- test : if (true or self.numPlayers > 1) then (dans updateGroup)
-- talents

ERACombatGrid_AuraSize = 20
ERACombatGrid_CellHeight = 44
ERACombatGrid_CellWidth = 111
ERACombatGrid_CellPadding = 2
ERACombatGrid_UnitBorderThickness = 2
ERACombatGrid_UnitPadding = 1
ERACombatGrid_DispellSize = 10
ERACombatGrid_HealthOffsetFromMainFrame = ERACombatGrid_UnitBorderThickness + ERACombatGrid_UnitPadding
ERACombatGrid_HealthOffsetFromCell = ERACombatGrid_CellPadding + ERACombatGrid_HealthOffsetFromMainFrame
ERACombatGrid_HealthWidth = ERACombatGrid_CellWidth - 2 * ERACombatGrid_HealthOffsetFromCell
ERACombatGrid_HealthHeight = ERACombatGrid_CellHeight - 2 * ERACombatGrid_HealthOffsetFromCell
ERACombatGrid_MainFrameWidthIncludingBorder = ERACombatGrid_CellWidth - 2 * ERACombatGrid_CellPadding

--------------------------------------------------------------------------------------------------------------------------------
---- GRID ----------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatGrid = {}
ERACombatGrid.__index = ERACombatGrid
setmetatable(ERACombatGrid, {__index = ERACombatModule})

function ERACombatGrid:AddTrackedBuff(spellID, position, priority, rC, gC, bC, rB, gB, bB, talent)
    return self:addTrackedAura(spellID, position, priority, rC, gC, bC, rB, gB, bB, talent, false, self.allTrackedBuffs)
end
function ERACombatGrid:AddTrackedDebuff(spellID, position, priority, rC, gC, bC, rB, gB, bB, talent)
    return self:addTrackedAura(spellID, position, priority, rC, gC, bC, rB, gB, bB, talent, true, self.allTrackedDebuffs)
end
function ERACombatGrid:addTrackedAura(spellID, position, priority, rC, gC, bC, rB, gB, bB, talent, isDebuff, array)
    local x = ERACombatGridAuraDefinition:create(self, 1 + #array, spellID, isDebuff, position, priority, rC, gC, bC, rB, gB, bB, talent)
    table.insert(array, x)
    return x
end

ERACombatGrid_counter = 0

function ERACombatGrid:Create(cFrame, x, y, anchor, spec, dispellID, ...)
    local g = {}
    setmetatable(g, ERACombatGrid)

    g.isGridVisible = ERACombatOptions_IsSpecModuleActive(spec, ERACombatOptions_Grid)
    g.anchor = anchor
    g.x = x
    g.y = y

    -- unités
    g.units = {}
    g.unitsByID = {}

    g.dispellID = dispellID
    g.dispells = {}
    for i, s in ipairs {...} do
        table.insert(g.dispells, s)
    end
    g.dispellOnCD = false

    -- évènements
    g.gridEvents = {}
    function g.gridEvents:UNIT_HEALTH(unitID)
        g:updateHealth(unitID)
    end
    function g.gridEvents:UNIT_MAXHEALTH(unitID)
        g:updateHealth(unitID)
    end
    function g.gridEvents:UNIT_ABSORB_AMOUNT_CHANGED(unitID)
        g:updateHealth(unitID)
    end
    function g.gridEvents:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unitID)
        g:updateHealth(unitID)
    end
    --[[
    function g.gridEvents:GROUP_JOINED()
        g:updateGroup()
    end
    function g.gridEvents:GROUP_LEFT()
        g:updateGroup()
    end
    ]]
    function g.gridEvents:GROUP_ROSTER_UPDATE()
        g:updateGroup()
    end
    function g.gridEvents:RAID_ROSTER_UPDATE()
        g:updateGroup()
    end
    function g.gridEvents:PLAYER_ROLES_ASSIGNED()
        g:updateGroup()
    end
    function g.gridEvents:ROLE_CHANGED_INFORM()
        g:updateGroup()
    end
    g.eventFrame = CreateFrame("Frame", nil, UIParent, nil)
    g.eventFrame:SetScript(
        "OnEvent",
        function(self, event, ...)
            g.gridEvents[event](self, ...)
        end
    )

    g.allTrackedBuffs = {}
    g.activeTrackedBuffsFetcher = {}
    g.activeTrackedBuffsArray = {}
    g.allTrackedDebuffs = {}
    g.activeTrackedDebuffsFetcher = {}
    g.activeTrackedDebuffsArray = {}
    g.isSolo = true

    g:construct(cFrame, 0.3, 0.1, false, spec)
    return g
end

function ERACombatGrid:Pack()
    self:RaidDebuffs()
    self.frame = CreateFrame("Frame", "ERACombatGridHeader" .. ERACombatGrid_counter, UIParent, "SecureGroupHeaderTemplate")
    ERACombatGrid_counter = ERACombatGrid_counter + 1
    self.frame.grid = self
    self.frame:SetSize(1024, 1024)
    self.frame:SetPoint(self.anchor, UIParent, "CENTER", self.x, self.y)
    if (self.isGridVisible) then
        self.frame:SetAttribute("template", "ERACombatGridPlayerFrame")
    else
        self.frame:SetAttribute("template", "ERACombatGridPlayerFrameEmpty")
    end
    self.frame:SetAttribute("showParty", true)
    self.frame:SetAttribute("showRaid", true)
    self.frame:SetAttribute("showPlayer", true)
    self.frame:SetAttribute("showSolo", false)
    if (self.anchor == "TOP" or self.anchor == "TOPRIGHT" or self.anchor == "TOPLEFT") then
        self.frame:SetAttribute("point", "TOP")
    else
        self.frame:SetAttribute("point", "BOTTOM")
    end
    if (self.anchor == "LEFT" or self.anchor == "TOPLEFT" or self.anchor == "BOTTOMLEFT") then
        self.frame:SetAttribute("columnAnchorPoint", "LEFT")
    else
        self.frame:SetAttribute("columnAnchorPoint", "RIGHT")
    end
    self.frame:SetAttribute("maxColumns", 6)
    self.frame:SetAttribute("unitsPerColumn", 8)
    self.frame:SetAttribute("sortMethod", "INDEX")
    self.frame:SetAttribute("groupBy", "ASSIGNEDROLE")
    self.frame:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,TANK,HEALER,DAMAGER,NONE")
    self.frame.initialConfigFunction = function(grid, unitframeName)
        ERACombatGrid_initialConfigFunction(grid, _G[unitframeName])
    end
    self.frame:SetAttribute(
        "initialConfigFunction",
        [[
        RegisterUnitWatch(self);
        self:SetAttribute("type", "target");
        self:SetAttribute("initial-width", 111);
        self:SetAttribute("initial-height", 44);
        self:GetParent():CallMethod("initialConfigFunction", self:GetName());
    ]]
    )
    if (not self.isGridVisible) then
    --self.frame:Hide()
    end
end

function ERACombatGrid:ResetToIdle()
    --if (self.isGridVisible) then
    self.frame:Show()
    --end
    for k, v in pairs(self.gridEvents) do
        self.eventFrame:RegisterEvent(k)
    end
    self:updateGroup()
end

function ERACombatGrid:SpecInactive(wasActive)
    if (wasActive) then
        self.frame:Hide()
        self.eventFrame:UnregisterAllEvents()
    end
end
function ERACombatGrid:CheckTalents()
    local index = 1
    self.activeTrackedBuffsFetcher = {}
    self.activeTrackedBuffsArray = {}
    for _, a in ipairs(self.allTrackedBuffs) do
        if (a:computeTalent(index)) then
            index = index + 1
            self.activeTrackedBuffsFetcher[a.spellID] = a
            table.insert(self.activeTrackedBuffsArray, a)
        end
    end
    index = 1
    self.activeTrackedDebuffsFetcher = {}
    self.activeTrackedDebuffsArray = {}
    for _, a in ipairs(self.allTrackedDebuffs) do
        if (a:computeTalent(index)) then
            index = index + 1
            self.activeTrackedDebuffsFetcher[a.spellID] = a
            table.insert(self.activeTrackedDebuffsArray, a)
        end
    end
    for _, u in pairs(self.unitsByID) do
        u:computeTalents()
    end
end

function ERACombatGrid:updateGroup()
    local thisself = self
    C_Timer.After(
        4,
        function()
            thisself.isSolo = GetNumGroupMembers() <= 1
        end
    )
    if (self.isGridVisible) then
        for _, u in pairs(self.unitsByID) do
            u:updateDefaultBorder()
        end
    end
end

function ERACombatGrid:updateHealth(unitID)
    local unit = self.unitsByID[unitID]
    if (unit) then
        unit:updateHealth()
    end
end

function ERACombatGrid:UpdateIdle(t)
    self:UpdateCombat(t)
end
function ERACombatGrid:UpdateCombat(t)
    for i, x in ipairs(self.activeTrackedBuffsArray) do
        x:prepareUpdate()
    end
    for i, x in ipairs(self.activeTrackedDebuffsArray) do
        x:prepareUpdate()
    end
    local started, duration = GetSpellCooldown(self.dispellID)
    self.dispellOnCD = started and duration and duration >= 2
    for _, u in pairs(self.unitsByID) do
        u:update(t)
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- UNIT FRAME ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatGridUnitPrototype = {}

ERACombatGridUnitEvents = {}

function ERACombatGrid_initialConfigFunction(gridframe, unitframe)
    --unitframe:SetAttribute("*type1", "target")
    --unitframe:SetAttribute("*type2", "menu")
    for name, value in pairs(ERACombatGridUnitPrototype) do
        unitframe[name] = value
    end
    for event, handler in pairs(ERACombatGridUnitEvents) do
        unitframe:HookScript(event, handler)
    end

    unitframe.grid = gridframe.grid

    if (unitframe.grid.isGridVisible) then
        --unitframe:SetSize(ERACombatGrid_CellWidth, ERACombatGrid_CellHeight)
        --unitframe:SetFrameStrata("MEDIUM")

        --unitframe.mainFrame = CreateFrame("Frame", nil, unitframe, BackdopTemplateMixin and "BackdropTemplate")
        unitframe.mainFrame = CreateFrame("Frame", nil, unitframe, "BackdropTemplate")
        unitframe.mainFrame:SetFrameStrata("LOW")
        unitframe.mainFrame:SetBackdrop(
            {
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = ERACombatGrid_UnitBorderThickness
            }
        )
        unitframe.borderR = 0.3
        unitframe.borderG = 0.3
        unitframe.borderB = 0.3
        unitframe.mainFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0)
        unitframe.mainFrame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
        unitframe.mainFrame:SetPoint("TOPLEFT", unitframe, "TOPLEFT", ERACombatGrid_CellPadding, -ERACombatGrid_CellPadding)
        unitframe.mainFrame:SetPoint("TOPRIGHT", unitframe, "TOPRIGHT", -ERACombatGrid_CellPadding, -ERACombatGrid_CellPadding)
        unitframe.mainFrame:SetPoint("BOTTOMLEFT", unitframe, "BOTTOMLEFT", ERACombatGrid_CellPadding, ERACombatGrid_CellPadding)
        unitframe.mainFrame:SetPoint("BOTTOMRIGHT", unitframe, "BOTTOMRIGHT", -ERACombatGrid_CellPadding, ERACombatGrid_CellPadding)

        unitframe.health = unitframe.mainFrame:CreateTexture(nil, "BORDER")
        unitframe.health:SetPoint("TOPLEFT", unitframe.mainFrame, "TOPLEFT", ERACombatGrid_HealthOffsetFromMainFrame, -ERACombatGrid_HealthOffsetFromMainFrame)
        unitframe.health:SetPoint("BOTTOMLEFT", unitframe.mainFrame, "BOTTOMLEFT", ERACombatGrid_HealthOffsetFromMainFrame, ERACombatGrid_HealthOffsetFromMainFrame)
        unitframe.health:SetWidth(ERACombatGrid_HealthWidth)
        unitframe.health:SetColorTexture(0.0, 1.0, 0.0, 1.0)

        unitframe.absorbHealBar = unitframe.mainFrame:CreateTexture(nil, "BORDER")
        unitframe.absorbHealBar:SetHeight(ERACombatGrid_HealthHeight)
        unitframe.absorbHealBar:SetColorTexture(1.0, 0.0, 0.0, 1.0)
        unitframe.absorbDamageBar = unitframe.mainFrame:CreateTexture(nil, "BORDER")
        unitframe.absorbDamageBar:SetColorTexture(0.0, 0.0, 1.0, 1.0)
        unitframe.absorbDamageBar:SetHeight(ERACombatGrid_HealthHeight)

        unitframe.nameBlock = unitframe:CreateFontString(nil, "HIGHLIGHT")
        ERALIB_SetFont(unitframe.nameBlock, ERACombatGrid_CellHeight * 0.25)
        unitframe.nameBlock:SetPoint("TOPLEFT", unitframe.mainFrame, "TOPLEFT", ERACombatGrid_DispellSize + ERACombatGrid_HealthOffsetFromCell + 4, -ERACombatGrid_HealthOffsetFromCell)

        unitframe.dispellMark = CreateFrame("Frame", nil, unitframe.mainFrame, "BackdropTemplate")
        unitframe.dispellMark:SetSize(ERACombatGrid_DispellSize, ERACombatGrid_DispellSize)
        unitframe.dispellMark:SetPoint("TOPLEFT", unitframe.mainFrame, "TOPLEFT", ERACombatGrid_HealthOffsetFromMainFrame, -ERACombatGrid_HealthOffsetFromMainFrame)
        unitframe.dispellMark:SetBackdrop(
            {
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 2
            }
        )
        unitframe.dispellMark:SetBackdropColor(1.0, 1.0, 1.0, 1.0)
        unitframe.dispellMark:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)
        unitframe.dispellMark:Hide()
        unitframe.dispellable = false

        unitframe.deadLine1 = unitframe.mainFrame:CreateLine(nil, "OVERLAY", "ERACombatGridPlayerDeadLine")
        unitframe.deadLine1:SetStartPoint("BOTTOMLEFT", unitframe.mainFrame, ERACombatGrid_HealthOffsetFromMainFrame, ERACombatGrid_HealthOffsetFromMainFrame)
        unitframe.deadLine1:SetEndPoint("TOPRIGHT", unitframe.mainFrame, -ERACombatGrid_HealthOffsetFromMainFrame, -ERACombatGrid_HealthOffsetFromMainFrame)
        unitframe.deadLine1:Hide()
        unitframe.deadLine2 = unitframe.mainFrame:CreateLine(nil, "OVERLAY", "ERACombatGridPlayerDeadLine")
        unitframe.deadLine2:SetStartPoint("TOPLEFT", unitframe.mainFrame, ERACombatGrid_HealthOffsetFromMainFrame, -ERACombatGrid_HealthOffsetFromMainFrame)
        unitframe.deadLine2:SetEndPoint("BOTTOMRIGHT", unitframe.mainFrame, -ERACombatGrid_HealthOffsetFromMainFrame, ERACombatGrid_HealthOffsetFromMainFrame)
        unitframe.deadLine2:Hide()
    end

    unitframe.dead = false
    unitframe.inRange = true
    unitframe.currentHealth = 0
    unitframe.maxHealth = 1
    unitframe.absorbDamageValue = 0
    unitframe.absorbHealingValue = 0

    unitframe.allBuffs = {}
    for _, x in ipairs(gridframe.grid.allTrackedBuffs) do
        table.insert(unitframe.allBuffs, ERACombatGridAuraInstance:create(x, unitframe))
    end
    unitframe.allDebuffs = {}
    for _, x in ipairs(gridframe.grid.allTrackedDebuffs) do
        table.insert(unitframe.allDebuffs, ERACombatGridAuraInstance:create(x, unitframe))
    end
    unitframe.activeBuffs = {}
    unitframe.activeDebuffs = {}
    unitframe:computeTalents()
end

function ERACombatGridUnitEvents:OnShow()
    self.grid:updateGroup()
end

function ERACombatGridUnitEvents:OnHide()
    self.grid:updateGroup()
end

function ERACombatGridUnitEvents:OnAttributeChanged(name, value)
    if (name == "unit") then
        if (value == nil) then
            if (self.unit ~= nil) then
                self.grid.unitsByID[self.unit] = nil
                self.unit = nil
            end
        else
            if (self.unit ~= nil and self.grid.unitsByID[self.unit] == self) then
                self.grid.unitsByID[self.unit] = nil
            end
            self.grid.unitsByID[value] = self
            self.unit = value
            self.isThisPlayer = UnitIsUnit(value, "player")

            self.inRange = true
            if (self.grid.isGridVisible) then
                self.nameBlock:SetText(UnitName(value))
                local _, className = UnitClass(value)
                local r, g, b = GetClassColor(className)
                self.r = r
                self.g = g
                self.b = b
                self:SetAlpha(1.0)
                self.health:SetColorTexture(r, g, b, 1.0)
                self:updateDefaultBorder()
            end
            self:updateHealth()
        end
    end
end

function ERACombatGridUnitPrototype:updateDefaultBorder()
    if (self.isThisPlayer) then
        self.defBR = 0.0
        self.defBG = 0.8
        self.defBB = 1.0
    else
        local role = UnitGroupRolesAssigned(self.unit)
        if (role == "TANK") then
            self.defBR = 0.8
            self.defBG = 0.0
            self.defBB = 0.8
        elseif (role == "HEALER") then
            self.defBR = 0.0
            self.defBG = 0.8
            self.defBB = 0.1
        else
            self.defBR = 0.3
            self.defBG = 0.3
            self.defBB = 0.3
        end
    end
end

function ERACombatGridUnitPrototype:computeTalents()
    for _, a in ipairs(self.activeBuffs) do
        if (a.def.indexInActiveAuras <= 0) then
            a:deactivate()
        end
    end
    self.activeBuffs = {}
    for _, a in ipairs(self.grid.activeTrackedBuffsArray) do
        local i = self.allBuffs[a.indexInAllAuras]
        i:activate()
        table.insert(self.activeBuffs, i)
    end

    for _, a in ipairs(self.activeDebuffs) do
        if (a.def.indexInActiveAuras <= 0) then
            a:deactivate()
        end
    end
    self.activeDebuffs = {}
    for _, a in ipairs(self.grid.activeTrackedDebuffsArray) do
        local i = self.allDebuffs[a.indexInAllAuras]
        i:activate()
        table.insert(self.activeDebuffs, i)
    end
end

function ERACombatGridUnitPrototype:setBorder(r, g, b)
    if (self.borderR ~= r or self.borderG ~= g or self.borderB ~= b) then
        self.borderR = r
        self.borderG = b
        self.borderB = r
        self.mainFrame:SetBackdropBorderColor(r, g, b, 1.0)
    end
end

function ERACombatGridUnitPrototype:updateHealth()
    if (UnitIsDeadOrGhost(self.unit)) then
        if (not self.dead) then
            self.currentHealth = 0
            self.maxHealth = 1
            self.absorbDamageValue = 0
            self.absorbHealingValue = 0
            self.dead = true
            if (self.grid.isGridVisible) then
                self.deadLine1:Show()
                self.deadLine2:Show()
                self.health:SetWidth(0)
                self.absorbHealBar:Hide()
                self.absorbDamageBar:Hide(0)
            end
        end
    else
        if (self.dead) then
            self.dead = false
            if (self.grid.isGridVisible) then
                self.deadLine1:Hide()
                self.deadLine2:Hide()
            end
        end
        local c = UnitHealth(self.unit)
        local m = UnitHealthMax(self.unit)
        local aH = UnitGetTotalHealAbsorbs(self.unit)
        local aD = UnitGetTotalAbsorbs(self.unit)
        if (c ~= self.currentHealth or m ~= self.maxHealth or ah ~= self.absorbHealingValue or aD ~= self.absorbDamageValue) then
            self.currentHealth = c
            self.maxHealth = m
            if (self.grid.isGridVisible) then
                local ratio = ERACombatGrid_HealthWidth / m
                local x
                if (aH > c) then
                    self.health:SetWidth(0)
                    x = c * ratio
                    self.absorbHealBar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", ERACombatGrid_HealthOffsetFromMainFrame, -ERACombatGrid_HealthOffsetFromMainFrame)
                    self.absorbHealBar:SetWidth(x)
                    x = x + ERACombatGrid_HealthOffsetFromMainFrame
                    if (self.absorbHealingValue <= 0) then
                        self.absorbHealBar:Show()
                    end
                else
                    if (aH > 0) then
                        x = (c - aH) * ratio
                        self.health:SetWidth(x)
                        x = x + ERACombatGrid_HealthOffsetFromMainFrame
                        self.absorbHealBar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", x, -ERACombatGrid_HealthOffsetFromMainFrame)
                        local aHwidth = aH * ratio
                        self.absorbHealBar:SetWidth(aHwidth)
                        x = x + aHwidth
                        if (self.absorbHealingValue <= 0) then
                            self.absorbHealBar:Show()
                        end
                    else
                        x = c * ratio
                        self.health:SetWidth(x)
                        x = x + ERACombatGrid_HealthOffsetFromMainFrame
                        if (self.absorbHealingValue > 0) then
                            self.absorbHealBar:Hide()
                        end
                    end
                end
                if (aD > 0) then
                    self.absorbDamageBar:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", x, -ERACombatGrid_HealthOffsetFromMainFrame)
                    self.absorbDamageBar:SetWidth(ratio * math.min(aD, m - c))
                    if (self.absorbDamageValue <= 0) then
                        self.absorbDamageBar:Show()
                    end
                elseif (self.absorbDamageValue > 0) then
                    self.absorbDamageBar:Hide()
                end
            end
            self.absorbDamageValue = aD
            self.absorbHealingValue = aH
        end
        if (self.isThisPlayer or UnitInRange(self.unit)) then
            if (not self.inRange) then
                self.inRange = true
                if (self.grid.isGridVisible) then
                    self.health:SetColorTexture(self.r, self.g, self.b, 1.0)
                    self:SetAlpha(1.0)
                end
            end
        else
            if (self.inRange) then
                self.inRange = false
                if (self.grid.isGridVisible) then
                    self.health:SetColorTexture(0.3, 0.3, 0.3, 1.0)
                    self:SetAlpha(0.5)
                end
            end
        end
    end
end

function ERACombatGridUnitPrototype_updateAura(t, expirationTime, durAura, stacks, def, array)
    local auraRemDuration
    if (expirationTime and expirationTime > 0) then
        auraRemDuration = expirationTime - t
    else
        auraRemDuration = 4096
    end
    if (not durAura or durAura < auraRemDuration) then
        durAura = auraRemDuration
    end
    if (not (stacks and stacks > 0)) then
        auraStacks = 1
    end
    array[def.indexInActiveAuras]:auraFound(auraRemDuration, durAura, stacks)
end
function ERACombatGridUnitPrototype:update(t)
    self:updateHealth()

    if (self.grid.isGridVisible) then
        local threat = UnitThreatSituation(self.unit)
        local isTanking = threat and threat >= 2
        if (UnitIsUnit("target", self.unit)) then
            if (self.isThisPlayer) then
                self:setBorder(1.0, 0.5, 1.0)
            else
                if (isTanking) then
                    self:setBorder(1.0, 1.0, 1.0)
                else
                    self:setBorder(1.0, 0.5, 0.5)
                end
            end
        else
            if (isTanking) then
                self:setBorder(1.0, 0.0, 0.0)
            else
                self:setBorder(self.defBR, self.defBG, self.defBB)
            end
        end
    end

    local dispellable = false
    for i = 1, 40 do
        local _, _, stacks, type, durAura, expirationTime, _, isStealable, _, spellID = UnitDebuff(self.unit, i)
        if (spellID) then
            local td = self.grid.activeTrackedDebuffsFetcher[spellID]
            if (td ~= nil) then
                ERACombatGridUnitPrototype_updateAura(t, expirationTime, durAura, stacks, td, self.activeDebuffs)
            end
            if (not dispellable) then
                for i, dis in ipairs(self.grid.dispells) do
                    if (type == dis) then
                        dispellable = true
                        break
                    end
                end
            end
        else
            break
        end
    end
    if (dispellable) then
        if (self.grid.dispellOnCD) then
            if (not self.dispellOnCD) then
                self.dispellOnCD = true
                if (self.grid.isGridVisible) then
                    self.dispellMark:SetBackdropColor(0.5, 0.5, 0.5, 1.0)
                end
            end
        else
            if (self.dispellOnCD) then
                self.dispellOnCD = false
                if (self.grid.isGridVisible) then
                    self.dispellMark:SetBackdropColor(1.0, 1.0, 1.0, 1.0)
                end
            end
        end
        if (not self.dispellable) then
            self.dispellable = true
            if (self.grid.isGridVisible) then
                self.dispellMark:Show()
            end
        end
    else
        if (self.dispellable) then
            self.dispellable = false
            if (self.grid.isGridVisible) then
                self.dispellMark:Hide()
            end
        end
    end

    for i = 1, 40 do
        local _, _, stacks, _, durAura, expirationTime, _, _, _, spellID = UnitBuff(self.unit, i, "PLAYER")
        if (spellID) then
            local tb = self.grid.activeTrackedBuffsFetcher[spellID]
            if (tb ~= nil) then
                ERACombatGridUnitPrototype_updateAura(t, expirationTime, durAura, stacks, tb, self.activeBuffs)
            end
        else
            break
        end
    end

    for i, x in ipairs(self.activeBuffs) do
        x:updateData()
    end
    for i, x in ipairs(self.activeDebuffs) do
        x:updateData()
    end
    if (self.grid.isGridVisible) then
        for i, x in ipairs(self.activeBuffs) do
            x.def:updateDisplay(x)
        end
        for i, x in ipairs(self.activeDebuffs) do
            x.def:updateDisplay(x)
        end
    end
end

function ERACombatGridUnitPrototype:GetAura(a)
    if (a.isDebuff) then
        return self.allDebuffs[a.indexInAllAuras]
    else
        return self.allBuffs[a.indexInAllAuras]
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- AURA DEFINITION -----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatGridAuraDefinition = {}
ERACombatGridAuraDefinition.__index = ERACombatGridAuraDefinition

function ERACombatGridAuraDefinition:create(g, indexInAllAuras, spellID, isDebuff, position, priority, rC, gC, bC, rB, gB, bB, talent)
    local a = {}
    setmetatable(a, ERACombatGridAuraDefinition)
    a.grid = g
    a.priority = priority
    a.position = position
    a.talent = talent
    a.isDebuff = isDebuff
    a.spellID = spellID
    a.indexInAllAuras = indexInAllAuras
    a.indexInActiveAuras = -1
    a.instances = {}
    a.rC = rC
    a.gC = gC
    a.bC = bC
    a.rB = rB
    a.gB = gB
    a.bB = bB
    return a
end

function ERACombatGridAuraDefinition:computeTalent(index)
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.indexInActiveAuras = -1
        self.instances = {}
        return false
    else
        self.indexInActiveAuras = index
        return true
    end
end

function ERACombatGridAuraDefinition:prepareUpdate()
    self.instances = {}
end

function ERACombatGridAuraDefinition:updateDisplay(instance)
    self:updateDisplayDefault(instance)
end
function ERACombatGridAuraDefinition:updateDisplayDefault(instance)
    if (instance.remDuration > 0) then
        ERAPieControl_SetOverlayValue(instance, 1 - instance.remDuration / instance.totDuration)
        if (instance.stacks > 1) then
            instance.text:SetText(instance.stacks)
        else
            instance.text:SetText(nil)
        end
        instance:show()
    else
        instance:hide()
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- AURA ON UNIT --------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatGridAuraInstance = {}
ERACombatGridAuraInstance.__index = ERACombatGridAuraInstance

function ERACombatGridAuraInstance:create(def, unitframe)
    local a = {}
    setmetatable(a, ERACombatGridAuraInstance)
    a.def = def
    a.unitframe = unitframe
    return a
end

function ERACombatGridAuraInstance:activate()
    if (self.unitframe.grid.isGridVisible and not self.frame) then
        self.frame = CreateFrame("Frame", nil, self.unitframe.mainFrame, "ERACombatGridAuraFrame")
        self.size = ERACombatGrid_AuraSize
        self.frame:SetSize(ERACombatGrid_AuraSize, ERACombatGrid_AuraSize)
        self.frame:SetFrameLevel(3 + self.def.priority)
        if (self.def.isDebuff) then
            self.frame:SetPoint(
                "BOTTOMRIGHT",
                self.unitframe.mainFrame,
                "BOTTOMRIGHT",
                -ERACombatGrid_HealthOffsetFromMainFrame - self.def.position * ERACombatGrid_AuraSize,
                ERACombatGrid_HealthOffsetFromMainFrame
            )
        else
            self.frame:SetPoint(
                "BOTTOMLEFT",
                self.unitframe.mainFrame,
                "BOTTOMLEFT",
                ERACombatGrid_HealthOffsetFromMainFrame + self.def.position * ERACombatGrid_AuraSize,
                ERACombatGrid_HealthOffsetFromMainFrame
            )
        end
        self.frame.BORDER:SetVertexColor(self.def.rB, self.def.gB, self.def.bB, 1.0)
        self.frame.CENTER:SetVertexColor(self.def.rC, self.def.gC, self.def.bC, 1.0)
        self.trt = self.frame.TRT
        self.trr = self.frame.TRR
        self.tlt = self.frame.TLT
        self.tlr = self.frame.TLR
        self.blr = self.frame.BLR
        self.blt = self.frame.BLT
        self.brt = self.frame.BRT
        self.brr = self.frame.BRR
        ERAPieControl_Init(self)
        ERAPieControl_SetOverlayAlpha(self, 1.0)
        self.text = self.frame.Text
        ERALIB_SetFont(self.text, ERACombatGrid_AuraSize * 0.8)
        self.frame:Hide()
        self.visible = false
    end
end

function ERACombatGridAuraInstance:deactivate()
    self.remDuration = 0
    if (not self.totDuration) then
        self.totDuration = 1
    end
    self.stacks = 0
    self.visible = false
    self.frame:Hide()
end

function ERACombatGridAuraInstance:auraFound(auraRemDuration, durAura, stacks)
    self.found = true
    self.remDuration = auraRemDuration
    self.totDuration = durAura
    self.stacks = stacks
end

function ERACombatGridAuraInstance:updateData()
    if (self.found) then
        self.found = false
        table.insert(self.def.instances, self)
    else
        self.remDuration = 0
        self.totDuration = 1
        self.stacks = 0
    end
end

function ERACombatGridAuraInstance:show()
    if (not self.visible) then
        self.visible = true
        self.frame:Show()
    end
end
function ERACombatGridAuraInstance:hide()
    if (self.frame and self.visible) then
        self.visible = false
        self.frame:Hide()
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- INSTANCES -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERALIBTalent_Nathria = ERALIBTalent:CreateInstance(2296)

function ERACombatGrid:RaidDebuffs()
    -- rgbC, rgbB

    self:AddTrackedDebuff(342074, 0, 1, 1.0, 0.0, 0.0, 0.0, 0.5, 0.5, ERALIBTalent_Nathria) -- bat jump
    self:AddTrackedDebuff(328897, 0, 2, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- bat tank bleed

    self:AddTrackedDebuff(335114, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- altimor shot 1
    self:AddTrackedDebuff(335304, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- altimor shot 2
    self:AddTrackedDebuff(335116, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- altimor shot 3

    self:AddTrackedDebuff(339251, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- kael drained
    self:AddTrackedDebuff(341473, 1, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- kael bleed

    self:AddTrackedDebuff(329298, 0, 1, 1.0, 0.5, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- blue giant zero heal

    self:AddTrackedDebuff(324983, 0, 1, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- inerva 1 minute damage
    self:AddTrackedDebuff(324982, 0, 1, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- inerva 1 minute damage
    self:AddTrackedDebuff(325004, 0, 1, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- inerva 1 minute damage
    self:AddTrackedDebuff(325936, 0, 2, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- inerva 10 seconds damage
    self:AddTrackedDebuff(325908, 0, 2, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- inerva 10 seconds damage

    self:AddTrackedDebuff(346651, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- dance drain
    self:AddTrackedDebuff(346654, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- dance drain

    self:AddTrackedDebuff(334765, 0, 1, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, ERALIBTalent_Nathria) -- generals small dot
    self:AddTrackedDebuff(334771, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria) -- generals big dot

    --self:AddTrackedDebuff(spellID, 0, 1, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, ERALIBTalent_Nathria)
end
