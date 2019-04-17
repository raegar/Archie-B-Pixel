math.randomseed( os.time() )

--lib
dofile("lib/shellsort.lua")
dofile("lib/table.lua")
dofile("lib/vectorMath.lua")
dofile("lib/hex.lua")
dofile("lib/math.lua")
dofile("lib/color.lua")
dofile("lib/bitmapFont.lua")
dofile("lib/button.lua")

-- game
-- add files here
dofile("state.lua")
dofile("sprites.lua")
dofile("titleState.lua")
dofile("menuState.lua")
dofile("tile.lua")
dofile("entity.lua")
dofile("levels.lua")
dofile("storyState.lua")
dofile("gameState.lua")
dofile("endGameState.lua")
dofile("stateManager.lua")

-- GLOBAL APPLICATION SETTINGS
_settings = {}

-- SYSTEM GLOBALS
window = {width = 800, height = 600}

local strayTime = 0
local function mainUpdate(time)
	if time > .06 then time = .06 end
	strayTime = strayTime + time
	while strayTime >= 0.015625 do
		strayTime = strayTime - 0.015625
		--_time = _time + 0.015625
		for index, state in pairs(_slotState.states) do
			if state and state._enabled and state.update then
				local newState = state:update(0.015625)
				if newState then

					if state.close then
						state:close()
					end

					state = newState

					if state.init then
						state:init()
					end
				end
			end
		end
	end
	-- Run the garbage collector every update loop. This will decrease overall
	-- performance of the game, but prevent the framerate from "dipping". The
	-- step value is how many kB of memory that it should try to clean up.
	collectgarbage("step", 50) -- attempt to clean up 500 kB
end
hook.add("frameUpdate", mainUpdate)

local function mainRender()

	for index, state in pairs(_slotState.states) do
		if state and state._enabled and state.render then
			state:render()
		end
	end
	
end
hook.add("frameRender", mainRender)

local function mainInit()

	_userPath = daisy.getUserFolderPath("/")
	window.width, window.height = video.getScreenSize()
	daisy.setWindowTitle("Archie B. Pixel v0.9 beta")
	
	-- initialize settings here by using
	-- _setting.value = _setting.value or defaultValue
	local newTable = table.load(_userPath .. "settings.cfg")
	if newTable then
		_settings = newTable
	else
		_settings = {}
	end
	
	
	
	-- initial state

	addState(TitleState:new(), "title")

end
hook.add("gameInit", mainInit)

local function mainClose()

	local path = daisy.getUserFolderPath("/")
	table.save(_settings, path .. "settings.cfg")
	
end
hook.add("gameClose", mainClose)

_key = 0
local function keyPressed(key)
	if _key ~= key then
		--print(key)
	end
	_key = key

	for index, state in pairs(_slotState.states) do
		if state and state._enabled and state.keyPressed then
			state:keyPressed(key)
		end
	end
	
end
hook.add("keyPress", keyPressed)

local function mouseClick(x, y, button, clickCount)
	for index, state in pairs(_slotState.states) do
		if state and state._enabled and state.mouseClick then
			state:mouseClick(x,y,button,clickCount)
		end
	end
end
hook.add("mouseButton", mouseClick)

local function joyButtonPressed(joy, btn)
	for index, state in pairs(_slotState.states) do
		if state and state._enabled and state.joyButtonPressed then
			state:joyButtonPressed(joy,btn)
		end
	end
end
hook.add("joystickButtonPressed", joyButtonPressed)

local function joyButtonReleased(joy, btn)
	for index, state in pairs(_slotState.states) do
		if state and state._enabled and state.joyButtonReleased then
			state:joyButtonReleased(joy,btn)
		end
	end
end
hook.add("joystickButtonReleased", joyButtonReleased)
