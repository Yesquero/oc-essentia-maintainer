local mockConstants = require("oc-mock.constants")
local serialization = require("serialization")

---@class MEInterface
local me_interface = {}

local function flter(filterTable, table)
    local res = false
    for k, v in pairs(filterTable) do
        res = table[k] == v
    end
    return res
end

local function loadData()
    local data = {}
    local file = assert(io.open(mockConstants.MEDump, "r"))
    local i, line = 1, file:read()
    while line do
        data[i] = serialization.unserialize(line)

        line = file:read()
        i = i + 1
    end
    file:close()
    return data
end

---Get a list of the stored items in the network.
---@param filter table?
---@return table
function me_interface.getItemsInNetwork(filter)
    local data = loadData()
    local res = {}
    if not filter then
        for ind, val in pairs(data) do
            if val.size > 0 then res[#res + 1] = val end
        end
    else
        for ind, val in ipairs(data) do
            if val.size > 0 and flter(filter, val) then res[#res + 1] = val end
        end
    end
    return res
end

return me_interface
