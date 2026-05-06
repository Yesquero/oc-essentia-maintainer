local IEssentiaStorage = require("oces.interface.essentia-storage")

---@class InfusionProviderES: IEssentiaStorage
---@field new fun(self, infusionProvider: TEIP): InfusionProviderES
local InfusionProviderES = IEssentiaStorage:inherit()

function InfusionProviderES:getAspect(name) return self.component.getAspectCount(name) end

function InfusionProviderES:getAspects() return self.component.getAspects() end

function InfusionProviderES:initialize(infusionProvider)
    assert(infusionProvider, "Infusion Provider is null")
    self.component = infusionProvider
end

return InfusionProviderES
