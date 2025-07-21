-- Config.lua
-- Configuration des éléments d'interface à masquer

HideUI = HideUI or {}
HideUI.Config = {}

-- ============================================================================
-- CONFIGURATION DES ÉLÉMENTS À MASQUER
-- ============================================================================

-- Barres d'action principales (bas de l'écran)
HideUI.Config.mainActionBars = {
    "ActionBarFrame", "MultiBarBottomLeft", "MultiBarBottomRight",
    "StanceBarFrame", "PetActionBarFrame",
    "StanceButton1", "StanceButton2", "StanceButton3", "StanceButton4", "StanceButton5",
    "StanceButton6", "StanceButton7", "StanceButton8", "StanceButton9", "StanceButton10"
}

-- Barres d'action latérales (côtés de l'écran)
HideUI.Config.sideActionBars = {
    "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7"
}

-- Liste complète des barres d'action
HideUI.Config.actionBars = {}
for _, bar in pairs(HideUI.Config.mainActionBars) do
    table.insert(HideUI.Config.actionBars, bar)
end
for _, bar in pairs(HideUI.Config.sideActionBars) do
    table.insert(HideUI.Config.actionBars, bar)
end

-- Éléments d'interface principaux
HideUI.Config.uiElements = {
    -- Cadres de joueur et cible
    "PlayerFrame", "TargetFrame",
    -- Quêtes et objectifs
    "ObjectiveTrackerFrame", "QuestWatchFrame",
    -- Barres principales et expérience
    "MainMenuBar", "StatusTrackingBarManager", "ExperienceBarFrame", "ReputationBarFrame",
    -- Art de l'interface
    "MainMenuBarArtFrame", "MainMenuBarArtFrameBackground",
    "MainMenuBarLeftEndCap", "MainMenuBarRightEndCap",
    -- Boutons de navigation
    "ActionBarUpButton", "ActionBarDownButton", "MainMenuBarPageNumber",
    -- Buffs et debuffs
    "BuffFrame", "DebuffFrame", "CastingBarFrame",
    -- Micro menu et boutons sociaux
    "MicroButtonAndBagsBar", "MicroMenuContainer", "MicroButtonFrame",
    "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton",
    "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton",
    "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton",
    "StoreMicroButton", "MainMenuMicroButton", "HelpMicroButton",
    "SocialsMicroButton", "WorldMapMicroButton",
    -- Postures et métamorphoses
    "StanceBarLeft", "StanceBarMiddle", "StanceBarRight", "ShapeshiftBarFrame",
    "ShapeshiftButton1", "ShapeshiftButton2", "ShapeshiftButton3", "ShapeshiftButton4", "ShapeshiftButton5",
    "ShapeshiftButton6", "ShapeshiftButton7", "ShapeshiftButton8", "ShapeshiftButton9", "ShapeshiftButton10",
    -- Éléments divers
    "KeyRingButton", "QuickJoinToastButton", "GameMenuFrame", "ChatFrameSocialTab"
}

-- Éléments de sacs à masquer (séparés des autres éléments UI)
HideUI.Config.bagElements = {
    "BagBarFrame", "MainMenuBarBackpackButton", "BackpackTokenFrame",
    "CharacterBag0Slot", "CharacterBag1Slot", "CharacterBag2Slot", "CharacterBag3Slot", "CharacterBag4Slot",
    "BagsBar", "BagSlotButton", "MainMenuBarBagButtons",
    "ContainerFrameCombinedBags", "CombinedBagContainer"
}

-- Éléments de chat à masquer
HideUI.Config.chatElements = {
    "ChatFrameChannelButton", "ChatFrameToggleVoiceDeafenButton", "ChatFrameToggleVoiceMuteButton",
    "ChatFrame1EditBox", "ChatFrame1ButtonFrame", "GeneralDockManager", "ChatFrame1ResizeButton",
    "ChatFrameMenuButton", "ChatFrame1TabText", "ChatFrame1ButtonFrameUpButton",
    "ChatFrame1ButtonFrameDownButton", "ChatFrame1ButtonFrameBottomButton", "ChatFrame1ButtonFrameMinimizeButton"
}

-- ============================================================================
-- CONFIGURATION DU SURVOL
-- ============================================================================

-- Zones de survol pour différents éléments
HideUI.Config.hoverZones = {
    chat = {
        region = {left = 0, right = 450, bottom = 0, top = 350},
        elements = "chat",
        delay = 3
    },
    mainBars = {
        region = {left = 500, right = 0, bottom = 0, top = 120}, -- right sera calculé dynamiquement
        elements = "mainBars",
        delay = 2
    },
    sideBars = {
        region = {left = 0, right = 0, bottom = 120, top = 0}, -- calculé dynamiquement
        elements = "sideBars",
        delay = 2
    },
    objectives = {
        region = {left = 0, right = 0, bottom = 150, top = 0}, -- calculé dynamiquement
        elements = "objectives",
        delay = 3
    },
    bags = {
        region = {left = 0, right = 0, bottom = 0, top = 100}, -- calculé dynamiquement
        elements = "bags",
        delay = 2
    }
}

-- ============================================================================
-- CONFIGURATION DU CHAT TEMPORAIRE
-- ============================================================================

-- Types de messages à afficher temporairement
HideUI.Config.importantChatTypes = {
    ["CHAT_MSG_WHISPER"] = true,           -- Messages privés reçus
    ["CHAT_MSG_WHISPER_INFORM"] = true,    -- Messages privés envoyés
    ["CHAT_MSG_PARTY"] = true,             -- Messages de groupe
    ["CHAT_MSG_PARTY_LEADER"] = true,      -- Messages du chef de groupe
    ["CHAT_MSG_RAID"] = true,              -- Messages de raid
    ["CHAT_MSG_RAID_LEADER"] = true,       -- Messages du chef de raid
    ["CHAT_MSG_RAID_WARNING"] = true,      -- Avertissements de raid
    ["CHAT_MSG_GUILD"] = true,             -- Messages de guilde
    ["CHAT_MSG_OFFICER"] = true,           -- Messages d'officier
    ["CHAT_MSG_INSTANCE_CHAT"] = true,     -- Messages d'instance
    ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = true -- Messages du chef d'instance
}

-- ============================================================================
-- CONFIGURATION DEBUG
-- ============================================================================

-- Éléments à vérifier dans le debug
HideUI.Config.debugFrames = {
    "MicroButtonAndBagsBar", "MicroMenuContainer", "MicroButtonFrame",
    "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton",
    "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton",
    "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton",
    "StoreMicroButton", "MainMenuMicroButton", "HelpMicroButton",
    "SocialsMicroButton", "WorldMapMicroButton", "BagBarFrame",
    "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
    "CharacterBag2Slot", "CharacterBag3Slot", "CharacterBag4Slot",
    "QuickJoinToastButton", "BagSlotButton", "MainMenuBarBagButtons",
    "BagsBar", "ContainerFrameCombinedBags", "CombinedBagContainer"
}

-- ============================================================================
-- FONCTIONS UTILITAIRES DE CONFIGURATION
-- ============================================================================

-- Met à jour les zones de survol dynamiquement
function HideUI.Config.UpdateHoverZones()
    local screenWidth = UIParent:GetWidth()
    local screenHeight = UIParent:GetHeight()
    
    -- Zone des barres principales
    HideUI.Config.hoverZones.mainBars.region.right = screenWidth
    
    -- Zone des barres latérales
    HideUI.Config.hoverZones.sideBars.region.left = screenWidth - 150
    HideUI.Config.hoverZones.sideBars.region.right = screenWidth
    HideUI.Config.hoverZones.sideBars.region.top = screenHeight - 200
    
    -- Zone des objectifs
    HideUI.Config.hoverZones.objectives.region.left = screenWidth - 400
    HideUI.Config.hoverZones.objectives.region.right = screenWidth - 150
    HideUI.Config.hoverZones.objectives.region.top = screenHeight - 100
    
    -- Zone des sacs
    HideUI.Config.hoverZones.bags.region.left = screenWidth - 200
    HideUI.Config.hoverZones.bags.region.right = screenWidth
end