local constants = {
    version = "0.9.4",
    defaultCfgPath = "/etc/oces.cfg",
    defaultRecordsPath = "/etc/oces-records.txt",
    defaultEPConfigPath = "/etc/oces-ep.cfg",
    defaultPriority = 0,
    defaultPollingInterval = 10,
    databaseSlots = 81,
    smelteryitemSlot = 1,
    essentiaPerSecond = 1.0,
}

local SmelterType = {
    Default = "Default",
    EssentiaSmeltery = "EssentiaSmeltery",
    AdvancedAlchemicalConstruct = "AdvancedAlchemicalConstruct",
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
