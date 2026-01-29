-- RestockShoppingList_UI.lua
local addonName, addonTable = ...
local UI = {}
addonTable.UI = UI
local Core = addonTable.Core
local AceGUI = LibStub("AceGUI-3.0")

local currentListIndex = nil

function UI:UpdateControlStates()
    if not self.frame then return end
    local listSelected = (currentListIndex ~= nil)

    -- List modification buttons
    self.deleteListButton:SetDisabled(not listSelected)
    self.renameListButton:SetDisabled(not listSelected)
    if self.exportListButton then
        self.exportListButton:SetDisabled(not listSelected)
    end

    -- Add item controls
    self.addItemEdit:SetDisabled(not listSelected)
    self.addItemButton:SetDisabled(not listSelected)
end

function UI:Initialize()
    if self.frame then return end

    self.frame = AceGUI:Create("Frame")
    self.frame:SetTitle("Restock Shopping List")
    self.frame:SetStatusText("Restock Shopping List")
    self.frame:SetCallback("OnClose", function(widget) widget.frame:Hide() end)
    self.frame:SetLayout("Flow")
    self.frame:SetWidth(755)

    -- Enable closing with Escape key
    _G["RestockShoppingListFrame"] = self.frame.frame
    table.insert(UISpecialFrames, "RestockShoppingListFrame")
    
    -- Container for list selection controls
    local topContainer = AceGUI:Create("SimpleGroup")
    topContainer:SetLayout("Flow")
    topContainer:SetFullWidth(true)
    self.frame:AddChild(topContainer)

    self.listDropdown = AceGUI:Create("Dropdown")
    self.listDropdown:SetLabel("List")
    self.listDropdown:SetCallback("OnValueChanged", function(widget, event, key)
        currentListIndex = key
        self:RefreshItems()
        self:UpdateControlStates()
    end)
    topContainer:AddChild(self.listDropdown)

    local addListButton = AceGUI:Create("Button")
    addListButton:SetText("Add")
    addListButton:SetWidth(100)
    addListButton:SetCallback("OnClick", function()
        StaticPopup_Show("RSL_NEW_LIST")
    end)
    topContainer:AddChild(addListButton)

    self.deleteListButton = AceGUI:Create("Button")
    self.deleteListButton:SetText("Delete")
    self.deleteListButton:SetWidth(100)
    self.deleteListButton:SetCallback("OnClick", function()
        if currentListIndex then
            local numLists = #Core:GetLists()
            Core:DeleteList(currentListIndex)

            if numLists <= 1 then
                currentListIndex = nil
            elseif currentListIndex > #Core:GetLists() then
                currentListIndex = nil
            end

            self:RefreshLists()
            self:RefreshItems()
            self:UpdateControlStates()
        end
    end)
    topContainer:AddChild(self.deleteListButton)

    self.renameListButton = AceGUI:Create("Button")
    self.renameListButton:SetText("Rename")
    self.renameListButton:SetWidth(100)
    self.renameListButton:SetCallback("OnClick", function()
        if currentListIndex then
            StaticPopup_Show("RSL_RENAME_LIST")
        end
    end)
    topContainer:AddChild(self.renameListButton)

    self.exportListButton = AceGUI:Create("Button")
    self.exportListButton:SetText("Export")
    self.exportListButton:SetWidth(100)
    self.exportListButton:SetCallback("OnClick", function()
        if currentListIndex then
            local data = Core:ExportList(currentListIndex)
            if data then
                StaticPopup_Show("RSL_EXPORT", nil, nil, data)
            end
        end
    end)
    topContainer:AddChild(self.exportListButton)

    self.importListButton = AceGUI:Create("Button")
    self.importListButton:SetText("Import")
    self.importListButton:SetWidth(100)
    self.importListButton:SetCallback("OnClick", function()
        StaticPopup_Show("RSL_IMPORT")
    end)
    topContainer:AddChild(self.importListButton)

    -- Visual separator
    local separator = AceGUI:Create("Heading")
    separator:SetText("")
    separator:SetFullWidth(true)
    self.frame:AddChild(separator)

    -- Container for Add Item controls
    local addItemContainer = AceGUI:Create("SimpleGroup")
    addItemContainer:SetLayout("Flow")
    addItemContainer:SetFullWidth(true)
    self.frame:AddChild(addItemContainer)

    self.addItemEdit = AceGUI:Create("EditBox")
    self.addItemEdit:SetLabel("Add Item")
    self.addItemEdit:SetWidth(200)
    self.addItemEdit:SetCallback("OnEnterPressed", function(widget, event, text)
        self:HandleAddItem(text)
        widget:SetText("")
    end)
    addItemContainer:AddChild(self.addItemEdit)

    self.addItemButton = AceGUI:Create("Button")
    self.addItemButton:SetText("Add Item")
    self.addItemButton:SetWidth(150)
    self.addItemButton:SetCallback("OnClick", function()
        self:HandleAddItem(self.addItemEdit:GetText())
        self.addItemEdit:SetText("")
    end)
    addItemContainer:AddChild(self.addItemButton)

    -- Container for the item list
    self.itemScroll = AceGUI:Create("ScrollFrame")
    self.itemScroll:SetLayout("List")
    self.itemScroll:SetFullWidth(true)
    self.itemScroll:SetFullHeight(true)
    self.frame:AddChild(self.itemScroll)
    
    -- Popups
    StaticPopupDialogs["RSL_NEW_LIST"] = {
        text = "Name of the new list:",
        button1 = "Create",
        button2 = "Cancel",
        hasEditBox = true,
        OnShow = function(self)
            if self.data then
                self.EditBox:SetText(self.data)
                self.EditBox:HighlightText()
            end
        end,
        OnAccept = function(self)
            local text = self.EditBox:GetText()
            if text and text ~= "" then
                if not Core:AddList(text) then
                    local failedText = text
                    C_Timer.After(0.1, function()
                        StaticPopup_Show("RSL_NEW_LIST", nil, nil, failedText)
                    end)
                end
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            StaticPopup_OnClick(parent, 1)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopupDialogs["RSL_RENAME_LIST"] = {
        text = "New name for the list:",
        button1 = "Rename",
        button2 = "Cancel",
        hasEditBox = true,
        OnShow = function(self)
            if self.data then
                self.EditBox:SetText(self.data)
                self.EditBox:HighlightText()
            elseif currentListIndex then
                local list = Core:GetLists()[currentListIndex]
                if list then
                    self.EditBox:SetText(list.name)
                    self.EditBox:HighlightText()
                end
            end
        end,
        OnAccept = function(self)
            local text = self.EditBox:GetText()
            if text and text ~= "" and currentListIndex then
                if not Core:RenameList(currentListIndex, text) then
                    local failedText = text
                    C_Timer.After(0.1, function()
                        StaticPopup_Show("RSL_RENAME_LIST", nil, nil, failedText)
                    end)
                end
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            StaticPopup_OnClick(parent, 1)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopupDialogs["RSL_EXPORT"] = {
        text = "Export Code (Ctrl+C to copy):",
        button1 = "Close",
        hasEditBox = true,
        OnShow = function(self)
            if self.data then
                self.EditBox:SetText(self.data)
                self.EditBox:HighlightText()
                self.EditBox:SetScript("OnChar", function(eb) eb:SetText(self.data); eb:HighlightText(); end)
            end
        end,
        EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
        EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopupDialogs["RSL_IMPORT"] = {
        text = "Paste Export Code here:",
        button1 = "Import",
        button2 = "Cancel",
        hasEditBox = true,
        OnAccept = function(self)
            local text = self.EditBox:GetText()
            if text and text ~= "" then
                Core:ImportList(text)
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            StaticPopup_OnClick(parent, 1)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    self:RefreshLists()
    self:UpdateControlStates()
end

function UI:HandleAddItem(text)
    if not currentListIndex then
        -- This check is now backed up by disabled controls
        return
    end
    if text == "" then return end

    local itemID, itemName
    if string.match(text, "item:(%d+)") then
        itemID = tonumber(string.match(text, "item:(%d+)"))
        itemName = GetItemInfo(itemID)
    elseif tonumber(text) then
        itemID = tonumber(text)
        itemName = GetItemInfo(itemID)
    else
        itemName = text
        local _, link = GetItemInfo(itemName)
        if link then
            itemID = tonumber(string.match(link, "item:(%d+)"))
        else
            itemID = 0 -- Fallback, maybe notify user?
        end
    end

    if not itemName then itemName = text end

    Core:AddItemToList(currentListIndex, itemID, itemName, 1, 3)
    self:RefreshItems()
end

function UI:SelectList(index)
    currentListIndex = index
    self:RefreshLists()
    self:RefreshItems()
    self:UpdateControlStates()
end

function UI:RefreshLists()
    if not self.frame then return end
    local lists = Core:GetLists()
    local listData = {}
    for i, list in ipairs(lists) do
        listData[i] = list.name
    end
    self.listDropdown:SetList(listData)
    self.listDropdown:SetValue(currentListIndex)
end

function UI:RefreshItems()
    if not self.frame then return end
    self.itemScroll:ReleaseChildren()
    if not currentListIndex then return end

    local list = Core:GetLists()[currentListIndex]
    if not list then return end

    -- Header
    local headerGroup = AceGUI:Create("SimpleGroup")
    headerGroup:SetLayout("Flow")
    --headerGroup:SetWidth(800)
    headerGroup:SetFullWidth(true)
    -- Clean up potential background from recycled frames
    if headerGroup.frame.rsl_bg then
        headerGroup.frame.rsl_bg:Hide()
    end
    self.itemScroll:AddChild(headerGroup)

    local iconHeader = AceGUI:Create("Label")
    iconHeader:SetText("")
    iconHeader:SetWidth(30)
    headerGroup:AddChild(iconHeader)

    local nameLabel = AceGUI:Create("Label")
    nameLabel:SetText("Item Name")
    nameLabel:SetWidth(250)
    headerGroup:AddChild(nameLabel)

    local qtyLabel = AceGUI:Create("Label")
    qtyLabel:SetText("Qty")
    qtyLabel:SetWidth(75)
    headerGroup:AddChild(qtyLabel)

    local qualityLabel = AceGUI:Create("Label")
    qualityLabel:SetText("Quality")
    qualityLabel:SetWidth(75)
    headerGroup:AddChild(qualityLabel)

    local delSpacer = AceGUI:Create("Label")
    delSpacer:SetText(" ")
    delSpacer:SetWidth(40)
    headerGroup:AddChild(delSpacer)

    for i, item in ipairs(list.items) do
        local itemGroup = AceGUI:Create("SimpleGroup")
        itemGroup:SetLayout("Flow")
        itemGroup:SetFullWidth(true)

        -- Background for table look (Zebra-Striping)
        local bg = itemGroup.frame.rsl_bg
        if not bg then
            bg = itemGroup.frame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            itemGroup.frame.rsl_bg = bg
        end
        bg:Show()
        if i % 2 == 0 then
            bg:SetColorTexture(1, 1, 1, 0.05) -- Even rows slightly lighter
        else
            bg:SetColorTexture(0, 0, 0, 0.2)  -- Odd rows slightly darker
        end

        self.itemScroll:AddChild(itemGroup)

        local iconTexture = GetItemIcon(item.itemID) or 134400 -- 134400 = Question Mark
        local iconLabel = AceGUI:Create("Label")
        iconLabel:SetText("|T"..iconTexture..":24:24|t")
        iconLabel:SetWidth(30)
        itemGroup:AddChild(iconLabel)

        local label = AceGUI:Create("Label")
        label:SetText(item.name)
        label:SetWidth(250)
        itemGroup:AddChild(label)

        local qtyEdit = AceGUI:Create("EditBox")
        qtyEdit:SetWidth(75)
        qtyEdit:SetText(item.qty)
        qtyEdit:SetCallback("OnTextChanged", function(widget, event, text)
            Core:UpdateItem(currentListIndex, i, tonumber(text) or 1, item.quality)
        end)
        itemGroup:AddChild(qtyEdit)

        local qualityDropdown = AceGUI:Create("Dropdown")
        local qualityList = {
            [0] = "Any",
            [1] = "|A:Professions-Icon-Quality-Tier1-Small:16:16|a",
            [2] = "|A:Professions-Icon-Quality-Tier2-Small:16:16|a",
            [3] = "|A:Professions-Icon-Quality-Tier3-Small:16:16|a"
        }
        qualityDropdown:SetList(qualityList)
        qualityDropdown:SetValue(item.quality)
        qualityDropdown:SetWidth(75)
        qualityDropdown:SetCallback("OnValueChanged", function(widget, event, key)
            Core:UpdateItem(currentListIndex, i, tonumber(qtyEdit:GetText()) or 1, key)
            item.quality = key -- Update our local copy for the qtyEdit callback
        end)
        itemGroup:AddChild(qualityDropdown)

        local delBtn = AceGUI:Create("Button")
        delBtn:SetText("X")
        delBtn:SetWidth(40)
        delBtn:SetCallback("OnClick", function()
            Core:RemoveItemFromList(currentListIndex, i)
            self:RefreshItems()
        end)
        itemGroup:AddChild(delBtn)
    end
end

function UI:Toggle()
    if not self.frame then
        self:Initialize()
        self.frame.frame:Show()
    else
        if self.frame.frame:IsShown() then
            self.frame.frame:Hide()
        else
            self.frame.frame:Show()
        end
    end
end
