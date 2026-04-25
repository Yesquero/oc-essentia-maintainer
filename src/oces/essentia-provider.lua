local Class = require("ysq.class")
local MEItemSource = require("oces.impl.me-item-source")
local SBSmeltery = require("oces.impl.sb-smeltery")
local constants = require("oces.constants")
local ocesUtil = require("oces.utility")

local component = require("component")
local serialization = require("serialization")

---@alias EPConfig { efficiency: integer, accelerationCards: integer, sourceType: string, smelterType:string, smelterAdapterID:string, sourceAdapterID: string, interfaceAdaptedID: string}

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
	local ratioDifference = math.maxinteger

	local missingAspecRatio = ocesUtil.valToPercentDict(missingAspects)

	for index, ratioDict in pairs(self.ItemDB.aspectRatioLookup) do
		local newDifference = 0
		local anyAspectPresent = false
		for aspect, value in pairs(missingAspecRatio) do
			anyAspectPresent = self.ItemDB.aspectLookup[aspect] ~= nil
			newDifference = newDifference + math.abs(value - (ratioDict[aspect] or 0))
		end

		if anyAspectPresent and newDifference < ratioDifference then
			dbSlot = index
			ratioDifference = newDifference
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
}

local typeSelfLookup = {
	[constants.SmelterType.EssentiaSmeltery] = SBSmeltery,
	[constants.ItemSourceType.ExportBus] = MEItemSource,
}

function EssentiaProvider:readConfig()
	local file =
		assert(io.open(self.configPath, "r"), "Could not open Essentia Provider config file: " .. self.configPath)
	---@type EPConfig
	local epConfig = assert(serialization.unserialize(file:read("a")), "Essentia Provider config file parsing error.")

	local smeltery = typeNewLookup[epConfig.smelterType](
		typeSelfLookup[epConfig.smelterType],
		component.proxy(epConfig.smelterAdapterID),
		epConfig.efficiency
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
---@retrun msg?
function EssentiaProvider:findAspectSource(name, maxResults) return self.itemSource:findAspectSource(name, maxResults) end

---Attempts to use associated ItemSource to make missing aspects.
---@param missingAspects Aspects
---@return boolean | nil
---@return string?
function EssentiaProvider:refillAspects(missingAspects)
	local dbSlot = self:findItemStackToSmelt(missingAspects)
	if not dbSlot then return false, "Database has no Item with required aspects." end

	if not self.itemSource:isSmelterAvailable() then
		return false, "Essentia Smelter is unavailable / proccessing items."
	end

	local amount = 0
	for asp, val in pairs(self.ItemDB.items[dbSlot].aspects) do
		amount = math.max(amount, math.ceil((missingAspects[asp] or 0) / val))
	end

	local res, msg = self.itemSource:smeltItems(dbSlot, amount)
	if res then
		return true,
			string.format("(Requested)/(Actual): %i / %i %s(s) inserted.", amount, res, self.ItemDB.items[dbSlot].label)
	else
		return false, msg
	end
end

return EssentiaProvider
