local function isTableEmpty(table) return type(next(table)) == "nil" end

print(isTableEmpty({}))
print(isTableEmpty({ str = 1 }))
