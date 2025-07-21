-- Commands.lua
-- Module de gestion des commandes slash et fonctions de debug

HideUI = HideUI or {}
HideUI.Commands = {}

-- ============================================================================
-- FONCTIONS DE DEBUG
-- ============================================================================

-- Fonction de debug pour scanner les éléments visibles
function HideUI.Commands.DebugVisibleElements()
    print("|cFF00FF00HideUI Debug:|r Scan des éléments visibles...")
    
    local foundVisible = false
    for _, frameName in pairs(HideUI.Config.debugFrames) do
        local frame = _G[frameName]
        if frame and frame:IsShown() and frame:GetAlpha() > 0 then
            local x, y = frame:GetCenter()
            if x and y then
                print(string.format("|cFFFFFF00%s|r - Visible à (%.0f, %.0f) Alpha: %.2f", 
                    frameName, x, y, frame:GetAlpha()))
                foundVisible = true
            end
        end
    end
    
    if not foundVisible then
        print("|cFF00FF00Aucun élément problématique détecté !|r")
    end
    print("|cFF00FF00Debug terminé.|r")
end

-- Affiche l'état actuel de l'addon
function HideUI.Commands.ShowStatus()
    local state = HideUI.State
    print("|cFF00FF00HideUI Status:|r")
    print("  Barres d'action: " .. (state.barsHidden and "|cFFFF0000masquées|r" or "|cFF00FF00affichées|r"))
    print("  Chat: " .. (state.chatHidden and "|cFFFF0000masqué|r" or "|cFF00FF00affiché|r"))
    print("  Interface: " .. (state.uiHidden and "|cFFFF0000masquée|r" or "|cFF00FF00affichée|r"))
    print("  Sacs: " .. (state.bagsHidden and "|cFFFF0000masqués|r" or "|cFF00FF00affichés|r"))
    print("  Micro-menus: " .. (state.microMenuHidden and "|cFFFF0000masqués|r" or "|cFF00FF00affichés|r"))
    print("  Barres latérales: " .. (state.sideBarHidden and "|cFFFF0000masquées|r" or "|cFF00FF00affichées|r"))
    print("  En combat: " .. (state.inCombat and "|cFFFF6600Oui|r" or "|cFF00FF00Non|r"))
    print("  Override combat: " .. (state.combatOverrideActive and "|cFFFF6600Actif|r" or "|cFF00FF00Inactif|r"))
    
    -- État des modules temporaires
    if HideUI.Chat and HideUI.Chat.IsTemporaryActive() then
        print("  Chat temporaire: |cFF87CEEBActif|r")
    end
    if HideUI.Bags and HideUI.Bags.IsTemporaryActive() then
        print("  Sacs temporaires: |cFF87CEEBActif|r")
    end
    if HideUI.Bags and HideUI.Bags.IsMerchantActive() then
        print("  Mode marchand: |cFF87CEEBActif|r")
    end
end

-- Affiche l'aide détaillée
function HideUI.Commands.ShowHelp()
    print("|cFF00FF00HideUI Commands:|r")
    print("  |cFFFFFF00/hideui|r ou |cFFFFFF00/hui|r - Basculer l'interface complète")
    print("  |cFFFFFF00/hideui bars|r - Basculer les barres d'action")
    print("  |cFFFFFF00/hideui chat|r - Basculer le chat")
    print("  |cFFFFFF00/hideui ui|r - Basculer les éléments d'interface")
    print("  |cFFFFFF00/hideui bags|r - Basculer les sacs")
    print("  |cFFFFFF00/hideui menu|r - Basculer les micro-menus")
    print("  |cFFFFFF00/hideui show|r - Tout afficher")
    print("  |cFFFFFF00/hideui status|r - Afficher l'état actuel")
    print("  |cFFFFFF00/hideui debug|r - Scanner les éléments visibles")
    print("  |cFFFFFF00/hideui bags hide/show|r - Forcer masquer/afficher les sacs")
    print("|cFF00FF00Raccourcis clavier:|r")
    print("  |cFFFFFF00Touche '<'|r - Basculer l'interface complète")
    print("  |cFFFFFF00Touche 'B'|r - Affiche les sacs temporairement si masqués")
    print("|cFF00FF00Fonctionnalités:|r")
    print("  |cFF32CD32Combat automatique|r - L'interface s'affiche en combat")
    print("  |cFF87CEEB Chat temporaire|r - Le chat s'affiche pour les messages importants")
    print("  |cFFFFB6C1Survol intelligent|r - Chat, barres, sacs et quêtes s'affichent au survol")
end

-- ============================================================================
-- COMMANDES SLASH
-- ============================================================================

-- Gestionnaire principal des commandes slash
function HideUI.Commands.HandleSlashCommand(msg)
    msg = msg:lower():trim()
    
    if msg == "" then
        if HideUI.Core then
            HideUI.Core.ToggleAll()
        end
    elseif msg == "bars" or msg == "barres" then
        if HideUI.Core then
            HideUI.Core.ToggleActionBars()
        end
    elseif msg == "chat" then
        if HideUI.Core then
            HideUI.Core.ToggleChat()
        end
    elseif msg == "ui" or msg == "interface" then
        if HideUI.Core then
            HideUI.Core.ToggleUIElements()
        end
    elseif msg == "bags" or msg == "sacs" then
        if HideUI.Core then
            HideUI.Core.ToggleBags()
        end
    elseif msg == "menu" or msg == "micromenu" then
        if HideUI.Core then
            HideUI.Core.ToggleMicroMenu()
        end
    elseif msg == "show" or msg == "afficher" then
        if HideUI.Core then
            HideUI.Core.ShowAll()
        end
    elseif msg == "status" or msg == "etat" then
        HideUI.Commands.ShowStatus()
    elseif msg == "debug" then
        HideUI.Commands.DebugVisibleElements()
    elseif msg == "debug bags" or msg == "debug sacs" then
        if HideUI.Bags and HideUI.Bags.DebugBagOpening then
            HideUI.Bags.DebugBagOpening()
        else
            print("|cFFFF0000HideUI:|r Module Bags non disponible")
        end
    elseif msg == "bags hide" then
        if HideUI.Bags then
            HideUI.Bags.ForceHide()
            print("|cFF87CEEB HideUI:|r Sacs masqués forcés")
        end
    elseif msg == "bags show" then
        if HideUI.Bags then
            HideUI.Bags.ShowOnHover()
            print("|cFF87CEEB HideUI:|r Sacs affichés forcés")
        end
    elseif msg == "bags debug on" then
        if HideUI.Bags and HideUI.Bags.SetDebugMode then
            HideUI.Bags.SetDebugMode(true)
        end
    elseif msg == "bags debug off" then
        if HideUI.Bags and HideUI.Bags.SetDebugMode then
            HideUI.Bags.SetDebugMode(false)
        end
    elseif msg == "help" or msg == "aide" then
        HideUI.Commands.ShowHelp()
    elseif msg == "reset" then
        HideUI.Commands.ResetAddon()
    else
        print("|cFFFF0000HideUI:|r Commande inconnue. Tapez |cFFFFFF00/hideui help|r pour l'aide")
    end
end

-- Réinitialise l'addon
function HideUI.Commands.ResetAddon()
    -- Annuler tous les timers actifs
    if HideUI.Hover then
        HideUI.Hover.CancelAllTimers()
    end
    if HideUI.Chat then
        HideUI.Chat.CancelTemporary()
    end
    if HideUI.Bags then
        HideUI.Bags.CancelTemporary()
    end
    
    -- Remettre tout en état affiché
    if HideUI.Core then
        HideUI.Core.ShowAll()
    end
    
    -- Réinitialiser les états
    HideUI.State.combatOverrideActive = false
    
    print("|cFF00FF00HideUI:|r Addon réinitialisé - toute l'interface est maintenant visible")
end

-- ============================================================================
-- INITIALISATION DES COMMANDES
-- ============================================================================

-- Initialise les commandes slash
function HideUI.Commands.Initialize()
    SLASH_HIDEUI1 = "/hideui"
    SLASH_HIDEUI2 = "/hui"
    
    SlashCmdList["HIDEUI"] = HideUI.Commands.HandleSlashCommand
end

-- Initialiser automatiquement les commandes
HideUI.Commands.Initialize()