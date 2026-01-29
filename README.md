# RestockShoppingList

RestockShoppingList is a World of Warcraft addon that helps you manage shopping lists for **Auctionator** to automatically restock items.

## Features
- **List Management:** Create, rename, and delete multiple shopping lists.
- **Item Configuration:** Add items with a target quantity and minimum quality.
- **Smart Auctionator Integration:**
  - Automatically exports your lists to Auctionator when the Auction House opens.
  - Checks your current inventory (Bags + Bank) for each item.
  - Creates a specific Auctionator Shopping List (prefixed with `RSL:`) containing only the items you need to buy to reach your target quantity.
- **Import/Export:** Share your lists with others using serialized strings.

## Installation
1. Download the addon.
2. Extract the folder to `Interface\AddOns\RestockShoppingList`.
3. Ensure **Auctionator** is installed and enabled.

## Usage
1. Open the configuration window with `/rsl`.
2. Create a new list and add items with your desired target quantity.
3. Visit the Auction House. The addon will calculate missing items and create a shopping list in Auctionator for you.

## Commands
- `/rsl` - Toggles the configuration window.