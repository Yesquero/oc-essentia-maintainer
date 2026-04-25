local Class = require("ysq.class")

---@class IEssentiaSmeltery: AbstractClass
local IEssentiaSmeltery = Class:inherit()

IEssentiaSmeltery.efficiency = 1

---Check if this smelter can accept items to smelt.
---@return boolean
function IEssentiaSmeltery:isAvailable() error("not implemented") end

return IEssentiaSmeltery
