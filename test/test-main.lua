local utilityTest = require( "test.test-utility" )
local maintainerTest = require( "test.test-maintainer" )

local function runTests()
    utilityTest.testArrayRemove()

    maintainerTest.setup()

    print( "Tests finished" )
end

runTests()
