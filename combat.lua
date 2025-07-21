-- Combat.lua
-- Module de gestion du combat et du fondu

HideUI = HideUI or {}
HideUI.Combat = {}

-- Variables locales
local fadeTimer = nil

-- ============================================================================
-- FONCTIONS PRINCIPALES
-- ============================================================================

-- Applique un niveau d'alpha à tous les éléments
function HideUI.Combat.ApplyFadeToAllElements(alpha)
    -- Vérifier que la configuration est disponible
    if not HideUI.Config then
        print("|cFFFF0000HideUI Combat:|r Configuration non chargée, impossible d'appliquer le fondu")
        return
    end
    
    -- Barres d'action
    if HideUI.Config.actionBars then
        for _, barName in pairs(HideUI.Config.actionBars) do
            local bar = _G[barName]
            if bar then
                bar:SetAlpha(alpha)
            end
        end
    end
    
    -- Éléments d'UI
    if HideUI.Config.uiElements then
        for _, elementName in pairs(HideUI.Config.uiElements) do
            local element = _G[elementName]
            if element then
                element:SetAlpha(alpha)
            end
        end
    end
    
    -- Éléments de sacs
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
    
    -- Fenêtres de sacs
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame then
            containerFrame:SetAlpha(alpha)
        end
    end
end

-- Applique l'état masqué complet
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

-- Affiche immédiatement l'interface en combat
function HideUI.Combat.ShowUIForCombat()
    HideUI.State.combatOverrideActive = true
    
    if fadeTimer then
        fadeTimer:Cancel()
    end
    
    -- Affichage immédiat avec alpha = 1
    HideUI.Combat.ApplyFadeToAllElements(1)
    
    -- Vérifier que la configuration est disponible avant de réactiver les interactions
    if not HideUI.Config then
        print("|cFFFF0000HideUI Combat:|r Configuration non chargée, interactions souris non restaurées")
        return
    end
    
    -- Réactiver les interactions souris
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
    
    -- Réactiver les micro-menus
    if HideUI.Config.microMenuElements then
        for _, elementName in pairs(HideUI.Config.microMenuElements) do
            local element = _G[elementName]
            if element and element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Réactiver le chat
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
    
    -- Réactiver les fenêtres de sacs
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame and containerFrame.EnableMouse then
            containerFrame:EnableMouse(true)
        end
    end
end

-- Fonction de fondu progressif
function HideUI.Combat.FadeOutUI()
    -- Vérifier que la configuration est chargée
    if not HideUI.Config then
        print("|cFFFF0000HideUI Combat:|r Configuration non chargée, fondu annulé")
        return
    end
    
    if fadeTimer then
        fadeTimer:Cancel()
    end
    
    -- Délai réduit à 1 seconde après la fin du combat
    fadeTimer = C_Timer.NewTimer(1, function()
        if not HideUI.State.inCombat and HideUI.State.combatOverrideActive then
            -- Fondu progressif plus rapide sur 0.8 secondes
            local fadeSteps = 10
            local currentStep = 0
            
            local fadeOutTimer = C_Timer.NewTicker(0.08, function(timer)
                currentStep = currentStep + 1
                local alpha = 1 - (currentStep / fadeSteps)
                
                if alpha <= 0 then
                    alpha = 0
                    HideUI.State.combatOverrideActive = false
                    -- Restaurer l'état masqué complet
                    local state = HideUI.State
                    if state.barsHidden or state.chatHidden or state.uiHidden or state.bagsHidden or state.microMenuHidden then
                        HideUI.Combat.ApplyHiddenState()
                    end
                    -- Annuler le timer à la fin
                    timer:Cancel()
                else
                    -- Appliquer le fondu à tous les éléments
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
-- GESTIONNAIRES D'ÉVÉNEMENTS
-- ============================================================================

-- Gestionnaire d'entrée en combat
function HideUI.Combat.OnEnterCombat()
    local state = HideUI.State
    
    if state.barsHidden or state.chatHidden or state.uiHidden or state.bagsHidden then
        HideUI.Combat.ShowUIForCombat()
        print("|cFFFF6600HideUI:|r Interface affichée pour le combat")
    end
end

-- Gestionnaire de sortie de combat
function HideUI.Combat.OnLeaveCombat()
    if HideUI.State.combatOverrideActive then
        print("|cFF32CD32HideUI:|r Combat terminé - fondu dans 1 seconde...")
        HideUI.Combat.FadeOutUI()
    end
end