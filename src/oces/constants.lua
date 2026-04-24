local constants = {
	version = "0.0.1",
	defaultCfgPath = "/etc/oces.cfg",
	defaultRecordsPath = "/etc/oces-records.txt",
	defaultEPConfigPath = "/etc/oces-ep.cfg",
	defaultPriority = 0,
	defaultPollingInterval = 10,
	databaseSlots = 81,
}

local SmelterType = {
	Default = 1,
	EssentiaSmeltry = 2,
	AdvancedAlchemicalConstruct = 3,
}

local ItemSourceType = {
	Default = 1,
	ExportBus = 2,
}

constants.SmelterType = SmelterType
constants.ItemSourceType = ItemSourceType

return constants
