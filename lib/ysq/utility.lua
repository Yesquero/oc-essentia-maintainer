local utility = {}

---Does a nested compare on tables, uses == on non table values, untested.
---@param left table
---@param right table
---@return boolean
function utility.compareTables(left, right)
	if left == nil and right == nil then return true end
	if left == nil or right == nil then return false end

	if type(left) ~= type(right) then return false end

	if type(left) ~= "table" then return left == right end

	for k, v in pairs(left) do
		if not utility.compareTables(right[k], v) then return false end
	end

	for k, v in pairs(right) do
		if not utility.compareTables(left[k], v) then return false end
	end

	return true
end

---Remove elements from an array, returns false if no elements removed.
---cmp accepts signle arg, the valaue of arrray[i] at each iteration and must return true if it is to be removed, false otherwise.
---A variantion of https://stackoverflow.com/a/53038524
---TODO: add optional is array arg an array check
---@param array any[]
---@param cmp fun(any): boolean
---@return boolean
function utility.arrayRemove(array, cmp)
	if #array == 0 then return false end

	local j, len = 1, #array
	for i = 1, len do
		if cmp(array[i]) then
			array[i] = nil
		elseif i ~= j then
			array[j] = array[i]
			array[i] = nil
			j = j + 1
		else
			j = j + 1
		end
	end

	return len ~= #array
end

---Clear a file, is the file is meant to be used with OC serialization methods pass true as second arg write {} to the file
---@param filename string
---@param isSerializationTarget boolean?
function utility.clearFile(filename, isSerializationTarget)
	local file = assert(io.open(filename, "w"))
	local isSerializationTarget = isSerializationTarget or false
	if isSerializationTarget then file:write("{}") end
	file:close()
end

return utility
