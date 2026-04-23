local Class = require("ysq.class")
local constants = require("oces.constants")

---@class ItemDB: AbstractClass
---@field new fun(self: ItemDB, dbComponent: table): ItemDB
---@field dbComponent DatabaseComponent
---@field items { label: string, aspects: Aspects[] }[]
---@field aspectLookup { [string]: { slot: integer, amount: integer }[]}
---@field numSlots integer
local ItemDatabase = Class:inherit({
	dbComponent = nil,
	items = {},
	aspectLookup = {},
	numSlots = constants.databaseSlots,
})

---Initializes list of available items
function ItemDatabase:initializeItems()
	assert(self.dbComponent)
	for i = 1, self.numSlots do
		local entry = self.dbComponent.get(i)
		if entry and entry.aspects then
			self.items[i] = {
				label = entry.label,
				aspects = entry.aspects,
			}
		end
	end
end

---Rebuild aspect lookup table
function ItemDatabase:rebuildLookupTable()
	local availableAspects = {}
	for i = 1, #self.items do
		for key, val in pairs(self.items[i].aspects) do
			availableAspects[key] = true
		end
	end

	for key, val in pairs(availableAspects) do
		local itemsWithAspect = {}
		for i = 1, #self.items do
			local aspectAmount = self.items[i].aspects[key]
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
		self.aspectLookup[key] = itemsWithAspect
	end
end

---Initialize item and lookup tables.
---@param dbComponent DatabaseComponent
function ItemDatabase:initialize(dbComponent)
	assert(dbComponent, "Database component is null")
	self.dbComponent = dbComponent

	self:initializeItems()
	self:rebuildLookupTable()
end

return ItemDatabase
