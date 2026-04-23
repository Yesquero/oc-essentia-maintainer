-- Inspired by https://riki.house/programming/lua/classes

---@class AbstractClass
local Class = {}

Class.__index = Class

---Default initialization function, called in new, subclasses should override this
---@param ... unknown
function Class:initialize(...)
	error("not implemented")
end

---Inherit form this class, supply a table arg to act as a protoype for the new class
---@param prototype table?
---@return table
function Class:inherit(prototype)
	local subclass = prototype or {}
	subclass.__index = subclass
	setmetatable(subclass, self)
	return subclass
end

---Make a new instace, forwards all args to initialize()
---@param ... unknown
---@return table
function Class:new(...)
	local instance = {}
	setmetatable(instance, self)
	self.initialize(instance, ...)
	return instance
end

return Class
