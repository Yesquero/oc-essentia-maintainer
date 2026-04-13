local serialization = require( "serialization" )

local constants = require( "oces.constants" )
local util = require( "oces.utility" )

local essentiaMaintainer = {}

local config = {
    defaultPriority = constants.defaultPriority,
    pollingInterval = constants.defaultPollingInterval,
    recordsPath = constants.defaultRecordsPath
}

---@class Maintainer
essentiaMaintainer.Maintainer = {
    ---@type {name: string, amount: integer, priority: integer}[]
    aspectList = {},
    ---@type { [string]: integer }
    aspectLookup = {},
    configPath = constants.defaultCfgPath,
    config = config,
    ---@type IEssentiaStorage
    essentiaStorage = nil
}

---Create an instance.
---@param o table?
---@return Maintainer
function essentiaMaintainer.Maintainer:new( o )
    o = o or {}
    setmetatable( o, self )
    self.__index = self
    return o
end

---Read config from a file.
---TODO: create file with default values if none exists
---TODO: sanity check values
---@return boolean
function essentiaMaintainer.Maintainer:readConfig()
    local file = assert( io.open( self.configPath, "r" ), "Could not open config file." )
    self.config = assert( serialization.unserialize( file:read( "a" ) ), "Error when reading config file." )
    file:close()

    return true
end

---Read list of aspects to maintain from a file.
---TODO: handle empty file case
---@return boolean
function essentiaMaintainer.Maintainer:readRecords()
    local file = assert( io.open( self.config.recordsPath, "r" ), "Could not open records file." )
    self.aspectList = assert( serialization.unserialize( file:read( "a" ) ), "Error when reading records file." )
    file:close()

    self:rebuildLookup()

    return true
end

---Add an aspect to list of aspect to maintain, uses default priority from config if none given.
---TODO: add check against a list of known aspects
---@param name string
---@param amount integer
---@param priority integer?
---@return boolean
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

---Delete aspect with given name from the list of aspects to maintain.
---Returns false if no matching aspect found or aspect list is empty.
---Assumes readRecords() will be called sometime afterwards, meant to be used from CLI.
---TODO: current implementation readRecords will be run before aspectList or aspectLookup will be accessed again, this should be fine if its only called from cli though.
---@param name string
---@return boolean
---@return string?
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

---Uses OC serialization pretty print to visualize currently maintained aspects.
---@return string
function essentiaMaintainer.Maintainer:showAspectList()
    return serialization.serialize( self.aspectList, true )
end

---Save current list of maintained aspect to a file.
---@return boolean
function essentiaMaintainer.Maintainer:saveRecords()
    local file = assert( io.open( self.config.recordsPath, "w" ) )
    file = assert( io.open( self.config.recordsPath, "w" ), "Error when writing to records file." )
    file:write( serialization.serialize( self.aspectList ) )
    file:close()

    return true
end

---Rebuild aspects lookup table based on maintained aspects.
function essentiaMaintainer.Maintainer:rebuildLookup()
    self.aspectLookup = {}

    local sortByPriority = function( left, right )
        return left.priority > right.priority
    end
    table.sort( self.aspectList, sortByPriority )

    for i = 1, #self.aspectList do self.aspectLookup[self.aspectList[i].name] = i end
end

function essentiaMaintainer.Maintainer:getMissingAspects()
    local availableAspects = self.essentiaStorage:getAspects()
    return {}
end

return essentiaMaintainer
