-- RestockShoppingList.lua
-- RestockShoppingList.lua (Core Logic)

local addonName, addonTable = ...
local RestockShoppingList = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
addonTable.Core = RestockShoppingList

-- Default values for the database
local defaults = {
    char = {
        lists = {}
    }
}

function RestockShoppingList:OnInitialize()
    -- Load database
    self.db = LibStub("AceDB-3.0"):New("RestockShoppingListDB", defaults, true)
    
    -- Polyfill for removed UIDropDownMenu_SetIcon to prevent errors in UI
    if not UIDropDownMenu_SetIcon then
        UIDropDownMenu_SetIcon = function() end
    end

    -- Register slash command
    self:RegisterChatCommand("rsl", "ToggleUI")
end

function RestockShoppingList:ToggleUI()
    if addonTable.UI then
        addonTable.UI:Toggle()
    end
end

function RestockShoppingList:OnEnable()
    self:RegisterEvent("AUCTION_HOUSE_SHOW")
    self:RegisterEvent("AUCTION_HOUSE_CLOSED")
end

function RestockShoppingList:AUCTION_HOUSE_SHOW()
        self:ExportToAuctionator()
end

function RestockShoppingList:AUCTION_HOUSE_CLOSED()
        self:CleanupAuctionatorLists()
end