local constants = require("oces.constants")

local itemDatabase = {}

---@class ItemDB
itemDatabase.ItemDB = {
	---@type DatabaseComponent
	dbComponent = nil,
	---@type  { label: string, aspects: Aspects[] }[]
	items = {},
	---@type { [string]: { slot: integer, amount: integer }[]}
	aspectLookup = {},
	numSlots = constants.databaseSlots,
}

local function initializeItems()
	assert(itemDatabase.ItemDB.dbComponent)
	for i = 1, itemDatabase.ItemDB.numSlots do
		local entry = itemDatabase.ItemDB.dbComponent.get(i)
		if entry and entry.aspects then
			itemDatabase.ItemDB.items[i] = {
				label = entry.label,
				aspects = entry.aspects,
			}
		end
	end
end

local function rebuildLookupTable()
	local availableAspects = {}
	for i = 1, #itemDatabase.ItemDB.items do
		for key, val in pairs(itemDatabase.ItemDB.items[i].aspects) do
			availableAspects[key] = true
		end
	end

	for key, val in pairs(availableAspects) do
		local itemsWithAspect = {}
		for i = 1, #itemDatabase.ItemDB.items do
			local aspectAmount = itemDatabase.ItemDB.items[i].aspects[key]
			if aspectAmount then
				itemsWithAspect[#itemsWithAspect + 1] = {
					slot = i,
					amount = aspectAmount,
				}
			end
		end
		table.sort(itemsWithAspect, function(lhs, rhs)
			return lhs.amount > rhs.amount
		end)
		itemDatabase.ItemDB.aspectLookup[key] = itemsWithAspect
	end
end

---Initialize item and lookup tables.
---@param dbComponent any
function itemDatabase.ItemDB.init(dbComponent)
	assert(dbComponent, "Database component is null")
	itemDatabase.ItemDB.dbComponent = dbComponent

	initializeItems()
	rebuildLookupTable()
end

return itemDatabase
