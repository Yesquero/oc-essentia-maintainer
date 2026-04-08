require( "mock.general" )

local serialization = require( "serialization" )

local val = { str = "str" }

print( serialization.serialize( val, true ) )
