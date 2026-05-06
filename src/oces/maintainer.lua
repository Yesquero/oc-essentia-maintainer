local filesystem = require("filesystem")
local serialization = require("serialization")

local Class = require("ysq.class")
local constants = require("oces.constants")
local util = require("ysq.utility")

---@class MaintainerConfig
local config = {
    defaultPriority = constants.defaultPriority,
    mainPollingInterval = constants.mainPollingInterval,
    refillPollingInterval = constants.refillPollingInterval,
    tableMaxNumLen = constants.tableMaxNumLen,
    tableEntrierPerRow = constants.tableEntrierPerRow,
    recordsPath = constants.defaultRecordsPath,
    knownAspectsPath = constants.defaultKnownAspectsPath,
}

local printCfg = {
    maxAspLen = 0,
}

---@class EssentiaMaintainer: AbstractClass
---@field new fun(self,essentiaStorage: IEssentiaStorage, configPath: string?): EssentiaMaintainer
local EssentiaMaintainer = Class:inherit()

---@type {name: string, amount: integer, priority: integer}[]
EssentiaMaintainer.aspectList = {}
---@type { [string]: integer }
EssentiaMaintainer.aspectLookup = {}
---@type string
EssentiaMaintainer.configPath = constants.defaultCfgPath
---@type MaintainerConfig
EssentiaMaintainer.config = config
---@type IEssentiaStorage
EssentiaMaintainer.essentiaStorage = nil
---@type { [string]: boolean}
EssentiaMaintainer.knownAspects = {}

---@param path string
local function createBlankRecords(path)
    local file = assert(io.open(path, "w"))
    file:write("{}")
    file:close()
end

---Read config from a file.
---TODO: create file with default values if none exists
---TODO: sanity check values
---@return boolean
function EssentiaMaintainer:readConfig()
    local file = assert(io.open(self.configPath, "r"), "Could not open config file: " .. self.configPath)
    self.config = assert(serialization.unserialize(file:read("a")), "Error when reading config file.")
    file:close()
    return true
end

---Read list of aspects to maintain from a file.
---@return boolean
function EssentiaMaintainer:readRecords()
    if not filesystem.exists(self.config.recordsPath) then createBlankRecords(self.config.recordsPath) end

    local file =
        assert(io.open(self.config.recordsPath, "r"), "Could not open records file: " .. self.config.recordsPath)
    self.aspectList = assert(
        serialization.unserialize(file:read("a")),
        "Error when reading records file: " .. self.config.recordsPath
    )
    file:close()
    table.sort(self.aspectList, function(lhs, rhs) return lhs.name < rhs.name end)

    self:rebuildLookup()

    return true
end

---Read list of known aspects from a file.
---@return boolean
function EssentiaMaintainer:readKnwonAspects()
    local file = assert(
        io.open(self.config.knownAspectsPath, "r"),
        "Could not open known aspects file: " .. self.config.knownAspectsPath
    )
    self.knownAspects =
        assert(serialization.unserialize(file:read("a")), "Parsing error: " .. self.config.knownAspectsPath)
    file:close()
    return true
end

---Add aspect to the list of knwon aspects, save it to file.
---@param name string
---@return boolean
---@return string
function EssentiaMaintainer:addKnownAspect(name)
    assert(name and type(name) == "string")
    if self.knownAspects[name] then return false, "Aspect already in knwon aspects list: " .. name end

    self.knownAspects[name] = true
    local file = assert(
        io.open(self.config.knownAspectsPath, "w"),
        "Could not open knwon aspects file: " .. self.config.knownAspectsPath
    )
    assert(file:write(serialization.serialize(self.knownAspects)))
    file:close()

    return true, string.format("Added %s to the list of known aspects.", name)
end

---Delete aspect from the list of knwon aspects, save it to file.
---@param name string
---@return boolean
---@return string
function EssentiaMaintainer:deleteKnownAspect(name)
    assert(name and type(name) == "string")
    if not self.knownAspects[name] then return false, "No such aspect in known aspects list: " .. name end

    self.knownAspects[name] = nil
    local file = assert(
        io.open(self.config.knownAspectsPath, "w"),
        "Could not open knwon aspects file: " .. self.config.knownAspectsPath
    )
    assert(file:write(serialization.serialize(self.knownAspects)))
    file:close()

    return true, string.format("Deleted %s from the list of known aspects.", name)
end

---Add an aspect to list of aspect to maintain, uses default priority from config if none given.
---TODO: add check against a list of known aspects
---@param name string
---@param amount integer
---@param priority integer?
---@return boolean
---@return string
function EssentiaMaintainer:addAspect(name, amount, priority)
    assert(name and type(name) == "string", "addAspect invalid argument(s)")
    assert(amount and type(amount == "number" and amount > 0), "addAspect invalid argument(s)")

    if not self.knownAspects[name] then
        return false, string.format("Unknown aspect: %s; Check spelling or add it to the list of known aspects.", name)
    end

    local msg = "Added aspect: "

    self:readRecords()

    if self.aspectLookup[name] then
        self.aspectList[self.aspectLookup[name]].amount = amount
        msg = "Updated aspect: "
    else
        self.aspectList[#self.aspectList + 1] = {
            name = name,
            amount = amount,
            priority = priority or self.config.defaultPriority,
        }
    end

    table.sort(self.aspectList, function(lhs, rhs) return lhs.name < rhs.name end)

    self:saveRecords()
    self:rebuildLookup()

    return true, msg .. name
end

---Delete aspect with given name from the list of aspects to maintain.
---Returns false if no matching aspect found or aspect list is empty.
---Assumes readRecords() will be called sometime afterwards, meant to be used from CLI.
---TODO: current implementation assumes readRecords will be run before aspectList or aspectLookup will be accessed again, this should be fine if its only called from cli though.
---@param name string
---@return boolean
---@return string?
function EssentiaMaintainer:deleteAspect(name)
    assert(name and type(name) == "string", "deleteAspect invalid argument(s)")

    self:readRecords()
    if #self.aspectList == 0 then return true end

    local res = util.arrayRemove(self.aspectList, function(val) return val.name == name end)
    if res then
        self:saveRecords()
        return true
    end

    return false, "Could not find saved aspect with matching name: " .. name
end

---Returns stylized string representation of maintained aspects and their current amount.
---@return string
function EssentiaMaintainer:formattedAspectTable()
    local storedAspects = self.essentiaStorage:getAspects()

    local res = "ASPECTS: Actual / Desired\n"
    local header =
        string.rep("-", (8 + printCfg.maxAspLen + self.config.tableMaxNumLen * 2) * self.config.tableEntrierPerRow - 1)
    res = res .. header .. "\n"
    local cnt = 0

    for ind, val in ipairs(self.aspectList) do
        if cnt == 0 and ind ~= 1 then res = res .. "\n" end

        local namePadding = string.rep(" ", printCfg.maxAspLen - #val.name)
        local firstNumPadding = string.rep(" ", self.config.tableMaxNumLen - #tostring(storedAspects[val.name] or 0))
        local secondNumPadding = string.rep(" ", self.config.tableMaxNumLen - #tostring(val.amount))
        local mark = "-"
        if (storedAspects[val.name] or 0) >= val.amount then mark = "+" end

        res = res
            .. string.format(
                "%s%s:%s%s%i / %i%s | ",
                mark,
                val.name,
                namePadding,
                firstNumPadding,
                (storedAspects[val.name] or 0),
                val.amount,
                secondNumPadding
            )

        if cnt == self.config.tableEntrierPerRow - 1 then
            cnt = 0
        else
            cnt = cnt + 1
        end
    end

    return res .. "\n" .. header
end

---Save current list of maintained aspect to a file.
---@return boolean
function EssentiaMaintainer:saveRecords()
    local file = assert(io.open(self.config.recordsPath, "w"))
    file = assert(io.open(self.config.recordsPath, "w"), "Error when writing to records file.")
    file:write(serialization.serialize(self.aspectList))
    file:close()

    return true
end

---Rebuild aspects lookup table based on maintained aspects.
function EssentiaMaintainer:rebuildLookup()
    self.aspectLookup = {}

    -- local sortByPriority = function(left, right) return left.priority > right.priority end
    -- table.sort(self.aspectList, sortByPriority)

    for i = 1, #self.aspectList do
        printCfg.maxAspLen = math.max(printCfg.maxAspLen, #self.aspectList[i].name)
        self.aspectLookup[self.aspectList[i].name] = i
    end
end

---TODO check args ?
function EssentiaMaintainer:initialize(essentiaStorage, configPath)
    self.configPath = configPath or constants.defaultCfgPath
    self.essentiaStorage = essentiaStorage
    self:readConfig()
    self:readRecords()
    self:readKnwonAspects()
end

---Returns a dict of missing aspects.
---@return { [string]: integer }
function EssentiaMaintainer:getMissingAspects()
    local storedAspects = self.essentiaStorage:getAspects()
    local missingAspect = {}

    for asp, ind in pairs(self.aspectLookup) do
        local amount = self.aspectList[ind].amount - (storedAspects[asp] or 0)
        if amount > 0 then missingAspect[asp] = amount end
    end

    return missingAspect
end

return EssentiaMaintainer
