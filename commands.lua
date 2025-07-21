-- Commands.lua

HideUI = HideUI or {}
HideUI.Commands = {}

-- ============================================================================
-- COMMANDES SLASH
-- ============================================================================

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
        end
    elseif msg == "bags hide" then
        if HideUI.Bags then
            HideUI.Bags.ForceHide()
        end
    elseif msg == "bags show" then
        if HideUI.Bags then
            HideUI.Bags.ShowOnHover()
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
    end
end

-- Reset addon
function HideUI.Commands.ResetAddon()
    if HideUI.Hover then
        HideUI.Hover.CancelAllTimers()
    end
    if HideUI.Chat then
        HideUI.Chat.CancelTemporary()
    end
    if HideUI.Bags then
        HideUI.Bags.CancelTemporary()
    end
    
    if HideUI.Core then
        HideUI.Core.ShowAll()
    end
    
    HideUI.State.combatOverrideActive = false
end

-- ============================================================================
-- INITIALISATION DES COMMANDES
-- ============================================================================

function HideUI.Commands.Initialize()
    SLASH_HIDEUI1 = "/hideui"
    SLASH_HIDEUI2 = "/hui"
    
    SlashCmdList["HIDEUI"] = HideUI.Commands.HandleSlashCommand
end

HideUI.Commands.Initialize()