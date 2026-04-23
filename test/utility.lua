local util = require("ysq.utility")

local utilityTest = {}

function utilityTest.testArrayRemove()
	local arr = {}
	local res = util.arrayRemove(arr, {})
	assert(not res)

	arr = { 1, 2, 3, 4, 5, 6 }

	res = util.arrayRemove(arr, function(val)
		return val == -1
	end)
	assert(not res)

	res = util.arrayRemove(arr, function(val)
		return val == 3
	end)
	assert(res and util.compareTables(arr, { 1, 2, 4, 5, 6 }))

	res = util.arrayRemove(arr, function(val)
		return val == 1
	end)
	assert(res and util.compareTables(arr, { 2, 4, 5, 6 }))

	res = util.arrayRemove(arr, function(val)
		return val == 6
	end)
	assert(res and util.compareTables(arr, { 2, 4, 5 }))

	res = util.arrayRemove(arr, function(val)
		return val == 2 or val == 5
	end)
	assert(res and util.compareTables(arr, { 4 }))

	res = util.arrayRemove(arr, function(val)
		return val == 4
	end)
	assert(res and util.compareTables(arr, {}))

	print("utilityTest.testArrayRemove complete")
end

return utilityTest
