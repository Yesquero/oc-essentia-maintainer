local utility = {}

---@param dict {[string]: integer}
---@return {[string]: number}
function utility.valToPercentDict(dict)
	local ratioDict = {}
	local sum = 0
	for k, v in pairs(dict) do
		sum = sum + v
	end

	for k, v in pairs(dict) do
		ratioDict[k] = v / sum * 100
	end

	return ratioDict
end

return utility
