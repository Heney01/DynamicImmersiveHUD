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
    elseif msg == "show" or msg == "afficher" then
        if HideUI.Core then
            HideUI.Core.ShowAll()
        end
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
    
    if HideUI.Core then
        HideUI.Core.ShowAll()
    end
    
    HideUI.State.combatOverrideActive = false
end

-- ============================================================================
-- COMMANDS INITIALIZATION
-- ============================================================================

function HideUI.Commands.Initialize()
    SLASH_HIDEUI1 = "/hideui"
    SLASH_HIDEUI2 = "/hui"
    
    SlashCmdList["HIDEUI"] = HideUI.Commands.HandleSlashCommand
end

HideUI.Commands.Initialize()