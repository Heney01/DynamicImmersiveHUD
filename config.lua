-- Config.lua
-- Configuration of interface elements to hide

HideUI = HideUI or {}
HideUI.Config = {}

-- ============================================================================
-- CONFIGURATION OF ELEMENTS TO HIDE
-- ============================================================================

-- Main action bars (bottom of screen)
HideUI.Config.mainActionBars = {
    "ActionBarFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
    "StanceBarFrame", "PetActionBarFrame",
    "StanceButton1", "StanceButton2", "StanceButton3", "StanceButton4", "StanceButton5",
    "StanceButton6", "StanceButton7", "StanceButton8", "StanceButton9", "StanceButton10"
}

-- Side action bars (sides of screen)
HideUI.Config.sideActionBars = {
    "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7"
}

-- Complete action bars list
HideUI.Config.actionBars = {}
for _, bar in pairs(HideUI.Config.mainActionBars) do
    table.insert(HideUI.Config.actionBars, bar)
end
for _, bar in pairs(HideUI.Config.sideActionBars) do
    table.insert(HideUI.Config.actionBars, bar)
end

-- Main interface elements 
HideUI.Config.uiElements = {
    -- Player and target frames
    "PlayerFrame", "TargetFrame",
    -- Quests and objectives
    "ObjectiveTrackerFrame", "QuestWatchFrame",
    -- Main bars and experience
    "MainMenuBar", "StatusTrackingBarManager", "ExperienceBarFrame", "ReputationBarFrame",
    -- Interface art
    "MainMenuBarArtFrame", "MainMenuBarArtFrameBackground",
    "MainMenuBarLeftEndCap", "MainMenuBarRightEndCap",
    -- Navigation buttons
    "ActionBarUpButton", "ActionBarDownButton", "MainMenuBarPageNumber",
    -- Buffs and debuffs
    "BuffFrame", "DebuffFrame", "CastingBarFrame",
    -- Stances and shapeshifts
    "StanceBarLeft", "StanceBarMiddle", "StanceBarRight", "ShapeshiftBarFrame",
    "ShapeshiftButton1", "ShapeshiftButton2", "ShapeshiftButton3", "ShapeshiftButton4", "ShapeshiftButton5",
    "ShapeshiftButton6", "ShapeshiftButton7", "ShapeshiftButton8", "ShapeshiftButton9", "ShapeshiftButton10",
    -- Misc elements
    "KeyRingButton", "QuickJoinToastButton", "GameMenuFrame", "ChatFrameSocialTab"
}

-- Chat elements to hide
HideUI.Config.chatElements = {
    "ChatFrameChannelButton", "ChatFrameToggleVoiceDeafenButton", "ChatFrameToggleVoiceMuteButton",
    "ChatFrame1EditBox", "ChatFrame1ButtonFrame", "GeneralDockManager", "ChatFrame1ResizeButton",
    "ChatFrameMenuButton", "ChatFrame1TabText", "ChatFrame1ButtonFrameUpButton",
    "ChatFrame1ButtonFrameDownButton", "ChatFrame1ButtonFrameBottomButton", "ChatFrame1ButtonFrameMinimizeButton"
}

-- ============================================================================
-- HOVER CONFIGURATION 
-- ============================================================================

HideUI.Config.hoverZones = {
    chat = {
        region = {left = 0, right = 450, bottom = 0, top = 350},
        elements = "chat",
        delay = 3
    },
    mainBars = {
        region = {left = 500, right = 0, bottom = 0, top = 120}, -- right will be calculated dynamically
        elements = "mainBars",
        delay = 2
    },
    sideBars = {
        region = {left = 0, right = 0, bottom = 120, top = 0}, -- calculated dynamically
        elements = "sideBars",
        delay = 2
    },
    objectives = {
        region = {left = 0, right = 0, bottom = 150, top = 0}, -- calculated dynamically
        elements = "objectives",
        delay = 3
    }
}

-- ============================================================================
-- TEMPORARY CHAT CONFIGURATION
-- ============================================================================

-- Message types to show temporarily
HideUI.Config.importantChatTypes = {
    ["CHAT_MSG_WHISPER"] = true,           -- Received whispers
    ["CHAT_MSG_WHISPER_INFORM"] = true,    -- Sent whispers
    ["CHAT_MSG_PARTY"] = true,             -- Party messages
    ["CHAT_MSG_PARTY_LEADER"] = true,      -- Party leader messages
    ["CHAT_MSG_RAID"] = true,              -- Raid messages
    ["CHAT_MSG_RAID_LEADER"] = true,       -- Raid leader messages
    ["CHAT_MSG_RAID_WARNING"] = true,      -- Raid warnings
    ["CHAT_MSG_GUILD"] = true,             -- Guild messages
    ["CHAT_MSG_OFFICER"] = true,           -- Officer messages
    ["CHAT_MSG_INSTANCE_CHAT"] = true,     -- Instance messages
    ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = true -- Instance leader messages
}

-- ============================================================================
-- CONFIGURATION UTILITY FUNCTIONS
-- ============================================================================

-- Update hover zones dynamically
function HideUI.Config.UpdateHoverZones()
    local screenWidth = UIParent:GetWidth()
    local screenHeight = UIParent:GetHeight()
    
    -- Main bars zone
    HideUI.Config.hoverZones.mainBars.region.right = screenWidth
    
    -- Side bars zone
    HideUI.Config.hoverZones.sideBars.region.left = screenWidth - 150
    HideUI.Config.hoverZones.sideBars.region.right = screenWidth
    HideUI.Config.hoverZones.sideBars.region.top = screenHeight - 200
    
    -- Objectives zone
    HideUI.Config.hoverZones.objectives.region.left = screenWidth - 400
    HideUI.Config.hoverZones.objectives.region.right = screenWidth - 150
    HideUI.Config.hoverZones.objectives.region.top = screenHeight - 100

end