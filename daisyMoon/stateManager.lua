-- GLOBALS
_slotState = { states = {} }

function addState(class, id)
	local state = class:new()
	state._enabled = true
	state._id = id
	state:init()
	table.insert(_slotState.states, state)
	return state
end

function loadState(id)
	local state = table.load(_slotPath.."id")
	--state:init()
	table.insert(_slotState.states, state)
	return state
end

function unloadState(id)
	for index, state in pairs (_slotState.states) do
		if state._id == id then
			state:save()
			state:close()
			table.remove(_slotState.states, index)
		end
	end
end

function isStateEnabled(id)
	for index, state in pairs (_slotState.states) do
		if state._id == id then
			return state._enabled
		end	
	end
end

function getState(id)
	for index, state in pairs (_slotState.states) do
		if state._id == id then
			return state
		end
	end
end

function enableState(id)
	for index, state in pairs (_slotState.states) do
		if state._id == id then
			state:enable()
			state._enabled = true
		end
	end
end

function disableState(id)
	for index, state in pairs (_slotState.states) do
		if state._id == id then
			state:disable()
			state._enabled = false
		end
	end
end

function toggleState(id)
	for index, state in pairs (_slotState.states) do
		if state._id == id then
			state._enabled = not state._enabled
			if state._enabled then
				state:enable()
			else
				state:disable()
			end
		end
	end
end

function destroyState(id)
	for index, state in pairs (_slotState.states) do
		if state._id == id then
			state:close()
			table.remove(_slotState.states, index)
		end
	end
end