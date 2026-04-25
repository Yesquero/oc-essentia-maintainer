local IEssentiaSmeltery = require("oces.interface.essentia-smeltery")
local constants = require("oces.constants")

---@class SBSmeltery: IEssentiaSmeltery
---@field new fun(self, smeltery, efficinecy: number): SBSmeltery
local SBSmeltery = IEssentiaSmeltery:inherit()

---@type TCSmeltery
SBSmeltery.smeltery = nil
SBSmeltery.type = constants.SmelterType.EssentiaSmeltery

---Smeltery is considered available if its input slot is sempty.
---@return boolean
function SBSmeltery:isAvailable() return self.smeltery.getStackInSlot(constants.smelteryitemSlot).id == 0 end

function SBSmeltery:initialize(smeltery, efficinecy)
	assert(smeltery, "Essentia Smeltery component is null")
	assert(type(efficinecy) == "number" and efficinecy > 0, "Essentia Smeltery invalid efficiency" .. efficinecy)
	self.efficiency = efficinecy
	self.smeltery = smeltery
end

return SBSmeltery
