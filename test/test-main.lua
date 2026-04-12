local essentiaMaintainer = require( "maintainer" )

local constants = {
    cfgPath = "test/data/oces.cfg",
    recordsPath = "test/data/oces-records.txt"
}

local function clearRecords()
    local file = assert( io.open( constants.recordsPath, "w" ) )
    file:write( "{}" )
    file:close()
end

local function maintainerSetupTest()
    local maintainer = essentiaMaintainer.Maintainer:new( { defaultCfgPath = constants.cfgPath } )

    assert( maintainer.config.defaultPriority == 0 )
    assert( maintainer.config.pollingInterval == 10 )
    assert( maintainer.config.recordsPath == "/etc/oces-records.txt" )

    maintainer:readConfig()
    assert( maintainer.config.defaultPriority == -1 )
    assert( maintainer.config.pollingInterval == 5 )
    assert( maintainer.config.recordsPath == constants.recordsPath )

    clearRecords()

    maintainer:readRecords()
    assert( #maintainer.aspectList == 0 )

    maintainer:addAspect( "Vitium", 100, 25 )
    maintainer:addAspect( "Metallum", 1000, nil )
    assert( #maintainer.aspectList == 2 )

    maintainer.aspectList = {}
    assert( #maintainer.aspectList == 0 )

    maintainer:readRecords()
    assert( #maintainer.aspectList == 2 )
    assert( maintainer.aspectList[1].name == "Vitium" )
    assert( maintainer.aspectList[2].priority == maintainer.config.defaultPriority )
end

local function runTests()
    maintainerSetupTest()

    print( "Tests finished" )
end

runTests()
