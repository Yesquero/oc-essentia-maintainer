---@class MEEBus
local me_export_bus = {}

---Get the configuration of the export bus pointing in the specified direction.
---@param side number
---@param slot number?
---@return table
---@return string?
function me_export_bus.getExportConfiguration(side, slot) error("not implemented") end

---Configure the export bus pointing in the specified direction to export item stacks matching the specified descriptor.
---When called with side only clear the config.
---@param side number
---@param slot number?
---@param database table?
---@param entry number?
---@return boolean
function me_export_bus.setExportConfiguration(side, slot, database, entry) error("not implemented") end

---Make the export bus facing the specified direction perform a single export operation into the specified slot.
---@param side number
---@param slot number?
---@return integer
function me_export_bus.exportIntoSlot(side, slot) error("not implemented") end

return me_export_bus
