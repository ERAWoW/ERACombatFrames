ERACombatFrames_initialized = false

function ERACombatFrames_loaded()
    -- [copié-collé de l'addon DisableAutoAddSpells]
    -- This prevents icons from being animated onto the main action bar
    IconIntroTracker.RegisterEvent = function()
    end
    IconIntroTracker:UnregisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
    -- [/fin DisableAutoAddSpells]

    --ERACombatFrameMain:RegisterEvent("PLAYER_ENTERING_WORLD")
    ERACombatFrameMain:RegisterEvent("ADDON_LOADED")
    ERACombatFrameMain:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
end

function ERACombatFrames_event(event, ...)
    -- [copié-collé de l'addon DisableAutoAddSpells]
    -- In the unlikely event that you're looking at a different action page while switching talents
    -- the spell is automatically added to your main bar. This takes it back off.
    if (event == "SPELL_PUSHED_TO_ACTIONBAR") then
        local spellID, slotIndex, slotPos = ...
        -- This event should never fire in combat, but check anyway
        if not InCombatLockdown() then
            ClearCursor()
            PickupAction(slotIndex)
            ClearCursor()
        -- [/fin DisableAutoAddSpells]
        end
    elseif (event == "ADDON_LOADED") then
        local addonName = ...
        if (addonName == "ERACombatFrames") then
            ERACombatFrames_PlayerIsNotMaxLevel = UnitLevel("player") < 60
            local _, _, classID = UnitClass("player")
            ERACombatFrames_classID = classID
            ERACombatOptions_initialize()
            local cFrame = ERACombatFrame:Create()
            if (classID == 12) then
                ERACombatFrames_DemonHunterSetup(cFrame)
            elseif (classID == 2) then
                ERACombatFrames_PaladinSetup(cFrame)
            elseif (classID == 3) then
                ERACombatFrames_HunterSetup(cFrame)
            elseif (classID == 5) then
                ERACombatFrames_PriestSetup(cFrame)
            elseif (classID == 6) then
                ERACombatFrames_DeathKnightSetup(cFrame)
            elseif (classID == 8) then
                ERACombatFrames_MageSetup(cFrame)
            elseif (classID == 9) then
                ERACombatFrames_WarlockSetup(cFrame)
            elseif (classID == 10) then
                ERACombatFrames_MonkSetup(cFrame)
            elseif (classID == 11) then
                ERACombatFrames_DruidSetup(cFrame)
            end
        end
    end
end
