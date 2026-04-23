local database = require("oc-mock.database")

---@class Component
local component = {
	---@type DatabaseComponent
	database = database,
}

return component
