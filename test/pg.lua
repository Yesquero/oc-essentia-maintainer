local component = require("component")
local serialization = require("serialization")

print(serialization.serialize(component.database.dummyData, true))

print("Playground")
