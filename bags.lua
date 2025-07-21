-- Bags.lua
-- Module de gestion des sacs

HideUI = HideUI or {}
HideUI.Bags = {}

-- Variables locales
local bagTemporaryActive = false
local bagTimer = nil
local originalToggleBag = nil
local originalToggleAllBags = nil
local originalToggleBackpack = nil
local merchantActive = false
local merchantFrame = nil
local debugMode = false -- Variable pour activer/désactiver le debug

-- Fonction de debug conditionnelle
local function DebugPrint(message)
    if debugMode then
        print("|cFFFFAA00HideUI Debug:|r " .. message)
    end
end

-- ============================================================================
-- FONCTIONS PRINCIPALES
-- ============================================================================

-- Affiche temporairement les sacs
function HideUI.Bags.ShowTemporary()
    if not HideUI.State.bagsHidden then 
        -- Si les sacs ne sont pas masqués, utiliser le comportement normal
        if ToggleAllBags then
            ToggleAllBags()
        end
        return 
    end
    
    -- Si l'affichage temporaire est déjà actif, on ferme les sacs et on désactive le mode temporaire
    if bagTemporaryActive then
        -- Fermer les sacs
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
        
        -- Désactiver le mode temporaire immédiatement
        HideUI.Bags.CancelTemporary()
        
        -- Masquer les éléments de sacs
        HideUI.Bags.HideAfterDelay()
        
        print("|cFF87CEEB HideUI:|r Sacs fermés et masqués")
        return
    end
    
    bagTemporaryActive = true
    
    -- Annuler le timer précédent s'il existe
    if bagTimer then
        bagTimer:Cancel()
    end
    
    -- Afficher les éléments de sacs d'abord
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
            if element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Ouvrir réellement les sacs - utiliser la fonction originale ou une approche alternative
    C_Timer.After(0.1, function()
        if originalToggleAllBags then
            -- Utiliser la fonction originale sauvegardée
            originalToggleAllBags()
        elseif ToggleAllBags then
            -- Forcer l'ouverture en désactivant temporairement notre hook
            local tempBagsHidden = HideUI.State.bagsHidden
            local tempBagTemporaryActive = bagTemporaryActive
            HideUI.State.bagsHidden = false
            bagTemporaryActive = false
            ToggleAllBags()
            HideUI.State.bagsHidden = tempBagsHidden
            bagTemporaryActive = tempBagTemporaryActive
        else
            -- Méthode alternative : simuler un clic sur le bouton de sac
            local backpackButton = _G["MainMenuBarBackpackButton"]
            if backpackButton and backpackButton:IsVisible() then
                backpackButton:Click()
            end
        end
    end)
    
    -- Afficher toutes les fenêtres de sacs ouvertes
    C_Timer.After(0.2, function()
        for i = 1, 13 do
            local containerFrame = _G["ContainerFrame"..i]
            if containerFrame and containerFrame:IsShown() then
                containerFrame:SetAlpha(1)
                containerFrame:EnableMouse(true)
            end
        end
    end)
    
    print("|cFF87CEEB HideUI:|r Sacs affichés temporairement")
    
    -- Programmer le masquage automatique dans 8 secondes (réduit car masquage instantané)
    bagTimer = C_Timer.NewTimer(8, function()
        HideUI.Bags.HideAfterDelay()
    end)
end

-- Masque les sacs après le délai
function HideUI.Bags.HideAfterDelay()
    DebugPrint("HideAfterDelay appelé")
    DebugPrint("- bagsHidden: " .. (HideUI.State.bagsHidden and "true" or "false"))
    DebugPrint("- merchantActive: " .. (merchantActive and "true" or "false"))
    DebugPrint("- combatOverrideActive: " .. (HideUI.State.combatOverrideActive and "true" or "false"))
    
    if not HideUI.State.bagsHidden then 
        DebugPrint("Arrêt: sacs pas supposés être masqués")
        return
    end
    
    -- Ne pas masquer si on est chez un marchand
    if merchantActive then
        print("|cFF87CEEB HideUI:|r Masquage des sacs annulé (marchand actif)")
        return
    end
    
    -- Ne pas masquer en combat
    if HideUI.State.combatOverrideActive then
        DebugPrint("Masquage des sacs annulé (combat actif)")
        return
    end
    
    -- Désactiver le mode temporaire
    bagTemporaryActive = false
    
    DebugPrint("Procédure de masquage instantané")
    
    -- Masquage instantané (sans fondu)
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(0)
            if element.EnableMouse then
                element:EnableMouse(false)
            end
        end
    end
    
    -- Masquer toutes les fenêtres de sacs
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame then
            containerFrame:SetAlpha(0)
            containerFrame:EnableMouse(false)
        end
    end
    
    print("|cFF87CEEB HideUI:|r Sacs masqués instantanément")
end

-- Applique le basculement des sacs
function HideUI.Bags.ApplyToggle(isHidden)
    -- Annuler l'affichage temporaire si actif
    if bagTemporaryActive then
        bagTemporaryActive = false
        if bagTimer then
            bagTimer:Cancel()
        end
    end
    
    -- Si en combat, ne pas appliquer immédiatement
    if not HideUI.State.combatOverrideActive then
        if HideUI.Core then
            HideUI.Core.ToggleElementList(HideUI.Config.bagElements, isHidden, "bags")
        end
        
        -- Gestion spéciale des fenêtres de sacs - instantané
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
    
    -- Si on masque les sacs, s'assurer que tout est bien masqué instantanément
    if isHidden then
        -- Pas de délai, masquage immédiat
        HideUI.Bags.ForceHide()
    end
end

-- Affiche les sacs au survol
function HideUI.Bags.ShowOnHover()
    if not HideUI.State.bagsHidden or HideUI.State.combatOverrideActive then return end
    
    -- Affichage instantané des éléments de sacs
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

-- Masque les sacs après le survol
function HideUI.Bags.HideAfterHover()
    if not HideUI.State.bagsHidden or bagTemporaryActive or HideUI.State.combatOverrideActive or merchantActive then 
        return 
    end
    
    -- Masquage instantané des sacs
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
-- HOOKS DES FONCTIONS DE SACS
-- ============================================================================

function HideUI.Bags.SetupHooks()
    -- Hook ToggleBag
    if ToggleBag and not originalToggleBag then
        originalToggleBag = ToggleBag
        ToggleBag = function(bagID)
            if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive and not merchantActive then
                HideUI.Bags.ShowTemporary()
                -- Ne pas appeler la fonction originale ici car ShowTemporary s'en charge
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
                -- Ne pas appeler la fonction originale ici car ShowTemporary s'en charge
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
                -- Ne pas appeler la fonction originale ici car ShowTemporary s'en charge
                return
            end
            return originalToggleBackpack()
        end
    end
    
    -- Hook des boutons de sacs individuels
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
    
    -- Hook du bouton principal de sac à dos
    local backpackButton = _G["MainMenuBarBackpackButton"]
    if backpackButton and not backpackButton.hideUIHooked then
        backpackButton:HookScript("OnClick", function()
            if HideUI.State.bagsHidden and not HideUI.State.combatOverrideActive and not bagTemporaryActive and not merchantActive then
                HideUI.Bags.ShowTemporary()
            end
        end)
        backpackButton.hideUIHooked = true
    end
    
    -- Créer un frame pour écouter les événements de marchand
    if not merchantFrame then
        merchantFrame = CreateFrame("Frame")
        merchantFrame:RegisterEvent("MERCHANT_SHOW")
        merchantFrame:RegisterEvent("MERCHANT_CLOSED")
        
        merchantFrame:SetScript("OnEvent", function(self, event, ...)
            DebugPrint("Événement marchand reçu: " .. event)
            
            if event == "MERCHANT_SHOW" then
                DebugPrint("Marchand ouvert")
                HideUI.Bags.ShowForMerchant()
            elseif event == "MERCHANT_CLOSED" then
                DebugPrint("Marchand fermé")
                HideUI.Bags.HideAfterMerchant()
            end
        end)
        
        print("|cFF00FF00HideUI:|r Gestionnaire d'événements marchand créé")
    end
end

-- ============================================================================
-- FONCTIONS D'ÉTAT
-- ============================================================================

-- Vérifie si l'affichage temporaire est actif
function HideUI.Bags.IsTemporaryActive()
    return bagTemporaryActive
end

-- Annule l'affichage temporaire
function HideUI.Bags.CancelTemporary()
    if bagTemporaryActive then
        bagTemporaryActive = false
        if bagTimer then
            bagTimer:Cancel()
            bagTimer = nil
        end
    end
end

-- Force le masquage immédiat des sacs
function HideUI.Bags.ForceHide()
    if not HideUI.State.bagsHidden then return end
    
    -- Ne pas masquer si on est chez un marchand
    if merchantActive then
        print("|cFF87CEEB HideUI:|r Sacs maintenus visibles (marchand)")
        return
    end
    
    -- Désactiver le mode temporaire
    HideUI.Bags.CancelTemporary()
    
    -- Masquer immédiatement les éléments de sacs
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(0)
            if element.EnableMouse then
                element:EnableMouse(false)
            end
        end
    end
    
    -- Masquer toutes les fenêtres de sacs
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame then
            containerFrame:SetAlpha(0)
            containerFrame:EnableMouse(false)
        end
    end
end

-- ============================================================================
-- FONCTIONS DE DEBUG POUR LES SACS
-- ============================================================================

-- Fonction de debug pour tester l'ouverture des sacs
function HideUI.Bags.DebugBagOpening()
    print("|cFF00FF00HideUI Bags Debug:|r")
    print("  État des sacs masqués: " .. (HideUI.State.bagsHidden and "OUI" or "NON"))
    print("  Affichage temporaire actif: " .. (bagTemporaryActive and "OUI" or "NON"))
    print("  Marchand actif: " .. (merchantActive and "OUI" or "NON"))
    print("  Combat override actif: " .. (HideUI.State.combatOverrideActive and "OUI" or "NON"))
    print("  Timer actif: " .. (bagTimer and "OUI" or "NON"))
    
    -- Tester les fonctions disponibles
    print("  ToggleAllBags disponible: " .. (ToggleAllBags and "OUI" or "NON"))
    print("  ToggleBackpack disponible: " .. (ToggleBackpack and "OUI" or "NON"))
    print("  originalToggleAllBags sauvegardé: " .. (originalToggleAllBags and "OUI" or "NON"))
    
    -- Vérifier l'état du marchand dans le jeu
    local merchantShown = MerchantFrame and MerchantFrame:IsShown()
    print("  MerchantFrame affiché: " .. (merchantShown and "OUI" or "NON"))
    
    -- Vérifier le bouton de sac
    local backpackButton = _G["MainMenuBarBackpackButton"]
    if backpackButton then
        print("  Bouton sac à dos trouvé: OUI")
        print("  Bouton visible: " .. (backpackButton:IsVisible() and "OUI" or "NON"))
        print("  Bouton enabled: " .. (backpackButton:IsEnabled() and "OUI" or "NON"))
        print("  Alpha du bouton: " .. backpackButton:GetAlpha())
    else
        print("  Bouton sac à dos trouvé: NON")
    end
    
    -- Vérifier l'état des sacs
    local numBagsOpen = 0
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame and containerFrame:IsShown() then
            numBagsOpen = numBagsOpen + 1
            print("  ContainerFrame" .. i .. " ouvert (alpha: " .. containerFrame:GetAlpha() .. ")")
        end
    end
    print("  Nombre de sacs ouverts: " .. numBagsOpen)
end

-- ============================================================================
-- GESTION DES MARCHANDS
-- ============================================================================

-- Affiche les sacs quand on parle à un marchand
function HideUI.Bags.ShowForMerchant()
    if not HideUI.State.bagsHidden then return end
    
    DebugPrint("ShowForMerchant appelé")
    
    merchantActive = true
    
    -- Annuler TOUS les timers et modes en cours
    if bagTimer then
        bagTimer:Cancel()
        bagTimer = nil
        DebugPrint("Timer de sacs annulé")
    end
    
    -- Forcer la désactivation du mode temporaire
    if bagTemporaryActive then
        bagTemporaryActive = false
        DebugPrint("Mode temporaire désactivé")
    end
    
    -- Afficher les éléments de sacs
    for _, elementName in pairs(HideUI.Config.bagElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
            if element.EnableMouse then
                element:EnableMouse(true)
            end
        end
    end
    
    -- Ouvrir automatiquement les sacs si ils ne sont pas déjà ouverts
    local numBagsOpen = 0
    for i = 1, 13 do
        local containerFrame = _G["ContainerFrame"..i]
        if containerFrame and containerFrame:IsShown() then
            numBagsOpen = numBagsOpen + 1
            containerFrame:SetAlpha(1)
            containerFrame:EnableMouse(true)
        end
    end
    
    DebugPrint(numBagsOpen .. " sacs déjà ouverts")
    
    -- Si aucun sac n'est ouvert, les ouvrir
    if numBagsOpen == 0 then
        C_Timer.After(0.1, function()
            if not merchantActive then
                DebugPrint("Marchand fermé avant ouverture des sacs")
                return
            end
            
            if originalToggleAllBags then
                DebugPrint("Ouverture avec originalToggleAllBags")
                originalToggleAllBags()
            elseif ToggleAllBags then
                DebugPrint("Ouverture avec ToggleAllBags")
                local tempBagsHidden = HideUI.State.bagsHidden
                local tempMerchantActive = merchantActive
                HideUI.State.bagsHidden = false
                merchantActive = false
                ToggleAllBags()
                HideUI.State.bagsHidden = tempBagsHidden
                merchantActive = tempMerchantActive
            end
        end)
        
        -- S'assurer que les sacs sont visibles après ouverture
        C_Timer.After(0.3, function()
            if not merchantActive then
                DebugPrint("Marchand fermé avant vérification finale")
                return
            end
            
            for i = 1, 13 do
                local containerFrame = _G["ContainerFrame"..i]
                if containerFrame and containerFrame:IsShown() then
                    containerFrame:SetAlpha(1)
                    containerFrame:EnableMouse(true)
                    DebugPrint("ContainerFrame" .. i .. " forcé visible")
                end
            end
        end)
    end
    
    print("|cFF87CEEB HideUI:|r Sacs affichés pour le marchand")
end

-- Masque les sacs quand on quitte le marchand
function HideUI.Bags.HideAfterMerchant()
    if not merchantActive then 
        DebugPrint("HideAfterMerchant appelé mais marchand déjà inactif")
        return 
    end
    
    DebugPrint("HideAfterMerchant appelé, désactivation du mode marchand")
    merchantActive = false
    
    -- Si les sacs sont supposés être masqués, les masquer instantanément
    if HideUI.State.bagsHidden then
        DebugPrint("Masquage des sacs car bagsHidden = true")
        HideUI.Bags.HideAfterDelay()
    else
        DebugPrint("Pas de masquage car bagsHidden = false")
    end
    
    print("|cFF87CEEB HideUI:|r Marchand fermé, sacs masqués instantanément")
end

-- Vérifie si on est actuellement chez un marchand
function HideUI.Bags.IsMerchantActive()
    return merchantActive
end

-- Active/désactive le mode debug pour les sacs
function HideUI.Bags.SetDebugMode(enabled)
    debugMode = enabled
    if enabled then
        print("|cFF00FF00HideUI:|r Debug des sacs activé")
    else
        print("|cFF00FF00HideUI:|r Debug des sacs désactivé")
    end
end