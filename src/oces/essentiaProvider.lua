local Class = require("ysq.class")
local constants = require("oces.constants")
local ocesUtil = require("oces.utility")

local serialization = require("serialization")

---@class EssentiaProvider: AbstractClass
---@field new fun(self, ItemDB: ItemDB, configPath: string?)
local EssentiaProvider = Class:inherit()

---@type IItemSource[]
EssentiaProvider.itemSources = {}
---@type ItemDB
EssentiaProvider.ItemDB = nil
EssentiaProvider.configPath = nil

---Given a dict of missing aspects finds slot number of ItemStack with ratio of aspects closest to that of missing aspects.
---Return nil if no ItemStack found.
---@param missingAspects { [string]: integer }
---@retrun integer
function EssentiaProvider:findItemStackToSmelt(missingAspects)
	---@type integer
	local dbSlot = nil
	local ratioDifference = math.maxinteger

	local missingAspecRatio = ocesUtil.valToRatioDict(missingAspects)

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
	--self:readConfig()
end

function EssentiaProvider:readConfig()
	local file =
		assert(io.open(self.configPath, "r"), "Could not open Essentia Provider config file: " .. self.configPath)
	local sources = assert(serialization.unserialize(file:read("a")), "Essentia Provider config file parsing error.")

	error("unfinished")
end

return EssentiaProvider
