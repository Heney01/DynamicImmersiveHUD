-- Core.lua
-- Main module for HideUI Elements
-- Manages initialization and coordination of modules

local addonName, addon = ...

-- ============================================================================
-- NAMESPACE AND GLOBAL VARIABLES
-- ============================================================================
HideUI = HideUI or {}
HideUI.Core = {}

-- Global state variables
HideUI.State = {
    barsHidden = false,
    chatHidden = false,
    uiHidden = false,
    sideBarHidden = false,
    bagsHidden = false,
    microMenuHidden = false,
    inCombat = false,
    combatOverrideActive = false,
    originalAlphas = {}
}

-- Main frame
local frame = CreateFrame("Frame", "HideUIElementsFrame")

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- Save original alpha values
function HideUI.Core.SaveOriginalAlphas()
    local state = HideUI.State
    local config = HideUI.Config
    
    -- Check that configuration is loaded
    if not config then
        print("|cFFFF0000HideUI:|r Configuration not loaded, postponing alpha save")
        return
    end
    
    -- Action bars
    if config.actionBars then
        for _, barName in pairs(config.actionBars) do
            local bar = _G[barName]
            if bar and not state.originalAlphas[barName] then
                state.originalAlphas[barName] = bar:GetAlpha()
            end
        end
    end
    
    -- UI elements
    if config.uiElements then
        for _, elementName in pairs(config.uiElements) do
            local element = _G[elementName]
            if element and not state.originalAlphas[elementName] then
                state.originalAlphas[elementName] = element:GetAlpha()
            end
        end
    end
    
    -- Bag elements
    if config.bagElements then
        for _, elementName in pairs(config.bagElements) do
            local element = _G[elementName]
            if element and not state.originalAlphas[elementName] then
                state.originalAlphas[elementName] = element:GetAlpha()
            end
        end
    end
    
    -- Micro-menus
    if config.microMenuElements then
        for _, elementName in pairs(config.microMenuElements) do
            local element = _G[elementName]
            if element and not state.originalAlphas[elementName] then
                state.originalAlphas[elementName] = element:GetAlpha()
            end
        end
    end
end

-- Apply hide/show to an element list
function HideUI.Core.ToggleElementList(elementList, isHidden, elementType)
    local state = HideUI.State
    
    -- Check that element list exists
    if not elementList then
        print("|cFFFF0000HideUI:|r Element list not found for " .. (elementType or "unknown"))
        return
    end
    
    for _, elementName in pairs(elementList) do
        local element = _G[elementName]
        if element then
            if isHidden then
                element:SetAlpha(0)
                if element.EnableMouse then
                    element:EnableMouse(false)
                end
            else
                local originalAlpha = state.originalAlphas[elementName] or 1
                element:SetAlpha(originalAlpha)
                if element.EnableMouse then
                    element:EnableMouse(true)
                end
            end
        end
    end
end

-- Toggle action bars
function HideUI.Core.ToggleActionBars()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.barsHidden = not HideUI.State.barsHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.actionBars then
        HideUI.Core.ToggleElementList(HideUI.Config.actionBars, HideUI.State.barsHidden, "bars")
    end
    
    local status = HideUI.State.barsHidden and "hidden" or "shown"
    print("|cFF00FF00HideUI:|r Action bars " .. status)
end

-- Toggle chat
function HideUI.Core.ToggleChat()
    HideUI.State.chatHidden = not HideUI.State.chatHidden
    
    -- Delegate to Chat module
    if HideUI.Chat then
        HideUI.Chat.ApplyToggle(HideUI.State.chatHidden)
    end
    
    local status = HideUI.State.chatHidden and "hidden" or "shown"
    print("|cFF00FF00HideUI:|r Chat " .. status)
end

-- Toggle interface elements
function HideUI.Core.ToggleUIElements()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.uiHidden = not HideUI.State.uiHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.uiElements then
        HideUI.Core.ToggleElementList(HideUI.Config.uiElements, HideUI.State.uiHidden, "ui")
    end
    
    local status = HideUI.State.uiHidden and "hidden" or "shown"
    print("|cFF00FF00HideUI:|r Interface elements " .. status)
end

-- Toggle bags
function HideUI.Core.ToggleBags()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.bagsHidden = not HideUI.State.bagsHidden
    
    -- Delegate to Bags module
    if HideUI.Bags then
        HideUI.Bags.ApplyToggle(HideUI.State.bagsHidden)
    end
    
    local status = HideUI.State.bagsHidden and "hidden" or "shown"
    print("|cFF00FF00HideUI:|r Bags " .. status)
end

-- Toggle micro-menus
function HideUI.Core.ToggleMicroMenu()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.microMenuHidden = not HideUI.State.microMenuHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.microMenuElements then
        HideUI.Core.ToggleElementList(HideUI.Config.microMenuElements, HideUI.State.microMenuHidden, "microMenu")
    end
    
    local status = HideUI.State.microMenuHidden and "hidden" or "shown"
    print("|cFF00FF00HideUI:|r Micro-menus " .. status)
end

-- Toggle everything
function HideUI.Core.ToggleAll()
    local state = HideUI.State
    
    if state.barsHidden or state.chatHidden or state.uiHidden or state.sideBarHidden or state.bagsHidden or state.microMenuHidden then
        -- If something is hidden, show everything
        if state.barsHidden then HideUI.Core.ToggleActionBars() end
        if state.chatHidden then HideUI.Core.ToggleChat() end
        if state.uiHidden then HideUI.Core.ToggleUIElements() end
        if state.bagsHidden then HideUI.Core.ToggleBags() end
        if state.microMenuHidden then HideUI.Core.ToggleMicroMenu() end
        if state.sideBarHidden then 
            state.sideBarHidden = false
            if not state.combatOverrideActive and HideUI.Config and HideUI.Config.sideActionBars then
                HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, false, "sideBars")
            end
            print("|cFF00FF00HideUI:|r Side bars shown")
        end
    else
        -- If everything is shown, hide everything
        HideUI.Core.ToggleActionBars()
        HideUI.Core.ToggleChat()
        HideUI.Core.ToggleUIElements()
        HideUI.Core.ToggleBags()
        HideUI.Core.ToggleMicroMenu()
        state.sideBarHidden = true
        if not state.combatOverrideActive and HideUI.Config and HideUI.Config.sideActionBars then
            HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, true, "sideBars")
        end
        print("|cFF00FF00HideUI:|r Side bars hidden")
    end
end

-- Show everything
function HideUI.Core.ShowAll()
    local state = HideUI.State
    
    if state.barsHidden then HideUI.Core.ToggleActionBars() end
    if state.chatHidden then HideUI.Core.ToggleChat() end
    if state.uiHidden then HideUI.Core.ToggleUIElements() end
    if state.bagsHidden then HideUI.Core.ToggleBags() end
    if state.microMenuHidden then HideUI.Core.ToggleMicroMenu() end
    print("|cFF00FF00HideUI:|r Interface restored")
end

-- ============================================================================
-- EVENT MANAGEMENT
-- ============================================================================
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Enter combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Leave combat

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            print("|cFF00FF00Dynamic Immersive HUD|r v2.0 loaded successfully!")
            print("Use |cFFFFFF00/hideui|r or the |cFFFFFF00<|r key to toggle interface")
            print("Use the |cFFFFFF00B|r key to show bags temporarily")
            print("|cFF32CD32Automatic combat:|r Interface shows in combat and disappears after")
            print("|cFF87CEEBTemporary chat:|r Chat shows for important messages")
            print("|cFFFFB6C1Smart hover:|r Chat, bars, bags, micro-menus and quests show on hover")
        end
    elseif event == "PLAYER_LOGIN" then
        -- Wait for all modules to load before saving alphas
        C_Timer.After(1, function()
            HideUI.Core.SaveOriginalAlphas()
        end)
        
        -- Initialize other modules with delay
        C_Timer.After(2, function()
            if HideUI.Keybinds then HideUI.Keybinds.Setup() end
        end)
        C_Timer.After(3, function()
            if HideUI.Chat then HideUI.Chat.SetupHooks() end
        end)
        C_Timer.After(4, function()
            if HideUI.Bags then HideUI.Bags.SetupHooks() end
        end)
        C_Timer.After(5, function()
            if HideUI.Hover then HideUI.Hover.Initialize() end
        end)
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Enter combat
        HideUI.State.inCombat = true
        if HideUI.Combat then
            HideUI.Combat.OnEnterCombat()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Leave combat
        HideUI.State.inCombat = false
        if HideUI.Combat then
            HideUI.Combat.OnLeaveCombat()
        end
    end
end)

-- ============================================================================
-- GLOBAL FUNCTIONS FOR KEYBINDINGS
-- ============================================================================
function HideUI_ToggleAll() HideUI.Core.ToggleAll() end
function HideUI_ToggleBars() HideUI.Core.ToggleActionBars() end
function HideUI_ToggleChat() HideUI.Core.ToggleChat() end
function HideUI_ToggleMicroMenu() HideUI.Core.ToggleMicroMenu() end
function HideUI_ShowBagsTemporary() 
    if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive then
        HideUI.Bags.ShowTemporary()
    elseif not HideUI.State.bagsHidden then
        -- If bags are not hidden, normal behavior of B key
        if ToggleAllBags then
            ToggleAllBags()
        end
    end
end