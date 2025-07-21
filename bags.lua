-- Bags.lua
-- Bags management module

HideUI = HideUI or {}
HideUI.Bags = {}

-- Local variables
local bagTemporaryActive = false
local bagTimer = nil
local originalToggleBag = nil
local originalToggleAllBags = nil
local originalToggleBackpack = nil

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- Show bags temporarily
function HideUI.Bags.ShowTemporary()
    -- Vérifier que le système est prêt
    if not HideUI.State then
        return
    end
    
    -- Si l'addon est désactivé, utiliser le comportement normal
    if not HideUI.State.addonEnabled then
        if ToggleAllBags then
            ToggleAllBags()
        end
        return
    end
    
    if not HideUI.State.bagsHidden then 
        -- If bags are not hidden, use normal behavior
        if ToggleAllBags then
            ToggleAllBags()
        end
        return 
    end
    
    -- If temporary display is already active, close bags and disable temporary mode
    if bagTemporaryActive then
        -- Close bags
        if originalToggleAllBags then
            originalToggleAllBags()
        elseif ToggleAllBags then
            local tempBagsHidden = HideUI.State.bagsHidden
            local tempBagTemporaryActive = bagTemporaryActive
            HideUI.State.bagsHidden = false
            bagTemporaryActive = false
            ToggleAllBags()
            HideUI.State.bagsHidden = tempBagsHidden
            bagTemporaryActive = tempBagTemporaryActive
        end
        
        -- Disable temporary mode immediately
        HideUI.Bags.CancelTemporary()
        
        -- Hide bag elements
        HideUI.Bags.HideAfterDelay()
    
        return
    end
    
    bagTemporaryActive = true
    
    -- Cancel previous timer if exists
    if bagTimer then
        bagTimer:Cancel()
    end
    
    -- Show bag elements first
    if HideUI.Config and HideUI.Config.bagElements then
        for _, elementName in pairs(HideUI.Config.bagElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(1)
                if element.EnableMouse then
                    element:EnableMouse(true)
                end
            end
        end
    end
    
    -- Actually open bags - use original function or alternative approach
    C_Timer.After(0.1, function()
        if originalToggleAllBags then
            -- Use saved original function
            originalToggleAllBags()
        elseif ToggleAllBags then
            -- Force opening by temporarily disabling our hook
            local tempBagsHidden = HideUI.State.bagsHidden
            local tempBagTemporaryActive = bagTemporaryActive
            HideUI.State.bagsHidden = false
            bagTemporaryActive = false
            ToggleAllBags()
            HideUI.State.bagsHidden = tempBagsHidden
            bagTemporaryActive = tempBagTemporaryActive
        else
            -- Alternative method: simulate bag button click
            local backpackButton = _G["MainMenuBarBackpackButton"]
            if backpackButton and backpackButton:IsVisible() then
                backpackButton:Click()
            end
        end
    end)
    
    -- Show all open bag windows
    C_Timer.After(0.2, function()
        for i = 1, 13 do
            local containerFrame = _G["ContainerFrame"..i]
            if containerFrame and containerFrame:IsShown() then
                containerFrame:SetAlpha(1)
                containerFrame:EnableMouse(true)
            end
        end
    end)
        
    -- Schedule automatic hiding in 8 seconds (reduced because instant hiding)
    bagTimer = C_Timer.NewTimer(8, function()
        HideUI.Bags.HideAfterDelay()
    end)
end

-- Hide bags after delay
function HideUI.Bags.HideAfterDelay()
    if not HideUI.State or not HideUI.State.bagsHidden then 
        return
    end
   
    -- Don't hide in combat
    if HideUI.State.combatOverrideActive then
        return
    end
    
    -- Disable temporary mode
    bagTemporaryActive = false
    
    -- Instant hiding (no fade)
    if HideUI.Config and HideUI.Config.bagElements then
        for _, elementName in pairs(HideUI.Config.bagElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(0)
                if element.EnableMouse then
                    element:EnableMouse(false)
                end
            end
        end
    end
    
    -- Hide all bag windows
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame then
            containerFrame:SetAlpha(0)
            containerFrame:EnableMouse(false)
        end
    end
end

-- Apply bag toggle
function HideUI.Bags.ApplyToggle(isHidden)
    -- Cancel temporary display if active
    if bagTemporaryActive then
        bagTemporaryActive = false
        if bagTimer then
            bagTimer:Cancel()
        end
    end
    
    -- If in combat, don't apply immediately
    if not HideUI.State.combatOverrideActive then
        if HideUI.Core and HideUI.Config and HideUI.Config.bagElements then
            HideUI.Core.ToggleElementList(HideUI.Config.bagElements, isHidden, "bags")
        end
        
        -- Special handling of bag windows - instant
        for i = 1, 13 do
            local containerFrame = _G["ContainerFrame"..i]
            if containerFrame then
                if isHidden then
                    containerFrame:SetAlpha(0)
                    containerFrame:EnableMouse(false)
                else
                    if containerFrame:IsShown() then
                        containerFrame:SetAlpha(1)
                        containerFrame:EnableMouse(true)
                    end
                end
            end
        end
    end
    
    -- If hiding bags, ensure everything is hidden instantly
    if isHidden then
        -- No delay, immediate hiding
        HideUI.Bags.ForceHide()
    end
end

-- Show bags on hover
function HideUI.Bags.ShowOnHover()
    if not HideUI.State or not HideUI.State.bagsHidden or HideUI.State.combatOverrideActive then 
        return 
    end
    
    -- Instant display of bag elements
    if HideUI.Config and HideUI.Config.bagElements then
        for _, elementName in pairs(HideUI.Config.bagElements) do
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

-- Hide bags after hover
function HideUI.Bags.HideAfterHover()
    if not HideUI.State or not HideUI.State.bagsHidden or bagTemporaryActive or HideUI.State.combatOverrideActive then 
        return 
    end
    
    -- Instant bag hiding
    if HideUI.Config and HideUI.Config.bagElements then
        for _, elementName in pairs(HideUI.Config.bagElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(0)
                if element.EnableMouse then
                    element:EnableMouse(false)
                end
            end
        end
    end
end

-- ============================================================================
-- BAG FUNCTION HOOKS
-- ============================================================================

function HideUI.Bags.SetupHooks()
    -- Hook ToggleBag
    if ToggleBag and not originalToggleBag then
        originalToggleBag = ToggleBag
        ToggleBag = function(bagID)
            if HideUI.State and HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive then
                HideUI.Bags.ShowTemporary()
                -- Don't call original function here as ShowTemporary handles it
                return
            end
            return originalToggleBag(bagID)
        end
    end
    
    -- Hook ToggleAllBags  
    if ToggleAllBags and not originalToggleAllBags then
        originalToggleAllBags = ToggleAllBags
        ToggleAllBags = function()
            if HideUI.State and HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive then
                HideUI.Bags.ShowTemporary()
                -- Don't call original function here as ShowTemporary handles it
                return
            end
            return originalToggleAllBags()
        end
    end
    
    -- Hook ToggleBackpack
    if ToggleBackpack and not originalToggleBackpack then
        originalToggleBackpack = ToggleBackpack
        ToggleBackpack = function()
            if HideUI.State and HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive then
                HideUI.Bags.ShowTemporary()
                -- Don't call original function here as ShowTemporary handles it
                return
            end
            return originalToggleBackpack()
        end
    end
    
    -- Hook individual bag buttons
    for i = 0, 4 do
        local bagButton = _G["CharacterBag"..i.."Slot"]
        if bagButton and not bagButton.hideUIHooked then
            bagButton:HookScript("OnClick", function()
                if HideUI.State and HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive  then
                    HideUI.Bags.ShowTemporary()
                end
            end)
            bagButton.hideUIHooked = true
        end
    end
    
    -- Hook main backpack button
    local backpackButton = _G["MainMenuBarBackpackButton"]
    if backpackButton and not backpackButton.hideUIHooked then
        backpackButton:HookScript("OnClick", function()
            if HideUI.State and HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive then
                HideUI.Bags.ShowTemporary()
            end
        end)
        backpackButton.hideUIHooked = true
    end

end

-- ============================================================================
-- STATE FUNCTIONS
-- ============================================================================

-- Check if temporary display is active
function HideUI.Bags.IsTemporaryActive()
    return bagTemporaryActive
end

-- Cancel temporary display
function HideUI.Bags.CancelTemporary()
    if bagTemporaryActive then
        bagTemporaryActive = false
        if bagTimer then
            bagTimer:Cancel()
            bagTimer = nil
        end
    end
end

-- Force immediate bag hiding
function HideUI.Bags.ForceHide()
    if not HideUI.State or not HideUI.State.bagsHidden then 
        return 
    end
    
    -- Disable temporary mode
    HideUI.Bags.CancelTemporary()
    
    -- Immediately hide bag elements
    if HideUI.Config and HideUI.Config.bagElements then
        for _, elementName in pairs(HideUI.Config.bagElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(0)
                if element.EnableMouse then
                    element:EnableMouse(false)
                end
            end
        end
    end
    
    -- Hide all bag windows
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame then
            containerFrame:SetAlpha(0)
            containerFrame:EnableMouse(false)
        end
    end
end
