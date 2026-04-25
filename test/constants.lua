local testConstants = {
	cfgPath = "test/data/oces.cfg",
	recordsPath = "test/data/oces-records.txt",
	defaultPollingInterval = 5,
	defaultPriority = 10,
	dbDataFile = "resource/data/db_dump.txt",
	getAspectsDataFile = "resource/data/getAspects.txt",
	epConfigPath = "test/data/oces-ep.cfg",
	databaseID = "ab142877-2995-479c-b1e6-363146c898d0",
	validExportSide = 4,
}

local EPConfig = {
	efficiency = 0.8,
	accelerationCards = 3,
	sourceType = "ExportBus",
	smelterType = "EssentiaSmeltery",
	smelterAdapterID = "e0eab32d-41e8-4a1a-aafd-c8bf15117ffd",
	sourceAdapterID = "4f177b1e-a237-4cf7-b353-c63fd363a1e0",
	interfaceAdaptedID = "7363a082-6765-45f4-8a48-a5d57692a581",
}
testConstants.epConfig = EPConfig

testConstants.expectedDBItems = {
	{ label = "Clear Glass", aspects = { Vitreus = 5 } },
	{ label = "Blitz Rod", aspects = { Aer = 15, Alkimia = 5 } },
	{ label = "Blaze Rod", aspects = { Potentia = 5, Ignis = 15 } },
	{ label = "Lead Ingot", aspects = { Ordo = 5, Metallum = 10 } },
	{ label = "Sand", aspects = { Perditio = 5, Terra = 5 } },
	{ label = "Vishroom", aspects = { Mortuus = 1, Herba = 2, Vitium = 8, Praecantatio = 1, Perditio = 1 } },
	{ label = "Stone Gear", aspects = { Machina = 5 } },
	{ label = "Oak Bookshelf", aspects = { Cognitio = 8 } },
	{ label = "Coal", aspects = { Potentia = 10, Ignis = 10 } },
	{ label = "Bone", aspects = { Mortuus = 5, Victus = 5 } },
}

return testConstants
