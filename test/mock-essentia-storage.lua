local constants = require("test.constants")
local essentiStorage = require("oces.interface.essentia-storage")
local serialization = require("serialization")
local util = require("ysq.utility")

local mockEssentiaStorage = {}

---@class MockES: IEssentiaStorage
---@field dummyData { [string]: integer }
---@field new fun(self): MockES
mockEssentiaStorage.MockES = essentiStorage.IEssentiaStorage:new({
	dummyData = {},
})

---@param name string
---@return integer
function mockEssentiaStorage.MockES:getAspect(name)
	return self.dummyData[name]
end

---@return { [string]: integer }
function mockEssentiaStorage.MockES:getAspects()
	return self.dummyData
end

function mockEssentiaStorage.MockES:init()
	local file = assert(io.open(constants.getAspectsDataFile), "Caould not open mock getAspect file.")
	self.dummyData = assert(serialization.unserialize(file:read("a")))
end

function mockEssentiaStorage.setup()
	---@type MockES
	local mockES = mockEssentiaStorage.MockES:new()

	assert(util.compareTables(mockES:getAspects(), { Vitreus = 10, Potentia = 10, Vitium = 19 }))

	assert(mockES:getAspect("Vitium") == 19)

	print("mockEssentiaStorage.setup complete")
end

return mockEssentiaStorage
