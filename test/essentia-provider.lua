local EssentiaProvider = require("oces.essentiaProvider")
local ItemDatabase = require("oces.item-database")
local component = require("component")
local util = require("ysq.utility")

local essentiaProviderTest = {}

function essentiaProviderTest.integrationTest()
	local itemDB = ItemDatabase:new(component.database)

	---@type EssentiaProvider
	local ep = EssentiaProvider:new(itemDB)

	local missingAspects = {
		InvalidAspect = -1,
	}
	assert(ep:findItemStackToSmelt(missingAspects) == nil)

	missingAspects = {
		Vitium = 800,
		Ignis = 100,
		Terra = 50,
		Perditio = 50,
	}
	assert(ep:findItemStackToSmelt(missingAspects) == 6)

	missingAspects = {
		Vitreus = 50,
		Ignis = 1000,
		Potentia = 300,
	}
	assert(ep:findItemStackToSmelt(missingAspects) == 3)

	missingAspects = {
		Vitreus = 50,
		Ignis = 550,
		Potentia = 450,
	}
	assert(ep:findItemStackToSmelt(missingAspects) == 9)

	print("essentiaProviderTest.integrationTest complete")
end

return essentiaProviderTest
