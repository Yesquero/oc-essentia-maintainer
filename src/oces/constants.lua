local constants = {
    version = "0.9.71",
    defaultCfgPath = "/etc/oces/maintainer.cfg",
    defaultRecordsPath = "/etc/oces/records.txt",
    defaultEPConfigPath = "/etc/oces/provider.cfg",
    defaultKnownAspectsPath = "/etc/oces/known-aspects.txt",
    defaultCombinerCfgPath = "/etc/oces/combiner.cfg",
    aspectCombinationsPath = "/etc/oces/combinations.txt",
    defaultPriority = 0,
    mainPollingInterval = 10,
    refillPollingInterval = 5,
    tableEntrierPerRow = 4,
    tableMaxNumLen = 5,
    databaseSlots = 81,
    smelteryitemSlot = 1,
    essentiaPerSecond = 1.0,
}

local SmelterType = {
    Default = "Default",
    EssentiaSmeltery = "EssentiaSmeltery",
    AdvancedAlchemicalSmelter = "AdvancedAlchemicalSmelter",
}
setmetatable(SmelterType, {
    __index = function(table, index) error("Invalid SmelterType") end,
})

local ItemSourceType = {
    Default = "Default",
    ExportBus = "ExportBus",
}
setmetatable(ItemSourceType, {
    __index = function(table, index) error("Invalid ItemSourceType") end,
})

constants.SmelterType = SmelterType
constants.ItemSourceType = ItemSourceType

return constants
