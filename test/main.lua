local itemDBTest = require("test.item-database")
local maintainerTest = require("test.maintainer")
local mockEssentiaStorage = require("test.mock-essentia-storage")
local utilityTest = require("test.utility")

local function runTests()
	print("Running tests...")

	mockEssentiaStorage.setup()

	-- utilityTest.testArrayRemove()

	-- maintainerTest.setup()

	-- itemDBTest.setup()

	print("Tests complete")
end

runTests()
