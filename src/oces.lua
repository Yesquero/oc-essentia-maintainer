local component = require("component")
local computer = require("computer")
local shell = require("shell")
local term = require("term")

local EssentiaMaintainer = require("oces.maintainer")
local EssentiaProvider = require("oces.essentia-provider")
local InfusionProvider = require("oces.impl.infusion-provider-es")
local ItemDatabase = require("oces.item-database")
local constants = require("oces.constants")

---@param Maintainer EssentiaMaintainer
---@param name string
---@param amount integer
local function addAspect(Maintainer, name, amount)
    local res = Maintainer:addAspect(name, amount)
    if res then
        print("Added aspect: " .. name)
    else
        print("Could not add aspect: " .. name)
    end
end

---@param Maintainer EssentiaMaintainer
---@param name string
local function deleteAspect(Maintainer, name)
    local res, msg = Maintainer:deleteAspect(name)
    if res then
        print("Deleted aspect: " .. name)
    else
        print("Could not delete aspect: " .. name .. "; " .. msg)
    end
end

---@param Maintainer EssentiaMaintainer
local function showAspects(Maintainer) print(Maintainer:formattedAspectTable()) end

---@param Provider EssentiaProvider
---@param name string
---@param maxResults integer
local function findAspectSource(Provider, name, maxResults)
    local res, msg = Provider:findAspectSource(name, maxResults or 1)
    if res then
        for ind, val in ipairs(res) do
            print(string.format("%s: %i %s", val.label, val.aspects[name], name))
        end
    else
        print(msg)
    end
end

---@param Maintainer EssentiaMaintainer
---@param Provider EssentiaProvider
local function maintainerLoop(Maintainer, Provider)
    local smelterType = Provider.itemSource.smeltery.type
    local succes = "Refilling aspects: %s"
    local wait = "Waiting for smelter to finish... ~%i sec"
    local waitAlt = "Estimated smelting time: ~%i sec (not updating)"
    while true do
        term.clear()
        print(Maintainer:formattedAspectTable())

        local missingAspects = Maintainer:getMissingAspects()

        local res, time, msg = Provider:refillAspects(missingAspects)
        if res and smelterType == constants.SmelterType.EssentiaSmeltery then
            local start = computer.uptime()
            while time > computer.uptime() - start do
                term.clear()
                print(Maintainer:formattedAspectTable())
                print(string.format(succes, msg))
                print(string.format(wait, math.ceil(time - computer.uptime() + start)))

                os.sleep(5)
            end
        elseif res and smelterType == constants.SmelterType.AdvancedAlchemicalSmelter then
            local start = computer.uptime()
            local estimate = string.format(waitAlt, time)
            while not Provider.itemSource:isSmelterAvailable() do
                term.clear()
                print(Maintainer:formattedAspectTable())
                print(string.format(succes, msg))
                print(estimate)
                print(string.format("Elapsed: ~%i sec", math.ceil(computer.uptime() - start)))

                os.sleep(3)
            end
        else
            print("Unable to refill aspects: " .. msg)
            os.sleep(Maintainer.config.pollingInterval)
        end
    end
end

local function showHelp()
    local usage = [[
    oces version %s 
    Usage: oces [key] arg...
    Keys:
    --add <string> <integer>    Add Aspect to the list of maintained aspects.
    --delete <string>           Delete Aspect from the list of maintained aspects.
    --show                      Show list of maintained aspects.
    --find <string> <integer>   Find all items with the specified aspect, sorted by its amount. Second arg is max number of results.
    --start                     Start maintaining aspects, runs in foreground.
    --help                      Show usage.
    ]]

    print(string.format(usage, constants.version))
end

---@param args any[]
---@param ops {[string]: boolean}
local function chooseFunction(args, ops)
    if ops.add then
        local amount = tonumber(args[2])
        if not amount then error("Invalid `add` argument: " .. args[2]) end

        local EssentiaStorage = InfusionProvider:new(component.thaumicenergistics_infusion_provider)
        local Maintainer = EssentiaMaintainer:new(EssentiaStorage)

        addAspect(Maintainer, args[1], amount)
    elseif ops.delete then
        local EssentiaStorage = InfusionProvider:new(component.thaumicenergistics_infusion_provider)
        local Maintainer = EssentiaMaintainer:new(EssentiaStorage)

        deleteAspect(Maintainer, args[1])
    elseif ops.show then
        local EssentiaStorage = InfusionProvider:new(component.thaumicenergistics_infusion_provider)
        local Maintainer = EssentiaMaintainer:new(EssentiaStorage)

        showAspects(Maintainer)
    elseif ops.find then
        local maxRes = tonumber(args[2])
        if not maxRes then error("Invalid `find` argument: " .. args[2]) end

        local ItemDB = ItemDatabase:new(component.database)
        local Provider = EssentiaProvider:new(ItemDB)
        findAspectSource(Provider, args[1], maxRes)
    elseif ops.start then
        local EssentiaStorage = InfusionProvider:new(component.thaumicenergistics_infusion_provider)
        local ItemDB = ItemDatabase:new(component.database)
        local Maintainer = EssentiaMaintainer:new(EssentiaStorage)
        local Provider = EssentiaProvider:new(ItemDB)
        maintainerLoop(Maintainer, Provider)
    elseif ops.help then
        showHelp()
    else
        error("Invalid programm options.")
    end
end

local function main(...)
    local args, ops = shell.parse(...)

    local res, msg = pcall(chooseFunction, args, ops)
    if not res then print("Something went wrong: " .. msg) end
end

main(...)
