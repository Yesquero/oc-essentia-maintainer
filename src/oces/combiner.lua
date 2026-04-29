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
---@type { [string]: {fisrt: string, seond: string}}
EssentiaCombiner.aspectCombinations = nil
---@type string
EssentiaCombiner.combinationsPath = nil

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
function EssentiaCombiner:initialize(
    combinationsPath,
    firstInput,
    secondInput,
    inputSize,
    numCombiners,
    essentiaPerSecond
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

    self.firstInput = firstInput
    self.secondInput = secondInput
    self.inputSize = inputSize
    self.numCombiners = numCombiners
    self.essentiaPerSecond = essentiaPerSecond
    self.combinationsPath = combinationsPath

    self:readCombinations()
end

---Reads combinations from a file.
---@return boolean
function EssentiaCombiner:readCombinations()
    local file = assert(io.open(self.combinationsPath, "r"), "Could not open file: " .. self.combinationsPath)
    self.aspectCombinations = assert(serialization.unserialize(file:read("a")))
    file:close()
    return true
end

---Add combination to the list of combinations and save it to a file.
---@param name string
---@param first string
---@param second string
---@return boolean
---@return string
function EssentiaCombiner:addCombination(name, first, second)
    assert(type(name) == "string", type(first) == "string", type(second) == "string")
    if self.aspectCombinations[name] then
        return false, string.format("Combination already present: %s - %s + %s", name, first, second)
    end
end

return EssentiaCombiner
