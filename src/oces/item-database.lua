local Class = require("ysq.class")
local constants = require("oces.constants")
local ocesUtil = require("oces.utility")

---@class ItemDB: AbstractClass
---@field new fun(self: ItemDB, dbComponent: table): ItemDB
---@field dbComponent DatabaseComponent
---@field items { label: string, aspects: Aspects[] }[]
---@field aspectLookup { [string]: { slot: integer, amount: integer }[]}
---@field aspectRatioLookup { [integer]: Aspects}
---@field numSlots integer
local ItemDatabase = Class:inherit({
    dbComponent = nil,
    items = {},
    aspectLookup = {},
    numSlots = constants.databaseSlots,
    aspectRatioLookup = {},
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
function ItemDatabase:rebuildAspectLookup()
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
        table.sort(itemsWithAspect, function(lhs, rhs) return lhs.amount > rhs.amount end)
        self.aspectLookup[key] = itemsWithAspect
    end
end

function ItemDatabase:rebuildRatioLookup()
    for i = 1, #self.items do
        self.aspectRatioLookup[i] = ocesUtil.valToPercentDict(self.items[i].aspects)
    end
end

---Initialize item and lookup tables.
---@param dbComponent DatabaseComponent
function ItemDatabase:initialize(dbComponent)
    assert(dbComponent, "Database component is null")
    self.dbComponent = dbComponent

    self:initializeItems()
    self:rebuildAspectLookup()
    self:rebuildRatioLookup()
end

---Get underlying Database component.
---@return DatabaseComponent
function ItemDatabase:getComponent() return self.dbComponent end

return ItemDatabase
