local constants = require("oces.constants")
local essentiaMaintainer = require("oces.maintainer")
local testConstants = require("test.constants")
local util = require("ysq.utility")

local maintainerTest = {}

function maintainerTest.setup()
	local maintainer = essentiaMaintainer.Maintainer:new({ configPath = testConstants.cfgPath })

	assert(util.compareTables(maintainer.config, {
		defaultPriority = constants.defaultPriority,
		pollingInterval = constants.defaultPollingInterval,
		recordsPath = constants.defaultRecordsPath,
	}))

	maintainer:readConfig()
	assert(util.compareTables(maintainer.config, {
		defaultPriority = testConstants.defaultPriority,
		pollingInterval = testConstants.defaultPollingInterval,
		recordsPath = testConstants.recordsPath,
	}))

	util.clearFile(maintainer.config.recordsPath, true)

	maintainer:readRecords()
	assert(#maintainer.aspectList == 0)

	maintainer:addAspect("Metallum", 1000)
	maintainer:addAspect("Vitium", 100, 25)
	assert(#maintainer.aspectList == 2 and util.compareTables(maintainer.aspectLookup, { Metallum = 2, Vitium = 1 }))
	assert(maintainer.aspectList[2].name == "Metallum")

	maintainer.aspectList = {}
	assert(#maintainer.aspectList == 0)

	maintainer:readRecords()
	assert(#maintainer.aspectList == 2 and util.compareTables(maintainer.aspectLookup, { Metallum = 2, Vitium = 1 }))
	assert(maintainer.aspectList[1].name == "Vitium")
	assert(maintainer.aspectList[2].priority == maintainer.config.defaultPriority)

	local res, msg = maintainer:deleteAspect("test")
	assert(not res)

	res = maintainer:deleteAspect("Vitium")
	assert(res)
	maintainer:readRecords()
	assert(#maintainer.aspectList == 1 and util.compareTables(maintainer.aspectLookup, { Metallum = 1 }))
	assert(maintainer.aspectList[1].name == "Metallum")

	print("maintainerTest.setup complete")
end

return maintainerTest
