-- Core.lua
-- Main module for HideUI Elements

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
    inCombat = false,
    combatOverrideActive = false,
    originalAlphas = {},
    autoHideOnStartup = true,
    addonEnabled = true
}

-- Main frame
local frame = CreateFrame("Frame", "HideUIElementsFrame")

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================

-- NOUVEAU: S'assurer que les éléments système critiques sont toujours visibles
function HideUI.Core.EnsureCriticalElementsVisible()
    local criticalElements = {
        "GameMenuFrame",
        "InterfaceOptionsFrame", 
        "VideoOptionsFrame",
        "AudioOptionsFrame",
        "ChatConfigFrame",
        "KeyBindingFrame",
        "MacroFrame"
    }
    
    for _, elementName in pairs(criticalElements) do
        local element = _G[elementName]
        if element then
            -- S'assurer que l'élément a une alpha normale s'il est visible
            if element:IsShown() and element:GetAlpha() < 0.1 then
                element:SetAlpha(1)
            end
        end
    end
end

-- Save original alpha values
function HideUI.Core.SaveOriginalAlphas()
    local state = HideUI.State
    local config = HideUI.Config
    
    -- Check that configuration is loaded
    if not config then
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
end

-- Apply hide/show to an element list
function HideUI.Core.ToggleElementList(elementList, isHidden, elementType)
    local state = HideUI.State
    
    -- Check that element list exists
    if not elementList then
        return
    end
    
    -- Éléments à ne JAMAIS cacher (protection système)
    local protectedElements = {
        "GameMenuFrame",
        "InterfaceOptionsFrame", 
        "VideoOptionsFrame",
        "AudioOptionsFrame",
        "ChatConfigFrame",
        "KeyBindingFrame",
        "MacroFrame",
        "UIParent",
        "WorldFrame"
    }
    
    for _, elementName in pairs(elementList) do
        -- Vérifier si l'élément est protégé
        local isProtected = false
        for _, protected in pairs(protectedElements) do
            if elementName == protected then
                isProtected = true
                break
            end
        end
        
        if not isProtected then
            local element = _G[elementName]
            if element then
                if isHidden then
                    -- Seulement changer l'alpha, NE JAMAIS désactiver EnableMouse
                    element:SetAlpha(0)
                else
                    local originalAlpha = state.originalAlphas[elementName] or 1
                    element:SetAlpha(originalAlpha)
                end
            end
        end
    end
end

-- Toggle action bars
function HideUI.Core.ToggleActionBars()
    if not HideUI.State.addonEnabled then return end
    
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.barsHidden = not HideUI.State.barsHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.actionBars then
        HideUI.Core.ToggleElementList(HideUI.Config.actionBars, HideUI.State.barsHidden, "bars")
        -- Gestion spéciale pour MainMenuBar
        HideUI.Core.ToggleMainMenuBar(HideUI.State.barsHidden)
    end
end

-- Toggle chat
function HideUI.Core.ToggleChat()
    if not HideUI.State.addonEnabled then return end
    
    HideUI.State.chatHidden = not HideUI.State.chatHidden
    
    -- Delegate to Chat module
    if HideUI.Chat then
        HideUI.Chat.ApplyToggle(HideUI.State.chatHidden)
    end
end

-- Toggle interface elements
function HideUI.Core.ToggleUIElements()
    if not HideUI.State.addonEnabled then return end
    
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.uiHidden = not HideUI.State.uiHidden
    
    if not HideUI.State.combatOverrideActive and HideUI.Config and HideUI.Config.uiElements then
        HideUI.Core.ToggleElementList(HideUI.Config.uiElements, HideUI.State.uiHidden, "ui")
    end
    
    -- Gestion spéciale pour le targeting
    if HideUI.Targeting then
        if HideUI.State.uiHidden then
            -- Si on cache l'UI et qu'on n'a pas de cible, cacher le target frame
            if not UnitExists("target") then
                HideUI.Targeting.ForceHide()
            end
        else
            -- Si on montre l'UI, appliquer l'état normal du target frame
            HideUI.Targeting.ApplyToggle(false)
        end
    end
end

-- Toggle bags
function HideUI.Core.ToggleBags()
    if not HideUI.State.addonEnabled then return end
    
    HideUI.Core.SaveOriginalAlphas()
    HideUI.State.bagsHidden = not HideUI.State.bagsHidden
    
    -- Delegate to Bags module
    if HideUI.Bags then
        HideUI.Bags.ApplyToggle(HideUI.State.bagsHidden)
    else
        -- Fallback si le module Bags n'est pas disponible
        if HideUI.Config and HideUI.Config.bagElements then
            HideUI.Core.ToggleElementList(HideUI.Config.bagElements, HideUI.State.bagsHidden, "bags")
        end
    end
end

-- Toggle everything (même logique que ShowAll mais garde le nom pour compatibilité)
function HideUI.Core.ToggleAll()
    HideUI.Core.ShowAll()  -- Utilise la nouvelle logique smart switch
end

-- Show everything or Hide everything (smart switch)
function HideUI.Core.ShowAll()
    if not HideUI.State.addonEnabled then return end
    
    local state = HideUI.State
    
    -- Déterminer si on doit montrer ou cacher basé sur l'état actuel
    local shouldHide = not (state.barsHidden or state.chatHidden or state.uiHidden or state.sideBarHidden or state.bagsHidden)
    
    if shouldHide then
        -- Si tout est visible, tout cacher
        if not state.barsHidden then HideUI.Core.ToggleActionBars() end
        if not state.chatHidden then HideUI.Core.ToggleChat() end
        if not state.uiHidden then HideUI.Core.ToggleUIElements() end
        if not state.bagsHidden then HideUI.Core.ToggleBags() end
        if not state.sideBarHidden then 
            state.sideBarHidden = true
            if not state.combatOverrideActive and HideUI.Config and HideUI.Config.sideActionBars then
                HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, true, "sideBars")
            end
        end
    else
        -- Si quelque chose est caché, tout montrer
        if state.barsHidden then HideUI.Core.ToggleActionBars() end
        if state.chatHidden then HideUI.Core.ToggleChat() end
        if state.uiHidden then HideUI.Core.ToggleUIElements() end
        if state.bagsHidden then HideUI.Core.ToggleBags() end
        if state.sideBarHidden then 
            state.sideBarHidden = false
            if not state.combatOverrideActive and HideUI.Config and HideUI.Config.sideActionBars then
                HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, false, "sideBars")
            end
        end
    end
end

-- Gestion spéciale pour MainMenuBar (éviter les conflits clavier)
function HideUI.Core.ToggleMainMenuBar(isHidden)
    local elements = {"MainMenuBar", "MainMenuBarArtFrame"}
    
    for _, elementName in pairs(elements) do
        local element = _G[elementName]
        if element then
            if isHidden then
                -- Seulement alpha, pas EnableMouse pour éviter les conflits clavier
                element:SetAlpha(0)
            else
                local originalAlpha = HideUI.State.originalAlphas[elementName] or 1
                element:SetAlpha(originalAlpha)
            end
        end
    end
end

-- Smart toggle pour raccourci clavier (force hide/show selon l'état)
function HideUI.Core.SmartToggle()
    if not HideUI.State.addonEnabled then return end
    
    local state = HideUI.State
    
    -- Détecter si l'interface est actuellement cachée ou visible
    local isAnyHidden = state.barsHidden or state.chatHidden or state.uiHidden or state.sideBarHidden or state.bagsHidden
    
    if isAnyHidden then
        -- Si quelque chose est caché → FORCE SHOW ALL
        HideUI.Core.ForceShowAll()
    else
        -- Si tout est visible → FORCE HIDE ALL
        HideUI.Core.ForceHideAll()
    end
end

-- Force hide all (sans conditions)
function HideUI.Core.ForceHideAll()
    if not HideUI.State.addonEnabled then return end
    
    local state = HideUI.State
    
    -- Forcer le cache de tous les éléments
    if not state.barsHidden then
        state.barsHidden = true
        if HideUI.Config and HideUI.Config.actionBars then
            HideUI.Core.ToggleElementList(HideUI.Config.actionBars, true, "bars")
        end
        HideUI.Core.ToggleMainMenuBar(true)
    end
    
    if not state.chatHidden then
        state.chatHidden = true
        if HideUI.Chat then
            HideUI.Chat.ApplyToggle(true)
        end
    end
    
    if not state.uiHidden then
        state.uiHidden = true
        if HideUI.Config and HideUI.Config.uiElements then
            HideUI.Core.ToggleElementList(HideUI.Config.uiElements, true, "ui")
        end
        if HideUI.Targeting and not UnitExists("target") then
            HideUI.Targeting.ForceHide()
        end
    end
    
    if not state.bagsHidden then
        state.bagsHidden = true
        if HideUI.Bags then
            HideUI.Bags.ApplyToggle(true)
        end
    end
    
    if not state.sideBarHidden then
        state.sideBarHidden = true
        if HideUI.Config and HideUI.Config.sideActionBars then
            HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, true, "sideBars")
        end
    end
end

-- Force show all (version améliorée)
function HideUI.Core.ForceShowAll()
    local state = HideUI.State
    
    -- Forcer l'affichage de tous les éléments
    if state.barsHidden then
        state.barsHidden = false
        if HideUI.Config and HideUI.Config.actionBars then
            HideUI.Core.ToggleElementList(HideUI.Config.actionBars, false, "bars")
        end
        HideUI.Core.ToggleMainMenuBar(false)
    end
    
    if state.chatHidden then
        state.chatHidden = false
        if HideUI.Chat then
            HideUI.Chat.ApplyToggle(false)
        end
    end
    
    if state.uiHidden then
        state.uiHidden = false
        if HideUI.Config and HideUI.Config.uiElements then
            HideUI.Core.ToggleElementList(HideUI.Config.uiElements, false, "ui")
        end
        if HideUI.Targeting then
            HideUI.Targeting.ApplyToggle(false)
        end
    end
    
    if state.bagsHidden then
        state.bagsHidden = false
        if HideUI.Bags then
            HideUI.Bags.ApplyToggle(false)
        end
    end
    
    if state.sideBarHidden then
        state.sideBarHidden = false
        if HideUI.Config and HideUI.Config.sideActionBars then
            HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, false, "sideBars")
        end
    end
    
    -- Version étendue pour désactivation addon
    if not HideUI.State.addonEnabled then
        -- Restore all elements to visible state
        local config = HideUI.Config
        if not config then return end
        
        -- Action bars
        if config.actionBars then
            for _, barName in pairs(config.actionBars) do
                local bar = _G[barName]
                if bar then
                    local originalAlpha = HideUI.State.originalAlphas[barName] or 1
                    bar:SetAlpha(originalAlpha)
                end
            end
        end
        
        -- Main menu bar
        HideUI.Core.ToggleMainMenuBar(false)
        
        -- UI elements
        if config.uiElements then
            for _, elementName in pairs(config.uiElements) do
                local element = _G[elementName]
                if element then
                    local originalAlpha = HideUI.State.originalAlphas[elementName] or 1
                    element:SetAlpha(originalAlpha)
                end
            end
        end
        
        -- Side bars
        if config.sideActionBars then
            for _, barName in pairs(config.sideActionBars) do
                local bar = _G[barName]
                if bar then
                    local originalAlpha = HideUI.State.originalAlphas[barName] or 1
                    bar:SetAlpha(originalAlpha)
                end
            end
        end
        
        -- Chat
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame"..i]
            if chatFrame then
                chatFrame:SetAlpha(1)
            end
            local chatTab = _G["ChatFrame"..i.."Tab"]
            if chatTab then
                chatTab:SetAlpha(1)
            end
        end
        
        if config.chatElements then
            for _, elementName in pairs(config.chatElements) do
                local element = _G[elementName]
                if element then
                    element:SetAlpha(1)
                end
            end
        end
        
        -- Bags
        if config.bagElements then
            for _, elementName in pairs(config.bagElements) do
                local element = _G[elementName]
                if element then
                    element:SetAlpha(1)
                end
            end
        end
        
        -- Bag windows
        for i = 1, 13 do
            local containerFrame = _G["ContainerFrame"..i]
            if containerFrame and containerFrame:IsShown() then
                containerFrame:SetAlpha(1)
            end
        end
        
        -- Target frame
        local targetFrame = _G["TargetFrame"]
        if targetFrame then
            targetFrame:SetAlpha(1)
        end
        
        -- Critical elements
        HideUI.Core.EnsureCriticalElementsVisible()
    end
end

-- Activer/désactiver l'addon complètement
function HideUI.Core.ToggleAddon()
    HideUI.State.addonEnabled = not HideUI.State.addonEnabled
    
    if HideUI.State.addonEnabled then
    else        
        -- Force afficher tout et désactiver tous les systèmes
        HideUI.Core.ForceShowAll()
        
        -- Annuler tous les timers en cours
        if HideUI.Hover then
            HideUI.Hover.CancelAllTimers()
        end
        if HideUI.Chat then
            HideUI.Chat.CancelTemporary()
        end
        if HideUI.Bags then
            HideUI.Bags.CancelTemporary()
        end
        if HideUI.Targeting then
            HideUI.Targeting.CancelTemporary()
        end
        
        -- Réinitialiser les états mais garder addon désactivé
        local addonState = HideUI.State.addonEnabled  -- Sauvegarder
        HideUI.State.barsHidden = false
        HideUI.State.chatHidden = false
        HideUI.State.uiHidden = false
        HideUI.State.sideBarHidden = false
        HideUI.State.bagsHidden = false
        HideUI.State.combatOverrideActive = false
        HideUI.State.addonEnabled = addonState  -- Restaurer
    end
end

-- Activer/désactiver l'auto-hide au démarrage
function HideUI.Core.ToggleAutoHide()
    HideUI.State.autoHideOnStartup = not HideUI.State.autoHideOnStartup
end

-- Cache automatiquement l'interface au démarrage
function HideUI.Core.AutoHideOnStartup()
    if not HideUI.State.autoHideOnStartup or not HideUI.State.addonEnabled then
        return
    end
    
    -- Attendre que tous les éléments soient chargés
    C_Timer.After(3, function()
        -- Vérifier qu'on n'est pas en combat
        if not InCombatLockdown() then
            -- Sauvegarder les alphas originaux avant de cacher
            HideUI.Core.SaveOriginalAlphas()
            
            -- Cacher tous les éléments
            HideUI.State.barsHidden = true
            HideUI.State.chatHidden = true
            HideUI.State.uiHidden = true
            HideUI.State.sideBarHidden = true
            HideUI.State.bagsHidden = true
            
            -- Appliquer le cache immédiatement
            if HideUI.Config and HideUI.Config.actionBars then
                HideUI.Core.ToggleElementList(HideUI.Config.actionBars, true, "bars")
            end
            
            if HideUI.Chat then
                HideUI.Chat.ApplyToggle(true)
            end
            
            if HideUI.Config and HideUI.Config.uiElements then
                HideUI.Core.ToggleElementList(HideUI.Config.uiElements, true, "ui")
            end
            
            if HideUI.Config and HideUI.Config.sideActionBars then
                HideUI.Core.ToggleElementList(HideUI.Config.sideActionBars, true, "sideBars")
            end
            
            -- Cacher les sacs
            if HideUI.Bags then
                HideUI.Bags.ApplyToggle(true)
            elseif HideUI.Config and HideUI.Config.bagElements then
                HideUI.Core.ToggleElementList(HideUI.Config.bagElements, true, "bags")
            end
        else
            -- Si en combat, réessayer dans 5 secondes
            C_Timer.After(5, HideUI.Core.AutoHideOnStartup)
        end
    end)
end

-- ============================================================================
-- EVENT MANAGEMENT
-- ============================================================================
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
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
            if HideUI.Targeting then HideUI.Targeting.SetupEvents() end
            if HideUI.Bags then HideUI.Bags.SetupHooks() end
        end)
        C_Timer.After(5, function()
            if HideUI.Hover then HideUI.Hover.Initialize() end
        end)
        
        -- Auto-hide au démarrage
        HideUI.Core.AutoHideOnStartup()
        
        -- S'assurer que les éléments critiques restent visibles
        C_Timer.NewTicker(2, function()
            HideUI.Core.EnsureCriticalElementsVisible()
        end)
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Déclenché à chaque fois qu'on entre dans le monde (y compris après /reload)
        local isInitialLogin, isReloadingUi = ...
        
        if isReloadingUi and HideUI.State.autoHideOnStartup then
            -- Si c'est un reload, relancer l'auto-hide
            HideUI.Core.AutoHideOnStartup()
        end
        
        -- S'assurer que les éléments critiques sont visibles après reload
        C_Timer.After(1, function()
            HideUI.Core.EnsureCriticalElementsVisible()
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
function HideUI_ShowAll() HideUI.Core.ShowAll() end
function HideUI_ToggleAutoHide() HideUI.Core.ToggleAutoHide() end
function HideUI_ToggleAddon() HideUI.Core.ToggleAddon() end
function HideUI_SmartToggle() HideUI.Core.SmartToggle() end

-- Fonctions globales pour les sacs
function HideUI_ShowBagsTemporary() 
    if HideUI.Bags and HideUI.Bags.ShowTemporary then 
        HideUI.Bags.ShowTemporary() 
    else
        -- Fallback simple : utiliser la fonction Blizzard
        if ToggleAllBags then
            ToggleAllBags()
        end
    end 
end
function HideUI_ToggleBags() 
    if HideUI.Bags and HideUI.Bags.ShowTemporary then 
        HideUI.Bags.ShowTemporary() 
    else
        -- Fallback simple
        if ToggleAllBags then
            ToggleAllBags()
        end
    end 
end