local database = require("oc-mock.database")
local me_exportbus = require("oc-mock.me-export-bus")
local me_interface = require("oc-mock.me_interface")
local smeltery = require("oc-mock.smeltery")
local thaumicenergistics_infusion_provider = require("oc-mock.te-infusion-provider")

---@class Component
local component = {
    ---@type DatabaseComponent
    database = database,
    ---@type TEIP
    thaumicenergistics_infusion_provider = thaumicenergistics_infusion_provider,
    ---@type MEEBus
    me_exportbus = me_exportbus,
    ---@type MEInterface
    me_interface = me_interface,
    smeltery = smeltery,
}

---Return component with given id.
---@param uuid string
---@return table | nil
---@return string?
function component.proxy(uuid) error("not implemented") end

return component
