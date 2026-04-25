local IEssentiaStorage = require("oces.interface.essentia-storage")
local constants = require("test.constants")
local serialization = require("serialization")
local util = require("ysq.utility")

---@class MockES: IEssentiaStorage
---@field dummyData { [string]: integer }
local MockEssentiaStorage = IEssentiaStorage:inherit({
	dummyData = {},
})

function MockEssentiaStorage:getAspect(name) return self.dummyData[name] end

function MockEssentiaStorage:getAspects() return self.dummyData end

function MockEssentiaStorage:initialize()
	local file = assert(io.open(constants.getAspectsDataFile), "Could not open mock getAspect file.")
	self.dummyData = assert(serialization.unserialize(file:read("a")))
end

function MockEssentiaStorage.unitTest()
	---@type MockES
	local mockES = MockEssentiaStorage:new()

	assert(util.compareTables(mockES:getAspects(), { Vitreus = 10, Potentia = 10, Vitium = 19 }))

	assert(mockES:getAspect("Vitium") == 19)

	print("mockEssentiaStorage.unitTest complete")
end

return MockEssentiaStorage
