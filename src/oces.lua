local component = require("component")
local shell = require("shell")
local term = require("term")

local EssentiaMaintainer = require("oces.maintainer")
local EssentiaProvider = require("oces.essentia-provider")
local InfusionProvider = require("oces.impl.infusion-provider-es")
local ItemDatabase = require("oces.item-database")
local constants = require("oces.constants")

local function init()
	local EssentiaStorage = InfusionProvider:new(component.thaumicenergistics_infusion_provider)
	local ItemDB = ItemDatabase:new(component.database)
	local Maintainer = EssentiaMaintainer:new(EssentiaStorage)
	local Provider = EssentiaProvider:new(ItemDB)

	return EssentiaStorage, ItemDB, Maintainer, Provider
end

---@param Maintainer EssentiaMaintainer
---@param name string
---@param amount integer
local function addAspect(Maintainer, name, amount)
	local res = Maintainer:addAspect(name, amount)
	if res then
		print("Added aspect: " .. name)
	else
		print("Could not add aspect: " .. name)
	end
end

---@param Maintainer EssentiaMaintainer
---@param name string
local function deleteAspect(Maintainer, name)
	local res, msg = Maintainer:deleteAspect(name)
	if res then
		print("Deleted aspect: " .. name)
	else
		print("Could not delete aspect: " .. name .. "; " .. msg)
	end
end

---@param Maintainer EssentiaMaintainer
local function showAspects(Maintainer) print(Maintainer:showAspectList()) end

---@param Provider EssentiaProvider
local function findAspectSource(Provider, name, maxResults)
	local res, msg = Provider:findAspectSource(name, maxResults or 0)
	if res then
		for ind, val in ipairs(res) do
			print(string.format("%s: %i %s", val.label, val.aspects[name]), name)
		end
	else
		print(msg)
	end
end

---@param Maintainer EssentiaMaintainer
---@param Provider EssentiaProvider
local function maintainerLoop(Maintainer, Provider)
	term.clear()
	print(Maintainer:showAspectList())

	local missingAspects = Maintainer:getMissingAspects()

	local res, msg = Provider:refillAspects(missingAspects)
	if res then
		print("Refilling aspects: " .. msg)
	else
		print("Unable to refill aspects: " .. msg)
	end

	os.sleep(Maintainer.config.pollingInterval)
end

local function showHelp()
	local usage = [[
	oces version %s 
	Usage: oces [key] arg...
	Keys:
	--add <string> <integer>	Add Aspect to the list of maintained aspects.
	--delete <string>			Delete Aspect from the list of maintained aspects.
	--show						Show list of maintained aspects.
	--find <string> <integer>	Find all items with the specified aspect, sorted by its amount. Second arg is max number of results.
	--start						Start maintaining aspects, runs in foreground.
	--help						Show usage.
	]]

	print(string.format(usage, constants.version))
end

---@param args any[]
---@param ops {[string]: boolean}
---@param Maintainer EssentiaMaintainer
---@param Provider EssentiaProvider
local function chooseFunction(args, ops, Maintainer, Provider)
	if ops.add then
		addAspect(Maintainer, args[1], args[2])
	elseif ops.delete then
		deleteAspect(Maintainer, args[1])
	elseif ops.show then
		showAspects(Maintainer)
	elseif ops.find then
		findAspectSource(Provider, args[1], args[2])
	elseif ops.start then
		maintainerLoop(Maintainer, Provider)
	elseif ops.help then
		showHelp()
	else
		error("Invalid programm options.")
	end
end

local function main()
	local initRes, EssentiaStorage, ItemDB, Maintainer, Provider = pcall(init)
	if not initRes then
		print("Something went wrong: " .. EssentiaStorage)
		return
	end

	---@diagnostic disable-next-line:unexpect-dots
	local args, ops = shell.parse(...)

	local res, msg = pcall(chooseFunction, args, ops, Maintainer, Provider)
	if not res then print("Something went wrong: " .. msg) end
end

main()
