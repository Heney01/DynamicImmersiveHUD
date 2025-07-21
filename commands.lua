-- Commands.lua
-- Slash command management and debug functions module

HideUI = HideUI or {}
HideUI.Commands = {}

-- ============================================================================
-- DEBUG FUNCTIONS
-- ============================================================================

-- Debug function to scan visible elements
function HideUI.Commands.DebugVisibleElements()
    print("|cFF00FF00HideUI Debug:|r Scanning visible elements...")
    
    local foundVisible = false
    for _, frameName in pairs(HideUI.Config.debugFrames) do
        local frame = _G[frameName]
        if frame and frame:IsShown() and frame:GetAlpha() > 0 then
            local x, y = frame:GetCenter()
            if x and y then
                print(string.format("|cFFFFFF00%s|r - Visible at (%.0f, %.0f) Alpha: %.2f", 
                    frameName, x, y, frame:GetAlpha()))
                foundVisible = true
            end
        end
    end
    
    if not foundVisible then
        print("|cFF00FF00No problematic elements detected!|r")
    end
    print("|cFF00FF00Debug completed.|r")
end

-- Display current addon status
function HideUI.Commands.ShowStatus()
    local state = HideUI.State
    print("|cFF00FF00HideUI Status:|r")
    print("  Action bars: " .. (state.barsHidden and "|cFFFF0000hidden|r" or "|cFF00FF00shown|r"))
    print("  Chat: " .. (state.chatHidden and "|cFFFF0000hidden|r" or "|cFF00FF00shown|r"))
    print("  Interface: " .. (state.uiHidden and "|cFFFF0000hidden|r" or "|cFF00FF00shown|r"))
    print("  Bags: " .. (state.bagsHidden and "|cFFFF0000hidden|r" or "|cFF00FF00shown|r"))
    print("  Micro-menus: " .. (state.microMenuHidden and "|cFFFF0000hidden|r" or "|cFF00FF00shown|r"))
    print("  Side bars: " .. (state.sideBarHidden and "|cFFFF0000hidden|r" or "|cFF00FF00shown|r"))
    print("  In combat: " .. (state.inCombat and "|cFFFF6600Yes|r" or "|cFF00FF00No|r"))
    print("  Combat override: " .. (state.combatOverrideActive and "|cFFFF6600Active|r" or "|cFF00FF00Inactive|r"))
    
    -- Temporary module states
    if HideUI.Chat and HideUI.Chat.IsTemporaryActive() then
        print("  Temporary chat: |cFF87CEEBActive|r")
    end
    if HideUI.Bags and HideUI.Bags.IsTemporaryActive() then
        print("  Temporary bags: |cFF87CEEBActive|r")
    end
    if HideUI.Bags and HideUI.Bags.IsMerchantActive() then
        print("  Merchant mode: |cFF87CEEBActive|r")
    end
end

-- Display detailed help
function HideUI.Commands.ShowHelp()
    print("|cFF00FF00HideUI Commands:|r")
    print("  |cFFFFFF00/hideui|r or |cFFFFFF00/hui|r - Toggle complete interface")
    print("  |cFFFFFF00/hideui bars|r - Toggle action bars")
    print("  |cFFFFFF00/hideui chat|r - Toggle chat")
    print("  |cFFFFFF00/hideui ui|r - Toggle interface elements")
    print("  |cFFFFFF00/hideui bags|r - Toggle bags")
    print("  |cFFFFFF00/hideui menu|r - Toggle micro-menus")
    print("  |cFFFFFF00/hideui show|r - Show all")
    print("  |cFFFFFF00/hideui status|r - Display current status")
    print("  |cFFFFFF00/hideui debug|r - Scan visible elements")
    print("  |cFFFFFF00/hideui bags hide/show|r - Force hide/show bags")
    print("|cFF00FF00Keyboard shortcuts:|r")
    print("  |cFFFFFF00'<' key|r - Toggle complete interface")
    print("  |cFFFFFF00'B' key|r - Show bags temporarily if hidden")
    print("|cFF00FF00Features:|r")
    print("  |cFF32CD32Automatic combat|r - Interface shows in combat")
    print("  |cFF87CEEBTemporary chat|r - Chat shows for important messages")
    print("  |cFFFFB6C1Smart hover|r - Chat, bars, bags and quests show on hover")
end

-- ============================================================================
-- SLASH COMMANDS
-- ============================================================================

-- Main slash command handler
function HideUI.Commands.HandleSlashCommand(msg)
    msg = msg:lower():trim()
    
    if msg == "" then
        if HideUI.Core then
            HideUI.Core.ToggleAll()
        end
    elseif msg == "bars" then
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
    elseif msg == "bags" then
        if HideUI.Core then
            HideUI.Core.ToggleBags()
        end
    elseif msg == "menu" or msg == "micromenu" then
        if HideUI.Core then
            HideUI.Core.ToggleMicroMenu()
        end
    elseif msg == "show" then
        if HideUI.Core then
            HideUI.Core.ShowAll()
        end
    elseif msg == "status" then
        HideUI.Commands.ShowStatus()
    elseif msg == "debug" then
        HideUI.Commands.DebugVisibleElements()
    elseif msg == "debug bags" then
        if HideUI.Bags and HideUI.Bags.DebugBagOpening then
            HideUI.Bags.DebugBagOpening()
        else
            print("|cFFFF0000HideUI:|r Bags module not available")
        end
    elseif msg == "bags hide" then
        if HideUI.Bags then
            HideUI.Bags.ForceHide()
            print("|cFF87CEEB HideUI:|r Bags force hidden")
        end
    elseif msg == "bags show" then
        if HideUI.Bags then
            HideUI.Bags.ShowOnHover()
            print("|cFF87CEEB HideUI:|r Bags force shown")
        end
    elseif msg == "bags debug on" then
        if HideUI.Bags and HideUI.Bags.SetDebugMode then
            HideUI.Bags.SetDebugMode(true)
        end
    elseif msg == "bags debug off" then
        if HideUI.Bags and HideUI.Bags.SetDebugMode then
            HideUI.Bags.SetDebugMode(false)
        end
    elseif msg == "help" then
        HideUI.Commands.ShowHelp()
    elseif msg == "reset" then
        HideUI.Commands.ResetAddon()
    else
        print("|cFFFF0000HideUI:|r Unknown command. Type |cFFFFFF00/hideui help|r for help")
    end
end

-- Reset addon
function HideUI.Commands.ResetAddon()
    -- Cancel all active timers
    if HideUI.Hover then
        HideUI.Hover.CancelAllTimers()
    end
    if HideUI.Chat then
        HideUI.Chat.CancelTemporary()
    end
    if HideUI.Bags then
        HideUI.Bags.CancelTemporary()
    end
    
    -- Restore everything to shown state
    if HideUI.Core then
        HideUI.Core.ShowAll()
    end
    
    -- Reset states
    HideUI.State.combatOverrideActive = false
    
    print("|cFF00FF00HideUI:|r Addon reset - all interface elements are now visible")
end

-- ============================================================================
-- COMMAND INITIALIZATION
-- ============================================================================

-- Initialize slash commands
function HideUI.Commands.Initialize()
    SLASH_HIDEUI1 = "/hideui"
    SLASH_HIDEUI2 = "/hui"
    
    SlashCmdList["HIDEUI"] = HideUI.Commands.HandleSlashCommand
end

-- Auto-initialize commands
HideUI.Commands.Initialize()