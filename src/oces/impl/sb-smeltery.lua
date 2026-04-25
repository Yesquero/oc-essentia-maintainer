local IEssentiaSmeltery = require("oces.interface.essentia-smeltery")
local constants = require("oces.constants")

---@class SBSmeltery: IEssentiaSmeltery
---@field new fun(self, smeltery, efficinecy: number, essentiaPerSecond: number): SBSmeltery
local SBSmeltery = IEssentiaSmeltery:inherit()

---@type TCSmeltery
SBSmeltery.smeltery = nil
SBSmeltery.type = constants.SmelterType.EssentiaSmeltery

---Smeltery is considered available if its input slot is sempty.
---@return boolean
function SBSmeltery:isAvailable() return self.smeltery.getStackInSlot(constants.smelteryitemSlot).id == 0 end

---@param smeltery table
---@param efficinecy number
---@param essentiaPerSecond number
function SBSmeltery:initialize(smeltery, efficinecy, essentiaPerSecond)
    assert(smeltery, "Essentia Smeltery component is null")
    assert(type(efficinecy) == "number" and efficinecy > 0, "Essentia Smeltery invalid efficiency" .. efficinecy)
    self.efficiency = efficinecy
    self.smeltery = smeltery
    self.essentiaPerSecond = essentiaPerSecond
end

return SBSmeltery
