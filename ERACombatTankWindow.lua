-- TODO
-- rien

ERACombatTankWindow_Points = 64
ERACombatTankWindow_DECount = 256
ERACombatTankWindow_YScale = 0.5

--------------------------------------------------------------------------------------------------------------------------------
-- DAMAGE WINDOW ---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatTankWindow = {}
ERACombatTankWindow.__index = ERACombatTankWindow
setmetatable(ERACombatTankWindow, {__index = ERACombatModuleNestedInTimers})

function ERACombatTankWindow:Create(timers, height, spec, windowDuration, x, y, initWidth, isModuleActive)
    local w = {}
    setmetatable(w, ERACombatTankWindow)

    w.isModuleActive = isModuleActive
    w.frame = CreateFrame("Frame", nil, timers.frame, "ERACombatTankWindowFrame")
    w:constructNested(timers, 0, 0, "BOTTOMRIGHT", true, spec)
    if (isModuleActive) then
        w.frame:SetSize(initWidth, height)
    else
        w.frame:Hide()
    end
    w.height = height
    w.width = initWidth
    w.windowDuration = windowDuration
    w.offsetX = x
    w.offsetY = y

    w.brText = w.frame.BRText
    ERALIB_SetFont(w.brText, 50)

    w.chart = w.frame.Chart

    -- points
    w.points = {}
    for i = 1, ERACombatTankWindow_Points do
        table.insert(w.points, ERACombatTankWindowPoint:create(w, i))
    end

    -- dégâts
    w.playerGUID = UnitGUID("player")
    w.link = ERACombatTankWindowDamageEvent:create(nil, w)
    local current = w.link
    for i = 2, ERACombatTankWindow_DECount do
        current = ERACombatTankWindowDamageEvent:create(current, w)
    end
    w.link.nxt = current
    w.first = nil
    w.last = nil
    w.currentDamage = 0

    return w
end

function ERACombatTankWindow:ExitCombat()
    self.currentDamage = 0
    if (self.first) then
        local nxtlast = self.last.nxt
        local current = self.first
        repeat
            current:hide()
            current = current.nxt
        until (current == nxtlast)
        self.first = nil
        self.last = nil
    end
end

function ERACombatTankWindow:ResetToIdle()
    self:ExitCombat()
end
function ERACombatTankWindow:SpecInactive(wasActive)
    if (wasActive) then
        self:ExitCombat()
    end
end

function ERACombatTankWindow:CLEU(t)
    local _, evt, _, _, _, _, _, destGUY, _, _, _, dmgIfSwing, _, _, dmgIfSpell, absIfSwing, _, _, _, absIfSpell = CombatLogGetCurrentEventInfo()
    if (destGUY == self.playerGUID) then
        local dmg
        if (evt == "SWING_DAMAGE") then
            if (absIfSwing) then
                dmg = dmgIfSwing + absIfSwing
            else
                dmg = dmgIfSwing
            end
        elseif (evt == "SPELL_DAMAGE" or evt == "SPELL_PERIODIC_DAMAGE" or evt == "RANGE_DAMAGE") then
            if (absIfSpell) then
                dmg = dmgIfSpell + absIfSpell
            else
                dmg = dmgIfSpell
            end
        else
            return
        end
        local chosenOne
        if (self.last) then
            if (self.last.nxt == self.first) then
                -- plus de place
                return
            else
                chosenOne = self.last.nxt
            end
        else
            self.first = self.link
            chosenOne = self.link
        end
        self.last = chosenOne
        chosenOne.t = t
        chosenOne.dmg = dmg
    end
end

function ERACombatTankWindow:updateAsNested_returnHeightForTimerOverlay(t)
    if (self.timers and self.isModuleActive) then
        local w = ERACombat_TimerWidth * (self.windowDuration / self.timers.timerStandardDuration)
        if (self.width ~= w) then
            self.width = w
            self.frame:SetSize(w, self.height)
        end
    end

    if (not self.first) then
        self:drawFlat(t)
        return 0
    end

    local tPast = t - self.windowDuration
    local delta = self.windowDuration / ERACombatTankWindow_Points

    for i, p in ipairs(self.points) do
        p:prepareUpdate(tPast + i * delta)
    end

    while (self.first.t <= tPast) do
        self.first:hide()
        if (self.first == self.last) then
            self.first = nil
            self.last = nil
            self:drawFlat(t)
            return 0
        else
            self.first = self.first.nxt
        end
    end

    local max = UnitHealthMax("player") * ERACombatTankWindow_YScale

    self.currentDamage = 0
    local current = self.first
    local nxtlast = self.last.nxt
    repeat
        if (self.isModuleActive) then
            for i, p in ipairs(self.points) do
                p:add(current)
            end
            current:draw(max, tPast)
        end
        self.currentDamage = self.currentDamage + current.dmg
        current = current.nxt
    until (current == nxtlast)

    if (self.isModuleActive) then
        local prv = 0
        for i, p in ipairs(self.points) do
            p:draw(max, prv, i)
            prv = p.y
        end
    end

    self:Updated(t)

    return 0
end
function ERACombatTankWindow:Updated(t)
end

function ERACombatTankWindow:drawFlat(t)
    self.currentDamage = 0
    if (self.isModuleActive) then
        for i, p in ipairs(self.points) do
            p.dmg = 0
            p:draw(1, 1, i)
        end
    end
    self:Updated(t)
end

--------------------------------------------------------------------------------------------------------------------------------
-- CURVE POINT -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatTankWindowPoint = {}
ERACombatTankWindowPoint.__index = ERACombatTankWindowPoint

function ERACombatTankWindowPoint:create(w, i)
    local p = {}
    setmetatable(p, ERACombatTankWindowPoint)
    p.dmg = 0
    p.w = w
    p.line = w.chart:CreateLine(nil, "OVERLAY", "ERACombatTankWindowCurveLine")
    return p
end

function ERACombatTankWindowPoint:prepareUpdate(tPoint)
    self.t = tPoint
    self.dmg = 0
end

function ERACombatTankWindowPoint:add(de)
    self.dmg = self.dmg + de.dmg / (1 + math.pow(4 * math.abs(de.t - self.t), 4))
end

function ERACombatTankWindowPoint:draw(max, prvY, i)
    if (self.dmg > 0) then
        if (self.dmg >= max) then
            self.y = self.w.height - 1
        else
            self.y = self.w.height * self.dmg / max
        end
    else
        self.y = 1
    end
    self.line:SetStartPoint("BOTTOMLEFT", self.w.chart, self.w.width * (1 - ((i - 1) / ERACombatTankWindow_Points)), prvY)
    self.line:SetEndPoint("BOTTOMLEFT", self.w.chart, self.w.width * (1 - (i / ERACombatTankWindow_Points)), self.y)
end

--------------------------------------------------------------------------------------------------------------------------------
-- DAMAGE EVENT ----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatTankWindowDamageEvent = {}
ERACombatTankWindowDamageEvent.__index = ERACombatTankWindowDamageEvent

function ERACombatTankWindowDamageEvent:create(nxt, w)
    local de = {}
    setmetatable(de, ERACombatTankWindowDamageEvent)
    de.nxt = nxt
    de.w = w
    de.t = 0
    de.dmg = 0
    de.line = w.chart:CreateLine(nil, "OVERLAY", "ERACombatTankWindowDELine")
    de.visible = true
    de:hide()
    return de
end

function ERACombatTankWindowDamageEvent:hide()
    if (self.visible) then
        self.visible = false
        self.line:Hide()
    end
end

function ERACombatTankWindowDamageEvent:draw(max, tPast)
    local x = self.w.width * (1 - (self.t - tPast) / self.w.windowDuration)
    self.line:SetStartPoint("BOTTOMLEFT", self.w.chart, x, 0)
    local y
    if (self.dmg > max) then
        y = self.w.height
    else
        y = self.w.height * (self.dmg / max)
    end
    self.line:SetEndPoint("BOTTOMLEFT", self.w.chart, x, y)
    if (not self.visible) then
        self.visible = true
        self.line:Show()
    end
end
