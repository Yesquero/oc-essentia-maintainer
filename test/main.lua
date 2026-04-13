local itemDBTest = require("test.item-database")
local maintainerTest = require("test.maintainer")
local utilityTest = require("test.utility")

local function runTests()
	print("Running tests...")

	utilityTest.testArrayRemove()

	maintainerTest.setup()

	itemDBTest.setup()

	print("Tests complete")
end

runTests()
