-- Core.lua
-- Module principal de HideUI Elements
-- Gère l'initialisation et la coordination des modules

local addonName, addon = ...

-- ============================================================================
-- NAMESPACE ET VARIABLES GLOBALES
-- ============================================================================
HideUI = HideUI or {}
HideUI.Core = {}

-- Variables d'état globales
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

-- Frame principal
local frame = CreateFrame("Frame", "HideUIElementsFrame")

-- ============================================================================
-- FONCTIONS PRINCIPALES
-- ============================================================================

-- Sauvegarde des valeurs alpha originales
function HideUI.Core.SaveOriginalAlphas()
    local state = HideUI.State
    local config = HideUI.Config
    
    -- Vérifier que la configuration est chargée
    if not config then
        print("|cFFFF0000HideUI:|r Configuration non chargée, report de la sauvegarde des alphas")
        return
    end
    
    -- Barres d'action
    if config.actionBars then
        for _, barName in pairs(config.actionBars) do
            local bar = _G[barName]
            if bar and not state.originalAlphas[barName] then
                state.originalAlphas[barName] = bar:GetAlpha()
            end
        end
    end
    
    -- Éléments d'UI
    if config.uiElements then
        for _, elementName in pairs(config.uiElements) do
            local element = _G[elementName]
            if element and not state.originalAlphas[elementName] then
                state.originalAlphas[elementName] = element:GetAlpha()
            end
        end
    end
    
    -- Éléments de sacs
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

-- Applique le masquage/affichage à une liste d'éléments
function HideUI.Core.ToggleElementList(elementList, isHidden, elementType)
    local state = HideUI.State
    
    -- Vérifier que la liste d'éléments existe
    if not elementList then
        print("|cFFFF0000HideUI:|r Liste d'éléments non trouvée pour " .. (elementType or "inconnu"))
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

-- Basculer les barres d'action
function HideUI.Core.ToggleActionBars()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.barsHidden = not HideUI.State.barsHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.actionBars then
        HideUI.Core.ToggleElementList(HideUI.Config.actionBars, HideUI.State.barsHidden, "bars")
    end
    
    local status = HideUI.State.barsHidden and "masquées" or "affichées"
    print("|cFF00FF00HideUI:|r Barres d'action " .. status)
end

-- Basculer le chat
function HideUI.Core.ToggleChat()
    HideUI.State.chatHidden = not HideUI.State.chatHidden
    
    -- Déléguer au module Chat
    if HideUI.Chat then
        HideUI.Chat.ApplyToggle(HideUI.State.chatHidden)
    end
    
    local status = HideUI.State.chatHidden and "masqué" or "affiché"
    print("|cFF00FF00HideUI:|r Chat " .. status)
end

-- Basculer les éléments d'interface
function HideUI.Core.ToggleUIElements()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.uiHidden = not HideUI.State.uiHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.uiElements then
        HideUI.Core.ToggleElementList(HideUI.Config.uiElements, HideUI.State.uiHidden, "ui")
    end
    
    local status = HideUI.State.uiHidden and "masqués" or "affichés"
    print("|cFF00FF00HideUI:|r Éléments d'interface " .. status)
end

-- Basculer les sacs
function HideUI.Core.ToggleBags()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.bagsHidden = not HideUI.State.bagsHidden
    
    -- Déléguer au module Bags
    if HideUI.Bags then
        HideUI.Bags.ApplyToggle(HideUI.State.bagsHidden)
    end
    
    local status = HideUI.State.bagsHidden and "masqués" or "affichés"
    print("|cFF00FF00HideUI:|r Sacs " .. status)
end

-- Basculer les micro-menus
function HideUI.Core.ToggleMicroMenu()
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.microMenuHidden = not HideUI.State.microMenuHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.microMenuElements then
        HideUI.Core.ToggleElementList(HideUI.Config.microMenuElements, HideUI.State.microMenuHidden, "microMenu")
    end
    
    local status = HideUI.State.microMenuHidden and "masqués" or "affichés"
    print("|cFF00FF00HideUI:|r Micro-menus " .. status)
end

-- Basculer tout
function HideUI.Core.ToggleAll()
    local state = HideUI.State
    
    if state.barsHidden or state.chatHidden or state.uiHidden or state.sideBarHidden or state.bagsHidden or state.microMenuHidden then
        -- Si quelque chose est masqué, tout afficher
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
            print("|cFF00FF00HideUI:|r Barres latérales affichées")
        end
    else
        -- Si tout est affiché, tout masquer
        HideUI.Core.ToggleActionBars()
        HideUI.Core.ToggleChat()
        HideUI.Core.ToggleUIElements()
        HideUI.Core.ToggleBags()
        HideUI.Core.ToggleMicroMenu()
        state.sideBarHidden = true
        if not state.combatOverrideActive and HideUI.Config and HideUI.Config.sideActionBars then
            HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, true, "sideBars")
        end
        print("|cFF00FF00HideUI:|r Barres latérales masquées")
    end
end

-- Tout afficher
function HideUI.Core.ShowAll()
    local state = HideUI.State
    
    if state.barsHidden then HideUI.Core.ToggleActionBars() end
    if state.chatHidden then HideUI.Core.ToggleChat() end
    if state.uiHidden then HideUI.Core.ToggleUIElements() end
    if state.bagsHidden then HideUI.Core.ToggleBags() end
    if state.microMenuHidden then HideUI.Core.ToggleMicroMenu() end
    print("|cFF00FF00HideUI:|r Interface restaurée")
end

-- ============================================================================
-- GESTION DES ÉVÉNEMENTS
-- ============================================================================
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entrée en combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Sortie de combat

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            print("|cFF00FF00Dynamic Immersive HUD|r v2.0 chargé avec succès !")
            print("Utilisez |cFFFFFF00/hideui|r ou la touche |cFFFFFF00<|r pour basculer l'interface")
            print("Utilisez la touche |cFFFFFF00B|r pour afficher temporairement les sacs")
            print("|cFF32CD32Combat automatique:|r L'interface s'affiche en combat et disparaît après")
            print("|cFF87CEEB Chat temporaire:|r Le chat s'affiche pour les messages importants")
            print("|cFFFFB6C1Survol intelligent:|r Chat, barres, sacs, micro-menus et quêtes s'affichent au survol")
        end
    elseif event == "PLAYER_LOGIN" then
        -- Attendre que tous les modules soient chargés avant de sauvegarder les alphas
        C_Timer.After(1, function()
            HideUI.Core.SaveOriginalAlphas()
        end)
        
        -- Initialiser les autres modules avec délai
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
        -- Entrée en combat
        HideUI.State.inCombat = true
        if HideUI.Combat then
            HideUI.Combat.OnEnterCombat()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Sortie de combat
        HideUI.State.inCombat = false
        if HideUI.Combat then
            HideUI.Combat.OnLeaveCombat()
        end
    end
end)

-- ============================================================================
-- FONCTIONS GLOBALES POUR LES KEYBINDINGS
-- ============================================================================
function HideUI_ToggleAll() HideUI.Core.ToggleAll() end
function HideUI_ToggleBars() HideUI.Core.ToggleActionBars() end
function HideUI_ToggleChat() HideUI.Core.ToggleChat() end
function HideUI_ToggleMicroMenu() HideUI.Core.ToggleMicroMenu() end
function HideUI_ShowBagsTemporary() 
    if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive then
        HideUI.Bags.ShowTemporary()
    elseif not HideUI.State.bagsHidden then
        -- Si les sacs ne sont pas masqués, comportement normal de la touche B
        if ToggleAllBags then
            ToggleAllBags()
        end
    end
end