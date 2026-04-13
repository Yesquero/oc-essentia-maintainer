local serialization = require( "serialization" )

local constants = require( "oces.constants" )
local util = require( "oces.utility" )

local essentiaMaintainer = {}

local config = {
    defaultPriority = constants.defaultPriority,
    pollingInterval = constants.defaultPollingInterval,
    recordsPath = constants.defaultRecordsPath
}

essentiaMaintainer.Maintainer = {
    aspectList = {},
    aspectLookup = {},
    configPath = constants.defaultCfgPath,
    config = config,
    essentiaStorage = nil
}

function essentiaMaintainer.Maintainer:new( o )
    o = o or {}
    setmetatable( o, self )
    self.__index = self
    return o
end

-- TODO: create file with default values if none exists
-- TODO: sanity check values
function essentiaMaintainer.Maintainer:readConfig()
    local file = assert( io.open( self.configPath, "r" ), "Could not open config file." )
    self.config = assert( serialization.unserialize( file:read( "a" ) ), "Error when reading config file." )
    file:close()

    return true
end

-- TODO: handle empty file case
function essentiaMaintainer.Maintainer:readRecords()
    local file = assert( io.open( self.config.recordsPath, "r" ), "Could not open records file." )
    self.aspectList = assert( serialization.unserialize( file:read( "a" ) ), "Error when reading records file." )
    file:close()

    self:rebuildLookup()

    return true
end

-- TODO: add check against a list of known aspects
function essentiaMaintainer.Maintainer:addAspect( name, amount, priority )
    assert( name and type( name ) == "string", "addAspect invalid argument(s)" )
    assert( amount and type( amount == "number" and amount > 0 ), "addAspect invalid argument(s)" )

    self:readRecords()
    self.aspectList[#self.aspectList+1] = {
        name = name,
        amount = amount,
        priority = priority or self.config.defaultPriority
    }

    self:saveRecords()
    self:rebuildLookup()

    return true
end

-- TODO: current implementation readRecords will be run before aspectList or aspectLookup will be accessed again, this should be fine if its only called from cli though
function essentiaMaintainer.Maintainer:deleteAspect( name )
    assert( name and type( name ) == "string", "deleteAspect invalid argument(s)" )

    self:readRecords()
    if #self.aspectList == 0 then return true end

    local res = util.arrayRemove( self.aspectList, function( val )
        return val.name == name
    end )
    if res then
        self:saveRecords()
        return true
    end

    return false, "Could not find saved aspect with matching name: " .. name
end

function essentiaMaintainer.Maintainer:showAspectList()
    return serialization.serialize( self.aspectList, true )
end

function essentiaMaintainer.Maintainer:saveRecords()
    local file = assert( io.open( self.config.recordsPath, "w" ) )
    file = assert( io.open( self.config.recordsPath, "w" ), "Error when writing to records file." )
    file:write( serialization.serialize( self.aspectList ) )
    file:close()

    return true
end

function essentiaMaintainer.Maintainer:rebuildLookup()
    self.aspectLookup = {}

    local sortByPriority = function( left, right )
        return left.priority > right.priority
    end
    table.sort( self.aspectList, sortByPriority )

    for i = 1, #self.aspectList do self.aspectLookup[self.aspectList[i].name] = i end
end

return essentiaMaintainer
