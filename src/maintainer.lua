local serialization = require( "serialization" )

local essentiaMaintainer = {}

local config = {
    defaultPriority = 0,
    pollingInterval = 10,
    recordsPath = "/etc/oces-records.txt"
}

essentiaMaintainer.Maintainer = {
    aspectList = {},
    defaultCfgPath = "str",
    config = config
}

function essentiaMaintainer.Maintainer:new( o )
    o = o or {}
    setmetatable( o, self )
    self.__index = self
    return o
end

-- TODO: create file with default values if none exists
function essentiaMaintainer.Maintainer:readConfig()
    local file = assert( io.open( self.defaultCfgPath, "r" ), "Could not open config file." )
    self.config = assert( serialization.unserialize( file:read( "a" ) ), "Error when reading config file." )
    file:close()
end

-- TODO: handle empty file case
function essentiaMaintainer.Maintainer:readRecords()
    local file = assert( io.open( self.config.recordsPath, "r" ), "Could not open records file." )
    self.aspectList = assert( serialization.unserialize( file:read( "a" ) ), "Error when reading records file." )
    file:close()
end

function essentiaMaintainer.Maintainer:addAspect( name, amount, priority )
    assert( name and type( name ) == "string" )
    assert( amount and type( amount == "number" ) )

    self:readRecords()
    self.aspectList[#self.aspectList+1] = {
        name = name,
        amount = amount,
        priority = priority or self.config.defaultPriority
    }

    local file = assert( io.open( self.config.recordsPath, "w" ) )
    file = assert( io.open( self.config.recordsPath, "w" ), "Error when writing to records file." )
    file:write( serialization.serialize( self.aspectList ) )
    file:close()
end

function essentiaMaintainer.Maintainer:deleteAspect()
    error( "Not implemented" )
end

function essentiaMaintainer.Maintainer:showAspectList()
    error( "Not implemented" )
end

return essentiaMaintainer
