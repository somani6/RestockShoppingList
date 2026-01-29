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

function Core:AddItemToList(listIndex, itemID, name, qty, quality)
    if not self.db.char.lists[listIndex] then return end

    -- Check for duplicates
    for _, item in ipairs(self.db.char.lists[listIndex].items) do
        if (itemID and itemID ~= 0 and item.itemID == itemID) or (name and strlower(item.name) == strlower(name)) then
            return
        end
    end

    table.insert(self.db.char.lists[listIndex].items, {
        itemID = itemID,
        name = name,
        qty = qty or 1,
        quality = quality or 0 -- 0=Egal, 1=T1, 2=T2, 3=T3
    })

    table.sort(self.db.char.lists[listIndex].items, function(a, b)
        return strlower(a.name) < strlower(b.name)
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