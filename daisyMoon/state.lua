function inherit(object, table)
	return setmetatable(object, {__index = table})
end

function inherited(table)
	return setmetatable({}, {__index = table})
end

State = {}

function State:new()
	local o = inherited(self)
	
	return o
end

function State:update(time)

end

function State:render()

end