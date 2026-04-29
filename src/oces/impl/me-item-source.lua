local IItemSource = require("oces.interface.item-source")
local constants = require("oces.constants")
local util = require("ysq.utility")

---@class ExportBusIS: IItemSource
---@field new fun(itemDatabase: ItemDB, exportBus: table, smeltery: table, accelerationCardNum: integer, meInterface: table): ExportBusIS
local ExportBusIS = IItemSource:inherit()

ExportBusIS.type = constants.ItemSourceType.ExportBus
---@type MEEBus
ExportBusIS.exportBus = nil
---@type IEssentiaSmeltery
ExportBusIS.smeltery = nil
---@type MEInterface
ExportBusIS.meInterface = nil
ExportBusIS.exportSide = -1
ExportBusIS.accelerationCardNum = 0

function ExportBusIS:initialize(itemDatabase, exportBus, smeltery, accelerationCardNum, meInterface)
    assert(itemDatabase, "Item database is null")
    assert(exportBus, "Export Bus component is null")
    assert(smeltery, "Essentia Smeltery is null")
    assert(meInterface, "ME interface component is null")
    assert(accelerationCardNum >= 0 and accelerationCardNum <= 3, "Invalid number of Acceleration Cards")
    self.exportBus = exportBus
    self.smeltery = smeltery
    self.itemDatabase = itemDatabase
    self.meInterface = meInterface
    self.accelerationCardNum = accelerationCardNum

    for i = 1, 5, 1 do
        local res, msg = self.exportBus.getExportConfiguration(i)
        if res ~= nil or (res == nil and msg == nil) then self.exportSide = i end
    end
end

---Configure Export Bus to export ItemStack from specified database slot.
---@return boolean | nil
---@return string?
function ExportBusIS:setBusConfig(dbSlot)
    ---@diagnostic disable-next-line: param-type-mismatch
    return self.exportBus.setExportConfiguration(self.exportSide, self.itemDatabase:getComponent().address, dbSlot)
end

-- Cant have 4 Acceleration Cards because Export bus has 4 slots and we use 1 Redstone Card.
local exportBusOps = {
    [0] = 1,
    [1] = 8,
    [2] = 32,
    [3] = 64,
}

---Calcuelate wait time in seconds.
---@param itemsInserted integer
---@param essentiaPerItem integer
---@param essentiaPerSecond number
---@return integer
local function calculateWaitTime(itemsInserted, essentiaPerItem, essentiaPerSecond)
    return math.ceil(itemsInserted * essentiaPerItem / essentiaPerSecond)
end

---Calculates amount of operations Export Bus should perfrom taking efficieny, stack size and number of Acceleration Cards into account.
---@param amount integer
---@param stackSize integer
---@return integer
function ExportBusIS:calculateExportOps(amount, stackSize)
    return math.ceil(
        math.ceil(amount / self.smeltery.efficiency) / math.min(stackSize, exportBusOps[self.accelerationCardNum])
    )
end

---Clears Export Bus config.
---@return boolean | nil
---@return string?
function ExportBusIS:clearBusConfig() return self.exportBus.setExportConfiguration(self.exportSide) end

---Check if associated Essentia Smelter can accepts items.
---@return boolean
function ExportBusIS:isSmelterAvailable() return self.smeltery:canAcceptItems() end

---Attempt to insert specified amount of items into the Essentia Smelter. Takes efficiency, stack size and number of Acceleration Cards into account.
---Returns amount of items inserted, anticipated time(sec) before smelter becomes available and optional error string.
---@param dbSlot integer
---@param amount integer
---@return integer | nil
---@return integer | nil
---@return string?
function ExportBusIS:smeltItems(dbSlot, amount)
    local found = self.meInterface.getItemsInNetwork({
        label = self.itemDatabase.items[dbSlot].label,
    })
    if not found[1] then
        return nil, 0, "ME network has no items with label: " .. self.itemDatabase.items[dbSlot].label
    end

    local res, msg = self:clearBusConfig()
    if not res then return nil, 0, msg end

    res, msg = self:setBusConfig(dbSlot)
    if not res then return nil, 0, msg end

    local totalInserted = 0
    for i = 1, self:calculateExportOps(amount, found[1].maxSize) do
        local res, msg = self.exportBus.exportIntoSlot(self.exportSide)
        if not res and totalInserted == 0 then return res, 0, msg end

        totalInserted = totalInserted + (res or 0)
    end

    return totalInserted,
        calculateWaitTime(totalInserted, self.itemDatabase.items[dbSlot].totalAspects, self.smeltery.essentiaPerSecond)
end

---Attempts to find ItemStacks with specified aspect.
---@param name string
---@param maxResults integer?
---@return { label: string, aspects: Aspects}[] | nil
---@return string?
function ExportBusIS:findAspectSource(name, maxResults)
    local allItems = self.meInterface.getItemsInNetwork()
    util.arrayRemove(allItems, function(value) return not value.aspects or value.aspects[name] == nil end)

    if #allItems == 0 then return nil, "No items found with aspect: " .. name end

    local maxResults = math.min(#allItems, maxResults or 1)
    local res = {}
    table.sort(allItems, function(lhs, rhs) return lhs.aspects[name] > rhs.aspects[name] end)
    for i = 1, maxResults do
        res[#res + 1] = {
            label = allItems[i].label,
            aspects = allItems[i].aspects,
        }
    end

    return res
end

return ExportBusIS
