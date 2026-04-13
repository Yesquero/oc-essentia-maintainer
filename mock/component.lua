local database = require( "mock.database" )

---@class Component
local component = {
    ---@type DatabaseComponent
    database = database
}

return component
