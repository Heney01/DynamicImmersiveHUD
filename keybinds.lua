-- Keybinds.lua
-- Module de gestion des raccourcis clavier

HideUI = HideUI or {}
HideUI.Keybinds = {}

-- ============================================================================
-- CONFIGURATION DES KEYBINDINGS
-- ============================================================================

-- Headers et noms pour les keybindings
BINDING_HEADER_HIDEUIELEMENTS = "Hide UI Elements"
BINDING_NAME_HIDEUI_TOGGLE_ALL = "Basculer l'interface complète"
BINDING_NAME_HIDEUI_TOGGLE_BARS = "Basculer les barres d'action"
BINDING_NAME_HIDEUI_TOGGLE_CHAT = "Basculer le chat"
BINDING_NAME_HIDEUI_TOGGLE_BAGS = "Afficher les sacs temporairement"

-- ============================================================================
-- CONFIGURATION AUTOMATIQUE DES TOUCHES
-- ============================================================================

-- Configure automatiquement les raccourcis clavier
function HideUI.Keybinds.Setup()
    if InCombatLockdown() then
        -- Si on est en combat, reporter la configuration
        C_Timer.After(2, HideUI.Keybinds.Setup)
        return
    end
    
    -- Créer une macro pour basculer l'interface complète
    local macroName = "HideUIToggle"
    local macroBody = "/script HideUI_ToggleAll()"
    
    -- Supprimer l'ancienne macro si elle existe
    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex ~= 0 then
        DeleteMacro(macroIndex)
    end
    
    -- Créer la nouvelle macro
    local success = CreateMacro(macroName, "INV_Misc_QuestionMark", macroBody, nil)
    if success then
        -- Assigner la touche '<'
        SetBinding("<", "MACRO " .. macroName)
        print("|cFF00FF00HideUI:|r Touche '<' configurée pour basculer l'interface")
    end
    
    -- Créer une macro pour les sacs
    local bagMacroName = "HideUIBags"
    local bagMacroBody = "/script HideUI_ShowBagsTemporary()"
    
    local bagMacroIndex = GetMacroIndexByName(bagMacroName)
    if bagMacroIndex ~= 0 then
        DeleteMacro(bagMacroIndex)
    end
    
    local bagSuccess = CreateMacro(bagMacroName, "INV_Misc_Bag_08", bagMacroBody, nil)
    if bagSuccess then
        -- Assigner la touche 'B' pour les sacs
        SetBinding("B", "MACRO " .. bagMacroName)
        print("|cFF00FF00HideUI:|r Touche 'B' configurée pour afficher les sacs temporairement")
    end
    
    -- Sauvegarder les raccourcis
    SaveBindings(GetCurrentBindingSet())
end

-- ============================================================================
-- GESTION ALTERNATIVE DES RACCOURCIS
-- ============================================================================

-- Configuration alternative sans macros (pour éviter les conflits)
function HideUI.Keybinds.SetupAlternative()
    if InCombatLockdown() then
        return
    end
    
    -- Essayer d'assigner directement les touches aux fonctions globales
    SetBinding("<", "HIDEUI_TOGGLE_ALL")
    SetBinding("B", "HIDEUI_TOGGLE_BAGS")
    
    SaveBindings(GetCurrentBindingSet())
    print("|cFF00FF00HideUI:|r Raccourcis configurés en mode alternatif")
end

-- Vérifie et répare les raccourcis si nécessaire
function HideUI.Keybinds.CheckAndRepair()
    local binding1 = GetBinding("<")
    local binding2 = GetBinding("B")
    
    if not binding1 or not binding1:find("HideUI") then
        print("|cFFFFAA00HideUI:|r Raccourci '<' manquant, reconfiguration...")
        HideUI.Keybinds.Setup()
    end
    
    if not binding2 or not binding2:find("HideUI") then
        print("|cFFFFAA00HideUI:|r Raccourci 'B' manquant, reconfiguration...")
        HideUI.Keybinds.Setup()
    end
end

-- ============================================================================
-- FONCTIONS UTILITAIRES
-- ============================================================================

-- Affiche les raccourcis actuels
function HideUI.Keybinds.ShowCurrentBindings()
    print("|cFF00FF00HideUI Raccourcis actuels:|r")
    
    local binding1 = GetBinding("<")
    local binding2 = GetBinding("B")
    
    if binding1 then
        print("  Touche '<': " .. binding1)
    else
        print("  Touche '<': |cFFFF0000Non configurée|r")
    end
    
    if binding2 then
        print("  Touche 'B': " .. binding2)
    else
        print("  Touche 'B': |cFFFF0000Non configurée|r")
    end
end

-- Supprime les raccourcis HideUI
function HideUI.Keybinds.RemoveBindings()
    if InCombatLockdown() then
        print("|cFFFF0000HideUI:|r Impossible de supprimer les raccourcis en combat")
        return
    end
    
    SetBinding("<")  -- Supprime le binding
    SetBinding("B")  -- Supprime le binding
    
    -- Supprimer les macros associées
    local macroIndex1 = GetMacroIndexByName("HideUIToggle")
    if macroIndex1 ~= 0 then
        DeleteMacro(macroIndex1)
    end
    
    local macroIndex2 = GetMacroIndexByName("HideUIBags")
    if macroIndex2 ~= 0 then
        DeleteMacro(macroIndex2)
    end
    
    SaveBindings(GetCurrentBindingSet())
    print("|cFF00FF00HideUI:|r Raccourcis supprimés")
end

-- ============================================================================
-- GESTION DES CONFLITS
-- ============================================================================

-- Vérifie s'il y a des conflits avec d'autres addons
function HideUI.Keybinds.CheckConflicts()
    local conflicts = {}
    
    -- Vérifier la touche '<'
    local binding1 = GetBinding("<")
    if binding1 and not binding1:find("HideUI") then
        table.insert(conflicts, {key = "<", current = binding1})
    end
    
    -- Vérifier la touche 'B'
    local binding2 = GetBinding("B")
    if binding2 and not binding2:find("HideUI") and not binding2:find("TOGGLEBAG") then
        table.insert(conflicts, {key = "B", current = binding2})
    end
    
    if #conflicts > 0 then
        print("|cFFFFAA00HideUI:|r Conflits de raccourcis détectés:")
        for _, conflict in ipairs(conflicts) do
            print("  Touche '" .. conflict.key .. "' utilisée par: " .. conflict.current)
        end
        print("Utilisez |cFFFFFF00/hideui bindings remove|r puis |cFFFFFF00/hideui bindings setup|r pour forcer la configuration")
        return false
    end
    
    return true
end