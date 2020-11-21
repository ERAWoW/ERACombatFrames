-- TODO
-- dispells à tester
-- adapter Backdrop à l'API shadowlands sur playerframe et sa dispellMark
-- test : if (true or self.numPlayers > 1) then (dans updateGroup)
-- talents

ERACombatGrid_AuraIconSize = 16
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

function ERACombatGrid:AddTrackedBuff(spellID, iconID, position)
    if (position) then
        self.maxBuffPosition = math.max(self.maxBuffPosition, position)
    else
        position = self.maxBuffPosition + 1
        self.maxBuffPosition = position
    end
    return self:addTrackedAura(spellID, iconID, self.trackedBuffs, self.trackedBuffsFetcher, false, position)
end
function ERACombatGrid:AddTrackedDebuff(spellID, iconID, position)
    if (position) then
        self.maxDebuffPosition = math.max(self.maxDebuffPosition, position)
    else
        position = self.maxDebuffPosition + 1
        self.maxDebuffPosition = position
    end
    return self:addTrackedAura(spellID, iconID, self.trackedDebuffs, self.trackedDebuffsFetcher, true, position)
end
function ERACombatGrid:addTrackedAura(spellID, iconID, array, fetcher, isDebuff, position)
    if (not iconID) then
        _, _, iconID = GetSpellInfo(spellID)
    end
    local x = ERACombatGridAuraDefinition:create(self, 1 + #array, spellID, iconID, isDebuff, position)
    table.insert(array, x)
    fetcher[spellID] = x
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

    g.maxBuffPosition = 0
    g.maxDebuffPosition = 0
    g.trackedBuffsFetcher = {}
    g.trackedBuffs = {}
    g.trackedDebuffsFetcher = {}
    g.trackedDebuffs = {}
    g.isSolo = true

    g:construct(cFrame, 0.3, 0.1, false, spec)
    return g
end

function ERACombatGrid:Pack()
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
    -- TODO
end

function ERACombatGrid:updateGroup()
    local thisself = self
    C_Timer.After(
        4,
        function()
            thisself.isSolo = GetNumGroupMembers() <= 1
        end
    )
    -- TODO affichage, le reste
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
    for i, x in ipairs(self.trackedBuffs) do
        x:prepareUpdate()
    end
    for i, x in ipairs(self.trackedDebuffs) do
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

    unitframe.buffs = {}
    for i, x in ipairs(gridframe.grid.trackedBuffs) do
        table.insert(unitframe.buffs, ERACombatGridAuraInstance:create(x, unitframe))
    end
    unitframe.debuffs = {}
    for i, x in ipairs(gridframe.grid.trackedDebuffs) do
        table.insert(unitframe.debuffs, ERACombatGridAuraInstance:create(x, unitframe))
    end
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
            end
            self:updateHealth()
        end
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

function ERACombatGridUnitPrototype:update(t)
    self:updateHealth()

    if (self.grid.isGridVisible) then
        if (UnitIsUnit("player", self.unit)) then
            if (UnitIsUnit("target", self.unit)) then
                self:setBorder(0.5, 1.0, 0.5)
            else
                self:setBorder(0.0, 0.6, 0.0)
            end
        else
            if (UnitIsUnit("target", self.unit)) then
                self:setBorder(1.0, 1.0, 1.0)
            else
                self:setBorder(0.3, 0.3, 0.3)
            end
        end
    end

    local dispellable = false
    for i = 1, 40 do
        local _, _, stacks, type, durAura, expirationTime, _, isStealable, _, spellID = UnitDebuff(self.unit, i)
        if (spellID) then
            local td = self.grid.trackedDebuffsFetcher[spellID]
            if (td ~= nil) then
                local auraRemDuration
                if (expirationTime and expirationTime > 0) then
                    auraRemDuration = expirationTime - t
                else
                    auraRemDuration = 4096
                end
                if (not (stacks and stacks > 0)) then
                    auraStacks = 1
                end
                self.debuffs[td.index]:auraFound(auraRemDuration, durAura, stacks)
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
            local tb = self.grid.trackedBuffsFetcher[spellID]
            if (tb ~= nil) then
                local auraRemDuration
                if (expirationTime and expirationTime > 0) then
                    auraRemDuration = expirationTime - t
                else
                    auraRemDuration = 4096
                end
                if (not (stacks and stacks > 0)) then
                    auraStacks = 1
                end
                self.buffs[tb.index]:auraFound(auraRemDuration, durAura, stacks)
            end
        else
            break
        end
    end

    for i, x in ipairs(self.buffs) do
        x:update()
    end
    for i, x in ipairs(self.debuffs) do
        x:update()
    end
end

function ERACombatGridUnitPrototype:GetAura(a)
    if (a.isDebuff) then
        return self.debuffs[a.index]
    else
        return self.buffs[a.index]
    end
end
--------------------------------------------------------------------------------------------------------------------------------
---- AURA DEFINITION -----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatGridAuraDefinition = {}
ERACombatGridAuraDefinition.__index = ERACombatGridAuraDefinition

function ERACombatGridAuraDefinition:create(g, index, spellID, iconID, isDebuff, position)
    local a = {}
    setmetatable(a, ERACombatGridAuraDefinition)
    a.grid = g
    a.index = index
    a.position = position
    a.isDebuff = isDebuff
    a.spellID = spellID
    a.iconID = iconID
    a.instances = {}
    return a
end

function ERACombatGridAuraDefinition:prepareUpdate()
    self.instances = {}
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
    if (unitframe.grid.isGridVisible) then
        a.icon = ERAPieIcon:Create(unitframe.mainFrame, "BOTTOMLEFT", ERACombatGrid_AuraIconSize, def.iconID)
        if (def.isDebuff) then
            a.icon:Draw(
                ERACombatGrid_MainFrameWidthIncludingBorder - ERACombatGrid_HealthOffsetFromMainFrame - (def.position - 0.5) * ERACombatGrid_AuraIconSize,
                ERACombatGrid_HealthOffsetFromMainFrame + 0.5 * ERACombatGrid_AuraIconSize,
                false
            )
        else
            a.icon:Draw(ERACombatGrid_HealthOffsetFromMainFrame + (def.position - 0.5) * ERACombatGrid_AuraIconSize, ERACombatGrid_HealthOffsetFromMainFrame + 0.5 * ERACombatGrid_AuraIconSize, false)
        end
        a.icon:SetOverlayAlpha(0.7)
        a.icon:Hide()
    end
    return a
end

function ERACombatGridAuraInstance:auraFound(auraRemDuration, durAura, stacks)
    self.found = true
    self.remDuration = auraRemDuration
    self.totDuration = durAura
    self.stacks = stacks
end

function ERACombatGridAuraInstance:update()
    if (self.found) then
        self.found = false
        table.insert(self.def.instances, self)
        if (self.icon) then
            self.icon:SetOverlayValue(1 - self.remDuration / self.totDuration)
            if (self.stacks > 1) then
                self.icon:SetMainText(self.stacks)
            else
                self.icon:SetMainText(nil)
            end
            self.icon:Show()
        end
    else
        self.remDuration = 0
        self.totDuration = 1
        self.stacks = 0
        if (self.icon) then
            self.icon:Hide()
        end
    end
end
