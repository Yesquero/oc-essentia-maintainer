local utility = {}

function utility.comparePOD( left, right )
    if left == nil and right == nil then return true end
    if left == nil or right == nil then return false end

    assert( type( left ) == "table" and type( right ) == "table" )

    if #left ~= #right then return false end

    for k, v in pairs( left ) do
        assert( type( v ) ~= "table" )
        if right[k] ~= v then return false end
    end

    return true
end

return utility
