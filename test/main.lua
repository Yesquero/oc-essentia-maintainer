local utilityTest = require( "test.utility" )
local maintainerTest = require( "test.maintainer" )
local itemDBTest = require( "test.item-database" )

local function runTests()
    utilityTest.testArrayRemove()

    maintainerTest.setup()

    itemDBTest.setup()

    print( "Tests complete" )
end

runTests()
