local addonName, addonTable = ...
local Core = addonTable.Core

-- --- Data Management ---

function Core:GetLists()
    return self.db.char.lists
end

function Core:AddList(name)
    -- Check for duplicate name (case-insensitive)
    for _, list in ipairs(self.db.char.lists) do
        if strlower(list.name) == strlower(name) then
            self:Print("A list with the name '"..name.."' already exists.")
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
     -- Check for duplicate name (case-insensitive)
    for i, list in ipairs(self.db.char.lists) do
        if i ~= index and strlower(list.name) == strlower(newName) then
            self:Print("A list with the name '"..newName.."' already exists.")
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

    -- Check for duplicates
    for _, item in ipairs(self.db.char.lists[listIndex].items) do
        if item.itemID == itemID then
            return
        end
    end

    table.insert(self.db.char.lists[listIndex].items, {
        itemID = itemID,
        qty = qty or 1,
        quality = quality or 0 -- 0=Egal, 1=T1, 2=T2, 3=T3
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