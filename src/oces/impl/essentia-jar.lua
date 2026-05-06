local IEssentiaStorage = require("oces.interface.essentia-storage")

---@class Jar: IEssentiaStorage
local Jar = IEssentiaStorage:inherit()

function Jar:initialize(jarComponent)
    assert(jarComponent, "Jar Component cannot be null.")
    self.component = jarComponent
end

---Get amount of stored aspect with specified name.
---@param name string
---@return integer
function Jar:getAspect(name) return self.component.getAspectCount(name) end

---Get stored aspects.
---@return Aspects
function Jar:getAspects() return self.component.getAspects() end
