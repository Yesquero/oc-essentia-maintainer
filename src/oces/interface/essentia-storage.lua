local essentiaStorage = {}

---@class IEssentiaStorage
essentiaStorage.IEssentiaStorage = {
}

---@return IEssentiaStorage
function essentiaStorage.IEssentiaStorage:new( o )
    o = o or {}
    setmetatable( o, self )
    self.__index = self
    return o
end

---Retruns dict of stored aspects.
---@return { [string]: integer }
function essentiaStorage.IEssentiaStorage:getAspects()
    error( "Not implemented" )
end

---Returns amount of aspect with matching name.
---@param name string
---@return integer
function essentiaStorage.IEssentiaStorage:getAspect( name )
    error( "Not implemented" )
end

return essentiaStorage
