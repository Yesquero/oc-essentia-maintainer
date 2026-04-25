local essentiaProviderTest = require("test.essentia-provider")
local itemDBTest = require("test.item-database")
local maintainerTest = require("test.maintainer")
local mockEssentiaStorage = require("test.mock-essentia-storage")
local utilityTest = require("test.utility")

local testConstants = require("test.constants")

local function runTests()
    print("Running tests...")

    mockEssentiaStorage.unitTest()

    utilityTest.testArrayRemove()

    maintainerTest.testInit()
    maintainerTest.unitTest()
    maintainerTest.integrationTest()
    --maintainerTest.showTest()

    itemDBTest.unitTest()

    essentiaProviderTest.integrationTest()

    os.remove(testConstants.recordsPath)

    print("Tests complete")
end

runTests()
