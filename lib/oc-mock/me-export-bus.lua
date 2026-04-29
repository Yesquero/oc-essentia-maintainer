local ME = require("oc-mock.me_interface")
local database = require("oc-mock.database")

---@class MEEBus
local me_export_bus = {}
me_export_bus.accCards = 0
me_export_bus.validSide = 4
me_export_bus.database = database
---@type integer | nil
me_export_bus.entry = nil
---@type integer | nil
me_export_bus.exportSize = nil
---@type integer | nil
me_export_bus.entryAmountCounter = 0

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
---@param side integer
---@param slot integer | nil
---@param database string | nil
---@param entry integer | nil
---@return boolean | nil
---@return string?
function me_export_bus.setExportConfiguration(side, slot, database, entry)
    if side == me_export_bus.validSide then
        if slot == nil and database == nil and entry == nil then -- clear config
            me_export_bus.entryAmountCounter = 0
            me_export_bus.entry = nil
            me_export_bus.exportSize = sizeLookup[me_export_bus.accCards]
            return true
        elseif slot == me_export_bus.database.address or database == me_export_bus.database.address then -- can omit slot
            ---@diagnostic disable-next-line: assign-type-mismatch
            me_export_bus.entry = (entry or database)
            me_export_bus.entryAmountCounter =
                ---@diagnostic disable-next-line: param-type-mismatch
                ME.getItemsInNetwork({ label = me_export_bus.database.get(entry or database).label })[1].size
            me_export_bus.exportSize =
                ---@diagnostic disable-next-line: param-type-mismatch
                math.min(sizeLookup[me_export_bus.accCards], me_export_bus.database.get(me_export_bus.entry).maxSize)
            return true
        else
            error("should not reach this")
        end
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
        if me_export_bus.entryAmountCounter >= me_export_bus.exportSize then
            me_export_bus.entryAmountCounter = me_export_bus.entryAmountCounter - me_export_bus.exportSize
            return me_export_bus.exportSize
        elseif me_export_bus.entryAmountCounter == 0 then
            return nil, "no items moved"
        else
            local res = math.min(me_export_bus.entryAmountCounter, me_export_bus.exportSize)
            me_export_bus.entryAmountCounter = 0
            return res
        end
    else
        return nil
    end
end

return me_export_bus
