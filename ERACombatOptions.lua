SLASH_ECF1 = "/ECF"
SlashCmdList["ECF"] = function(msg)
    ERACombatOptionsFrame:Show()
end

BINDING_HEADER_ERACOMBATFRAMES = "ERACombatFrames"
BINDING_NAME_ERACOMBATFRAMES_RELOADUI = "Reload UI"
BINDING_NAME_ERACOMBATFRAMES_SPEC1 = "spec 1"
BINDING_NAME_ERACOMBATFRAMES_SPEC2 = "spec 2"
BINDING_NAME_ERACOMBATFRAMES_SPEC3 = "spec 3"
BINDING_NAME_ERACOMBATFRAMES_SPEC4 = "spec 4"

ERACombatOptions_FrameContentOffset = 32
ERACombatOptions_FrameContentWidth = 1004

ERACombatOptions_TankWindow = "damage chart"
ERACombatOptions_Grid = "group/raid frames"

function ERACombatOptions_addSpecOption(classID, specID, optionName)
    local class = ERACombatOptionsVariables[classID]
    if (not class) then
        class = {}
        ERACombatOptionsVariables[classID] = class
    end
    local spec = class[specID]
    if (not spec) then
        spec = {}
        class[specID] = spec
    end
    if (spec[optionName] == nil) then
        spec[optionName] = true
    end
end

function ERACombatOptions_initialize()
    if (not ERACombatOptionsVariables) then
        ERACombatOptionsVariables = {}
    end

    ERACombatOptions_addSpecOption(2, 1, ERACombatOptions_Grid) -- paladin holy
    ERACombatOptions_addSpecOption(5, 1, ERACombatOptions_Grid) -- priest disc
    ERACombatOptions_addSpecOption(5, 2, ERACombatOptions_Grid) -- priest holy
    ERACombatOptions_addSpecOption(6, 1, ERACombatOptions_TankWindow) -- dk blood
    ERACombatOptions_addSpecOption(10, 2, ERACombatOptions_Grid) -- monk heal
    ERACombatOptions_addSpecOption(11, 4, ERACombatOptions_Grid) -- druid heal
    ERACombatOptions_addSpecOption(12, 2, ERACombatOptions_TankWindow) -- dh vengeance

    local optionsContent = ERACombatOptionsFrame.ScrollFrame.ScrollChild
    local y = -16
    for c = 1, GetNumClasses() do
        local class = ERACombatOptionsVariables[c]
        if (not class) then
            class = {}
            ERACombatOptionsVariables[c] = class
        end
        local className = GetClassInfo(c)
        local scount = GetNumSpecializationsForClassID(c)
        local max_spec_height = 36
        local frames = {}
        local specWidth = ERACombatOptions_FrameContentWidth / scount
        for s = 1, scount do
            local spec = class[s]
            if (not spec) then
                spec = {}
                class[s] = spec
            end

            local frame = CreateFrame("Frame", nil, optionsContent, "ERACombatOptionsSpecFrame")
            table.insert(frames, frame)
            local cbx = frame.header.checkbox
            local specID, name = GetSpecializationInfoForClassID(c, s)
            cbx.Text:SetText(className .. " - " .. name)
            cbx:SetChecked(not spec.disabled)
            cbx:SetScript(
                "OnClick",
                function()
                    spec.disabled = not cbx:GetChecked()
                end
            )
            local y_inner = 0
            local content = frame.details
            for k, v in pairs(spec) do
                if (k ~= "disabled") then
                    local option = CreateFrame("CheckButton", nil, content, "OptionsSmallCheckButtonTemplate")
                    option.Text:SetText(k)
                    option:SetChecked(v)
                    option:SetScript(
                        "OnClick",
                        function()
                            spec[k] = option:GetChecked()
                        end
                    )
                    option:SetPoint("TOPLEFT", content, "TOPLEFT", 8, y_inner - 10)
                    y_inner = y_inner - 20
                end
            end
            max_spec_height = math.max(max_spec_height, 36 - y_inner)
        end
        for s = 1, scount do
            local frame = frames[s]
            local xleft = (s - 1) * specWidth + ERACombatOptions_FrameContentOffset
            local xright = s * specWidth + ERACombatOptions_FrameContentOffset
            frame:SetSize(specWidth, 36)
            frame:SetPoint("TOPLEFT", optionsContent, "TOPLEFT", xleft, y)
            frame:SetPoint("BOTTOMRIGHT", optionsContent, "TOPLEFT", xright, y - max_spec_height)
        end
        y = y - max_spec_height - 28
    end
    optionsContent:SetSize(ERACombatOptions_FrameContentWidth, -y)
end

function ERACombatOptions_IsSpecActive(specID)
    local c = ERACombatOptionsVariables[ERACombatFrames_classID]
    if (c) then
        local s = c[specID]
        if (s) then
            if (s.disabled) then
                return nil
            else
                return specID
            end
        else
            return specID
        end
    else
        return specID
    end
end

function ERACombatOptions_IsSpecModuleActive(specID, moduleName)
    local c = ERACombatOptionsVariables[ERACombatFrames_classID]
    if (c) then
        local s = c[specID]
        if (s) then
            return s[moduleName]
        else
            return true
        end
    else
        return true
    end
end
