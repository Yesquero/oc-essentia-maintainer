local essentiaProviderTest = require("test.essentia-provider")
local itemDBTest = require("test.item-database")
local maintainerTest = require("test.maintainer")
local mockEssentiaStorage = require("test.mock-essentia-storage")
local utilityTest = require("test.utility")

local function runTests()
	print("Running tests...")

	mockEssentiaStorage.unitTest()

	utilityTest.testArrayRemove()

	maintainerTest.testInit()
	maintainerTest.unitTest()
	maintainerTest.integrationTest()

	itemDBTest.unitTest()

	essentiaProviderTest.integrationTest()

	print("Tests complete")
end

runTests()
