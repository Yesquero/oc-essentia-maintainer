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

---Creates an instance
---@param protoype table?
---@return ItemDB
function itemDatabase.ItemDB:new(protoype)
	protoype = protoype or {}
	setmetatable(protoype, self)
	self.__index = self
	return protoype
end

---Initializes list of available items
function itemDatabase.ItemDB:initializeItems()
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
function itemDatabase.ItemDB:rebuildLookupTable()
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
function itemDatabase.ItemDB:init(dbComponent)
	assert(dbComponent, "Database component is null")
	self.dbComponent = dbComponent

	self:initializeItems()
	self:rebuildLookupTable()
end

return itemDatabase
