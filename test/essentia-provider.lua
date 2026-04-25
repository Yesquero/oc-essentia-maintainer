local EssentiaProvider = require("oces.essentiaProvider")
local ItemDatabase = require("oces.item-database")

local testConstants = require("test.constants")

local component = require("component")

local essentiaProviderTest = {}

component.proxy = function(uuid)
	if uuid == testConstants.epConfig.interfaceAdaptedID then
		return component.me_interface
	elseif uuid == testConstants.epConfig.smelterAdapterID then
		return component.smeltery
	elseif uuid == testConstants.epConfig.sourceAdapterID then
		return component.me_exportbus
	elseif uuid == testConstants.databaseID then
		return component.database
	else
		error("Invalid uuid")
	end
end

---@param ep EssentiaProvider
local function testFindItemStack(ep)
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
		Ignis = 525,
		Potentia = 425,
	}
	assert(ep:findItemStackToSmelt(missingAspects) == 9)

	missingAspects = {
		Vitreus = 50,
		Terra = 250,
		Perditio = 250,
	}
	assert(ep:findItemStackToSmelt(missingAspects) == 5)

	missingAspects = {
		Cognitio = 1000,
		Terra = 250,
		Perditio = 250,
	}
	assert(ep:findItemStackToSmelt(missingAspects) == 8)

	print("essentiaProvider.findItemStackToSmelt test complete")
end

---@param ep EssentiaProvider
local function testMakeAspects(ep)
	local missingAspects = {
		InvalidAspect = -1,
	}
	local res, msg = ep:makeAspects(missingAspects)
	assert(res == false and msg == "Database has no Item with required aspects.")

	missingAspects = {
		Vitium = 800,
		Ignis = 100,
		Terra = 50,
		Perditio = 50,
	}
	component.smeltery.available = false
	res, msg = ep:makeAspects(missingAspects)
	assert(res == false and msg == "Essentia Smelter is unavailable / proccessing items.")
	component.smeltery.available = true

	res, msg = ep:makeAspects(missingAspects)
	assert(res == true and msg == "(Requested)/(Actual): 100 / 128 Vishroom(s) inserted.")

	print("essentiaProvider.testMakeAspects test complete")
end

---@param ep EssentiaProvider
local function testFindAspectSource(ep)
	assert(ep:findAspectSource("Invalid", 1) == nil)
	assert(ep:findAspectSource("Vitium", 1)[1].label == "Vishroom")

	print("essentiaProvider.findAspectSource test complete")
end

function essentiaProviderTest.integrationTest()
	local itemDB = ItemDatabase:new(component.database)

	---@type EssentiaProvider
	local ep = EssentiaProvider:new(itemDB, testConstants.epConfigPath)

	---@diagnostic disable-next-line:undefined-field
	assert(ep.itemSource.smeltery.type == testConstants.epConfig.smelterType)
	---@diagnostic disable-next-line:undefined-field
	assert(ep.itemSource.smeltery.efficiency == testConstants.epConfig.efficiency)
	assert(ep.itemSource.type == testConstants.epConfig.sourceType)
	---@diagnostic disable-next-line:undefined-field
	assert(ep.itemSource.accelerationCardNum == testConstants.epConfig.accelerationCards)
	---@diagnostic disable-next-line:undefined-field
	assert(ep.itemSource.exportSide == testConstants.validExportSide)

	testFindItemStack(ep)
	testFindAspectSource(ep)
	testMakeAspects(ep)

	print("essentiaProviderTest.integrationTest complete")
end

return essentiaProviderTest
