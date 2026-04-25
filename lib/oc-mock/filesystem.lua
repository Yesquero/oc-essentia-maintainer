local filesystem = {}

---Retrun true if specified path exists, false otherwise.
---@param path string
function filesystem.exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

return filesystem
