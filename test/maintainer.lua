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

local function unserializeFile(path)
    local file = assert(io.open(path, "r"))
    local res = assert(serialization.unserialize(file:read("a")))
    file:close()
    return res
end

function maintainerTest.unitTest()
    os.remove(testConstants.recordsPath)

    ---@diagnostic disable-next-line:param-type-mismatch
    local maintainer = EssentiaMaintainer:new(nil, testConstants.cfgPath)
    assert(util.compareTables(maintainer.config, {
        defaultPriority = testConstants.defaultPriority,
        mainPollingInterval = testConstants.mainPollingInterval,
        refillPollingInterval = testConstants.refillPollingInterval,
        tableMaxNumLen = testConstants.tableMaxNumLen,
        tableEntrierPerRow = testConstants.tableEntrierPerRow,
        recordsPath = testConstants.recordsPath,
        knownAspectsPath = testConstants.knownAspectsPath,
        aspectCombinationsPath = testConstants.aspectCombinationsPath,
    }))

    local knwonAspects = unserializeFile(testConstants.knownAspectsPath)
    assert(util.compareTables(maintainer.knownAspects, knwonAspects))

    util.clearFile(maintainer.config.recordsPath, true)

    local res, msg = maintainer:addAspect("Invalid", -1)
    assert(not res and msg == "Unknown aspect: Invalid; Check spelling or add it to the list of known aspects.")
    assert(#maintainer.aspectList == 0)

    res, msg = maintainer:addKnownAspect("Aer")
    assert(not res and msg == "Aspect already in knwon aspects list: Aer")

    res, msg = maintainer:deleteKnownAspect("Invalid")
    assert(not res and msg == "No such aspect in known aspects list: Invalid")

    local newAspect = "Celes"
    res, msg = maintainer:addKnownAspect(newAspect)
    knwonAspects = unserializeFile(testConstants.knownAspectsPath)
    assert(res and msg == string.format("Added %s to the list of known aspects.", newAspect))
    assert(maintainer.knownAspects[newAspect] and knwonAspects[newAspect])

    res, msg = maintainer:deleteKnownAspect(newAspect)
    knwonAspects = unserializeFile(testConstants.knownAspectsPath)
    assert(res and msg == string.format("Deleted %s from the list of known aspects.", newAspect))
    assert(not maintainer.knownAspects[newAspect] and not knwonAspects[newAspect])

    maintainer:readRecords()
    assert(#maintainer.aspectList == 0)

    maintainer:addAspect("Metallum", 1000)
    maintainer:addAspect("Vitium", 100, 25)
    maintainer:addAspect("Aer", 25)
    assert(
        #maintainer.aspectList == 3
            and util.compareTables(maintainer.aspectLookup, { Metallum = 2, Vitium = 3, Aer = 1 })
            and maintainer.aspectList[1].combination == false
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

    res, msg = maintainer:deleteAspect("test")
    assert(not res)

    res = maintainer:deleteAspect("Vitium")
    assert(res)
    maintainer:readRecords()
    assert(#maintainer.aspectList == 2 and util.compareTables(maintainer.aspectLookup, { Metallum = 2, Aer = 1 }))
    assert(maintainer.aspectList[1].name == "Aer")

    os.remove(testConstants.recordsPath)
    maintainer:readRecords()

    res, msg = maintainer:addAspect("Vitium", 200)
    assert(#maintainer.aspectList == 1)
    assert(maintainer.aspectList[1].amount == 200)
    assert(msg == "Added aspect: Vitium")
    res, msg = maintainer:addAspect("Vitium", 400)
    assert(#maintainer.aspectList == 1)
    assert(maintainer.aspectList[1].amount == 400)
    assert(msg == "Updated aspect: Vitium")

    assert(util.isTableEmpty(maintainer.aspectCombinations))
    res, msg = maintainer:addCombination("Invalid", "Invalid1", "invalid2")
    assert(not res and msg == "Unknown aspect: Invalid, check spelling or add it to the list of known aspects.")

    res, msg = maintainer:addAspect("Sanguis", 1000)
    assert(res)

    res, msg = maintainer:addCombination("Sanguis", "Mana", "Ordo")
    assert(
        res
            and util.compareTables(maintainer.aspectCombinations, { Sanguis = { first = "Mana", second = "Ordo" } })
            and maintainer.aspectList[maintainer.aspectLookup["Sanguis"]].combination
    )
    local combFile = unserializeFile(maintainer.config.aspectCombinationsPath)
    assert(combFile["Sanguis"])

    res, msg = maintainer:deleteCombination("Ordo")
    assert(not res and msg == "Combination not present: Ordo" and not util.isTableEmpty(maintainer.aspectCombinations))
    res, msg = maintainer:deleteCombination("Sanguis")
    combFile = unserializeFile(maintainer.config.aspectCombinationsPath)
    assert(
        res
            and util.isTableEmpty(maintainer.aspectCombinations)
            and util.isTableEmpty(combFile)
            and not maintainer.aspectList[maintainer.aspectLookup["Sanguis"]].combination
    )

    util.clearFile(maintainer.config.aspectCombinationsPath, true)

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
    maintainer:addAspect("Celes", 10000)
    maintainer:addAspect("Sonus", 1)
    maintainer:addAspect("Aer", 700)
    maintainer:addCombination("Aer", "Ordo", "Perditio")
    print(maintainer:formattedAspectTable())
    maintainer:addAspect("Auram", 300)
    maintainer:addCombination("Vitium", "Ordo", "Perditio")
    print(maintainer:formattedAspectTable())

    os.remove(testConstants.recordsPath)
    os.remove(testConstants.aspectCombinationsPath)
end

return maintainerTest
