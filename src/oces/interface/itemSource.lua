local Class = require("ysq.class")
local constants = require("oces.constants")

---@class IItemSource: AbstractClass
local IItemSource = Class:inherit()

IItemSource.efficiency = 1
IItemSource.smelterType = constants.SmelterType.Default
---@type ItemDB
IItemSource.ItemDB = nil

---Check is smelter associated with this item source is available.
---@return boolean
function IItemSource:isSmelterAvailable()
	error("not implemented")
end

---Attempts to insert specified amount of items matching the ItemStack in dbSlot into attached item smelter.
---Note that if smelter efficiency is not 100% then more or less items will be inserted, depending on exact efficiency.
---@param dbSlot integer
---@param amount integer
---@return boolean
---@return string?
function IItemSource:smeltItems(dbSlot, amount)
	error("not implemented")
end

---Attempts to find an ItemStack with maximum amount of specified aspect.
---@param name string
---@return table
function IItemSource:findBestAspectSource(name)
	error("not implemented")
end

return IItemSource
