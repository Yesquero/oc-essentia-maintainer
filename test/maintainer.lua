local EssentiaMaintainer = require("oces.maintainer")
local MockEssentiaStorage = require("test.mock-essentia-storage")
local constants = require("oces.constants")
local serialization = require("serialization")
local testConstants = require("test.constants")
local util = require("ysq.utility")

local maintainerTest = {}

local function setupRecords()
    local file = assert(io.open(testConstants.recordsPath, "w"))
    assert(file:write(serialization.serialize({ { name = "Ignis", amount = 100, priority = 0 } })))
    file:close()
end

function maintainerTest.testInit()
    setupRecords()

    ---@diagnostic disable-next-line:param-type-mismatch
    local maintainer = EssentiaMaintainer:new(nil, testConstants.cfgPath)
    assert(#maintainer.aspectList ~= 0)

    os.remove(testConstants.recordsPath)

    print("maintainerTest.testInit complete")
end

function maintainerTest.unitTest()
    os.remove(testConstants.recordsPath)

    ---@diagnostic disable-next-line:param-type-mismatch
    local maintainer = EssentiaMaintainer:new(nil, testConstants.cfgPath)
    assert(util.compareTables(maintainer.config, {
        defaultPriority = testConstants.defaultPriority,
        pollingInterval = testConstants.defaultPollingInterval,
        recordsPath = testConstants.recordsPath,
    }))

    util.clearFile(maintainer.config.recordsPath, true)

    maintainer:readRecords()
    assert(#maintainer.aspectList == 0)

    maintainer:addAspect("Metallum", 1000)
    maintainer:addAspect("Vitium", 100, 25)
    maintainer:addAspect("Aer", 25)
    assert(
        #maintainer.aspectList == 3
            and util.compareTables(maintainer.aspectLookup, { Metallum = 2, Vitium = 3, Aer = 1 })
    )
    assert(maintainer.aspectList[2].name == "Metallum")

    maintainer.aspectList = {}
    assert(#maintainer.aspectList == 0)

    maintainer:readRecords()
    assert(
        #maintainer.aspectList == 3
            and util.compareTables(maintainer.aspectLookup, { Metallum = 2, Vitium = 3, Aer = 1 })
    )
    assert(maintainer.aspectList[2].name == "Metallum")
    assert(maintainer.aspectList[1].priority == maintainer.config.defaultPriority)

    local res, msg = maintainer:deleteAspect("test")
    assert(not res)

    res = maintainer:deleteAspect("Vitium")
    assert(res)
    maintainer:readRecords()
    assert(#maintainer.aspectList == 2 and util.compareTables(maintainer.aspectLookup, { Metallum = 2, Aer = 1 }))
    assert(maintainer.aspectList[1].name == "Aer")

    print("maintainerTest.unitTest complete")
end

function maintainerTest.integrationTest()
    os.remove(testConstants.recordsPath)

    local MockES = MockEssentiaStorage:new()
    local maintainer = EssentiaMaintainer:new(MockES, testConstants.cfgPath)

    assert(util.compareTables(maintainer:getMissingAspects(), {}))

    maintainer:addAspect("Vitium", 100)
    assert(util.compareTables(maintainer:getMissingAspects(), {
        Vitium = 81,
    }))

    maintainer:addAspect("Metallum", 991)
    maintainer:addAspect("Potentia", 10)
    assert(util.compareTables(maintainer:getMissingAspects(), {
        Vitium = 81,
        Metallum = 991,
    }))

    print("maintainerTest.integrationTest complete")
end

function maintainerTest.showTest()
    os.remove(testConstants.recordsPath)

    local MockES = MockEssentiaStorage:new()
    local maintainer = EssentiaMaintainer:new(MockES, testConstants.cfgPath)

    maintainer:addAspect("Metallum", 991)
    maintainer:addAspect("Potentia", 10)
    maintainer:addAspect("Vitium", 1000)
    maintainer:addAspect("Ordo", 500)
    maintainer:addAspect("Perditio", 10000)
    maintainer:addAspect("Sonus", 1)
    maintainer:addAspect("Aer", 700)
    print(maintainer:formattedAspectTable())
    maintainer:addAspect("Amogus", 300)
    print(maintainer:formattedAspectTable())

    os.remove(testConstants.recordsPath)
end

return maintainerTest
