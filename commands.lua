-- Commands.lua

HideUI = HideUI or {}
HideUI.Commands = {}

-- ============================================================================
-- COMMANDES SLASH
-- ============================================================================

function HideUI.Commands.HandleSlashCommand(msg)
    local originalMsg = msg
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
        -- NOUVEAU: Toggle bags
        if HideUI.Core then
            HideUI.Core.ToggleBags()
        end
    elseif msg == "show" or msg == "afficher" then
        -- Maintenant c'est un smart switch
        if HideUI.Core then
            HideUI.Core.ShowAll()
        end
    elseif msg == "auto" or msg == "autohide" then
        if HideUI.Core then
            HideUI.Core.ToggleAutoHide()
        end
    elseif msg == "toggle" then
        -- NOUVEAU: Toggle activation de l'addon
        if HideUI.Core then
            HideUI.Core.ToggleAddon()
        end
    elseif msg == "smart" or msg == "force" then
        -- NOUVEAU: Smart toggle force hide/show
        if HideUI.Core then
            HideUI.Core.SmartToggle()
        end
    elseif msg == "keys" or msg == "keybinds" or msg == "raccourcis" then
        -- Show current keybinding status
        if HideUI.Keybinds then
            HideUI.Keybinds.ShowStatus()
        end
    elseif msg:match("^setkey") then
        -- Handle setkey command
        HideUI.Commands.HandleSetKeyCommand(originalMsg)
    elseif msg == "reset" then
        HideUI.Commands.ResetAddon()
    elseif msg == "fix" or msg == "repair" then
        -- Nouvelle commande: réparer les éléments système
        HideUI.Commands.FixSystemElements()
    elseif msg == "help" or msg == "aide" then
        HideUI.Commands.ShowHelp()
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
    if HideUI.Targeting then
        HideUI.Targeting.CancelTemporary()
    end
    if HideUI.Bags then
        HideUI.Bags.CancelTemporary()
    end
    
    if HideUI.Core then
        HideUI.Core.ShowAll()
    end
    
    HideUI.State.combatOverrideActive = false
    
    -- S'assurer que les éléments système sont visibles
    if HideUI.Core then
        HideUI.Core.EnsureCriticalElementsVisible()
    end
    
end

-- Nouveau: Réparer les éléments système
function HideUI.Commands.FixSystemElements()
    if HideUI.Core then
        HideUI.Core.EnsureCriticalElementsVisible()
    end
    
    -- Force restauration des éléments critiques
    local criticalElements = {
        "GameMenuFrame", "InterfaceOptionsFrame", "VideoOptionsFrame", 
        "AudioOptionsFrame", "ChatConfigFrame", "KeyBindingFrame", "MacroFrame"
    }
    
    for _, elementName in pairs(criticalElements) do
        local element = _G[elementName]
        if element then
            element:SetAlpha(1)
        end
    end
end

-- Handle setkey command
function HideUI.Commands.HandleSetKeyCommand(msg)
    if not HideUI.Keybinds then
        return
    end
    
    -- Extract the key part after "setkey"
    local keyPart = msg:match("^[Ss][Ee][Tt][Kk][Ee][Yy]%s+(.*)$")
    
    if not keyPart or keyPart == "" then
        return
    end
    
    keyPart = keyPart:trim()
    
    -- Handle special commands
    if keyPart:lower() == "clear" or keyPart:lower() == "remove" or keyPart:lower() == "none" then
        HideUI.Keybinds.SetCustomKey("")
        return
    end
    
    -- Check for confirm flag
    local isConfirm = keyPart:match("%s+confirm$")
    if isConfirm then
        keyPart = keyPart:gsub("%s+confirm$", "")
        HideUI.Keybinds.SetCustomKeyForced(keyPart:upper())
    else
        HideUI.Keybinds.SetCustomKey(keyPart:upper())
    end
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