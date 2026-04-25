local Class = require("ysq.class")
local constants = require("oces.constants")

---@class IItemSource: AbstractClass
local IItemSource = Class:inherit()

---@type ItemDB
IItemSource.ItemDB = nil
IItemSource.type = constants.ItemSourceType.Default

---Check is smelter associated with this item source is available.
---@return boolean
function IItemSource:isSmelterAvailable() error("not implemented") end

---Attempts to insert specified amount of items matching the ItemStack in dbSlot into attached item smelter.
---Note that if smelter efficiency is not 100% then more or less items will be inserted, depending on exact efficiency.
---@param dbSlot integer
---@param amount integer
---@return integer | nil
---@return string?
function IItemSource:smeltItems(dbSlot, amount) error("not implemented") end

---Attempts to find an ItemStack with maximum amount of specified aspect.
---@param name string
---@param maxResults integer?
---@return table
---@retrun msg?
function IItemSource:findAspectSource(name, maxResults) error("not implemented") end

return IItemSource
