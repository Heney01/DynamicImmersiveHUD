-- Chat.lua
-- Chat management module

HideUI = HideUI or {}
HideUI.Chat = {}

-- Local variables
local chatTemporaryActive = false
local chatTimer = nil

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- Apply chat toggle
function HideUI.Chat.ApplyToggle(isHidden)
    -- Si l'addon est désactivé, ne rien faire
    if HideUI.State and not HideUI.State.addonEnabled then
        return
    end
    
    -- Cancel temporary chat if active
    if chatTemporaryActive then
        chatTemporaryActive = false
        if chatTimer then
            chatTimer:Cancel()
        end
    end
    
    -- If in combat, don't apply immediately
    if not HideUI.State.combatOverrideActive then
        -- Main chat windows
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame"..i]
            if chatFrame then
                if isHidden then
                    chatFrame:SetAlpha(0)
                else
                    chatFrame:SetAlpha(1)
                end
            end
            
            -- Chat tabs
            local chatTab = _G["ChatFrame"..i.."Tab"]
            if chatTab then
                chatTab:SetAlpha(isHidden and 0 or 1)
            end
        end
        
        -- Additional chat elements
        if HideUI.Core then
            HideUI.Core.ToggleElementList(HideUI.Config.chatElements, isHidden, "chat")
        end
    end
end

-- Show chat temporarily
function HideUI.Chat.ShowTemporary()
    if not HideUI.State.chatHidden then return end
    
    chatTemporaryActive = true
    
    -- Cancel previous timer if exists
    if chatTimer then
        chatTimer:Cancel()
    end
    
    -- Show chat immediately
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            chatFrame:SetAlpha(1)
            chatFrame:EnableMouse(true)
        end
        local chatTab = _G["ChatFrame"..i.."Tab"]
        if chatTab then
            chatTab:SetAlpha(1)
        end
    end
    
    for _, elementName in pairs(HideUI.Config.chatElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
            if element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Schedule automatic hiding in 8 seconds
    chatTimer = C_Timer.NewTimer(8, function()
        HideUI.Chat.HideAfterDelay()
    end)
end

-- Hide chat after delay
function HideUI.Chat.HideAfterDelay()
    if chatTemporaryActive and HideUI.State.chatHidden and not HideUI.State.combatOverrideActive then
        -- Quick chat fade
        local fadeSteps = 8
        local currentStep = 0
        
        local chatFadeTimer = C_Timer.NewTicker(0.1, function(timer)
            currentStep = currentStep + 1
            local alpha = 1 - (currentStep / fadeSteps)
            
            if alpha <= 0 then
                alpha = 0
                chatTemporaryActive = false
                timer:Cancel()
            end
            
            -- Apply fade to chat
            for i = 1, NUM_CHAT_WINDOWS do
                local chatFrame = _G["ChatFrame"..i]
                if chatFrame then
                    chatFrame:SetAlpha(alpha)
                    if alpha <= 0 then
                        chatFrame:EnableMouse(false)
                    end
                end
                local chatTab = _G["ChatFrame"..i.."Tab"]
                if chatTab then
                    chatTab:SetAlpha(alpha)
                end
            end
            
            for _, elementName in pairs(HideUI.Config.chatElements) do
                local element = _G[elementName]
                if element then
                    element:SetAlpha(alpha)
                    if alpha <= 0 and element.EnableMouse then
                        element:EnableMouse(false)
                    end
                end
            end
            
            if currentStep >= fadeSteps then
                timer:Cancel()
            end
        end)
    end
end

-- Show chat on hover
function HideUI.Chat.ShowOnHover()
    if not HideUI.State.chatHidden or HideUI.State.combatOverrideActive then return end
    
    -- Show chat
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            chatFrame:SetAlpha(1)
            chatFrame:EnableMouse(true)
        end
        local chatTab = _G["ChatFrame"..i.."Tab"]
        if chatTab then
            chatTab:SetAlpha(1)
        end
    end
    
    for _, elementName in pairs(HideUI.Config.chatElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
            if element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
end

-- Hide chat after hover
function HideUI.Chat.HideAfterHover()
    if not HideUI.State.chatHidden or chatTemporaryActive or HideUI.State.combatOverrideActive then return end
    
    -- Chat fade
    local fadeSteps = 6
    local currentStep = 0
    
    local chatFadeTimer = C_Timer.NewTicker(0.1, function(timer)
        currentStep = currentStep + 1
        local alpha = 1 - (currentStep / fadeSteps)
        
        if alpha <= 0 then
            alpha = 0
            timer:Cancel()
        end
        
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame"..i]
            if chatFrame then
                chatFrame:SetAlpha(alpha)
                if alpha <= 0 then
                    chatFrame:EnableMouse(false)
                end
            end
            local chatTab = _G["ChatFrame"..i.."Tab"]
            if chatTab then
                chatTab:SetAlpha(alpha)
            end
        end
        
        for _, elementName in pairs(HideUI.Config.chatElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
                if alpha <= 0 and element.EnableMouse then
                    element:EnableMouse(false)
                end
            end
        end
    end)
end

-- ============================================================================
-- CHAT EVENT MANAGEMENT
-- ============================================================================

-- Chat event handler
function HideUI.Chat.OnChatMessage(event, message, sender, ...)
    if HideUI.Config.importantChatTypes[event] then
        HideUI.Chat.ShowTemporary()
    end
end

-- ============================================================================
-- CHAT FUNCTION HOOKS
-- ============================================================================

function HideUI.Chat.SetupHooks()
    -- Hook message sending function
    local originalSendChatMessage = SendChatMessage
    SendChatMessage = function(msg, chatType, ...)
        if msg and msg:trim() ~= "" then
            -- Message sent, show chat temporarily
            HideUI.Chat.ShowTemporary()
        end
        return originalSendChatMessage(msg, chatType, ...)
    end
    
    -- Register important chat events
    local frame = CreateFrame("Frame")
    for eventType, _ in pairs(HideUI.Config.importantChatTypes) do
        frame:RegisterEvent(eventType)
    end
    
    frame:SetScript("OnEvent", function(self, event, ...)
        HideUI.Chat.OnChatMessage(event, ...)
    end)
end

-- ============================================================================
-- STATE FUNCTIONS
-- ============================================================================

-- Check if temporary display is active
function HideUI.Chat.IsTemporaryActive()
    return chatTemporaryActive
end

-- Cancel temporary display
function HideUI.Chat.CancelTemporary()
    if chatTemporaryActive then
        chatTemporaryActive = false
        if chatTimer then
            chatTimer:Cancel()
            chatTimer = nil
        end
    end
end