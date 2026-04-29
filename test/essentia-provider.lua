local EssentiaMaintainer = require("oces.maintainer")
local EssentiaProvider = require("oces.essentia-provider")
local ItemDatabase = require("oces.item-database")
local MockEssentiaStorage = require("test.mock-essentia-storage")
local util = require("ysq.utility")

local testConstants = require("test.constants")

local component = require("component")

local essentiaProviderTest = {}

component.proxy = function(uuid)
    if uuid == testConstants.epCfg.interfaceAdaptedID then
        return component.me_interface
    elseif uuid == testConstants.epCfg.smelterAdapterID then
        return component.smeltery
    elseif uuid == testConstants.epCfg.sourceAdapterID then
        return component.me_exportbus
    elseif uuid == testConstants.databaseID then
        return component.database
    elseif uuid == testConstants.epCfgAlt.smelterAdapterID then
        return component.advanced_smelter
    else
        error("Invalid uuid")
    end
end

---@param ep EssentiaProvider
local function testFindItemStack(ep)
    local missingAspects = {
        InvalidAspect = -1,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == nil)

    missingAspects = {
        Vitium = 800,
        Ignis = 100,
        Terra = 50,
        Perditio = 50,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == 6)

    missingAspects = {
        Vitreus = 50,
        Ignis = 1000,
        Potentia = 300,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == 3)

    missingAspects = {
        Vitreus = 50,
        Ignis = 525,
        Potentia = 425,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == 3)

    missingAspects = {
        Vitreus = 50,
        Terra = 250,
        Perditio = 250,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == 5)

    missingAspects = {
        Cognitio = 1000,
        Terra = 250,
        Perditio = 250,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == 8)

    missingAspects = {
        Aer = 100,
        Sonus = 100,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == 2)

    missingAspects = {
        Vitium = 800,
        Ordo = 450,
        Terra = 490,
        Perditio = 500,
        Aqua = 500,
        Ignis = 500,
        Aer = 500,
    }
    assert(ep:findItemStackToSmelt(missingAspects) == 2)

    print("essentiaProvider.testFindItemStack complete")
end

---@param ep EssentiaProvider
local function testFindAspectSource(ep)
    assert(ep:findAspectSource("Invalid", 1) == nil)
    assert(ep:findAspectSource("Vitium", 1)[1].label == "Vishroom")
    local res, msg = ep:findAspectSource("Ordo", 10)

    print("essentiaProvider.testFindAspectSource complete")
end

---@param ep EssentiaProvider
---@param em EssentiaMaintainer
---@param expected table
local function testRefillAspects(ep, em, expected)
    local asserWrapper = function(res, time, msg, ind)
        assert(res == expected[ind].res and time == expected[ind].time and msg == expected[ind].msg)
    end

    local missingAspects = {
        InvalidAspect = -1,
    }
    local res, time, msg = ep:refillAspects(missingAspects)
    asserWrapper(res, time, msg, 1)

    em:addAspect("Potentia", 10)
    res, time, msg = ep:refillAspects(em:getMissingAspects())
    asserWrapper(res, time, msg, 2)
    em:deleteAspect("Potentia")

    missingAspects = {
        Cognitio = 400,
    }
    res, time, msg = ep:refillAspects(missingAspects)
    asserWrapper(res, time, msg, 3)

    missingAspects = {
        Vitium = 800,
        Ignis = 100,
        Terra = 50,
        Perditio = 50,
    }
    component.smeltery.available = false
    component.advanced_smelter.aspects = { Aer = 15 }
    res, time, msg = ep:refillAspects(missingAspects)
    asserWrapper(res, time, msg, 4)
    component.smeltery.available = true
    component.advanced_smelter.aspects = {}

    res, time, msg = ep:refillAspects(missingAspects)
    asserWrapper(res, time, msg, 5)

    missingAspects = {
        Aer = 1000,
        Ignis = 250,
        Potentia = 250,
        Sonus = 100,
    }
    res, time, msg = ep:refillAspects(missingAspects)
    asserWrapper(res, time, msg, 6)

    em:addAspect("Machina", 231)
    em:addAspect("Metallum", 10)
    res, time, msg = ep:refillAspects(em:getMissingAspects())
    asserWrapper(res, time, msg, 7)

    missingAspects = {
        Praemunio = 1000,
    }
    res, time, msg = ep:refillAspects(missingAspects)
    asserWrapper(res, time, msg, 8)

    missingAspects = {
        Vitreus = 400,
    }
    res, time, msg = ep:refillAspects(missingAspects)
    asserWrapper(res, time, msg, 9)

    print("essentiaProvider.testRefillAspects complete")
end

---@param ep EssentiaProvider
local function testConfig(ep, cfg)
    ---@diagnostic disable-next-line:undefined-field
    assert(ep.itemSource.smeltery.type == cfg.smelterType)
    ---@diagnostic disable-next-line:undefined-field
    assert(ep.itemSource.smeltery.efficiency == cfg.efficiency)
    assert(ep.itemSource.type == cfg.sourceType)
    ---@diagnostic disable-next-line:undefined-field
    assert(ep.itemSource.accelerationCardNum == cfg.accelerationCards)
    ---@diagnostic disable-next-line:undefined-field
    assert(ep.itemSource.smeltery.essentiaPerSecond == cfg.essentiaPerSecond)
    ---@diagnostic disable-next-line:undefined-field
    assert(ep.itemSource.exportSide == testConstants.validExportSide)

    print("essentiaProvider.testConfig complete")
end

function essentiaProviderTest.integrationTest()
    util.clearFile(testConstants.recordsPath, true)

    local itemDB = ItemDatabase:new(component.database)

    ---@type EssentiaProvider
    local ep = EssentiaProvider:new(itemDB, testConstants.epConfigPath)
    component.me_exportbus.accCards = testConstants.epCfg.accelerationCards

    testConfig(ep, testConstants.epCfg)
    testFindItemStack(ep)
    testFindAspectSource(ep)

    local MockEs = MockEssentiaStorage:new()
    local Maintainer = EssentiaMaintainer:new(MockEs, testConstants.cfgPath)

    local expected = {
        [1] = {
            res = false,
            time = 0,
            msg = "Database has no Item with required aspects: {InvalidAspect=-1}",
        },
        [2] = {
            res = false,
            time = 0,
            msg = "No Aspects missing;",
        },
        [3] = {
            res = false,
            time = 0,
            msg = "ME network has no items with label: Oak Bookshelf",
        },
        [4] = {
            res = false,
            time = 0,
            msg = "Essentia Smelter is unavailable / proccessing items;",
        },
        [5] = {
            res = true,
            time = 555,
            msg = "(Requested)/(Actual): 100 / 128 Vishroom(s) inserted;",
        },
        [6] = {
            res = true,
            time = 640,
            msg = "(Requested)/(Actual): 67 / 96 Blitz Rod(s) inserted;",
        },
        [7] = {
            res = true,
            time = 107,
            msg = "(Requested)/(Actual): 47 / 64 Stone Gear(s) inserted;",
        },
        [8] = {
            res = true,
            time = 290,
            msg = "(Requested)/(Actual): 50 / 10 Chain Chestplate(s) inserted;",
        },
        [9] = {
            res = true,
            time = 25,
            msg = "(Requested)/(Actual): 80 / 15 Clear Glass(s) inserted;",
        },
    }
    testRefillAspects(ep, Maintainer, expected)

    local epAlt = EssentiaProvider:new(itemDB, testConstants.epConfigPathAlt)
    component.me_exportbus.accCards = testConstants.epCfgAlt.accelerationCards

    testConfig(epAlt, testConstants.epCfgAlt)
    testFindItemStack(epAlt)
    testFindAspectSource(epAlt)

    util.clearFile(testConstants.recordsPath, true)
    Maintainer.aspectList = {}
    Maintainer:rebuildLookup()

    expected[5] = {
        res = true,
        time = 278,
        msg = "(Requested)/(Actual): 100 / 128 Vishroom(s) inserted;",
    }
    expected[6] = {
        res = true,
        time = 427,
        msg = "(Requested)/(Actual): 67 / 128 Blitz Rod(s) inserted;",
    }
    expected[7] = {
        res = true,
        time = 54,
        msg = "(Requested)/(Actual): 47 / 64 Stone Gear(s) inserted;",
    }
    expected[8] = {
        res = true,
        time = 145,
        msg = "(Requested)/(Actual): 50 / 10 Chain Chestplate(s) inserted;",
    }
    expected[9] = {
        res = true,
        time = 13,
        msg = "(Requested)/(Actual): 80 / 15 Clear Glass(s) inserted;",
    }
    testRefillAspects(epAlt, Maintainer, expected)

    print("essentiaProviderTest.integrationTest complete")
end

return essentiaProviderTest
