local IItemSource = require("oces.interface.item-source")
local constants = require("oces.constants")
local util = require("ysq.utility")

---@class ExportBusIS: IItemSource
local ExportBusIS = IItemSource:inherit()

ExportBusIS.type = constants.ItemSourceType.ExportBus
---@type MEEBus
ExportBusIS.exportBus = nil
---@type TCSmeltery
ExportBusIS.smeltery = nil
---@type MEInterface
ExportBusIS.meInterface = nil
ExportBusIS.exportSide = -1

function ExportBusIS:initialize(exportBus, smeltery, meInterface)
	assert(exportBus, "Export Bus component is null")
	assert(smeltery, "Essentia Smeltery component is null")
	assert(meInterface, "Essentia Smeltery component is null")
	self.exportBus = exportBus

	for i = 1, 5, 1 do
		if self.exportBus.getExportConfiguration(i) then self.exportSide = i end
	end
end

---Smeltery is considered available if its input slot is sempty.
---@return boolean
function ExportBusIS:isSmelterAvailable() return self.smeltery.getStackInSlot(constants.smelteryitemSlot).id == 0 end

---Attempts to find ItemStacks with specified aspect.
---@param name string
---@param maxResults integer?
---@return { label: string, aspects: Aspects} | nil
---@return string?
function ExportBusIS:findAspectSource(name, maxResults)
	local allItems = self.meInterface.getItemsInNetwork()
	util.arrayRemove(allItems, function(value) return value.aspects and value.aspects[name] == nil end)

	if #allItems == 0 then return nil, "No items found with aspect: " .. name end

	local maxResults = math.min(#allItems, maxResults or 1)
	local res = {}
	for i = 1, maxResults do
		res[#res + 1] = {
			label = allItems[i].label,
			aspects = allItems[i].aspects,
		}
	end
	table.sort(res, function(lhs, rhs) return lhs.aspects[name] > rhs.aspects[name] end)

	return res
end

return ExportBusIS
