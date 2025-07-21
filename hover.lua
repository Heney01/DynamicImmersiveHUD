-- Hover.lua
-- Module de gestion du survol intelligent

HideUI = HideUI or {}
HideUI.Hover = {}

-- Variables locales
local hoverTimers = {}
local hoverActiveElements = {}
local mouseCheckTimer = nil

-- ============================================================================
-- FONCTIONS PRINCIPALES
-- ============================================================================

-- Affiche temporairement un groupe d'éléments
function HideUI.Hover.ShowElementsOnHover(elementType)
    if HideUI.State.combatOverrideActive then return end
    
    -- Annuler le timer précédent pour ce type
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
        -- Afficher les barres principales (bas)
        for _, barName in pairs(HideUI.Config.mainActionBars) do
            local bar = _G[barName]
            if bar then
                bar:SetAlpha(1)
                if bar.EnableMouse then
                    bar:EnableMouse(true)
                end
            end
        end
        
        -- Afficher aussi les éléments de la barre principale
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
        -- Afficher les barres latérales uniquement
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
        -- Afficher les objectifs/quêtes
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
        -- Afficher les micro-menus
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

-- Masque les éléments après le délai
function HideUI.Hover.HideElementsAfterDelay(elementType, delay)
    hoverTimers[elementType] = C_Timer.NewTimer(delay, function()
        if not hoverActiveElements[elementType] then return end
        
        hoverActiveElements[elementType] = false
        
        if elementType == "chat" and HideUI.State.chatHidden then
            if HideUI.Chat then
                HideUI.Chat.HideAfterHover()
            end
            
        elseif elementType == "mainBars" and HideUI.State.barsHidden and not HideUI.State.combatOverrideActive then
            -- Fondu des barres principales avec éléments associés
            for _, barName in pairs(HideUI.Config.mainActionBars) do
                local bar = _G[barName]
                if bar then
                    bar:SetAlpha(0)
                    if bar.EnableMouse then
                        bar:EnableMouse(false)
                    end
                end
            end
            
            -- Masquer aussi les éléments de la barre principale
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
            -- Fondu des barres latérales
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
            -- Fondu des objectifs
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
            -- Fondu des micro-menus
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

-- Détecte si la souris est dans une zone
function HideUI.Hover.IsMouseInRegion(region)
    local mouseX, mouseY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    mouseX = mouseX / scale
    mouseY = mouseY / scale
    
    return mouseX >= region.left and mouseX <= region.right and 
           mouseY >= region.bottom and mouseY <= region.top
end

-- ============================================================================
-- INITIALISATION ET TIMER
-- ============================================================================

-- Initialise le système de survol
function HideUI.Hover.Initialize()
    -- Timer pour vérifier la position de la souris
    mouseCheckTimer = C_Timer.NewTicker(0.15, function()
        local state = HideUI.State
        
        if state.combatOverrideActive or 
           (not state.barsHidden and not state.chatHidden and not state.uiHidden and not state.sideBarHidden and not state.bagsHidden and not state.microMenuHidden) then
            return
        end
        
        -- Mettre à jour les zones de survol dynamiquement
        if HideUI.Config then
            HideUI.Config.UpdateHoverZones()
        end
        
        for zoneName, zoneData in pairs(HideUI.Config.hoverZones) do
            local isInZone = HideUI.Hover.IsMouseInRegion(zoneData.region)
            
            if isInZone then
                if not hoverActiveElements[zoneData.elements] then
                    HideUI.Hover.ShowElementsOnHover(zoneData.elements)
                    print("|cFFFFB6C1HideUI:|r " .. zoneData.elements .. " affiché au survol")
                end
                -- Annuler le timer de masquage si on survole encore
                if hoverTimers[zoneData.elements] then
                    hoverTimers[zoneData.elements]:Cancel()
                    hoverTimers[zoneData.elements] = nil
                end
            else
                -- Si on quitte la zone et que l'élément est actif, programmer le masquage
                if hoverActiveElements[zoneData.elements] and not hoverTimers[zoneData.elements] then
                    HideUI.Hover.HideElementsAfterDelay(zoneData.elements, zoneData.delay)
                end
            end
        end
    end)
end

-- ============================================================================
-- FONCTIONS UTILITAIRES
-- ============================================================================

-- Vérifie si un élément est actif au survol
function HideUI.Hover.IsElementActive(elementType)
    return hoverActiveElements[elementType] or false
end

-- Annule tous les timers de survol
function HideUI.Hover.CancelAllTimers()
    for elementType, timer in pairs(hoverTimers) do
        if timer then
            timer:Cancel()
        end
    end
    hoverTimers = {}
    hoverActiveElements = {}
end

-- Arrête le système de survol
function HideUI.Hover.Stop()
    if mouseCheckTimer then
        mouseCheckTimer:Cancel()
        mouseCheckTimer = nil
    end
    HideUI.Hover.CancelAllTimers()
end