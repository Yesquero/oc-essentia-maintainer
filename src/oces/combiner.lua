local Class = require("ysq.class")

local serialization = require("serialization")

---@class EssentiaCombiner: AbstractClass
local EssentiaCombiner = Class:inherit()

---@type IEssentiaStorage
EssentiaCombiner.firstInput = nil
---@type IEssentiaStorage
EssentiaCombiner.secondInput = nil
---@type integer
EssentiaCombiner.inputSize = nil
---@type integer
EssentiaCombiner.numCombiners = nil
---@type integer
EssentiaCombiner.essentiaPerSecond = nil
---@type { [string]: {first: string, second: string}}
EssentiaCombiner.aspectCombinations = nil
---@type string
EssentiaCombiner.combinationsPath = nil
---@type { [string]: boolean}
EssentiaCombiner.knownAspects = nil

---Attempts to refill missing aspect using associated combiner.
---@param missingAspects Aspects
---@return boolean
---@return integer?
---@return string?
function EssentiaCombiner:refillAspects(missingAspects) error("not implement") end

---Init.
---@param combinationsPath string
---@param firstInput IEssentiaStorage
---@param secondInput IEssentiaStorage
---@param inputSize integer
---@param numCombiners integer
---@param essentiaPerSecond number
---@param knownAspects { [string]: boolean }
function EssentiaCombiner:initialize(
    combinationsPath,
    firstInput,
    secondInput,
    inputSize,
    numCombiners,
    essentiaPerSecond,
    knownAspects
)
    assert(type(combinationsPath) == "string", "Essentia Combiner invalid combinations file path: " .. combinationsPath)
    assert(type(inputSize) == "number" and inputSize > 0, "Essentia Combiner invalid input size: " .. inputSize)
    assert(firstInput and secondInput, "Essentia Combiner input(s) cannot be null.")
    assert(
        type(numCombiners) == "number" and numCombiners > 0,
        "Essentia Combiner invalid number of combiners: " .. numCombiners
    )
    assert(
        type(essentiaPerSecond) == "number" and essentiaPerSecond > 0,
        "Essentia Combiner invalid essentia / sec: " .. essentiaPerSecond
    )
    assert(knownAspects, "Essentia Combiner: known aspects list cannot be null.")

    self.firstInput = firstInput
    self.secondInput = secondInput
    self.inputSize = inputSize
    self.numCombiners = numCombiners
    self.essentiaPerSecond = essentiaPerSecond
    self.combinationsPath = combinationsPath
    self.knownAspects = knownAspects

    self:readCombinations()
end

---Read combinations from a file.
---@return boolean
function EssentiaCombiner:readCombinations()
    local file = assert(io.open(self.combinationsPath, "r"), "Could not open file: " .. self.combinationsPath)
    self.aspectCombinations = assert(serialization.unserialize(file:read("a")))
    file:close()
    return true
end

local function checkKnownAspect(knownAspects, aspect)
    if not knownAspects[aspect] then
        return false,
            string.format("Unknown aspect: %s, check spelling or add it to the list of known aspects.", aspect)
    else
        return true
    end
end

---Save current list of combinations to a file.
function EssentiaCombiner:saveCombinations()
    local file = assert(io.open(self.combinationsPath, "w"), "Could not open file: " .. self.combinationsPath)
    assert(
        file:write(serialization:serialize(self.aspectCombinations)),
        "Could not write to file: " .. self.combinationsPath
    )
    file:close()
end

---Add combination to the list of combinations and save it to a file.
---@param name string
---@param first string
---@param second string
---@return boolean
---@return string | nil
function EssentiaCombiner:addCombination(name, first, second)
    assert(type(name) == "string", type(first) == "string", type(second) == "string")
    for i, v in ipairs({ name, first, second }) do
        local res, msg = checkKnownAspect(self.knownAspects, v)
        if not res then return res, msg end
    end

    if self.aspectCombinations[name] then
        return false, string.format("Combination already present: %s - %s + %s", name, first, second)
    end

    self.aspectCombinations[name] = { first = first, second = second }
    self:saveCombinations()

    return true
end

---Delete combination from the list of combinations, save changes to file.
---@param name string
---@return boolean
---@return string?
function EssentiaCombiner:deleteCombination(name)
    assert(type(name) == "string", "Invalid name argument: " .. name)

    local res, msg = checkKnownAspect(self.knownAspects, name)
    if not res then return false, msg end

    if not self.aspectCombinations[name] then return false, "Combination not present: " .. name end

    self.aspectCombinations[name] = nil
    self:saveCombinations()

    return true
end

return EssentiaCombiner
