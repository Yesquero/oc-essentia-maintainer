local mockConstants = require( "mock.constants" )
local serialization = require( "serialization" )

---@class DatabaseComponent
local database = {
    type = "database",
    dummyData = {}
}

---@alias Aspects { [string]: integer }
---@alias DBItemStack { oreNames: string[], size: integer, name: string, id: integer, damage: integer, maxSize: integer, label: string, hasTag: boolean, maxDamage: integer, aspects: Aspects[]? }

---Get the representation of the item stack stored in the specified slot.
---@param slot number
---@return DBItemStack
function database.get( slot )
    return database.dummyData[slot]
end

-- TODO: make function package private
local function loadData()
    local file = assert( io.open( mockConstants.dummyDBdataPath, "r" ) )
    local i, line = 1, file:read()
    while line do
        database.dummyData[i] = serialization.unserialize( line )

        line = file:read()
        i = i + 1
    end
    file:close()
end

loadData()

return database
