local essentiaMaintainer = require( "oces.maintainer" )
local util = require( "oces.utility" )
local constants = require( "oces.constants" )

local testConstants = {
    cfgPath = "test/data/oces.cfg",
    recordsPath = "test/data/oces-records.txt",
    defaultPollingInterval = 5,
    defaultPriority = 10
}

local function clearFile( filename )
    local file = assert( io.open( filename, "w" ) )
    file:write( "{}" )
    file:close()
end

local function maintainerTests()
    local maintainer = essentiaMaintainer.Maintainer:new( { configPath = testConstants.cfgPath } )

    assert( util.comparePOD( maintainer.config,
                             {
                                 defaultPriority = constants.defaultPriority,
                                 pollingInterval = constants
                                     .defaultPollingInterval,
                                 recordsPath = constants.defaultRecordsPath
                             } ) )

    maintainer:readConfig()
    assert( util.comparePOD( maintainer.config,
                             {
                                 defaultPriority = testConstants.defaultPriority,
                                 pollingInterval = testConstants.defaultPollingInterval,
                                 recordsPath =
                                     testConstants.recordsPath
                             } ) )

    clearFile( maintainer.config.recordsPath )

    maintainer:readRecords()
    assert( #maintainer.aspectList == 0 )

    maintainer:addAspect( "Metallum", 1000, nil )
    maintainer:addAspect( "Vitium", 100, 25 )
    assert( #maintainer.aspectList == 2 and util.comparePOD( maintainer.aspectLookup, { Metallum = 2, Vitium = 1 } ) )
    assert( maintainer.aspectList[2].name == "Metallum" )

    maintainer.aspectList = {}
    assert( #maintainer.aspectList == 0 )

    maintainer:readRecords()
    assert( #maintainer.aspectList == 2 )
    assert( maintainer.aspectList[1].name == "Vitium" )
    assert( maintainer.aspectList[2].priority == maintainer.config.defaultPriority )

    local res, msg = maintainer:deleteAspect( "test" )
    assert( res == false )

    res = maintainer:deleteAspect( "Vitium" )
    assert( res == true )
    maintainer:readRecords()
    assert( #maintainer.aspectList == 1 and util.comparePOD( maintainer.aspectLookup, { Metallum = 1 } ) )
    assert( maintainer.aspectList[1].name == "Metallum" )
end

local function runTests()
    maintainerTests()

    print( "Tests finished" )
end

runTests()
