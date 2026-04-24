local Class = require("ysq.class")

---@class IEssentiaStorage: AbstractClass
local IEssentiaStorage = Class:inherit()

---Retruns dict of stored aspects.
---@return { [string]: integer }
function IEssentiaStorage:getAspects() error("Not implemented") end

---Returns amount of aspect with matching name.
---@param name string
---@return integer
function IEssentiaStorage:getAspect(name) error("Not implemented") end

return IEssentiaStorage
