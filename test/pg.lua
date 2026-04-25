local dict = {
	add = true,
	delete = true,
}

local usage = [[
	oces version %s 
	Usage: oces [key] arg...
	Keys:
	--add <string> <integer>	Add Aspect to the list of maintained aspects.
	--delete <string>			Delete Aspect from the list of maintained aspects.
	--add <string> <integer>	Add Aspect to the list of maintained aspects.
	--add <string> <integer>	Add Aspect to the list of maintained aspects.
	--add <string> <integer>	Add Aspect to the list of maintained aspects.
	]]

print(string.format(usage, "0.0.1"))
