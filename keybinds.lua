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
BINDING_NAME_HIDEUI_TOGGLE_AUTOHIDE = "Toggle auto-hide at startup"
BINDING_NAME_HIDEUI_TOGGLE_ADDON = "Enable/Disable HideUI addon"
BINDING_NAME_HIDEUI_SMART_TOGGLE = "Smart Toggle (Force Hide/Show)"

-- ============================================================================
-- CUSTOM KEYBIND MANAGEMENT
-- ============================================================================

-- Set custom keybind for toggle all
function HideUI.Keybinds.SetCustomKey(keyString)
    if InCombatLockdown() then
        return false
    end
    
    -- Clear previous HideUI bindings first
    HideUI.Keybinds.ClearHideUIBindings()
    
    if not keyString or keyString == "" then
        return true
    end
    
    -- Validate key format
    if not HideUI.Keybinds.IsValidKey(keyString) then
        return false
    end
    
    -- Check if key is already used by another addon/function
    local existingBinding = GetBindingAction(keyString)
    if existingBinding and not existingBinding:find("HIDEUI") then
        return false
    end
    
    -- Set the binding
    local success = SetBinding(keyString, "HIDEUI_TOGGLE_ALL")
    if success then
        SaveBindings(GetCurrentBindingSet())
        return true
    else
        return false
    end
end

-- Set custom keybind with force option
function HideUI.Keybinds.SetCustomKeyForced(keyString)
    if InCombatLockdown() then
        return false
    end
    
    -- Clear previous HideUI bindings first
    HideUI.Keybinds.ClearHideUIBindings()
    
    -- Set the binding (overwrite existing)
    local success = SetBinding(keyString, "HIDEUI_TOGGLE_ALL")
    if success then
        SaveBindings(GetCurrentBindingSet())
        return true
    else
        return false
    end
end

-- Clear all HideUI bindings
function HideUI.Keybinds.ClearHideUIBindings()
    if InCombatLockdown() then
        return
    end
    
    -- List of possible HideUI bindings
    local hideUIBindings = {
        "HIDEUI_TOGGLE_ALL",
        "HIDEUI_TOGGLE_BARS", 
        "HIDEUI_TOGGLE_CHAT",
        "HIDEUI_TOGGLE_AUTOHIDE"
    }
    
    -- Clear all bindings for HideUI functions using GetBindingKey
    for _, hideUIBinding in pairs(hideUIBindings) do
        local key1, key2 = GetBindingKey(hideUIBinding)
        if key1 then
            SetBinding(key1)  -- Clear the binding
        end
        if key2 then
            SetBinding(key2)  -- Clear the second binding if exists
        end
    end
    
    -- Also remove any HideUI macros
    local macroName = "HideUIToggle"
    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex ~= 0 then
        DeleteMacro(macroIndex)
    end
    
    SaveBindings(GetCurrentBindingSet())
end

-- Get current HideUI keybind
function HideUI.Keybinds.GetCurrentKey()
    -- Use GetBindingKey instead of iterating through all bindings
    local key1, key2 = GetBindingKey("HIDEUI_TOGGLE_ALL")
    if key1 then
        return key1
    elseif key2 then
        return key2
    end
    return nil
end

-- Validate key format
function HideUI.Keybinds.IsValidKey(keyString)
    if not keyString or keyString == "" then
        return false
    end
    
    -- List of valid single keys (non-exhaustive but covers common cases)
    local validKeys = {
        -- Function keys
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
        -- Numbers
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
        -- Special characters
        "-", "=", "[", "]", "\\", ";", "'", ",", ".", "/", "`",
        -- Letters (will be converted to uppercase)
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        -- Special keys
        "TAB", "SPACE", "ENTER", "BACKSPACE", "DELETE", "INSERT", "HOME", "END",
        "PAGEUP", "PAGEDOWN", "UP", "DOWN", "LEFT", "RIGHT",
        -- Numpad
        "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", 
        "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPAD0", "NUMPADPLUS", "NUMPADMINUS",
        "NUMPADMULTIPLY", "NUMPADDIVIDE", "NUMPADDECIMAL", "NUMPADENTER"
    }
    
    -- Convert to uppercase for comparison
    keyString = keyString:upper()
    
    -- Check if it's a valid single key
    for _, validKey in pairs(validKeys) do
        if keyString == validKey then
            return true
        end
    end
    
    -- Check if it's a valid combination (CTRL-, ALT-, SHIFT-)
    if keyString:find("^CTRL%-") or keyString:find("^ALT%-") or keyString:find("^SHIFT%-") then
        local modifiedKey = keyString:match("^[A-Z]+%-(.+)$")
        if modifiedKey then
            return HideUI.Keybinds.IsValidKey(modifiedKey)
        end
    end
    
    return false
end

-- ============================================================================
-- AUTOMATIC SETUP (NO DEFAULT KEY)
-- ============================================================================

-- Setup function - no longer assigns default keys
function HideUI.Keybinds.Setup()
    if InCombatLockdown() then
        -- If in combat, postpone setup
        C_Timer.After(2, HideUI.Keybinds.Setup)
        return
    end
    
    -- Just ensure no conflicting old macros exist
    HideUI.Keybinds.CleanupOldMacros()
end

-- Clean up old macros from previous versions
function HideUI.Keybinds.CleanupOldMacros()
    if InCombatLockdown() then
        return
    end
    
    local macroName = "HideUIToggle"
    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex ~= 0 then
        DeleteMacro(macroIndex)
    end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Remove all HideUI shortcuts
function HideUI.Keybinds.RemoveAllBindings()
    if InCombatLockdown() then
        return
    end
    
    HideUI.Keybinds.ClearHideUIBindings()
end

-- Check for conflicts with other addons
function HideUI.Keybinds.CheckConflicts()
    local currentKey = HideUI.Keybinds.GetCurrentKey()
    
    if not currentKey then
        return true  -- No conflicts if no key assigned
    end
    
    local binding = GetBindingAction(currentKey)
    if binding and binding ~= "HIDEUI_TOGGLE_ALL" then
        return false, currentKey, binding
    end
    
    return true
end