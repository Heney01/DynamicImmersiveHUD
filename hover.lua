-- Hover.lua
-- Smart hover management module

HideUI = HideUI or {}
HideUI.Hover = {}

-- Local variables
local hoverTimers = {}
local hoverActiveElements = {}
local mouseCheckTimer = nil

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- Temporarily show a group of elements
function HideUI.Hover.ShowElementsOnHover(elementType)
    if HideUI.State.combatOverrideActive then return end
    
    -- Cancel previous timer for this type
    if hoverTimers[elementType] then
        hoverTimers[elementType]:Cancel()
        hoverTimers[elementType] = nil
    end
    
    hoverActiveElements[elementType] = true
    
    if elementType == "chat" and HideUI.State.chatHidden then
        if HideUI.Chat then
            HideUI.Chat.ShowOnHover()
        end
        
    elseif elementType == "mainBars" and HideUI.State.barsHidden then
        -- Show main bars (bottom)
        for _, barName in pairs(HideUI.Config.mainActionBars) do
            local bar = _G[barName]
            if bar then
                bar:SetAlpha(1)
                if bar.EnableMouse then
                    bar:EnableMouse(true)
                end
            end
        end
        
        -- Also show main bar elements
        local mainBarElements = {
            "MainMenuBar", "MainMenuBarArtFrame", "MainMenuBarArtFrameBackground",
            "MainMenuBarLeftEndCap", "MainMenuBarRightEndCap", "ActionBarUpButton", 
            "ActionBarDownButton", "MainMenuBarPageNumber"
        }
        
        for _, elementName in pairs(mainBarElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(1)
                if element.EnableMouse then
                    element:EnableMouse(true)
                end
            end
        end
        
    elseif elementType == "sideBars" and HideUI.State.sideBarHidden then
        -- Show side bars only
        for _, barName in pairs(HideUI.Config.sideActionBars) do
            local bar = _G[barName]
            if bar then
                bar:SetAlpha(1)
                if bar.EnableMouse then
                    bar:EnableMouse(true)
                end
            end
        end
        
    elseif elementType == "objectives" and HideUI.State.uiHidden then
        -- Show objectives/quests
        local objectiveElements = {"ObjectiveTrackerFrame", "QuestWatchFrame", "QuestMapFrame"}
        for _, elementName in pairs(objectiveElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(1)
                if element.EnableMouse then
                    element:EnableMouse(true)
                end
            end
        end
        
    elseif elementType == "bags" and HideUI.State.bagsHidden then
        if HideUI.Bags then
            HideUI.Bags.ShowOnHover()
        end
        
    elseif elementType == "microMenu" and HideUI.State.microMenuHidden then
        -- Show micro-menus
        for _, elementName in pairs(HideUI.Config.microMenuElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(1)
                if element.EnableMouse then
                    element:EnableMouse(true)
                end
            end
        end
    end
end

-- Hide elements after delay
function HideUI.Hover.HideElementsAfterDelay(elementType, delay)
    hoverTimers[elementType] = C_Timer.NewTimer(delay, function()
        if not hoverActiveElements[elementType] then return end
        
        hoverActiveElements[elementType] = false
        
        if elementType == "chat" and HideUI.State.chatHidden then
            if HideUI.Chat then
                HideUI.Chat.HideAfterHover()
            end
            
        elseif elementType == "mainBars" and HideUI.State.barsHidden and not HideUI.State.combatOverrideActive then
            -- Fade main bars with associated elements
            for _, barName in pairs(HideUI.Config.mainActionBars) do
                local bar = _G[barName]
                if bar then
                    bar:SetAlpha(0)
                    if bar.EnableMouse then
                        bar:EnableMouse(false)
                    end
                end
            end
            
            -- Also hide main bar elements
            local mainBarElements = {
                "MainMenuBar", "MainMenuBarArtFrame", "MainMenuBarArtFrameBackground",
                "MainMenuBarLeftEndCap", "MainMenuBarRightEndCap", "ActionBarUpButton", 
                "ActionBarDownButton", "MainMenuBarPageNumber"
            }
            
            for _, elementName in pairs(mainBarElements) do
                local element = _G[elementName]
                if element then
                    element:SetAlpha(0)
                    if element.EnableMouse then
                        element:EnableMouse(false)
                    end
                end
            end
            
        elseif elementType == "sideBars" and HideUI.State.sideBarHidden and not HideUI.State.combatOverrideActive then
            -- Fade side bars
            for _, barName in pairs(HideUI.Config.sideActionBars) do
                local bar = _G[barName]
                if bar then
                    bar:SetAlpha(0)
                    if bar.EnableMouse then
                        bar:EnableMouse(false)
                    end
                end
            end
            
        elseif elementType == "objectives" and HideUI.State.uiHidden and not HideUI.State.combatOverrideActive then
            -- Fade objectives
            local objectiveElements = {"ObjectiveTrackerFrame", "QuestWatchFrame", "QuestMapFrame"}
            for _, elementName in pairs(objectiveElements) do
                local element = _G[elementName]
                if element then
                    element:SetAlpha(0)
                    if element.EnableMouse then
                        element:EnableMouse(false)
                    end
                end
            end
            
        elseif elementType == "bags" and HideUI.State.bagsHidden then
            if HideUI.Bags then
                HideUI.Bags.HideAfterHover()
            end
            
        elseif elementType == "microMenu" and HideUI.State.microMenuHidden and not HideUI.State.combatOverrideActive then
            -- Fade micro-menus
            for _, elementName in pairs(HideUI.Config.microMenuElements) do
                local element = _G[elementName]
                if element then
                    element:SetAlpha(0)
                    if element.EnableMouse then
                        element:EnableMouse(false)
                    end
                end
            end
        end
        
        hoverTimers[elementType] = nil
    end)
end

-- Detect if mouse is in a region
function HideUI.Hover.IsMouseInRegion(region)
    local mouseX, mouseY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    mouseX = mouseX / scale
    mouseY = mouseY / scale
    
    return mouseX >= region.left and mouseX <= region.right and 
           mouseY >= region.bottom and mouseY <= region.top
end

-- ============================================================================
-- INITIALIZATION AND TIMER
-- ============================================================================

-- Initialize hover system
function HideUI.Hover.Initialize()
    -- Timer to check mouse position
    mouseCheckTimer = C_Timer.NewTicker(0.15, function()
        local state = HideUI.State
        
        if state.combatOverrideActive or 
           (not state.barsHidden and not state.chatHidden and not state.uiHidden and not state.sideBarHidden and not state.bagsHidden and not state.microMenuHidden) then
            return
        end
        
        -- Update hover zones dynamically
        if HideUI.Config then
            HideUI.Config.UpdateHoverZones()
        end
        
        for zoneName, zoneData in pairs(HideUI.Config.hoverZones) do
            local isInZone = HideUI.Hover.IsMouseInRegion(zoneData.region)
            
            if isInZone then
                if not hoverActiveElements[zoneData.elements] then
                    HideUI.Hover.ShowElementsOnHover(zoneData.elements)
                    print("|cFFFFB6C1HideUI:|r " .. zoneData.elements .. " shown on hover")
                end
                -- Cancel hide timer if still hovering
                if hoverTimers[zoneData.elements] then
                    hoverTimers[zoneData.elements]:Cancel()
                    hoverTimers[zoneData.elements] = nil
                end
            else
                -- If leaving zone and element is active, schedule hiding
                if hoverActiveElements[zoneData.elements] and not hoverTimers[zoneData.elements] then
                    HideUI.Hover.HideElementsAfterDelay(zoneData.elements, zoneData.delay)
                end
            end
        end
    end)
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Check if element is active on hover
function HideUI.Hover.IsElementActive(elementType)
    return hoverActiveElements[elementType] or false
end

-- Cancel all hover timers
function HideUI.Hover.CancelAllTimers()
    for elementType, timer in pairs(hoverTimers) do
        if timer then
            timer:Cancel()
        end
    end
    hoverTimers = {}
    hoverActiveElements = {}
end

-- Stop hover system
function HideUI.Hover.Stop()
    if mouseCheckTimer then
        mouseCheckTimer:Cancel()
        mouseCheckTimer = nil
    end
    HideUI.Hover.CancelAllTimers()
end