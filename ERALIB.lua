function ERALIB_SetFont(fs, size)
    fs:SetFont("Fonts\\FRIZQT__.TTF", size, "THICKOUTLINE")
end

--------------------------------------------------------------------------------------------------------------------------------
-- TALENTS ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERALIBTalent_all_talents = {}

ERALIBTalent = {}
ERALIBTalent.__index = ERALIBTalent

function ERALIBTalent:Create(tier, column)
    return ERALIBTalentYes:create(tier, column)
end

function ERALIBTalent:CreateLevel(lvl)
    return ERALIBTalentLevel:create(lvl)
end

function ERALIBTalent:CreateKyrian()
    return ERALIBTalentCovenant:create(1)
end
function ERALIBTalent:CreateKyrianOrSpellKnown(spellID)
    return ERALIBTalentCovenantOrSpellKnown:create(1, spellID)
end
function ERALIBTalent:CreateVenthyr()
    return ERALIBTalentCovenant:create(2)
end
function ERALIBTalent:CreateVenthyrOrSpellKnown(spellID)
    return ERALIBTalentCovenantOrSpellKnown:create(2, spellID)
end
function ERALIBTalent:CreateNightfae()
    return ERALIBTalentCovenant:create(3)
end
function ERALIBTalent:CreateNightfaeOrSpellKnown(spellID)
    return ERALIBTalentCovenantOrSpellKnown:create(3, spellID)
end
function ERALIBTalent:CreateNecrolords()
    return ERALIBTalentCovenant:create(4)
end
function ERALIBTalent:CreateNecrolordsOrSpellKnown(spellID)
    return ERALIBTalentCovenantOrSpellKnown:create(4, spellID)
end

function ERALIBTalent:CreateInstance(iid)
    return ERALIBTalentInstance:create(iid)
end

function ERALIBTalent:CreateNotTalent(tier, column, lvl)
    return ERALIBTalentNotTalent:create(tier, column, lvl)
end

function ERALIBTalent:CreateNot(cdt)
    return ERALIBTalentNot:create(cdt)
end
function ERALIBTalent:CreateAnd(...)
    return ERALIBTalentAnd:create(...)
end
function ERALIBTalent:CreateOr(...)
    return ERALIBTalentOr:create(...)
end
function ERALIBTalent:CreateXOR(t1, t2)
    return ERALIBTalentXOR:create(t1, t2)
end
function ERALIBTalent:CreateNOR(t1, t2)
    return ERALIBTalentNOR:create(t1, t2)
end

function ERALIBTalent:PlayerHasTalent()
    return self.talentActive
end

function ERALIBTalent:construct()
    table.insert(ERALIBTalent_all_talents, self)
end

function ERALIBTalent:update()
    self.talentActive = self:computeHasTalent()
end
-- abstract function computeHasTalent()

ERALIBTalentLevel = {}
ERALIBTalentLevel.__index = ERALIBTalentLevel
setmetatable(ERALIBTalentLevel, {__index = ERALIBTalent})
function ERALIBTalentLevel:create(lvl)
    local t = {}
    setmetatable(t, ERALIBTalentLevel)
    t.lvl = lvl
    t:construct()
    return t
end
function ERALIBTalentLevel:computeHasTalent()
    return self.lvl <= UnitLevel("player")
end

ERALIBTalentCovenant = {}
ERALIBTalentCovenant.__index = ERALIBTalentCovenant
setmetatable(ERALIBTalentCovenant, {__index = ERALIBTalent})
function ERALIBTalentCovenant:create(cid)
    local t = {}
    setmetatable(t, ERALIBTalentCovenant)
    t.cid = cid
    t:construct()
    return t
end
function ERALIBTalentCovenant:computeHasTalent()
    return self.cid == C_Covenants.GetActiveCovenantID()
end

ERALIBTalentCovenantOrSpellKnown = {}
ERALIBTalentCovenantOrSpellKnown.__index = ERALIBTalentCovenantOrSpellKnown
setmetatable(ERALIBTalentCovenantOrSpellKnown, {__index = ERALIBTalent})
function ERALIBTalentCovenantOrSpellKnown:create(cid, spellID)
    local t = {}
    setmetatable(t, ERALIBTalentCovenantOrSpellKnown)
    t.cid = cid
    t.spellID = spellID
    t:construct()
    return t
end
function ERALIBTalentCovenantOrSpellKnown:computeHasTalent()
    local c = C_Covenants.GetActiveCovenantID()
    if (c and c > 0) then
        return c == self.cid
    else
        for s = 1, 72 do
            local type, id = GetActionInfo(s)
            if (type == "spell" and id == self.spellID) then
                return true
            end
        end
        return false
    end
end

ERALIBTalentInstance = {}
ERALIBTalentInstance.__index = ERALIBTalentInstance
setmetatable(ERALIBTalentInstance, {__index = ERALIBTalent})
function ERALIBTalentInstance:create(iid)
    local t = {}
    setmetatable(t, ERALIBTalentInstance)
    t.iid = iid
    t:construct()
    return t
end
function ERALIBTalentInstance:computeHasTalent()
    local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
    return instanceID == self.iid
end

ERALIBTalentYes = {}
ERALIBTalentYes.__index = ERALIBTalentYes
setmetatable(ERALIBTalentYes, {__index = ERALIBTalent})
function ERALIBTalentYes:create(tier, column)
    local t = {}
    setmetatable(t, ERALIBTalentYes)
    t.tier = tier
    t.column = column
    t:construct()
    return t
end
function ERALIBTalentYes:computeHasTalent()
    local _, _, _, selected = GetTalentInfo(self.tier, self.column, 1)
    return selected
end

ERALIBTalentNotTalent = {}
ERALIBTalentNotTalent.__index = ERALIBTalentNotTalent
setmetatable(ERALIBTalentNotTalent, {__index = ERALIBTalent})
function ERALIBTalentNotTalent:create(tier, column, lvl)
    local t = {}
    setmetatable(t, ERALIBTalentNotTalent)
    t.tier = tier
    t.column = column
    t.lvl = lvl
    t:construct()
    return t
end
function ERALIBTalentNotTalent:computeHasTalent()
    if (self.lvl and self.lvl > UnitLevel("player")) then
        return false
    end
    local _, _, _, selected = GetTalentInfo(self.tier, self.column, 1)
    return not selected
end

ERALIBTalentNot = {}
ERALIBTalentNot.__index = ERALIBTalentNot
setmetatable(ERALIBTalentNot, {__index = ERALIBTalent})
function ERALIBTalentNot:create(cdt)
    local t = {}
    setmetatable(t, ERALIBTalentNot)
    t.cdt = cdt
    t:construct()
    return t
end
function ERALIBTalentNot:computeHasTalent()
    return not self.cdt:computeHasTalent()
end

ERALIBTalentAnd = {}
ERALIBTalentAnd.__index = ERALIBTalentAnd
setmetatable(ERALIBTalentAnd, {__index = ERALIBTalent})
function ERALIBTalentAnd:create(...)
    local t = {}
    setmetatable(t, ERALIBTalentAnd)
    t.conditions = {...}
    t:construct()
    return t
end
function ERALIBTalentAnd:computeHasTalent()
    for i, t in ipairs(self.conditions) do
        if (not t:computeHasTalent()) then
            return false
        end
    end
    return true
end

ERALIBTalentOr = {}
ERALIBTalentOr.__index = ERALIBTalentOr
setmetatable(ERALIBTalentOr, {__index = ERALIBTalent})
function ERALIBTalentOr:create(...)
    local t = {}
    setmetatable(t, ERALIBTalentOr)
    t.conditions = {...}
    t:construct()
    return t
end
function ERALIBTalentOr:computeHasTalent()
    for i, t in ipairs(self.conditions) do
        if (t:computeHasTalent()) then
            return true
        end
    end
    return false
end

ERALIBTalentXOR = {}
ERALIBTalentXOR.__index = ERALIBTalentXOR
setmetatable(ERALIBTalentXOR, {__index = ERALIBTalent})
function ERALIBTalentXOR:create(t1, t2)
    local t = {}
    setmetatable(t, ERALIBTalentXOR)
    t.t1 = t1
    t.t2 = t2
    t:construct()
    return t
end
function ERALIBTalentXOR:computeHasTalent()
    local t1v = self.t1:computeHasTalent()
    local t2v = self.t2:computeHasTalent()
    return (t1v or t2v) and not (t1v and t2v)
end

ERALIBTalentNOR = {}
ERALIBTalentNOR.__index = ERALIBTalentNOR
setmetatable(ERALIBTalentNOR, {__index = ERALIBTalent})
function ERALIBTalentNOR:create(t1, t2)
    local t = {}
    setmetatable(t, ERALIBTalentNOR)
    t.t1 = t1
    t.t2 = t2
    t:construct()
    return t
end
function ERALIBTalentNOR:computeHasTalent()
    local t1v = self.t1:computeHasTalent()
    local t2v = self.t2:computeHasTalent()
    return not (t1v or t2v)
end

ERALIBTalent_Kyrian = ERALIBTalent:CreateKyrian()
ERALIBTalent_Venthyr = ERALIBTalent:CreateVenthyr()
ERALIBTalent_VenthyrOrGenericSpell = ERALIBTalent:CreateVenthyrOrSpellKnown(300728)
ERALIBTalent_Nightfae = ERALIBTalent:CreateNightfae()
ERALIBTalent_NightfaeOrGenericSpell = ERALIBTalent:CreateNightfaeOrSpellKnown(310143)
ERALIBTalent_Necrolords = ERALIBTalent:CreateNecrolords()
ERALIBTalent_NecrolordsOrGenericSpell = ERALIBTalent:CreateNecrolordsOrSpellKnown(324631)
