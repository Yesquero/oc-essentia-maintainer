local utility = {}

-- TODO: handle table values but without metatable
function utility.comparePOD( left, right )
    if left == nil and right == nil then return true end
    if left == nil or right == nil then return false end

    assert( type( left ) == "table" and type( right ) == "table" )

    for k, v in pairs( left ) do
        assert( type( v ) ~= "table" )
        if right[k] ~= v then return false end
    end

    for k, v in pairs( right ) do
        assert( type( v ) ~= "table" )
        if left[k] ~= v then return false end
    end

    return true
end

--[[
Remove elements from an array, returns false if no elements removed.
cmp accepts signle arg, the valaue of arrray[i] at each iteration and must return true if it is to be removed, false otherwise.
A variantion of https://stackoverflow.com/a/53038524
 ]]
function utility.arrayRemove( array, cmp )
    if #array == 0 then
        return false
    end

    local j, len = 1, #array
    for i = 1, len do
        if cmp( array[i] ) then
            array[i] = nil
        elseif i ~= j then
            array[j] = array[i]
            array[i] = nil
            j = j + 1
        else
            j = j + 1
        end
    end

    return len ~= #array
end

function utility.clearFile( filename, isSerializationTarget )
    local file = assert( io.open( filename, "w" ) )
    local isSerializationTarget = isSerializationTarget or false
    if isSerializationTarget then
        file:write( "{}" )
    end
    file:close()
end

return utility
