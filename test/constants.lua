local testConstants = {
	cfgPath = "test/data/oces.cfg",
	recordsPath = "test/data/oces-records.txt",
	defaultPollingInterval = 5,
	defaultPriority = 10,
	dbDataFile = "resource/data/db_dump.txt",
	getAspectsDataFile = "resource/data/getAspects.txt",
}

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
