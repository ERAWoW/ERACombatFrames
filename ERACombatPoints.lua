-- TODO
-- tout

ERACombatPoints_PointSize = 22

------------------------------------------------------------------------------------------------------------------------
---- POINTS ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatPoints = {}
ERACombatPoints.__index = ERACombatPoints
setmetatable(ERACombatPoints, {__index = ERACombatModule})

function ERACombatPoints:ConstructPoints(cFrame, x, y, maxPoints, rB, gB, bB, rP, gP, bP, talent, ...)
    self:construct(cFrame, 0.2, 0.02, false, ...)
    self.frame = CreateFrame("Frame", nil, UIParent, nil)
    self.frame:SetPoint("TOP", UIParent, "CENTER", x, y)
    self.frame:SetSize(ERACombatPoints_PointSize * maxPoints, ERACombatPoints_PointSize)
    self.currentPoints = 0
    self.maxPoints = maxPoints
    self.talent = talent
    self.points = {}
    self.idlePoints = 0
    for i = 1, maxPoints do
        table.insert(self.points, ERACombatPoint:create(self, i, rB, gB, bB, rP, gP, bP))
    end
end

function ERACombatPoints:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatPoints:EnterCombat(fromIdle)
    if (self.talentActive) then
        self.frame:Show()
    end
end
function ERACombatPoints:EnterVehicle(fromCombat)
    self.frame:Hide()
end
function ERACombatPoints:ExitVehicle(toCombat)
    if (self.talentActive) then
        self.frame:Show()
    end
end
function ERACombatPoints:ResetToIdle()
    if (self.talentActive) then
        self.frame:Show()
    end
end
function ERACombatPoints:CheckTalents()
    if (self.talent and not self.talent:PlayerHasTalent()) then
        self.talentActive = false
        self.frame:Hide()
    else
        self.talentActive = true
    end
end

function ERACombatPoints:UpdateIdle(t)
    if (self.talentActive) then
        self:update(t)
        if (self.currentPoints == self.idlePoints) then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end
end
function ERACombatPoints:UpdateCombat(t)
    if (self.talentActive) then
        self:update(t)
    end
end
function ERACombatPoints:update(t)
    self.currentPoints = self:GetCurrentPoints()
    local upperBound
    if (self.currentPoints > self.maxPoints) then
        upperBound = self.maxPoints
    else
        upperBound = self.currentPoints
    end
    for i = 1, upperBound do
        self.points[i].point:Show()
    end
    for i = self.currentPoints + 1, self.maxPoints do
        self.points[i].point:Hide()
    end
    self:PointsUpdated(t)
end
function ERACombatPoints:PointsUpdated(t)
end
-- abstract function GetCurrentPoints(t)

ERACombatPoint = {}
ERACombatPoint.__index = ERACombatPoint

function ERACombatPoint:create(group, index, rB, gB, bB, rP, gP, bP)
    local p = {}
    setmetatable(p, ERACombatPoint)
    p.index = index
    p.frame = CreateFrame("Frame", nil, group.frame, "ERACombatPointFrame")
    p.frame:SetSize(ERACombatPoints_PointSize, ERACombatPoints_PointSize)
    p.frame:SetPoint("TOPLEFT", group.frame, "TOPLEFT", (index - 1) * ERACombatPoints_PointSize, 0)
    p.border = p.frame.Border
    p.border:SetVertexColor(rB, gB, bB)
    p.point = p.frame.Point
    p.point:SetVertexColor(rP, gP, bP)
    p.point:Hide()
    return p
end

------------------------------------------------------------------------------------------------------------------------
---- POINTS UNITPOWER --------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatPointsUnitPower = {}
ERACombatPointsUnitPower.__index = ERACombatPointsUnitPower
setmetatable(ERACombatPointsUnitPower, {__index = ERACombatPoints})

function ERACombatPointsUnitPower:Create(cFrame, x, y, powerType, maxPoints, rB, gB, bB, rP, gP, bP, talent, ...)
    local p = {}
    setmetatable(p, ERACombatPointsUnitPower)
    p:ConstructPoints(cFrame, x, y, maxPoints, rB, gB, bB, rP, gP, bP, talent, ...)
    p.powerType = powerType
    return p
end

function ERACombatPointsUnitPower:GetCurrentPoints(t)
    return UnitPower("player", self.powerType)
end
