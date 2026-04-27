local Class = require("ysq.class")
local constants = require("oces.constants")

---@class IEssentiaSmeltery: AbstractClass
local IEssentiaSmeltery = Class:inherit()

---@type table
IEssentiaSmeltery.component = nil
IEssentiaSmeltery.type = constants.SmelterType.Default
---@type integer
IEssentiaSmeltery.efficiency = nil
---@type integer
IEssentiaSmeltery.essentiaPerSecond = nil
---Check if this smelter can accept items to smelt.
---@return boolean
function IEssentiaSmeltery:canAcceptItems() error("not implemented") end

---@param component table
---@param efficinecy number
---@param essentiaPerSecond number
function IEssentiaSmeltery:initialize(component, efficinecy, essentiaPerSecond)
    assert(component, self.type .. " component is null")
    assert(type(efficinecy) == "number" and efficinecy > 0, self.type .. " invalid efficiency" .. efficinecy)
    assert(
        type(essentiaPerSecond) == "number" and essentiaPerSecond > 0,
        self.type .. " invalid essentia / s" .. essentiaPerSecond
    )
    self.efficiency = efficinecy
    self.component = component
    self.essentiaPerSecond = essentiaPerSecond
end

return IEssentiaSmeltery
