local AdvancedSmelter = require("oces.impl.advanced-smelter")
local Class = require("ysq.class")
local MEItemSource = require("oces.impl.me-item-source")
local SBSmeltery = require("oces.impl.sb-smeltery")
local constants = require("oces.constants")
local util = require("ysq.utility")

local component = require("component")
local serialization = require("serialization")

---@alias EPConfig { efficiency: integer, accelerationCards: integer, sourceType: string, smelterType:string, essentiaPerSecond:number, smelterAdapterID:string, sourceAdapterID: string, interfaceAdaptedID: string}

---@class EssentiaProvider: AbstractClass
---@field new fun(self, ItemDB: ItemDB, configPath: string?): EssentiaProvider
local EssentiaProvider = Class:inherit()

---@type IItemSource
EssentiaProvider.itemSource = nil
---@type ItemDB
EssentiaProvider.ItemDB = nil
EssentiaProvider.configPath = nil

---Given a dict of missing aspects finds database slot number of ItemStack with percentage ratio of aspects closest to that of missing aspects.
---Return nil if no ItemStack found.
---TODO: Explore ways to improve ItemStack finding algo.
---@param missingAspects Aspects
---@retrun integer | nil
function EssentiaProvider:findItemStackToSmelt(missingAspects)
    ---@type integer
    local dbSlot = nil
    local bestScore = 0.0

    local totalMissing = 0
    for k, v in pairs(missingAspects) do
        totalMissing = totalMissing + missingAspects[k]
    end

    for ind, val in ipairs(self.ItemDB.items) do
        local score = 0.0
        for asp, amt in pairs(missingAspects) do
            score = score + ((val.aspects[asp] or 0) * amt / totalMissing)
        end

        if score > bestScore then
            bestScore = score
            dbSlot = ind
        end
    end

    return dbSlot
end

---@param ItemDB ItemDB
---@param configPath string?
function EssentiaProvider:initialize(ItemDB, configPath)
    self.ItemDB = ItemDB
    self.configPath = configPath or constants.defaultEPConfigPath
    self:readConfig()
end

local typeNewLookup = {
    [constants.SmelterType.EssentiaSmeltery] = SBSmeltery.new,
    [constants.ItemSourceType.ExportBus] = MEItemSource.new,
    [constants.SmelterType.AdvancedAlchemicalSmelter] = AdvancedSmelter.new,
}

local typeSelfLookup = {
    [constants.SmelterType.EssentiaSmeltery] = SBSmeltery,
    [constants.ItemSourceType.ExportBus] = MEItemSource,
    [constants.SmelterType.AdvancedAlchemicalSmelter] = AdvancedSmelter,
}

function EssentiaProvider:readConfig()
    local file =
        assert(io.open(self.configPath, "r"), "Could not open Essentia Provider config file: " .. self.configPath)
    ---@type EPConfig
    local epConfig = assert(serialization.unserialize(file:read("a")), "Essentia Provider config file parsing error.")

    local smeltery = typeNewLookup[epConfig.smelterType](
        typeSelfLookup[epConfig.smelterType],
        ---@diagnostic disable-next-line:param-type-mismatch
        component.proxy(epConfig.smelterAdapterID),
        epConfig.efficiency,
        epConfig.essentiaPerSecond
    )

    ---@diagnostic disable
    local itemSource = typeNewLookup[epConfig.sourceType](
        typeSelfLookup[epConfig.sourceType],
        self.ItemDB,
        component.proxy(epConfig.sourceAdapterID),
        smeltery,
        epConfig.accelerationCards,
        component.proxy(epConfig.interfaceAdaptedID)
    )
    ---@diagnostic enable

    ---@diagnostic disable-next-line: assign-type-mismatch
    self.itemSource = itemSource
end

---Attempts to find an ItemStack with maximum amount of specified aspect.
---@param name string
---@param maxResults integer?
---@return { label: string, aspects: Aspects}[] | nil
---@retrun string?
function EssentiaProvider:findAspectSource(name, maxResults) return self.itemSource:findAspectSource(name, maxResults) end

---Attempts to use associated ItemSource to make missing aspects.
---@param missingAspects Aspects
---@return boolean | nil
---@return integer?
---@return string?
function EssentiaProvider:refillAspects(missingAspects)
    if util.isTableEmpty(missingAspects) then return false, 0, "No Aspects missing;" end

    local dbSlot = self:findItemStackToSmelt(missingAspects)
    if not dbSlot then
        return false, 0, "Database has no Item with required aspects: " .. serialization.serialize(missingAspects)
    end

    if not self.itemSource:isSmelterAvailable() then
        return false, 0, "Essentia Smelter is unavailable / proccessing items;"
    end

    local amount = 0
    for asp, val in pairs(self.ItemDB.items[dbSlot].aspects) do
        amount = math.max(amount, math.ceil((missingAspects[asp] or 0) / val))
    end

    local res, time, msg = self.itemSource:smeltItems(dbSlot, amount)
    if res then
        return true,
            time,
            string.format("(Requested)/(Actual): %i / %i %s(s) inserted;", amount, res, self.ItemDB.items[dbSlot].label)
    else
        return false, 0, msg
    end
end

return EssentiaProvider
