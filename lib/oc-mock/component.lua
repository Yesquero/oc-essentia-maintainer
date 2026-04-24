local database = require("oc-mock.database")
local me_exportbus = require("oc-mock.me-export-bus")
local thaumicenergistics_infusion_provider = require("oc-mock.te-infusion-provider")

---@class Component
local component = {
	---@type DatabaseComponent
	database = database,
	---@type TEIP
	thaumicenergistics_infusion_provider = thaumicenergistics_infusion_provider,
	---@type MEEBus
	me_exportbus = me_exportbus,
}

return component
