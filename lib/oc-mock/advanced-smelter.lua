---@class CompAdvSmelter
local advanced_smelter = {}

advanced_smelter.type = "advanced_smelter"
---@type Aspects
advanced_smelter.aspects = {}

---@return { [string]: integer }
function advanced_smelter.getAspects() return advanced_smelter.aspects end

---@return string[]
function advanced_smelter.getAspectNames()
    local names = {}
    for k, v in pairs(advanced_smelter.aspects) do
        names[#names + 1] = k
    end
    return names
end

---@param name string
---@return integer
function advanced_smelter.getAspectCount(name)
    if advanced_smelter.aspects[name] then
        return advanced_smelter.aspects[name]
    else
        return 0
    end
end

return advanced_smelter
