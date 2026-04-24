local utility = {}

---@param dict {[string]: integer}
---@return {[string]: number}
function utility.valToRatioDict(dict)
	local ratioDict = {}
	local min = math.maxinteger
	for k, v in pairs(dict) do
		min = math.min(min, v)
	end

	for k, v in pairs(dict) do
		ratioDict[k] = v / min
	end

	return ratioDict
end

return utility
