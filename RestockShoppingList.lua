-- RestockShoppingList.lua
local addonName, addonTable = ...
local RestockShoppingList = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
addonTable.Core = RestockShoppingList

local defaults = {
    char = {
        lists = {}
    }
}

function RestockShoppingList:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RestockShoppingListDB", defaults, true)
    
    -- Polyfill for removed UIDropDownMenu_SetIcon to prevent errors in UI
    if not UIDropDownMenu_SetIcon then
        UIDropDownMenu_SetIcon = function() end
    end

    self:RegisterChatCommand("rsl", "ToggleUI")
    self:SetupOptions()
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

function RestockShoppingList:SetupOptions()
    local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
    local panel = CreateFrame("Frame", "RestockShoppingListOptionsPanel", UIParent)
    panel.name = "RestockShoppingList"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L["TITLE"])

    local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    text:SetText(L["OPTIONS_INFO"])

    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -20)
    btn:SetText(L["OPTIONS_OPEN_BUTTON"])
    btn:SetWidth(150)
    btn:SetScript("OnClick", function()
        self:ToggleUI()
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category, layout = Settings.RegisterCanvasLayoutCategory(panel, "RestockShoppingList")
        Settings.RegisterAddOnCategory(category)
    else
        InterfaceOptions_AddCategory(panel)
    end
end