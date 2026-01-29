local addonName, addonTable = ...
local Core = addonTable.Core

-- --- Auctionator Integration ---

function Core:CleanupAuctionatorLists()
    for _, list in ipairs(self.db.char.lists) do
        --Auctionator.API.v1.DeleteShoppingList("RSL", "RSL: " .. list.name) This function is not yet implemented in Auctionator
    end
end

function Core:ExportToAuctionator()
    for i, list in ipairs(self.db.char.lists) do
        local rsl_searchStrings = {}
        for j, item in ipairs(list.items) do
            local itemName = GetItemInfo(item.itemID)
            -- Convert quality to string for Auctionator
            local tierStr = nil
            if item.quality == 1 then tierStr = "1"
            elseif item.quality == 2 then tierStr = "2"
            elseif item.quality == 3 then tierStr = "3"
            end
            local rsl_itemCount = C_Item.GetItemCount(item.itemID, true, true, true, true)
            if itemName and item.qty > rsl_itemCount then
                local rsl_buyAmount = item.qty - rsl_itemCount
                table.insert(rsl_searchStrings, Auctionator.API.v1.ConvertToSearchString("RSL", { 
                    searchString = itemName, 
                    isExact = true, 
                    categoryKey = nil, 
                    tier = tierStr, 
                    quantity = rsl_buyAmount
                }))
            end
        end
        if #list.items > 0 then
            -- We always push to auctionator even if the list is empty to clear previous searches
            Auctionator.API.v1.CreateShoppingList("RSL", "RSL: "..list.name, rsl_searchStrings)
        end
    end
end