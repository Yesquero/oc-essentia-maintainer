local filesystem = {}

local constants = require("oces.constants")
local testConstants = require("test.constants")

local validPaths = {
    constants.defaultCfgPath,
    testConstants.cfgPath,
    constants.defaultEPConfigPath,
    testConstants.epConfigPath,
}

---Retrun true if specified path exists, false otherwise.
---@param path string
function filesystem.exists(path)
    for k, v in ipairs(validPaths) do
        if path == v then return true end
    end
    return false
end

return filesystem
