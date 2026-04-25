---@class TCSmeltery
local smeltery = {}
smeltery.validSlot = 1
smeltery.available = true

---Get a description of the item stack in the specified slot.
---@param slot number
---@return DBItemStack
function smeltery.getStackInSlot(slot)
    if slot == smeltery.validSlot and smeltery.available then
        return { id = 0 }
    elseif slot == smeltery.validSlot and not smeltery.available then
        return { id = 1 }
    else
        error("side index out of bounds")
    end
end

return smeltery
