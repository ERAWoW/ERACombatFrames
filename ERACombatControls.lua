-- TODO
-- aura reverse overlay

--------------------------------------------------------------------------------------------------------------------------------
---- ICONS ---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERAIcon = {}
ERAIcon.__index = ERAIcon

function ERAIcon:constructIcon(parentFrame, relativePoint, size, iconID)
    -- affichage
    self.size = size
    self.frame:SetSize(size, size)
    self.mainText = self.frame.MainText
    ERALIB_SetFont(self.mainText, size * 0.4)
    self.secondaryText = self.frame.SecondaryText
    ERALIB_SetFont(self.secondaryText, size * 0.25)
    self.icon = self.frame.Icon
    self:SetIconTexture(iconID)

    -- position
    self.parentFrame = parentFrame
    self.relativePoint = relativePoint
    self.x = 0
    self.y = 0
    self.transAnim = self.frame.TranslationGroup
    self.translation = self.frame.TranslationGroup.Translation
    self.translation:SetScript(
        "OnFinished",
        function()
            self:endTranslate()
        end
    )

    -- beam
    self.beamAnim = self.frame.BeamGroup
    self.beam = self.frame.BeamGroup.Beam
    self.beaming = false

    -- colors
    self.desat = false
    self.alpha = 1
    self.r = 1
    self.g = 1
    self.b = 1
    self.mainTextR = 1.0
    self.mainTextG = 1.0
    self.mainTextB = 1.0
    self.mainTextA = 1.0

    -- statut
    self.visible = true
    self:Hide()
end

function ERAIcon:SetIconTexture(iconID, force)
    if (force) then
        self.iconID = iconID
        self.icon:SetTexture(136235)
        self.icon:SetTexture(iconID)
    else
        if (iconID and iconID ~= self.iconID) then
            self.iconID = iconID
            self.icon:SetTexture(self.iconID)
        end
    end
end

function ERAIcon:SetMainText(txt)
    self.mainText:SetText(txt)
end
function ERAIcon:SetMainTextColor(r, g, b, a)
    if (self.mainTextR ~= r or self.mainTextG ~= g or self.mainTextB ~= b or self.mainTextA ~= a) then
        self.mainTextR = r
        self.mainTextG = g
        self.mainTextB = b
        self.mainTextA = a
        self.mainText:SetTextColor(r, g, b, a)
    end
end
function ERAIcon:SetSecondaryText(txt)
    self.secondaryText:SetText(txt)
end
function ERAIcon:SetSecondaryTextColor(r, g, b, a)
    self.secondaryText:SetTextColor(r, g, b, a)
end

function ERAIcon:SetDesaturated(d)
    if (d) then
        if (not self.desat) then
            self.desat = true
            self.icon:SetDesaturated(true)
            self:additionalSetDesaturated(true)
        end
    else
        if (self.desat) then
            self.desat = false
            self.icon:SetDesaturated(false)
            self:additionalSetDesaturated(false)
        end
    end
end
function ERAIcon:additionalSetDesaturated(d)
end

function ERAIcon:SetAlpha(a)
    if (self.alpha ~= a) then
        self.alpha = a
        self.frame:SetAlpha(a)
    end
end

function ERAIcon:SetVertexColor(r, g, b, a)
    if (not a) then
        a = self.alpha
    end
    if (self.r ~= r or self.g ~= g or self.b ~= b or self.alpha ~= a) then
        self.r = r
        self.g = g
        self.b = b
        self.alpha = a
        self.icon:SetVertexColor(r, g, b, a)
    end
end

function ERAIcon:Hide()
    if (self.visible) then
        self.visible = false
        self.frame:Hide()
        if (self.beaming) then
            self.beamAnim:Stop()
        end
    end
end

function ERAIcon:Show()
    if (not self.visible) then
        self.visible = true
        self.frame:Show()
        if (self.beaming) then
            self.beamAnim:Play()
        end
    end
end

function ERAIcon:Draw(x, y, translateIfMoved)
    if (self.visible) then
        if (self.x ~= x or self.y ~= y) then
            if (translateIfMoved) then
                self.translation:SetOffset(x - self.x, y - self.y)
                self.transAnim:Play()
            else
                self.frame:SetPoint("CENTER", self.parentFrame, self.relativePoint, x, y)
            end
            self.x = x
            self.y = y
        end
    else
        self.visible = true
        self.frame:Show()
        self.x = x
        self.y = y
        self:endTranslate()
        if (self.beaming) then
            self.beamAnim:Play()
        end
    end
end

function ERAIcon:endTranslate()
    self.frame:SetPoint("CENTER", self.parentFrame, self.relativePoint, self.x, self.y)
end

function ERAIcon:Beam()
    if (not self.beaming) then
        self.beaming = true
        if (self.visible) then
            self.beamAnim:Play()
        end
    end
end
function ERAIcon:StopBeam()
    if (self.beaming) then
        self.beaming = false
        --if (self.visible) then
        self.beamAnim:Stop()
    --end
    end
end

--------------------------------------------------------------------------------------------------------------------------------
---- SQUARE ICONS --------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

ERASquareIcon = {}
ERASquareIcon.__index = ERASquareIcon
setmetatable(ERASquareIcon, {__index = ERAIcon})

function ERASquareIcon:Create(parentFrame, relativePoint, size, iconID)
    local i = {}
    setmetatable(i, ERASquareIcon)

    i.frame = CreateFrame("Frame", nil, parentFrame, "ERASquareIconFrame")
    i:constructIcon(parentFrame, relativePoint, size, iconID)

    return i
end

--------------------------------------------------------------------------------------------------------------------------------
---- PIE ICONS -----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

-- constantes
ERAPieIcon_DefaultOverlayAlpha = 0.88
ERAPieIcon_BorderR = 0.7
ERAPieIcon_BorderG = 0.0
ERAPieIcon_BorderB = 0.9

ERAPieIcon = {}
ERAPieIcon.__index = ERAPieIcon
setmetatable(ERAPieIcon, {__index = ERAIcon})

function ERAPieIcon:Create(parentFrame, relativePoint, size, iconID)
    local i = {}
    setmetatable(i, ERAPieIcon)

    i.frame = CreateFrame("Frame", nil, parentFrame, "ERAPieIconFrame")
    i:constructIcon(parentFrame, relativePoint, size, iconID)

    i.trt = i.frame.TRT
    i.trr = i.frame.TRR
    i.tlt = i.frame.TLT
    i.tlr = i.frame.TLR
    i.blr = i.frame.BLR
    i.blt = i.frame.BLT
    i.brt = i.frame.BRT
    i.brr = i.frame.BRR
    ERAPieControl_Init(i)

    i.border = i.frame.AROUND
    i.border:SetVertexColor(ERAPieIcon_BorderR, ERAPieIcon_BorderG, ERAPieIcon_BorderB, 1.0)

    return i
end

function ERAPieIcon:additionalSetDesaturated(d)
    if (d) then
        self.border:SetVertexColor(0.2, 0.2, 0.2, 1.0)
    else
        self.border:SetVertexColor(ERAPieIcon_BorderR, ERAPieIcon_BorderG, ERAPieIcon_BorderB, 1.0)
    end
end

function ERAPieIcon:SetOverlayAlpha(a)
    ERAPieControl_SetOverlayAlpha(self, a)
end

function ERAPieIcon:SetOverlayValue(value)
    ERAPieControl_SetOverlayValue(self, value)
end

function ERAPieControl_Init(x)
    x.rec = {}
    x.overlayAlpha = ERAPieIcon_DefaultOverlayAlpha
    table.insert(x.rec, x.tlr)
    table.insert(x.rec, x.trr)
    table.insert(x.rec, x.brr)
    table.insert(x.rec, x.blr)
    for _, r in ipairs(x.rec) do
        r:SetColorTexture(0, 0, 0, ERAPieIcon_DefaultOverlayAlpha)
        r:Hide()
    end
    x.tri = {}
    table.insert(x.tri, x.tlt)
    table.insert(x.tri, x.trt)
    table.insert(x.tri, x.brt)
    table.insert(x.tri, x.blt)
    for _, t in ipairs(x.tri) do
        t:SetVertexColor(0, 0, 0, ERAPieIcon_DefaultOverlayAlpha)
        t:Hide()
    end
    x.oClear = true
    x.quadrant = 0
end

function ERAPieControl_SetOverlayAlpha(x, a)
    if (x.overlayAlpha ~= a) then
        x.overlayAlpha = a
        for i, r in ipairs(x.rec) do
            r:SetColorTexture(0, 0, 0, a)
        end
        for i, t in ipairs(x.tri) do
            t:SetVertexColor(0, 0, 0, a)
        end
    end
end

function ERAPieControl_calcPosition(p, halfSize, straight)
    if (straight) then
        return halfSize * math.tan(2 * p * 3.1416)
    else
        return halfSize * (1 - math.tan((1 - 8 * p) * 3.1416 / 4))
    end
end
function ERAPieControl_SetOverlayValue(x, value)
    local halfSize = x.size / 2
    if ((not value) or value <= 0) then
        if (not x.oClear) then
            x.oClear = true
            x.quadrant = 0
            for i, t in ipairs(x.tri) do
                t:Hide()
            end
            for i, r in ipairs(x.rec) do
                r:Hide()
            end
        end
    elseif (value >= 1) then
        x.oClear = false
        x.quadrant = 0
        for i, t in ipairs(x.tri) do
            t:Hide()
        end
        for i, r in ipairs(x.rec) do
            r:Show()
        end
        x.trr:SetWidth(halfSize)
        x.brr:SetHeight(halfSize)
        x.blr:SetWidth(halfSize)
        x.tlr:SetHeight(halfSize)
    else
        x.oClear = false
        if (value <= 0.125) then
            if (x.quadrant ~= 1) then
                x.quadrant = 1
                x.trr:Hide()
                x.brr:Hide()
                x.blr:Hide()
                x.tlr:Hide()
                x.trt:Hide()
                x.brt:Hide()
                x.blt:Hide()
                x.tlt:Show()
            end
            x.tlt:SetPoint("TOPLEFT", x.frame, "TOP", -ERAPieControl_calcPosition(value, halfSize, true), 0)
        elseif (value <= 0.25) then
            if (x.quadrant ~= 2) then
                x.quadrant = 2
                x.trr:Hide()
                x.brr:Hide()
                x.blr:Hide()
                x.tlr:Show()
                x.trt:Hide()
                x.brt:Hide()
                x.blt:Hide()
                x.tlt:Show()
            end
            local h = ERAPieControl_calcPosition(value - 0.125, halfSize, false)
            x.tlt:SetPoint("TOPLEFT", x.frame, "TOPLEFT", 0, -h)
            x.tlr:SetHeight(h)
        elseif (value <= 0.375) then
            if (x.quadrant ~= 3) then
                x.quadrant = 3
                x.trr:Hide()
                x.brr:Hide()
                x.blr:Hide()
                x.tlr:Show()
                x.trt:Hide()
                x.brt:Hide()
                x.blt:Show()
                x.tlt:Hide()
            end
            x.tlr:SetHeight(halfSize)
            x.blt:SetPoint("BOTTOMLEFT", x.frame, "LEFT", 0, -ERAPieControl_calcPosition(value - 0.25, halfSize, true))
        elseif (value <= 0.5) then
            if (x.quadrant ~= 4) then
                x.quadrant = 4
                x.trr:Hide()
                x.brr:Hide()
                x.blr:Show()
                x.tlr:Show()
                x.trt:Hide()
                x.brt:Hide()
                x.blt:Show()
                x.tlt:Hide()
            end
            x.tlr:SetHeight(halfSize)
            local w = ERAPieControl_calcPosition(value - 0.375, halfSize, false)
            x.blt:SetPoint("BOTTOMLEFT", x.frame, "BOTTOMLEFT", w, 0)
            x.blr:SetWidth(w)
        elseif (value <= 0.625) then
            if (x.quadrant ~= 5) then
                x.quadrant = 5
                x.trr:Hide()
                x.brr:Hide()
                x.blr:Show()
                x.tlr:Show()
                x.trt:Hide()
                x.brt:Show()
                x.blt:Hide()
                x.tlt:Hide()
            end
            x.tlr:SetHeight(halfSize)
            x.blr:SetWidth(halfSize)
            x.brt:SetPoint("BOTTOMRIGHT", x.frame, "BOTTOM", ERAPieControl_calcPosition(value - 0.5, halfSize, true), 0)
        elseif (value <= 0.75) then
            if (x.quadrant ~= 6) then
                x.quadrant = 6
                x.trr:Hide()
                x.brr:Show()
                x.blr:Show()
                x.tlr:Show()
                x.trt:Hide()
                x.brt:Show()
                x.blt:Hide()
                x.tlt:Hide()
            end
            x.tlr:SetHeight(halfSize)
            x.blr:SetWidth(halfSize)
            local h = ERAPieControl_calcPosition(value - 0.625, halfSize, false)
            x.brr:SetHeight(h)
            x.brt:SetPoint("BOTTOMRIGHT", x.frame, "BOTTOMRIGHT", 0, h)
        elseif (value <= 0.875) then
            if (x.quadrant ~= 7) then
                x.quadrant = 7
                x.trr:Hide()
                x.brr:Show()
                x.blr:Show()
                x.tlr:Show()
                x.trt:Show()
                x.brt:Hide()
                x.blt:Hide()
                x.tlt:Hide()
            end
            x.tlr:SetHeight(halfSize)
            x.blr:SetWidth(halfSize)
            x.brr:SetHeight(halfSize)
            x.trt:SetPoint("TOPRIGHT", x.frame, "RIGHT", 0, ERAPieControl_calcPosition(value - 0.75, halfSize, true))
        else
            if (x.quadrant ~= 8) then
                x.quadrant = 8
                x.trr:Show()
                x.brr:Show()
                x.blr:Show()
                x.tlr:Show()
                x.trt:Show()
                x.brt:Hide()
                x.blt:Hide()
                x.tlt:Hide()
            end
            x.tlr:SetHeight(halfSize)
            x.blr:SetWidth(halfSize)
            x.brr:SetHeight(halfSize)
            local w = ERAPieControl_calcPosition(value - 0.875, halfSize, false)
            x.trr:SetWidth(w)
            x.trt:SetPoint("TOPRIGHT", x.frame, "TOPRIGHT", -w, 0)
        end
    end
end
