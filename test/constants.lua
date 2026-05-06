local testConstants = {
    cfgPath = "test/data/maintainer.cfg",
    recordsPath = "test/data/records.txt",
    knownAspectsPath = "test/data/known-aspects.txt",
    aspectCombinationsPath = "test/data/combinations.txt",
    mainPollingInterval = 5,
    refillPollingInterval = 2,
    tableEntrierPerRow = 5,
    tableMaxNumLen = 6,
    defaultPriority = 10,
    dbDataFile = "resource/data/db_dump.txt",
    getAspectsDataFile = "resource/data/getAspects.txt",
    epConfigPath = "test/data/provider.cfg",
    epConfigPathAlt = "test/data/provider-alt.cfg",
    databaseID = "ab142877-2995-479c-b1e6-363146c898d0",
    validExportSide = 4,
}

local EPConfig = {
    efficiency = 0.8,
    accelerationCards = 2,
    sourceType = "ExportBus",
    smelterType = "EssentiaSmeltery",
    essentiaPerSecond = 3.0,
    smelterAdapterID = "e0eab32d-41e8-4a1a-aafd-c8bf15117ffd",
    sourceAdapterID = "4f177b1e-a237-4cf7-b353-c63fd363a1e0",
    interfaceAdaptedID = "7363a082-6765-45f4-8a48-a5d57692a581",
}
testConstants.epCfg = EPConfig

local EPConfigAlt = {
    efficiency = 1,
    accelerationCards = 3,
    sourceType = "ExportBus",
    smelterType = "AdvancedAlchemicalSmelter",
    essentiaPerSecond = 6.0,
    smelterAdapterID = "ec6b45a0-41c3-4269-97fb-433bebb92db6",
    sourceAdapterID = "4f177b1e-a237-4cf7-b353-c63fd363a1e0",
    interfaceAdaptedID = "7363a082-6765-45f4-8a48-a5d57692a581",
}
testConstants.epCfgAlt = EPConfigAlt

testConstants.expectedDBItems = {
    { label = "Clear Glass", aspects = { Vitreus = 5 }, totalAspects = 5 },
    { label = "Blitz Rod", aspects = { Aer = 15, Alkimia = 5 }, totalAspects = 20 },
    { label = "Blaze Rod", aspects = { Potentia = 5, Ignis = 15 }, totalAspects = 20 },
    { label = "Lead Ingot", aspects = { Ordo = 5, Metallum = 10 }, totalAspects = 15 },
    { label = "Sand", aspects = { Perditio = 5, Terra = 5 }, totalAspects = 10 },
    {
        label = "Vishroom",
        aspects = { Mortuus = 1, Herba = 2, Vitium = 8, Praecantatio = 1, Perditio = 1 },
        totalAspects = 13,
    },
    { label = "Stone Gear", aspects = { Machina = 5 }, totalAspects = 5 },
    { label = "Oak Bookshelf", aspects = { Cognitio = 8 }, totalAspects = 8 },
    { label = "Coal", aspects = { Potentia = 10, Ignis = 10 }, totalAspects = 20 },
    { label = "Bone", aspects = { Mortuus = 5, Victus = 5 }, totalAspects = 10 },
    { label = "Sunflower", aspects = { Herba = 5, Sensus = 5, Aer = 1, Victus = 1 }, totalAspects = 12 },
    { label = "Chain Chestplate", aspects = { Praemunio = 20, Metallum = 67 }, totalAspects = 87 },
}

return testConstants
