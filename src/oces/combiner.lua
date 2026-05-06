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
end

return EssentiaCombiner
