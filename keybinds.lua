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
BINDING_NAME_HIDEUI_TOGGLE_BAGS = "Show bags temporarily"

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
        print("|cFF00FF00HideUI:|r '<' key configured to toggle interface")
    end
    
    -- Create macro for bags
    local bagMacroName = "HideUIBags"
    local bagMacroBody = "/script HideUI_ShowBagsTemporary()"
    
    local bagMacroIndex = GetMacroIndexByName(bagMacroName)
    if bagMacroIndex ~= 0 then
        DeleteMacro(bagMacroIndex)
    end
    
    local bagSuccess = CreateMacro(bagMacroName, "INV_Misc_Bag_08", bagMacroBody, nil)
    if bagSuccess then
        -- Assign 'B' key for bags
        SetBinding("B", "MACRO " .. bagMacroName)
        print("|cFF00FF00HideUI:|r 'B' key configured to show bags temporarily")
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
    SetBinding("B", "HIDEUI_TOGGLE_BAGS")
    
    SaveBindings(GetCurrentBindingSet())
    print("|cFF00FF00HideUI:|r Shortcuts configured in alternative mode")
end

-- Check and repair shortcuts if needed
function HideUI.Keybinds.CheckAndRepair()
    local binding1 = GetBinding("<")
    local binding2 = GetBinding("B")
    
    if not binding1 or not binding1:find("HideUI") then
        print("|cFFFFAA00HideUI:|r '<' shortcut missing, reconfiguring...")
        HideUI.Keybinds.Setup()
    end
    
    if not binding2 or not binding2:find("HideUI") then
        print("|cFFFFAA00HideUI:|r 'B' shortcut missing, reconfiguring...")
        HideUI.Keybinds.Setup()
    end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Display current shortcuts
function HideUI.Keybinds.ShowCurrentBindings()
    print("|cFF00FF00HideUI Current shortcuts:|r")
    
    local binding1 = GetBinding("<")
    local binding2 = GetBinding("B")
    
    if binding1 then
        print("  '<' key: " .. binding1)
    else
        print("  '<' key: |cFFFF0000Not configured|r")
    end
    
    if binding2 then
        print("  'B' key: " .. binding2)
    else
        print("  'B' key: |cFFFF0000Not configured|r")
    end
end

-- Remove HideUI shortcuts
function HideUI.Keybinds.RemoveBindings()
    if InCombatLockdown() then
        print("|cFFFF0000HideUI:|r Cannot remove shortcuts while in combat")
        return
    end
    
    SetBinding("<")  -- Remove binding
    SetBinding("B")  -- Remove binding
    
    -- Delete associated macros
    local macroIndex1 = GetMacroIndexByName("HideUIToggle")
    if macroIndex1 ~= 0 then
        DeleteMacro(macroIndex1)
    end
    
    local macroIndex2 = GetMacroIndexByName("HideUIBags")
    if macroIndex2 ~= 0 then
        DeleteMacro(macroIndex2)
    end
    
    SaveBindings(GetCurrentBindingSet())
    print("|cFF00FF00HideUI:|r Shortcuts removed")
end

-- ============================================================================
-- CONFLICT MANAGEMENT
-- ============================================================================

-- Check for conflicts with other addons
function HideUI.Keybinds.CheckConflicts()
    local conflicts = {}
    
    -- Check '<' key
    local binding1 = GetBinding("<")
    if binding1 and not binding1:find("HideUI") then
        table.insert(conflicts, {key = "<", current = binding1})
    end
    
    -- Check 'B' key
    local binding2 = GetBinding("B")
    if binding2 and not binding2:find("HideUI") and not binding2:find("TOGGLEBAG") then
        table.insert(conflicts, {key = "B", current = binding2})
    end
    
    if #conflicts > 0 then
        print("|cFFFFAA00HideUI:|r Shortcut conflicts detected:")
        for _, conflict in ipairs(conflicts) do
            print("  '" .. conflict.key .. "' key used by: " .. conflict.current)
        end
        print("Use |cFFFFFF00/hideui bindings remove|r then |cFFFFFF00/hideui bindings setup|r to force configuration")
        return false
    end
    
    return true
end