-- Combat.lua
-- Combat and fade management module

HideUI = HideUI or {}
HideUI.Combat = {}

-- Local variables
local fadeTimer = nil

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- Apply alpha level to all elements
function HideUI.Combat.ApplyFadeToAllElements(alpha)
    -- Check that configuration is available
    if not HideUI.Config then
        print("|cFFFF0000HideUI Combat:|r Configuration not loaded, unable to apply fade")
        return
    end
    
    -- Action bars
    if HideUI.Config.actionBars then
        for _, barName in pairs(HideUI.Config.actionBars) do
            local bar = _G[barName]
            if bar then
                bar:SetAlpha(alpha)
            end
        end
    end
    
    -- UI elements
    if HideUI.Config.uiElements then
        for _, elementName in pairs(HideUI.Config.uiElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
            end
        end
    end
    
    -- Bag elements
    if HideUI.Config.bagElements then
        for _, elementName in pairs(HideUI.Config.bagElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
            end
        end
    end
    
    -- Micro-menus
    if HideUI.Config.microMenuElements then
        for _, elementName in pairs(HideUI.Config.microMenuElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
            end
        end
    end
    
    -- Chat
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            chatFrame:SetAlpha(alpha)
        end
        local chatTab = _G["ChatFrame"..i.."Tab"]
        if chatTab then
            chatTab:SetAlpha(alpha)
        end
    end
    
    if HideUI.Config.chatElements then
        for _, elementName in pairs(HideUI.Config.chatElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
            end
        end
    end
    
    -- Bag windows
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame then
            containerFrame:SetAlpha(alpha)
        end
    end
end

-- Apply complete hidden state
function HideUI.Combat.ApplyHiddenState()
    local state = HideUI.State
    
    if state.barsHidden and HideUI.Core and HideUI.Config and HideUI.Config.actionBars then
        HideUI.Core.ToggleElementList(HideUI.Config.actionBars, true, "bars")
    end
    
    if state.chatHidden and HideUI.Chat then
        HideUI.Chat.ApplyToggle(true)
    end
    
    if state.uiHidden and HideUI.Core and HideUI.Config and HideUI.Config.uiElements then
        HideUI.Core.ToggleElementList(HideUI.Config.uiElements, true, "ui")
    end
    
    if state.bagsHidden and HideUI.Bags then
        HideUI.Bags.ApplyToggle(true)
    end
    
    if state.microMenuHidden and HideUI.Core and HideUI.Config and HideUI.Config.microMenuElements then
        HideUI.Core.ToggleElementList(HideUI.Config.microMenuElements, true, "microMenu")
    end
end

-- Immediately show interface for combat
function HideUI.Combat.ShowUIForCombat()
    HideUI.State.combatOverrideActive = true
    
    if fadeTimer then
        fadeTimer:Cancel()
    end
    
    -- Immediate display with alpha = 1
    HideUI.Combat.ApplyFadeToAllElements(1)
    
    -- Check that configuration is available before reactivating interactions
    if not HideUI.Config then
        print("|cFFFF0000HideUI Combat:|r Configuration not loaded, mouse interactions not restored")
        return
    end
    
    -- Reactivate mouse interactions
    if HideUI.Config.actionBars then
        for _, barName in pairs(HideUI.Config.actionBars) do
            local bar = _G[barName]
            if bar and bar.EnableMouse then
                bar:EnableMouse(true)
            end
        end
    end
    
    if HideUI.Config.uiElements then
        for _, elementName in pairs(HideUI.Config.uiElements) do
            local element = _G[elementName]
            if element and element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    if HideUI.Config.bagElements then
        for _, elementName in pairs(HideUI.Config.bagElements) do
            local element = _G[elementName]
            if element and element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Reactivate micro-menus
    if HideUI.Config.microMenuElements then
        for _, elementName in pairs(HideUI.Config.microMenuElements) do
            local element = _G[elementName]
            if element and element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Reactivate chat
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame and chatFrame.EnableMouse then
            chatFrame:EnableMouse(true)
        end
    end
    
    if HideUI.Config.chatElements then
        for _, elementName in pairs(HideUI.Config.chatElements) do
            local element = _G[elementName]
            if element and element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Reactivate bag windows
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame and containerFrame.EnableMouse then
            containerFrame:EnableMouse(true)
        end
    end
end

-- Progressive fade function
function HideUI.Combat.FadeOutUI()
    -- Check that configuration is loaded
    if not HideUI.Config then
        print("|cFFFF0000HideUI Combat:|r Configuration not loaded, fade canceled")
        return
    end
    
    if fadeTimer then
        fadeTimer:Cancel()
    end
    
    -- Reduced delay to 1 second after combat ends
    fadeTimer = C_Timer.NewTimer(1, function()
        if not HideUI.State.inCombat and HideUI.State.combatOverrideActive then
            -- Faster progressive fade over 0.8 seconds
            local fadeSteps = 10
            local currentStep = 0
            
            local fadeOutTimer = C_Timer.NewTicker(0.08, function(timer)
                currentStep = currentStep + 1
                local alpha = 1 - (currentStep / fadeSteps)
                
                if alpha <= 0 then
                    alpha = 0
                    HideUI.State.combatOverrideActive = false
                    -- Restore complete hidden state
                    local state = HideUI.State
                    if state.barsHidden or state.chatHidden or state.uiHidden or state.bagsHidden or state.microMenuHidden then
                        HideUI.Combat.ApplyHiddenState()
                    end
                    -- Cancel timer at end
                    timer:Cancel()
                else
                    -- Apply fade to all elements
                    HideUI.Combat.ApplyFadeToAllElements(alpha)
                end
                
                if currentStep >= fadeSteps then
                    timer:Cancel()
                end
            end)
        end
    end)
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

-- Enter combat handler
function HideUI.Combat.OnEnterCombat()
    local state = HideUI.State
    
    if state.barsHidden or state.chatHidden or state.uiHidden or state.bagsHidden then
        HideUI.Combat.ShowUIForCombat()
        print("|cFFFF6600HideUI:|r Interface shown for combat")
    end
end

-- Leave combat handler
function HideUI.Combat.OnLeaveCombat()
    if HideUI.State.combatOverrideActive then
        print("|cFF32CD32HideUI:|r Combat ended - fading in 1 second...")
        HideUI.Combat.FadeOutUI()
    end
end