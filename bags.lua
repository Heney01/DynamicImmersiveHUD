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
local merchantActive = false
local merchantFrame = nil
local debugMode = false -- Variable to enable/disable debug

-- Conditional debug function
local function DebugPrint(message)
    if debugMode then
        print("|cFFFFAA00HideUI Debug:|r " .. message)
    end
end

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- Show bags temporarily
function HideUI.Bags.ShowTemporary()
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
        
        print("|cFF87CEEB HideUI:|r Bags closed and hidden")
        return
    end
    
    bagTemporaryActive = true
    
    -- Cancel previous timer if exists
    if bagTimer then
        bagTimer:Cancel()
    end
    
    -- Show bag elements first
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
            if element.EnableMouse then
                element:EnableMouse(true)
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
    
    print("|cFF87CEEB HideUI:|r Bags shown temporarily")
    
    -- Schedule automatic hiding in 8 seconds (reduced because instant hiding)
    bagTimer = C_Timer.NewTimer(8, function()
        HideUI.Bags.HideAfterDelay()
    end)
end

-- Hide bags after delay
function HideUI.Bags.HideAfterDelay()
    DebugPrint("HideAfterDelay called")
    DebugPrint("- bagsHidden: " .. (HideUI.State.bagsHidden and "true" or "false"))
    DebugPrint("- merchantActive: " .. (merchantActive and "true" or "false"))
    DebugPrint("- combatOverrideActive: " .. (HideUI.State.combatOverrideActive and "true" or "false"))
    
    if not HideUI.State.bagsHidden then 
        DebugPrint("Stop: bags not supposed to be hidden")
        return
    end
    
    -- Don't hide if at merchant
    if merchantActive then
        print("|cFF87CEEB HideUI:|r Bag hiding canceled (merchant active)")
        return
    end
    
    -- Don't hide in combat
    if HideUI.State.combatOverrideActive then
        DebugPrint("Bag hiding canceled (combat active)")
        return
    end
    
    -- Disable temporary mode
    bagTemporaryActive = false
    
    DebugPrint("Instant hiding procedure")
    
    -- Instant hiding (no fade)
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(0)
            if element.EnableMouse then
                element:EnableMouse(false)
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
    
    print("|cFF87CEEB HideUI:|r Bags hidden instantly")
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
        if HideUI.Core then
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
    if not HideUI.State.bagsHidden or HideUI.State.combatOverrideActive then return end
    
    -- Instant display of bag elements
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

-- Hide bags after hover
function HideUI.Bags.HideAfterHover()
    if not HideUI.State.bagsHidden or bagTemporaryActive or HideUI.State.combatOverrideActive or merchantActive then 
        return 
    end
    
    -- Instant bag hiding
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

-- ============================================================================
-- BAG FUNCTION HOOKS
-- ============================================================================

function HideUI.Bags.SetupHooks()
    -- Hook ToggleBag
    if ToggleBag and not originalToggleBag then
        originalToggleBag = ToggleBag
        ToggleBag = function(bagID)
            if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive and not merchantActive then
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
            if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive and not merchantActive then
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
            if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive and not merchantActive then
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
                if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive and not merchantActive then
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
            if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive and not merchantActive then
                HideUI.Bags.ShowTemporary()
            end
        end)
        backpackButton.hideUIHooked = true
    end
    
    -- Create frame to listen for merchant events
    if not merchantFrame then
        merchantFrame = CreateFrame("Frame")
        merchantFrame:RegisterEvent("MERCHANT_SHOW")
        merchantFrame:RegisterEvent("MERCHANT_CLOSED")
        
        merchantFrame:SetScript("OnEvent", function(self, event, ...)
            DebugPrint("Merchant event received: " .. event)
            
            if event == "MERCHANT_SHOW" then
                DebugPrint("Merchant opened")
                HideUI.Bags.ShowForMerchant()
            elseif event == "MERCHANT_CLOSED" then
                DebugPrint("Merchant closed")
                HideUI.Bags.HideAfterMerchant()
            end
        end)
        
        print("|cFF00FF00HideUI:|r Merchant event handler created")
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
    if not HideUI.State.bagsHidden then return end
    
    -- Don't hide if at merchant
    if merchantActive then
        print("|cFF87CEEB HideUI:|r Bags kept visible (merchant)")
        return
    end
    
    -- Disable temporary mode
    HideUI.Bags.CancelTemporary()
    
    -- Immediately hide bag elements
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(0)
            if element.EnableMouse then
                element:EnableMouse(false)
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

-- ============================================================================
-- BAG DEBUG FUNCTIONS
-- ============================================================================

-- Debug function to test bag opening
function HideUI.Bags.DebugBagOpening()
    print("|cFF00FF00HideUI Bags Debug:|r")
    print("  Bags hidden state: " .. (HideUI.State.bagsHidden and "YES" or "NO"))
    print("  Temporary display active: " .. (bagTemporaryActive and "YES" or "NO"))
    print("  Merchant active: " .. (merchantActive and "YES" or "NO"))
    print("  Combat override active: " .. (HideUI.State.combatOverrideActive and "YES" or "NO"))
    print("  Timer active: " .. (bagTimer and "YES" or "NO"))
    
    -- Test available functions
    print("  ToggleAllBags available: " .. (ToggleAllBags and "YES" or "NO"))
    print("  ToggleBackpack available: " .. (ToggleBackpack and "YES" or "NO"))
    print("  originalToggleAllBags saved: " .. (originalToggleAllBags and "YES" or "NO"))
    
    -- Check merchant state in game
    local merchantShown = MerchantFrame and MerchantFrame:IsShown()
    print("  MerchantFrame shown: " .. (merchantShown and "YES" or "NO"))
    
    -- Check bag button
    local backpackButton = _G["MainMenuBarBackpackButton"]
    if backpackButton then
        print("  Backpack button found: YES")
        print("  Button visible: " .. (backpackButton:IsVisible() and "YES" or "NO"))
        print("  Button enabled: " .. (backpackButton:IsEnabled() and "YES" or "NO"))
        print("  Button alpha: " .. backpackButton:GetAlpha())
    else
        print("  Backpack button found: NO")
    end
    
    -- Check bag state
    local numBagsOpen = 0
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame and containerFrame:IsShown() then
            numBagsOpen = numBagsOpen + 1
            print("  ContainerFrame" .. i .. " open (alpha: " .. containerFrame:GetAlpha() .. ")")
        end
    end
    print("  Number of bags open: " .. numBagsOpen)
end

-- ============================================================================
-- MERCHANT MANAGEMENT
-- ============================================================================

-- Show bags when talking to merchant
function HideUI.Bags.ShowForMerchant()
    if not HideUI.State.bagsHidden then return end
    
    DebugPrint("ShowForMerchant called")
    
    merchantActive = true
    
    -- Cancel ALL timers and modes in progress
    if bagTimer then
        bagTimer:Cancel()
        bagTimer = nil
        DebugPrint("Bag timer canceled")
    end
    
    -- Force disable temporary mode
    if bagTemporaryActive then
        bagTemporaryActive = false
        DebugPrint("Temporary mode disabled")
    end
    
    -- Show bag elements
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
            if element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Automatically open bags if not already open
    local numBagsOpen = 0
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame and containerFrame:IsShown() then
            numBagsOpen = numBagsOpen + 1
            containerFrame:SetAlpha(1)
            containerFrame:EnableMouse(true)
        end
    end
    
    DebugPrint(numBagsOpen .. " bags already open")
    
    -- If no bags are open, open them
    if numBagsOpen == 0 then
        C_Timer.After(0.1, function()
            if not merchantActive then
                DebugPrint("Merchant closed before opening bags")
                return
            end
            
            if originalToggleAllBags then
                DebugPrint("Opening with originalToggleAllBags")
                originalToggleAllBags()
            elseif ToggleAllBags then
                DebugPrint("Opening with ToggleAllBags")
                local tempBagsHidden = HideUI.State.bagsHidden
                local tempMerchantActive = merchantActive
                HideUI.State.bagsHidden = false
                merchantActive = false
                ToggleAllBags()
                HideUI.State.bagsHidden = tempBagsHidden
                merchantActive = tempMerchantActive
            end
        end)
        
        -- Ensure bags are visible after opening
        C_Timer.After(0.3, function()
            if not merchantActive then
                DebugPrint("Merchant closed before final check")
                return
            end
            
            for i = 1, 13 do
                local containerFrame = _G["ContainerFrame"..i]
                if containerFrame and containerFrame:IsShown() then
                    containerFrame:SetAlpha(1)
                    containerFrame:EnableMouse(true)
                    DebugPrint("ContainerFrame" .. i .. " forced visible")
                end
            end
        end)
    end
    
    print("|cFF87CEEB HideUI:|r Bags shown for merchant")
end

-- Hide bags when leaving merchant
function HideUI.Bags.HideAfterMerchant()
    if not merchantActive then 
        DebugPrint("HideAfterMerchant called but merchant already inactive")
        return 
    end
    
    DebugPrint("HideAfterMerchant called, disabling merchant mode")
    merchantActive = false
    
    -- If bags are supposed to be hidden, hide them instantly
    if HideUI.State.bagsHidden then
        DebugPrint("Hiding bags because bagsHidden = true")
        HideUI.Bags.HideAfterDelay()
    else
        DebugPrint("No hiding because bagsHidden = false")
    end
    
    print("|cFF87CEEB HideUI:|r Merchant closed, bags hidden instantly")
end

-- Check if currently at merchant
function HideUI.Bags.IsMerchantActive()
    return merchantActive
end

-- Enable/disable debug mode for bags
function HideUI.Bags.SetDebugMode(enabled)
    debugMode = enabled
    if enabled then
        print("|cFF00FF00HideUI:|r Bag debug enabled")
    else
        print("|cFF00FF00HideUI:|r Bag debug disabled")
    end
end