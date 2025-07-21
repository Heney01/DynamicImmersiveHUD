-- Chat.lua
-- Module de gestion du chat

HideUI = HideUI or {}
HideUI.Chat = {}

-- Variables locales
local chatTemporaryActive = false
local chatTimer = nil

-- ============================================================================
-- FONCTIONS PRINCIPALES
-- ============================================================================

-- Applique le basculement du chat
function HideUI.Chat.ApplyToggle(isHidden)
    -- Annuler le chat temporaire si actif
    if chatTemporaryActive then
        chatTemporaryActive = false
        if chatTimer then
            chatTimer:Cancel()
        end
    end
    
    -- Si en combat, ne pas appliquer immédiatement
    if not HideUI.State.combatOverrideActive then
        -- Fenêtres de chat principales
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame"..i]
            if chatFrame then
                if isHidden then
                    chatFrame:SetAlpha(0)
                    chatFrame:EnableMouse(false)
                else
                    chatFrame:SetAlpha(1)
                    chatFrame:EnableMouse(true)
                end
            end
            
            -- Onglets de chat
            local chatTab = _G["ChatFrame"..i.."Tab"]
            if chatTab then
                chatTab:SetAlpha(isHidden and 0 or 1)
            end
        end
        
        -- Éléments additionnels du chat
        if HideUI.Core then
            HideUI.Core.ToggleElementList(HideUI.Config.chatElements, isHidden, "chat")
        end
    end
end

-- Affiche temporairement le chat
function HideUI.Chat.ShowTemporary()
    if not HideUI.State.chatHidden then return end
    
    chatTemporaryActive = true
    
    -- Annuler le timer précédent s'il existe
    if chatTimer then
        chatTimer:Cancel()
    end
    
    -- Afficher le chat immédiatement
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
    
    -- Programmer le masquage automatique dans 8 secondes
    chatTimer = C_Timer.NewTimer(8, function()
        HideUI.Chat.HideAfterDelay()
    end)
end

-- Masque le chat après le délai
function HideUI.Chat.HideAfterDelay()
    if chatTemporaryActive and HideUI.State.chatHidden and not HideUI.State.combatOverrideActive then
        -- Fondu rapide du chat
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
            
            -- Appliquer le fondu au chat
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

-- Affiche le chat au survol
function HideUI.Chat.ShowOnHover()
    if not HideUI.State.chatHidden or HideUI.State.combatOverrideActive then return end
    
    -- Afficher le chat
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

-- Masque le chat après le survol
function HideUI.Chat.HideAfterHover()
    if not HideUI.State.chatHidden or chatTemporaryActive or HideUI.State.combatOverrideActive then return end
    
    -- Fondu du chat
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
-- GESTION DES ÉVÉNEMENTS DE CHAT
-- ============================================================================

-- Gestionnaire d'événements de chat
function HideUI.Chat.OnChatMessage(event, message, sender, ...)
    if HideUI.Config.importantChatTypes[event] then
        HideUI.Chat.ShowTemporary()
    end
end

-- ============================================================================
-- HOOKS DES FONCTIONS DE CHAT
-- ============================================================================

function HideUI.Chat.SetupHooks()
    -- Hook de la fonction d'envoi de messages
    local originalSendChatMessage = SendChatMessage
    SendChatMessage = function(msg, chatType, ...)
        if msg and msg:trim() ~= "" then
            -- Message envoyé, afficher le chat temporairement
            HideUI.Chat.ShowTemporary()
        end
        return originalSendChatMessage(msg, chatType, ...)
    end
    
    -- Enregistrer les événements de chat importants
    local frame = CreateFrame("Frame")
    for eventType, _ in pairs(HideUI.Config.importantChatTypes) do
        frame:RegisterEvent(eventType)
    end
    
    frame:SetScript("OnEvent", function(self, event, ...)
        HideUI.Chat.OnChatMessage(event, ...)
    end)
end

-- ============================================================================
-- FONCTIONS D'ÉTAT
-- ============================================================================

-- Vérifie si l'affichage temporaire est actif
function HideUI.Chat.IsTemporaryActive()
    return chatTemporaryActive
end

-- Annule l'affichage temporaire
function HideUI.Chat.CancelTemporary()
    if chatTemporaryActive then
        chatTemporaryActive = false
        if chatTimer then
            chatTimer:Cancel()
            chatTimer = nil
        end
    end
end