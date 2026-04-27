---@class MEEBus
local me_export_bus = {}
me_export_bus.accCards = 0
me_export_bus.validSide = 4

local sizeLookup = {
    [0] = 1,
    [1] = 8,
    [2] = 32,
    [3] = 64,
}

---Get the configuration of the export bus pointing in the specified direction.
---@param side number
---@param slot number?
---@return table | nil
---@return string?
function me_export_bus.getExportConfiguration(side, slot)
    if side == me_export_bus.validSide then
        return nil
    else
        return nil, "no matching part"
    end
end

---Configure the export bus pointing in the specified direction to export item stacks matching the specified descriptor.
---When called with side only clear the config.
---@param side number
---@param slot number?
---@param database table?
---@param entry number?
---@return boolean | nil
---@return string?
function me_export_bus.setExportConfiguration(side, slot, database, entry)
    if side == me_export_bus.validSide then
        return true
    else
        return nil
    end
end

---Make the export bus facing the specified direction perform a single export operation into the specified slot.
---@param side number
---@param slot number?
---@return integer | nil
---@return string?
function me_export_bus.exportIntoSlot(side, slot)
    if side == me_export_bus.validSide then
        return sizeLookup[me_export_bus.accCards]
    else
        return nil
    end
end

return me_export_bus
