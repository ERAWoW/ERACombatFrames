-- TODO
-- tout

--------------------------------------------------------------------------------------------------------------------------------
-- BAR VIEW --------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatStatusBar_PrevisionHalfThickness = 2

ERACombatStatusBar = {}
ERACombatStatusBar.__index = ERACombatStatusBar

function ERACombatStatusBar:create(parentFrame, x, y, barWidth, barHeight, r, g, b)
    local bar = {}
    setmetatable(bar, ERACombatStatusBar)
    bar.frame = CreateFrame("Frame", nil, parentFrame, "ERACombatStatusBarFrameXML")
    bar.frame:SetPoint("TOP", parentFrame, x, y)
    bar.frame:SetSize(barWidth, barHeight)
    bar.width = barWidth

    bar.mainBar = bar.frame.MAIN_BAR
    bar.minusBar = bar.frame.MINUS_BAR
    bar.plusBar = bar.frame.PLUS_BAR
    bar.forecastH = bar.frame.FORECAST_H
    bar.forecastV = bar.frame.FORECAST_V

    bar.frame.MAIN_BAR:ClearAllPoints()
    bar.frame.MASK_BARS_LEFT:ClearAllPoints()
    bar.frame.MASK_BARS_RIGHT:ClearAllPoints()
    bar.frame.MASK_MAIN_LEFT:ClearAllPoints()
    bar.frame.MASK_MAIN_RIGHT:ClearAllPoints()

    bar.borderThickness = barHeight / 8
    local sideWidth = barHeight / 2
    bar.frame.MASK_BG_LEFT:SetWidth(sideWidth)
    bar.frame.MASK_BG_RIGHT:SetWidth(sideWidth)
    bar.frame.BORDER_LEFT:SetWidth(sideWidth)
    bar.frame.BORDER_RIGHT:SetWidth(sideWidth)
    bar.frame.BORDER_TOP:SetSize(barWidth - 2 * sideWidth, bar.borderThickness)
    bar.frame.BORDER_BOTTOM:SetSize(barWidth - 2 * sideWidth, bar.borderThickness)
    local barSideWidth = (barHeight - 2 * bar.borderThickness) / 2
    bar:maskBar(bar.frame.MASK_BARS_LEFT, bar.frame.MASK_BARS_RIGHT, barSideWidth)
    bar:maskBar(bar.frame.MASK_MAIN_LEFT, bar.frame.MASK_MAIN_RIGHT, barSideWidth)
    bar.frame.MASK_MAIN_MIDDLE:SetPoint("TOPLEFT", bar.frame, "TOPLEFT", barSideWidth, -bar.borderThickness)
    bar.frame.MASK_MAIN_MIDDLE:SetPoint("BOTTOMLEFT", bar.frame, "BOTTOMLEFT", barSideWidth, bar.borderThickness)
    bar.frame.MASK_MAIN_MIDDLE:SetPoint("TOPRIGHT", bar.frame, "TOPRIGHT", -barSideWidth, -bar.borderThickness)
    bar.frame.MASK_MAIN_MIDDLE:SetPoint("BOTTOMRIGHT", bar.frame, "BOTTOMRIGHT", -barSideWidth, bar.borderThickness)
    bar.frame.MAIN_BAR:SetPoint("TOPLEFT", bar.frame, "TOPLEFT", bar.borderThickness, -bar.borderThickness)
    bar.frame.MAIN_BAR:SetPoint("BOTTOMLEFT", bar.frame, "BOTTOMLEFT", bar.borderThickness, bar.borderThickness)

    bar.r = r
    bar.g = g
    bar.b = b
    bar.mainBar:SetVertexColor(r, g, b, 1)
    bar.rM1 = 1
    bar.gM1 = 0
    bar.bM1 = 0
    bar.rP2 = 0
    bar.gP2 = 0
    bar.bP2 = 1
    bar.rB = 1
    bar.gB = 1
    bar.bB = 1
    bar:SetBorderColor(0.9, 0.9, 0.9)
    bar.rF = 0.5
    bar.gF = 0.5
    bar.bF = 1.0

    bar.max = 1
    bar.value = 0
    bar.minus = 0
    bar.plus = 0
    bar.forecast = 0

    bar.mainBar:Hide()
    bar.mainVisible = false
    bar.minusBar:Hide()
    bar.minusVisible = false
    bar.plusBar:Hide()
    bar.plusVisible = false
    bar.forecastH:Hide()
    bar.forecastV:Hide()
    bar.forecastVVisible = false
    bar.forecastHVisible = false

    return bar
end
function ERACombatStatusBar:maskBar(left, right, barSideWidth)
    left:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.borderThickness, -self.borderThickness)
    left:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", self.borderThickness, self.borderThickness)
    left:SetWidth(barSideWidth)
    right:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -self.borderThickness, -self.borderThickness)
    right:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -self.borderThickness, self.borderThickness)
    right:SetWidth(barSideWidth)
end

function ERACombatStatusBar:SetBorderColor(r, g, b)
    if (self.rB ~= r or self.gB ~= g or self.bB ~= b) then
        self.rB = r
        self.gB = g
        self.bB = b
        self.frame.BORDER_LEFT:SetVertexColor(r, g, b, 1)
        self.frame.BORDER_TOP:SetVertexColor(r, g, b, 1)
        self.frame.BORDER_RIGHT:SetVertexColor(r, g, b, 1)
        self.frame.BORDER_BOTTOM:SetVertexColor(r, g, b, 1)
    end
end

function ERACombatStatusBar:SetMainColor(r, g, b)
    if (self.r ~= r or self.g ~= g or self.b ~= b) then
        self.r = r
        self.g = g
        self.b = b
        self.mainBar:SetVertexColor(r, g, b, 1)
    end
end

function ERACombatStatusBar:SetPrevisionColor(r, g, b)
    if (self.rF ~= r or self.gF ~= g or self.bF ~= b) then
        self.rF = r
        self.gF = g
        self.bF = b
        self.forecastH:SetColorTexture(r, g, b, 1)
        self.forecastV:SetColorTexture(r, g, b, 1)
    end
end

function ERACombatStatusBar:SetMax(x)
    if (self.max ~= x) then
        if (x <= 0) then
            self.max = 1
        else
            self.max = x
        end
        self:update()
    end
end
function ERACombatStatusBar:SetValue(x)
    if (self.value ~= x) then
        self.value = math.max(0, x)
        self:update()
    end
end
function ERACombatStatusBar:SetMinus(x)
    if (self.minus ~= x) then
        self.minus = x
        self:update()
    end
end
function ERACombatStatusBar:SetPlus(x)
    if (self.plus ~= x) then
        self.plus = x
        self:update()
    end
end
function ERACombatStatusBar:SetForecast(x)
    if (self.forecast ~= x) then
        self.forecast = x
        self:update()
    end
end
function ERACombatStatusBar:SetAll(max, value, minus, plus, forecast)
    if (self.max ~= max or self.value ~= value or self.minus ~= minus or self.plus ~= plus or self.forecast ~= forecast) then
        self.max = max
        self.value = value
        self.minus = minus
        self.plus = plus
        self.forecast = forecast
        self:update()
    end
end

function ERACombatStatusBar:update()
    local w = self.width - 2 * self.borderThickness
    local ratio = w / self.max
    local xCurrent = math.min(w, ratio * self.value)
    local mainWidth
    if (self.minus > 0) then
        local valWidth
        if (self.minus >= self.value) then
            valWidth = 0
        else
            valWidth = (self.value - self.minus) * ratio
        end
        self.minusBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", valWidth + self.borderThickness, -self.borderThickness)
        self.minusBar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", valWidth + self.borderThickness, self.borderThickness)
        self.minusBar:SetPoint("TOPRIGHT", self.frame, "TOPLEFT", xCurrent + self.borderThickness, -self.borderThickness)
        self.minusBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMLEFT", xCurrent + self.borderThickness, self.borderThickness)
        if (not self.minusVisible) then
            self.minusVisible = true
            self.minusBar:Show()
        end
        mainWidth = valWidth
    else
        mainWidth = xCurrent
        if (self.minusVisible) then
            self.minusVisible = false
            self.minusBar:Hide()
        end
    end
    if (mainWidth > 0) then
        if (not self.mainVisible) then
            self.mainVisible = true
            self.mainBar:Show()
        end
        self.mainBar:SetWidth(mainWidth)
    else
        if (self.mainVisible) then
            self.mainVisible = false
            self.mainBar:Hide()
        end
    end
    if (self.plus > 0) then
        local xPlus
        local total = self.value + self.plus
        if (total >= self.max) then
            xPlus = w
        else
            xPlus = total * ratio
        end
        self.plusBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", xCurrent + self.borderThickness, -self.borderThickness)
        self.plusBar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", xCurrent + self.borderThickness, self.borderThickness)
        self.plusBar:SetPoint("TOPRIGHT", self.frame, "TOPLEFT", xPlus + self.borderThickness, -self.borderThickness)
        self.plusBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMLEFT", xPlus + self.borderThickness, self.borderThickness)
        if (not self.plusVisible) then
            self.plusVisible = true
            self.plusBar:Show()
        end
    else
        if (self.plusVisible) then
            self.plusVisible = false
            self.plusBar:Hide()
        end
    end
    if (self.forecast > 0) then
        local xFore
        local total = self.value + self.forecast
        if (total > self.max) then
            xFore = self.width - self.borderThickness
            if (self.forecastVVisible) then
                self.forecastVVisible = false
                self.forecastV:Hide()
            end
        else
            xFore = total * ratio + self.borderThickness
            local xV = xFore - ERACombatStatusBar_PrevisionHalfThickness
            self.forecastV:SetStartPoint("TOPLEFT", self.frame, xV, 0)
            self.forecastV:SetEndPoint("BOTTOMLEFT", self.frame, xV, 0)
            if (not self.forecastVVisible) then
                self.forecastVVisible = true
                self.forecastV:Show()
            end
        end
        self.forecastH:SetStartPoint("LEFT", self.frame, xCurrent + self.borderThickness, 0)
        self.forecastH:SetEndPoint("LEFT", self.frame, xFore, 0)
        if (not self.forecastHVisible) then
            self.forecastHVisible = true
            self.forecastH:Show()
        end
    else
        if (self.forecastHVisible) then
            self.forecastHVisible = false
            self.forecastVVisible = false
            self.forecastH:Hide()
            self.forecastV:Hide()
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------------
-- COMMON HEALTH ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

function ERAOutOfCombatStatusBars_setHealth(bar, max, current, absorbHeal, absorbDamage, prevision)
    local ratio = current / max
    bar:SetBorderColor(1 - ratio, ratio, 0)
    bar:SetAll(max, current, absorbHeal, absorbDamage, prevision)
end

--------------------------------------------------------------------------------------------------------------------------------
-- OUT OF COMBAT ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERAOutOfCombatStatusBars = {}
ERAOutOfCombatStatusBars.__index = ERAOutOfCombatStatusBars
setmetatable(ERAOutOfCombatStatusBars, {__index = ERACombatModule})

function ERAOutOfCombatStatusBars:Create(cFrame, x, y, barWidth, barHeight, powerType, hideFull, r, g, b, showPet, ...)
    local ooc = {}
    setmetatable(ooc, ERAOutOfCombatStatusBars)

    ooc.frame = CreateFrame("Frame", nil, UIParent, nil)
    ooc.frame:SetPoint("TOP", UIParent, "CENTER", x, y)
    ooc.frame:SetSize(barWidth, 3 * barHeight)

    ooc.health = ERACombatStatusBar:create(ooc.frame, 0, 0, barWidth, barHeight, 0.0, 1.0, 0.0)
    if (powerType >= 0) then
        ooc.power = ERACombatStatusBar:create(ooc.frame, 0, -barHeight, barWidth, barHeight, r, g, b)
        ooc.hideFull = hideFull
        ooc.powerType = powerType
        ooc.powerValue = -1
        ooc.last_power_change = -1
    else
        ooc.powerType = -1
    end
    if (showPet) then
        ooc.pet = ERACombatStatusBar:create(ooc.frame, 0, -2 * barHeight, barWidth, barHeight, 0.0, 0.7, 0.0)
    end

    -- évènements
    ooc.events = {}
    function ooc.events:UNIT_HEALTH(unitID)
        if (unitID == "player") then
            ooc:updateHealth()
        elseif (unitID == "pet") then
            ooc:updateHealthPet()
        end
    end
    function ooc.events:UNIT_MAXHEALTH(unitID)
        if (unitID == "player") then
            ooc:updateHealth()
        elseif (unitID == "pet") then
            ooc:updateHealthPet()
        end
    end
    if (powerType >= 0) then
        function ooc.events:UNIT_POWER_FREQUENT(unitID)
            if (unitID == "player") then
                ooc:updatePower(GetTime())
            end
        end
        function ooc.events:UNIT_MAXPOWER(unitID)
            if (unitID == "player") then
                ooc:updatePower(GetTime())
            end
        end
    end
    ooc.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            ooc.events[event](self, ...)
        end
    )

    ooc:construct(cFrame, 0.5, -1, false, ...)
    return ooc
end

function ERAOutOfCombatStatusBars:EnterIdle()
    self:enter()
end
function ERAOutOfCombatStatusBars:ExitIdle()
    self:exit()
end
function ERAOutOfCombatStatusBars:ResetToIdle()
    self:enter()
end
function ERAOutOfCombatStatusBars:SpecInactive(wasActive)
    if (wasActive) then
        self:exit()
    end
end

function ERAOutOfCombatStatusBars:enter()
    self.last_power_change = GetTime()
    self.frame:Show()
    for k, v in pairs(self.events) do
        self.frame:RegisterEvent(k)
    end
    self:updateHealth()
    self:updateHealthPet()
    if (self:updatePower_returnShow()) then
        self.power.frame:Show()
    end
end
function ERAOutOfCombatStatusBars:exit()
    self.frame:Hide()
    self.frame:UnregisterAllEvents()
end

function ERAOutOfCombatStatusBars:UpdateIdle(t) --, elapsed)
    self:updateHealth()
    self:updateHealthPet()
    self:updatePower(t)
end

function ERAOutOfCombatStatusBars:updateHealth()
    local v = UnitHealth("player")
    local m = UnitHealthMax("player")
    ERAOutOfCombatStatusBars_setHealth(self.health, m, v, 0, 0, 0)
    if (v >= m) then
        self.health.frame:Hide()
    else
        self.health.frame:Show()
    end
end
function ERAOutOfCombatStatusBars:updateHealthPet()
    if (self.pet) then
        if (UnitExists("pet")) then
            local v = UnitHealth("pet")
            local m = UnitHealthMax("pet")
            ERAOutOfCombatStatusBars_setHealth(self.pet, m, v, 0, 0, 0)
            if (v >= m) then
                self.pet.frame:Hide()
            else
                self.pet.frame:Show()
            end
        else
            self.pet.frame:Hide()
        end
    end
end
function ERAOutOfCombatStatusBars:updatePower(t)
    local prvPower = self.powerValue
    if (self:updatePower_returnShow()) then
        if (self.powerValue == prvPower) then
            if (self.last_power_change + 10 < t) then
                self.power.frame:Hide()
            else
                self.power.frame:Show()
            end
        else
            self.last_power_change = t
            self.power.frame:Show()
        end
    end
end
function ERAOutOfCombatStatusBars:updatePower_returnShow()
    if (self.powerType >= 0) then
        local v = UnitPower("player", self.powerType)
        local m = UnitPowerMax("player", self.powerType)
        self.power:SetAll(m, v, 0, 0, 0)
        self.powerValue = v
        if (self.hideFull) then
            if (v >= m) then
                self.power.frame:Hide()
                return false
            else
                return true
            end
        else
            if (v > 0) then
                return true
            else
                self.power.frame:Hide()
                return false
            end
        end
    else
        return false
    end
end

--------------------------------------------------------------------------------------------------------------------------------
-- COMBAT HEALTH ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatHealth = {}
ERACombatHealth.__index = ERACombatHealth
setmetatable(ERACombatHealth, {__index = ERACombatModule})

function ERACombatHealth:Create(cFrame, x, y, barWidth, barHeight, ...)
    local b = {}
    setmetatable(b, ERACombatHealth)

    b.frame = CreateFrame("Frame", nil, UIParent, nil)
    b.frame:SetPoint("TOP", UIParent, "CENTER", x, y)
    b.frame:SetSize(barWidth, barHeight)

    b.bar = ERACombatStatusBar:create(b.frame, 0, 0, barWidth, barHeight, 0.0, 1.0, 0.0)

    b.currentHealth = 0
    b.maxHealth = 1
    b.absorbHealing = 0
    b.absorbDamage = 0
    b.healing = 0

    b.unitID = "player"
    b.checkUnitExists = false
    b.exists = true

    -- évènements
    b.events = {}
    function b.events:UNIT_HEALTH(unitID)
        if (unitID == b.unitID) then
            b.currentHealth = UnitHealth(b.unitID)
            b:update()
        end
    end
    function b.events:UNIT_MAXHEALTH(unitID)
        if (unitID == b.unitID) then
            b.maxHealth = UnitHealthMax(b.unitID)
            b:update()
        end
    end
    function b.events:UNIT_ABSORB_AMOUNT_CHANGED(unitID)
        if (unitID == b.unitID) then
            b.absorbDamage = UnitGetTotalAbsorbs(b.unitID)
            b:update()
        end
    end
    function b.events:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unitID)
        if (unitID == b.unitID) then
            b.absorbHealing = UnitGetTotalHealAbsorbs(b.unitID)
            b:update()
        end
    end
    b.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            b.events[event](self, ...)
        end
    )

    b:construct(cFrame, -1, 0.05, false, ...)
    return b
end

function ERACombatHealth:SetUnitID(unitID)
    self.unitID = unitID
    self.checkUnitExists = true
end

function ERACombatHealth:EnterCombat()
    self:enter()
end
function ERACombatHealth:ExitCombat()
    self:exit()
end
function ERACombatHealth:ResetToIdle()
    self:exit()
end
function ERACombatHealth:SpecInactive(wasActive)
    if (wasActive) then
        self:exit()
    end
end
function ERACombatHealth:enter()
    self.exists = true
    self.frame:Show()
    for k, v in pairs(self.events) do
        self.frame:RegisterEvent(k)
    end
    self.currentHealth = UnitHealth(self.unitID)
    self.maxHealth = UnitHealthMax(self.unitID)
    self.absorbDamage = UnitGetTotalAbsorbs(self.unitID)
    self.absorbHealing = UnitGetTotalHealAbsorbs(self.unitID)
    self:update()
end
function ERACombatHealth:exit()
    self.frame:Hide()
    self.frame:UnregisterAllEvents()
end

function ERACombatHealth:update()
    ERAOutOfCombatStatusBars_setHealth(self.bar, self.maxHealth, self.currentHealth, self.absorbHealing, self.absorbDamage, self.healing)
end

function ERACombatHealth:UpdateCombat(t) --, elapsed)
    if ((not self.checkUnitExists) or UnitExists(self.unitID)) then
        self.currentHealth = UnitHealth(self.unitID)
        self.maxHealth = UnitHealthMax(self.unitID)
        self.absorbHealing = UnitGetTotalHealAbsorbs(self.unitID)
        self.absorbDamage = UnitGetTotalAbsorbs(self.unitID)
        self:update()
        if (not self.exists) then
            self.exists = true
            self.frame:Show()
        end
    else
        if (self.exists) then
            self.exists = false
            self.frame:Hide()
        end
    end
end

function ERACombatHealth:SetHealing(value)
    self.healing = value
end

--------------------------------------------------------------------------------------------------------------------------------
-- COMBAT POWER ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatPower_IconSize = 22
ERACombatPower_TickSpill = 3

ERACombatPower = {}
ERACombatPower.__index = ERACombatPower
setmetatable(ERACombatPower, {__index = ERACombatModule})

function ERACombatPower:Create(cFrame, x, y, barWidth, barHeight, powerType, useEvents, r, g, b, ...)
    local bar = {}
    setmetatable(bar, ERACombatPower)

    bar.frame = CreateFrame("Frame", nil, UIParent, nil)
    bar.frame:SetPoint("TOP", UIParent, "CENTER", x, y)
    bar.frame:SetSize(barWidth, barHeight + 2 * ERACombatPower_TickSpill + ERACombatPower_IconSize)
    bar.barWidth = barWidth
    bar.tickHeight = barHeight + 1.5 * ERACombatPower_TickSpill
    bar.r = r
    bar.g = g
    bar.b = b
    bar.orangeWarning = -1
    bar.redWarning = -1
    bar.bar = ERACombatStatusBar:create(bar.frame, 0, -ERACombatPower_TickSpill, barWidth, barHeight, r, g, b)
    bar.bar.frame:SetFrameLevel(0)
    bar.visible = true
    bar.overlay = CreateFrame("Frame", nil, bar.frame)
    bar.overlay:SetFrameLevel(2)
    bar.overlay:SetAllPoints()

    -- évènements
    bar.events = {}
    if (useEvents) then
        function bar.events:UNIT_POWER_FREQUENT(unitID)
            if (unitID == "player") then
                bar:updateCurrentPower(true)
            end
        end
        function bar.events:UNIT_MAXPOWER(unitID)
            if (unitID == "player") then
                bar:updateMaxPower(true)
            end
        end
        bar.frame:SetScript(
            "OnEvent",
            function(self, event, ...)
                bar.events[event](self, ...)
            end
        )
    end

    bar.consumers = {}
    bar.activeConsumers = {}

    bar:construct(cFrame, -1, 0.05, false, ...)

    bar.currentPower = 0
    bar.maxPower = 1

    return bar
end

function ERACombatPower:EnterCombat()
    self:enter()
end
function ERACombatPower:ExitCombat()
    self:exit()
end
function ERACombatPower:ResetToIdle()
    self:exit()
end
function ERACombatPower:SpecInactive(wasActive)
    if (wasActive) then
        self:exit()
    end
end
function ERACombatPower:enter()
    for k, v in pairs(self.events) do
        self.frame:RegisterEvent(k)
    end
    self:updateMaxPower(false)
    self:updateCurrentPower(false)
    self.bar:SetAll(self.maxPower, self.currentPower, 0, 0, 0)
end
function ERACombatPower:exit()
    self.frame:Hide()
    self.frame:UnregisterAllEvents()
    self.visible = false
end

function ERACombatPower:PreUpdateCombat(t)
end
function ERACombatPower:UpdateCombat(t) --, elapsed)
    self:PreUpdateCombat(t)
    self:updateMaxPower(false)
    self:updateCurrentPower(false)
    if (self:ShouldBeVisible(t)) then
        self.bar:SetAll(self.maxPower, self.currentPower, 0, 0, 0)
        if (not self.visible) then
            self.visible = true
            self.frame:Show()
        end
    else
        if (self.visible) then
            self.visible = false
            self.frame:Hide()
        end
    end
end
function ERACombatPower:ShouldBeVisible(t)
    return true
end

function ERACombatPower:updateMaxPower(updateDisplay)
    local mp = UnitPowerMax("player")
    if (self.maxPower ~= mp) then
        self.maxPower = mp
        if (updateDisplay) then
            self.bar:SetMax(mp)
        end
        for i, c in ipairs(self.activeConsumers) do
            c:updatePosition()
        end
    end
end

function ERACombatPower:updateCurrentPower(updateDisplay)
    self.currentPower = UnitPower("player")
    if (updateDisplay) then
        self.bar:SetValue(self.currentPower)
    end
    for i, c in ipairs(self.activeConsumers) do
        c:updateCurrentPower()
    end
    if (self.redWarning > 0 and self.currentPower >= self.redWarning) then
        self.bar:SetMainColor(1.0, 0.2, 0.2)
    elseif (self.orangeWarning > 0 and self.currentPower >= self.orangeWarning) then
        self.bar:SetMainColor(0.8, 0.7, 0.1)
    else
        self.bar:SetMainColor(self.r, self.g, self.b)
    end
end

function ERACombatPower:CheckTalents()
    self.activeConsumers = {}
    for i, c in ipairs(self.consumers) do
        if (c:checkTalents()) then
            table.insert(self.activeConsumers, c)
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------------
-- CONSUMERS -------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

function ERACombatPower:AddConsumer(value, iconID, talent)
    return ERACombatPowerConsumer:create(self, value, iconID, talent)
end

ERACombatPowerConsumer = {}
ERACombatPowerConsumer.__index = ERACombatPowerConsumer

function ERACombatPowerConsumer:create(bar, value, iconID, talent)
    local c = {}
    setmetatable(c, ERACombatPowerConsumer)
    c.bar = bar
    c.value = value
    c.talent = talent
    c.tick = bar.overlay:CreateLine(nil, "OVERLAY", "ERACombatPowerTick")
    c.tickVisible = true
    if (iconID) then
        c.icon = ERASquareIcon:Create(bar.overlay, "TOPLEFT", ERACombatPower_IconSize, iconID)
    end
    table.insert(bar.consumers, c)
    return c
end

function ERACombatPowerConsumer:checkTalents()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        if (self.icon) then
            self.icon:Hide()
        end
        self:updatePosition()
        self.tick:Hide()
        self.tickVisible = false
        self.iconVisible = false
        return false
    else
        self.tick:Show()
        self.tickVisible = true
        return true
    end
end

function ERACombatPowerConsumer:updatePosition()
    local x = self.bar.barWidth * self.value / self.bar.maxPower
    self.tick:SetStartPoint("TOPLEFT", self.bar.frame, x, 0)
    self.tick:SetEndPoint("TOPLEFT", self.bar.frame, x, -self.bar.tickHeight)
    if (self.icon) then
        self.icon:Draw(x, -self.bar.tickHeight - ERACombatPower_IconSize / 2, false)
        self.iconVisible = false
        self.icon:Hide()
    end
end

function ERACombatPowerConsumer:updateCurrentPower()
    if (self:ComputeVisibility()) then
        if (not self.tickVisible) then
            self.tickVisible = true
            self.tick:Show()
        end
        if (self.bar.currentPower >= self.value) then
            if (not self.available) then
                self.available = true
                self.tick:SetVertexColor(0.0, 1.0, 0.0)
            end
        else
            if (self.available) then
                self.available = false
                self.tick:SetVertexColor(1.0, 1.0, 1.0)
            end
        end
        if (self.icon) then
            self.iconVisible = self:ComputeIconVisibility()
            if (self.iconVisible) then
                self.icon:Show()
            else
                self.icon:Hide()
            end
        end
    else
        if (self.tickVisible) then
            self.tickVisible = false
            self.tick:Hide()
            self.iconVisible = false
            self.icon:Hide()
        end
    end
end
function ERACombatPowerConsumer:ComputeVisibility()
    return true
end
function ERACombatPowerConsumer:ComputeIconVisibility()
    return false
end
