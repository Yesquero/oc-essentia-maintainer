local IEssentiaSmeltery = require("oces.interface.essentia-smeltery")
local constants = require("oces.constants")

---@class AdvancedSmelter: IEssentiaSmeltery
---@field new fun(self, component: table, efficinecy: number, essentiaPerSecond: number): AdvancedSmelter
---@field component CompAdvSmelter
local AdvancedSmelter = IEssentiaSmeltery:inherit()

AdvancedSmelter.type = constants.SmelterType.AdvancedAlchemicalSmelter

---@return boolean
function AdvancedSmelter:canAcceptItems() return #self.component.getAspectNames() == 0 end

return AdvancedSmelter
