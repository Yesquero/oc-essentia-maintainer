local IEssentiaSmeltery = require("oces.interface.essentia-smeltery")
local constants = require("oces.constants")

---@class SBSmeltery: IEssentiaSmeltery
---@field new fun(self, component: table, efficinecy: number, essentiaPerSecond: number): SBSmeltery
---@field component TCSmeltery
local SBSmeltery = IEssentiaSmeltery:inherit()

SBSmeltery.type = constants.SmelterType.EssentiaSmeltery

---Smeltery is considered available if its input slot is sempty.
---@return boolean
function SBSmeltery:canAcceptItems() return self.component.getStackInSlot(constants.smelteryitemSlot).id == 0 end

return SBSmeltery
