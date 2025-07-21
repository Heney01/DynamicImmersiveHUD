-- Targeting.lua
-- Target frame management module

HideUI = HideUI or {}
HideUI.Targeting = {}

-- Local variables
local targetTemporaryActive = false
local targetTimer = nil
local targetingFrame = nil

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- Show target frame when targeting something
function HideUI.Targeting.ShowTargetFrame()
    if not HideUI.State.uiHidden or (HideUI.State and not HideUI.State.addonEnabled) then 
        return 
    end
    
    targetTemporaryActive = true
    
    -- Cancel previous timer if exists
    if targetTimer then
        targetTimer:Cancel()
    end
    
    -- Show target-related elements immediately
    local targetElements = {
        "TargetFrame", 
        "TargetFrameHealthBar", 
        "TargetFrameManaBar",
        "TargetFrameTextureFrame",
        "TargetFrameNameBackground",
        "TargetFramePortrait",
        "TargetFrameToT",  -- Target of Target
        "FocusFrame"       -- Focus frame if exists
    }
    
    for _, elementName in pairs(targetElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
        end
    end
    
    -- Also show buffs/debuffs on target
    local buffElements = {
        "TargetFrameBuff1", "TargetFrameBuff2", "TargetFrameBuff3", "TargetFrameBuff4",
        "TargetFrameDebuff1", "TargetFrameDebuff2", "TargetFrameDebuff3", "TargetFrameDebuff4"
    }
    
    for _, elementName in pairs(buffElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
        end
    end
end

-- Hide target frame after losing target
function HideUI.Targeting.HideTargetFrame()
    if not HideUI.State.uiHidden or not targetTemporaryActive then return end
    
    targetTemporaryActive = false
    
    -- Quick fade for target elements
    local targetElements = {
        "TargetFrame", 
        "TargetFrameHealthBar", 
        "TargetFrameManaBar",
        "TargetFrameTextureFrame",
        "TargetFrameNameBackground",
        "TargetFramePortrait",
        "TargetFrameToT",
        "FocusFrame"
    }
    
    -- Fade with animation
    local fadeSteps = 8
    local currentStep = 0
    
    local targetFadeTimer = C_Timer.NewTicker(0.1, function(timer)
        currentStep = currentStep + 1
        local alpha = 1 - (currentStep / fadeSteps)
        
        if alpha <= 0 then
            alpha = 0
            timer:Cancel()
        end
        
        for _, elementName in pairs(targetElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
            end
        end
        
        -- Also fade buffs/debuffs
        local buffElements = {
            "TargetFrameBuff1", "TargetFrameBuff2", "TargetFrameBuff3", "TargetFrameBuff4",
            "TargetFrameDebuff1", "TargetFrameDebuff2", "TargetFrameDebuff3", "TargetFrameDebuff4"
        }
        
        for _, elementName in pairs(buffElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
            end
        end
        
        if currentStep >= fadeSteps then
            timer:Cancel()
        end
    end)
end

-- Apply target frame toggle (for manual toggle)
function HideUI.Targeting.ApplyToggle(isHidden)
    if isHidden then
        -- If manually hidden, cancel any temporary display
        if targetTemporaryActive then
            targetTemporaryActive = false
            if targetTimer then
                targetTimer:Cancel()
            end
        end
        
        -- Hide target elements if not in combat
        if not HideUI.State.combatOverrideActive then
            local targetElements = {"TargetFrame"}
            
            for _, elementName in pairs(targetElements) do
                local element = _G[elementName]
                if element then
                    element:SetAlpha(0)
                end
            end
        end
    else
        -- Show target elements
        local targetElements = {"TargetFrame"}
        
        for _, elementName in pairs(targetElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(1)
            end
        end
    end
end

-- ============================================================================
-- EVENT HANDLING
-- ============================================================================

-- Handle target changed events
function HideUI.Targeting.OnTargetChanged()
    if UnitExists("target") then
        -- We have a target, show the target frame
        HideUI.Targeting.ShowTargetFrame()
        
        -- Cancel hide timer if we get a new target quickly
        if targetTimer then
            targetTimer:Cancel()
            targetTimer = nil
        end
        
    else
        -- No target, schedule hiding after a delay (in case of quick retargeting)
        if targetTemporaryActive then
            targetTimer = C_Timer.NewTimer(2, function()
                HideUI.Targeting.HideTargetFrame()
            end)
        end
    end
end

-- Setup targeting event handlers
function HideUI.Targeting.SetupEvents()
    if not targetingFrame then
        targetingFrame = CreateFrame("Frame", "HideUITargetingFrame")
        targetingFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        targetingFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        
        targetingFrame:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_TARGET_CHANGED" then
                HideUI.Targeting.OnTargetChanged()
            elseif event == "PLAYER_FOCUS_CHANGED" then
                -- Similar handling for focus target
                if UnitExists("focus") and HideUI.State.uiHidden then
                    local focusFrame = _G["FocusFrame"]
                    if focusFrame then
                        focusFrame:SetAlpha(1)
                    end
                end
            end
        end)
    end
end

-- ============================================================================
-- STATE FUNCTIONS
-- ============================================================================

-- Check if target is temporarily active
function HideUI.Targeting.IsTargetTemporaryActive()
    return targetTemporaryActive
end

-- Cancel temporary target display
function HideUI.Targeting.CancelTemporary()
    if targetTemporaryActive then
        targetTemporaryActive = false
        if targetTimer then
            targetTimer:Cancel()
            targetTimer = nil
        end
    end
end

-- Force hide target frame (for reset/show all)
function HideUI.Targeting.ForceHide()
    if not HideUI.State.uiHidden then return end
    
    HideUI.Targeting.CancelTemporary()
    
    local targetElements = {
        "TargetFrame", 
        "TargetFrameHealthBar", 
        "TargetFrameManaBar",
        "TargetFrameTextureFrame",
        "TargetFrameNameBackground",
        "TargetFramePortrait",
        "TargetFrameToT",
        "FocusFrame"
    }
    
    for _, elementName in pairs(targetElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(0)
        end
    end
end