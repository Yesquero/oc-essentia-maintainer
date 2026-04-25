local Class = require("ysq.class")
local constants = require("oces.constants")

---@class IEssentiaSmeltery: AbstractClass
local IEssentiaSmeltery = Class:inherit()

IEssentiaSmeltery.efficiency = 1
IEssentiaSmeltery.essentiaPerSecond = constants.essentiaPerSecond

---Check if this smelter can accept items to smelt.
---@return boolean
function IEssentiaSmeltery:isAvailable() error("not implemented") end

return IEssentiaSmeltery
