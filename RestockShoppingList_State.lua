local addonName, addonTable = ...
local Core = addonTable.Core
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function Core:GetLists()
    return self.db.char.lists
end

function Core:AddList(name)
    for _, list in ipairs(self.db.char.lists) do
        if strlower(list.name) == strlower(name) then
            self:Print(L["ERROR_LIST_EXISTS"]:format(name))
            return false
        end
    end

    table.insert(self.db.char.lists, { name = name, items = {} })
    addonTable.UI:SelectList(#self.db.char.lists)
    return true
end

function Core:DeleteList(index)
    table.remove(self.db.char.lists, index)
    addonTable.UI:SelectList(nil)
end

function Core:RenameList(index, newName)
    for i, list in ipairs(self.db.char.lists) do
        if i ~= index and strlower(list.name) == strlower(newName) then
            self:Print(L["ERROR_LIST_EXISTS"]:format(newName))
            return false
        end
    end
    
    if self.db.char.lists[index] then
        self.db.char.lists[index].name = newName
        addonTable.UI:RefreshLists()
        return true
    end
    return false
end

function Core:AddItemToList(listIndex, itemID, qty, quality)
    if not self.db.char.lists[listIndex] then return end

    for _, item in ipairs(self.db.char.lists[listIndex].items) do
        if item.itemID == itemID then
            return
        end
    end

    table.insert(self.db.char.lists[listIndex].items, {
        itemID = itemID,
        qty = qty or 1,
        quality = quality or 0 -- 0=Egal, 1=T1, 2=T2, 3=T3, 4=T1(12), 5=T2(12)
    })

    table.sort(self.db.char.lists[listIndex].items, function(a, b)
        local nameA = GetItemInfo(a.itemID) or tostring(a.itemID)
        local nameB = GetItemInfo(b.itemID) or tostring(b.itemID)
        return strlower(nameA) < strlower(nameB)
    end)

    addonTable.UI:RefreshItems(listIndex)
end

function Core:RemoveItemFromList(listIndex, itemIndex)
    if not self.db.char.lists[listIndex] then return end
    table.remove(self.db.char.lists[listIndex].items, itemIndex)
    addonTable.UI:RefreshItems(listIndex)
end

function Core:UpdateItem(listIndex, itemIndex, qty, quality)
    local item = self.db.char.lists[listIndex].items[itemIndex]
    if item then
        item.qty = qty
        item.quality = quality
    end
end

function Core:ResolveItemID(text)
    if not text or text == "" then return nil end
    
    local itemID
    if string.match(text, "item:(%d+)") then
        itemID = tonumber(string.match(text, "item:(%d+)"))
    elseif tonumber(text) then
        itemID = tonumber(text)
    else
        local _, link = GetItemInfo(text)
        if link then
            itemID = tonumber(string.match(link, "item:(%d+)"))
        end
    end
    return itemID
end

function Core:GetItemDefaults(itemID)
    -- Determine Quantity from Inventory
    local count = C_Item.GetItemCount(itemID, true, false, true)
    local qty = (count and count > 0) and count or 1

    -- Determine Quality
    local quality = 0
    local reagentQuality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID)
    if reagentQuality then
        quality = reagentQuality
    else
        local _, link = GetItemInfo(itemID)
        if link then
            local craftedQuality = C_TradeSkillUI.GetItemCraftedQualityByItemInfo(link)
            quality = craftedQuality or 0

            -- Check for midnight icons in item link
            if (quality == 1 or quality == 2) and link:find("Professions%-ChatIcon%-Quality%-12") then
                quality = (quality == 1) and 4 or 5
            end
        end
    end
    return qty, quality
end