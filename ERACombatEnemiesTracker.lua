ERACombatEnemiesTracker = {}
ERACombatEnemiesTracker.__index = ERACombatEnemiesTracker
setmetatable(ERACombatEnemiesTracker, {__index = ERACombatModule})

function ERACombatEnemiesTracker:GetEnemiesCount()
    return self.enemiesCount
end

function ERACombatEnemiesTracker:OnEnemyAdded(f)
    table.insert(self.onEnemyAdded, f)
end
function ERACombatEnemiesTracker:OnEnemyRemoved(f)
    table.insert(self.onEnemyRemoved, f)
end

function ERACombatEnemiesTracker:Create(cFrame, updateCombat, ...)
    local et = {}
    setmetatable(et, ERACombatEnemiesTracker)
    et.frame = CreateFrame("Frame", nil, cFrame.frame, nil)
    et:construct(cFrame, -1, updateCombat, true, ...)

    et.playerGUID = UnitGUID("player")

    et.unassigned_plates_from_GUID = {}
    et.unassigned_GUID_to_time = {}
    et.enemiesByGUID = {}
    et.enemiesByNameplate = {}
    et.enemiesCount = 0

    et.onEnemyAdded = {}
    et.onEnemyRemoved = {}

    -- évènements
    et.events = {}
    function et.events:NAME_PLATE_UNIT_ADDED(unitToken)
        local guid = UnitGUID(unitToken)
        local t = et.unassigned_GUID_to_time[guid]
        if (t ~= nil) then
            et.unassigned_plates_from_GUID[guid] = nil
            et:addEnemy(guid, unitToken, GetTime())
        else
            et.unassigned_plates_from_GUID[guid] = unitToken
        end
    end
    function et.events:NAME_PLATE_UNIT_REMOVED(unitToken)
        local enemy = et.enemiesByNameplate[unitToken]
        if (enemy) then
            et:removeEnemy(enemy, true)
        else
            et.unassigned_plates_from_GUID[unitToken] = nil
        end
    end
    et.frame:SetScript(
        "OnEvent",
        function(self, event, ...)
            et.events[event](self, ...)
        end
    )

    return et
end

function ERACombatEnemiesTracker:SpecInactive(wasActive)
    if (wasActive) then
        self:reset()
        self.frame:UnregisterAllEvents()
    end
end
function ERACombatEnemiesTracker:reset()
    self.unassigned_GUID_to_time = {}
    self.enemiesByGUID = {}
    self.enemiesByNameplate = {}
    self.enemiesCount = 0
end
function ERACombatEnemiesTracker:ExitCombat()
    for k, v in pairs(self.enemiesByNameplate) do
        self.unassigned_plates_from_GUID[v.guid] = k
    end
    self:reset()
end
function ERACombatEnemiesTracker:ResetToIdle()
    self:reset()
    for k, v in pairs(self.events) do
        self.frame:RegisterEvent(k)
    end
end

function ERACombatEnemiesTracker:CheckTalents()
    -- osef
end

function ERACombatEnemiesTracker:CLEU(t)
    local _, evt, _, sourceGUY, _, _, _, targetGUY, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if (evt == "SPELL_CAST_SUCCESS" or evt == "SPELL_DAMAGE" or evt == "SWING_DAMAGE" or evt == "RANGE_DAMAGE" or evt == "SWING_MISSED" or evt == "SPELL_MISSED") then
        if (sourceGUY == self.playerGUID) then
            self:analyzeTargetSourceIsPlayer(t, targetGUY)
        end
    elseif (evt == "UNIT_DIED" or evt == "UNIT_DESTROYED" or evt == "UNIT_DISSIPATES") then
        local tar = self.enemiesByGUID[targetGUY]
        if (tar) then
            self:removeEnemy(tar, false)
        end
    end
    if (self.AdditionalCLEU) then
        self.AdditionalCLEU(t, evt, sourceGUY, targetGUY, spellID)
    end
end
function ERACombatEnemiesTracker:analyzeTargetSourceIsPlayer(t, targetGUY)
    local enemy = self.enemiesByGUID[targetGUY]
    if (enemy == nil) then
        local plateID = self.unassigned_plates_from_GUID[targetGUY]
        if (plateID) then
            self.unassigned_plates_from_GUID[targetGUY] = nil
            return self:addEnemy(targetGUY, plateID, t)
        else
            self.unassigned_GUID_to_time[targetGUY] = t
            return nil
        end
    else
        return enemy
    end
end

function ERACombatEnemiesTracker:addEnemy(guid, plateID, t)
    local tar = ERACombatEnemy:create(self, plateID, guid, t)
    self.enemiesByGUID[guid] = tar
    self.enemiesByNameplate[plateID] = tar
    self.enemiesCount = self.enemiesCount + 1
    for _, f in ipairs(self.onEnemyAdded) do
        f(tar, t)
    end
    return tar
end

function ERACombatEnemiesTracker:removeEnemy(t, nameplateRemoved)
    self.enemiesByGUID[t.guid] = nil
    self.enemiesByNameplate[t.plateID] = nil
    self.enemiesCount = self.enemiesCount - 1
    for _, f in ipairs(self.onEnemyRemoved) do
        f(tar, t)
    end
end

function ERACombatEnemiesTracker:UpdateCombat(t)
    self:updateEnemiesTracker(t)
end
function ERACombatEnemiesTracker:updateEnemiesTracker(t)
    self.currentTarget = nil
    for _, v in pairs(self.enemiesByGUID) do
        v:update(t)
        if (UnitIsUnit(v.plateID, "target")) then
            self.currentTarget = v
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------------
-- ENEMIES ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERACombatEnemy = {}
ERACombatEnemy.__index = ERACombatEnemy

ERACombatEnemy_expectancy_last_x_seconds = 8

function ERACombatEnemy:create(tracker, plateID, guid, t)
    local dt = {}
    setmetatable(dt, ERACombatEnemy)
    dt.tracker = tracker
    --dt.unitName = UnitName(plateID)
    dt.plateID = plateID
    dt.guid = guid
    dt.discoveryTime = t
    dt.healthAtDiscovery = UnitHealth(plateID)
    dt.lifeExpectancy = 100
    dt.timeStampCount = 2
    dt.firstHealthTimeStamp = {}
    dt.firstHealthTimeStamp.t = t - 1
    dt.firstHealthTimeStamp.h = dt.healthAtDiscovery
    dt.lastHealthTimeStamp = {}
    dt.lastHealthTimeStamp.t = t
    dt.lastHealthTimeStamp.h = dt.healthAtDiscovery
    dt.firstHealthTimeStamp.nxt = dt.lastHealthTimeStamp
    return dt
end

function ERACombatEnemy:update(t)
    local health = UnitHealth(self.plateID)
    self.currentHealth = health
    local expectancyBasedOnDiscovery
    if (health >= self.healthAtDiscovery) then
        self.healthAtDiscovery = health
        expectancyBasedOnDiscovery = 100
    else
        expectancyBasedOnDiscovery = math.min(100, health * (t - self.discoveryTime) / (self.healthAtDiscovery - health))
    end
    if (self.timeStampCount < ERACombatEnemy_expectancy_last_x_seconds) then
        if (t >= self.lastHealthTimeStamp.t + 0.99) then
            self.timeStampCount = self.timeStampCount + 1
            local tmp = {}
            tmp.t = t
            tmp.h = health
            self.lastHealthTimeStamp.nxt = tmp
            self.lastHealthTimeStamp = tmp
        end
    else
        if (t >= self.firstHealthTimeStamp.t + ERACombatEnemy_expectancy_last_x_seconds) then
            local tmp = self.firstHealthTimeStamp
            self.firstHealthTimeStamp = tmp.nxt
            tmp.nxt = nil
            self.lastHealthTimeStamp.nxt = tmp
            self.lastHealthTimeStamp = tmp
            tmp.t = t
            tmp.h = health
        end
    end
    if (health >= self.firstHealthTimeStamp.h) then
        expectancyBasedOnRecent = 100
    else
        expectancyBasedOnRecent = math.min(100, health * (t - self.firstHealthTimeStamp.t) / (self.firstHealthTimeStamp.h - health))
    end

    local ratio = 0.2 + 0.8 * health / UnitHealthMax(self.plateID)
    self.lifeExpectancy = (1 - ratio) * expectancyBasedOnRecent + ratio * expectancyBasedOnDiscovery
end
