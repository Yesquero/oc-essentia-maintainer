local essentiaStorage = {}

---@class IEssentiaStorage
essentiaStorage.IEssentiaStorage = {}

---@return IEssentiaStorage
function essentiaStorage.IEssentiaStorage:new(prototype)
	prototype = prototype or {}
	setmetatable(prototype, self)
	self.__index = self
	self:init()
	return prototype
end

---Retruns dict of stored aspects.
---@return { [string]: integer }
function essentiaStorage.IEssentiaStorage:getAspects()
	error("Not implemented")
end

---Returns amount of aspect with matching name.
---@param name string
---@return integer
function essentiaStorage.IEssentiaStorage:getAspect(name)
	error("Not implemented")
end

---Virtual initialization function
function essentiaStorage.IEssentiaStorage:init()
	return
end

return essentiaStorage
