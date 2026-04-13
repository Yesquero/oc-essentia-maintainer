local component = require("component")
local itemDB = require("oces.item-database")
local util = require("oces.utility")

local itemDBTest = {}

local expectedItems = {
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

function itemDBTest.setup()
	local itemDB = itemDB.ItemDB
	itemDB.init(component.database)

	assert(util.compareTables(itemDB.items, expectedItems))
	assert(util.compareTables(itemDB.aspectLookup["Ignis"], {
		{ slot = 3, amount = 15 },
		{ slot = 9, amount = 10 },
	}))
	assert(util.compareTables(itemDB.aspectLookup["Potentia"], {
		{ slot = 9, amount = 10 },
		{ slot = 3, amount = 5 },
	}))
	assert(util.compareTables(itemDB.aspectLookup["Vitreus"], {
		{ slot = 1, amount = 5 },
	}))
	assert(util.compareTables(itemDB.aspectLookup["Mortuus"], {
		{ slot = 10, amount = 5 },
		{ slot = 6, amount = 1 },
	}))

	print("itemDBTest.setup complete")
end

return itemDBTest
