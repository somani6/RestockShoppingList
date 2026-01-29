local addonName, addonTable = ...
local Core = addonTable.Core

function Core:ExportList(index)
    local list = self.db.char.lists[index]
    if not list then return nil end
    return self:Serialize(list)
end

function Core:ImportList(dataString)
    local success, list = self:Deserialize(dataString)
    if not success then
        self:Print("Import failed: Invalid data.")
        return false
    end
    
    if type(list) ~= "table" or not list.name or not list.items then
        self:Print("Import failed: Invalid list format.")
        return false
    end

    -- Check if list exists (case-insensitive) to update
    local existingIndex = nil
    for i, l in ipairs(self.db.char.lists) do
        if strlower(l.name) == strlower(list.name) then
            existingIndex = i
            break
        end
    end

    if existingIndex then
        self.db.char.lists[existingIndex] = list
        self:Print("List '"..list.name.."' has been updated.")
        addonTable.UI:SelectList(existingIndex)
    else
        table.insert(self.db.char.lists, list)
        self:Print("List '"..list.name.."' has been imported.")
        addonTable.UI:SelectList(#self.db.char.lists)
    end
    return true
end