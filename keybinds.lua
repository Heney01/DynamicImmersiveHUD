-- Keybinds.lua
-- Keyboard shortcut management module

HideUI = HideUI or {}
HideUI.Keybinds = {}

-- ============================================================================
-- KEYBINDING CONFIGURATION
-- ============================================================================

-- Headers and names for keybindings
BINDING_HEADER_HIDEUIELEMENTS = "Hide UI Elements"
BINDING_NAME_HIDEUI_TOGGLE_ALL = "Toggle complete interface"
BINDING_NAME_HIDEUI_TOGGLE_BARS = "Toggle action bars"
BINDING_NAME_HIDEUI_TOGGLE_CHAT = "Toggle chat"
-- BINDING_NAME_HIDEUI_TOGGLE_BAGS supprimé

-- ============================================================================
-- AUTOMATIC KEY CONFIGURATION
-- ============================================================================

-- Automatically configure keyboard shortcuts
function HideUI.Keybinds.Setup()
    if InCombatLockdown() then
        -- If in combat, postpone configuration
        C_Timer.After(2, HideUI.Keybinds.Setup)
        return
    end
    
    -- Create macro to toggle complete interface
    local macroName = "HideUIToggle"
    local macroBody = "/script HideUI_ToggleAll()"
    
    -- Delete old macro if it exists
    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex ~= 0 then
        DeleteMacro(macroIndex)
    end
    
    -- Create new macro
    local success = CreateMacro(macroName, "INV_Misc_QuestionMark", macroBody, nil)
    if success then
        -- Assign '<' key
        SetBinding("<", "MACRO " .. macroName)
    end
        
    -- Save shortcuts
    SaveBindings(GetCurrentBindingSet())
end

-- ============================================================================
-- ALTERNATIVE SHORTCUT MANAGEMENT
-- ============================================================================

-- Alternative configuration without macros (to avoid conflicts)
function HideUI.Keybinds.SetupAlternative()
    if InCombatLockdown() then
        return
    end
    
    -- Try to assign keys directly to global functions
    SetBinding("<", "HIDEUI_TOGGLE_ALL")
    
    SaveBindings(GetCurrentBindingSet())
end

-- Check and repair shortcuts if needed 
function HideUI.Keybinds.CheckAndRepair()
    local binding1 = GetBinding("<")
    
    if not binding1 or not binding1:find("HideUI") then
        HideUI.Keybinds.Setup()
    end
    
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Remove HideUI shortcuts (VERSION SIMPLIFIÉE)
function HideUI.Keybinds.RemoveBindings()
    if InCombatLockdown() then
        return
    end
    
    SetBinding("<")  -- Remove binding
    
    -- Delete associated macros
    local macroIndex1 = GetMacroIndexByName("HideUIToggle")
    if macroIndex1 ~= 0 then
        DeleteMacro(macroIndex1)
    end
        
    SaveBindings(GetCurrentBindingSet())
end

-- ============================================================================
-- CONFLICT MANAGEMENT
-- ============================================================================

-- Check for conflicts with other addons (VERSION SIMPLIFIÉE)
function HideUI.Keybinds.CheckConflicts()
    local conflicts = {}
    
    -- Check '<' key
    local binding1 = GetBinding("<")
    if binding1 and not binding1:find("HideUI") then
        table.insert(conflicts, {key = "<", current = binding1})
    end
    
    if #conflicts > 0 then
        return false
    end
    
    return true
end