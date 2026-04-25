local ItemDatabase = require("oces.item-database")
local component = require("component")
local testConstants = require("test.constants")
local util = require("ysq.utility")

local itemDBTest = {}

function itemDBTest.unitTest()
    local itemDB = ItemDatabase:new(component.database)

    assert(util.compareTables(itemDB.items, testConstants.expectedDBItems))
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

    print("itemDBTest.unitTest complete")
end

return itemDBTest
