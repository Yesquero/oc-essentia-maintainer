local essentiaStorage = {}

essentiaStorage.IEssentiaStorage = {
}

function essentiaStorage.IEssentiaStorage:new( o )
    o = o or {}
    setmetatable( o, self )
    self.__index = self
    return o
end

function essentiaStorage.IEssentiaStorage:getAspects()
    error( "Not implemented" )
end

function essentiaStorage.IEssentiaStorage:getAspect( name )
    error( "Not implemented" )
end

return essentiaStorage
