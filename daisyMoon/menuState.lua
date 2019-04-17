-- GLOBALS
MenuState = inherited(State)
StoryMode = true
MUSIC_VOLUME = 0.3
Master_Volume = 1
CurrentMusic = nil
-- LOCALS
local button = _button
local bitmapFont = _bitmapFont


function MenuState:new()
	local o = State:new()
	o = inherit(self)
	o.buttons = {}
	o.buttons.playButton = button:new(guiSprites["play"], guiSprites["playHover"], window.width/2, 250, true)
	o.buttons.storyOnButton = button:new(guiSprites["storyOn"], guiSprites["storyOnHover"], window.width/2, 350, true)
	o.buttons.storyOffButton = button:new(guiSprites["storyOff"], guiSprites["storyOffHover"], window.width/2, 350, true)
	o.buttons.quitButton = button:new(guiSprites["quit"], guiSprites["quitHover"], window.width/2, 450, true)
	o.menuSprite = guiSprites["menu"]
	audio.stopAllMusic()
	CurrentMusic = "audio/intro.ogg"
	audio.playMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume, true)
	
	return o
end

function MenuState:close()
end

function MenuState:enable()
end

function MenuState:disable()
end

function MenuState:init()
	CurrentLevel = 1
end

function MenuState:update(time)
	
	self.buttons.playButton:update(daisy.getMousePosition())
	if StoryMode then
		self.buttons.storyOnButton:update(daisy.getMousePosition())
	else
		self.buttons.storyOffButton:update(daisy.getMousePosition())
	end
	
	self.buttons.quitButton:update(daisy.getMousePosition())
end

function MenuState:renderLightmap()

end

function MenuState:render()

	video.renderRectangle(0, 0, window.width, window.height, 255, 0, 0, 0)
	local w,h = video.getSpriteStateSize(self.menuSprite)
	video.renderSpriteState(self.menuSprite, (window.width - w) / 2, (window.height - h) / 2)
	
	self.buttons.playButton:render()
	if StoryMode then
		self.buttons.storyOnButton:render()
	else
		self.buttons.storyOffButton:render()
	end
	self.buttons.quitButton:render()
	
	video.renderText("Design and Coding: Jamie Myland", 10, window.height-70, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Game Engine: DaisyMoon by Oxeye Games", 10, window.height-50, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Music: Geir Tjelta: http://noname.c64.org/csdb/scener/?id=1266", 10, window.height-30, 0, "font.fnt", 255, 255, 255, 255)
	
end

function MenuState:mouseClick(x,y,button,count)
	
	if self.buttons.playButton:checkSelected() then
		destroyState("menu")
		if StoryMode then
			addState(StoryState:new(), "story")
		else
			addState(GameState:new(), "game")
		end
	end
	
	if self.buttons.storyOnButton:checkSelected() then
		StoryMode = false
	end
	
	if self.buttons.storyOffButton:checkSelected() then
		StoryMode = true
	end
	
	if self.buttons.quitButton:checkSelected() then
		daisy.exitGame()
	end
end

function MenuState:keyPressed(key)
	if(key) == 27 then
		daisy.exitGame()
	end
	
	if(key) == 90 then
		destroyState("menu")
		if StoryMode then
			addState(StoryState:new(), "story")
		else
			addState(GameState:new(), "game")
		end
	end
	
	if(key) == 79 then
		Master_Volume = Master_Volume - 0.1
		Master_Volume = math.clamp(Master_Volume, 0, 1)
		audio.updateMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume)
	end
	
	if(key) == 80 then
		Master_Volume = Master_Volume + 0.1
		Master_Volume = math.clamp(Master_Volume, 0, 1)
		audio.updateMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume)
	end
	
end

function MenuState:joyButtonPressed(joy, button)
end

function MenuState:joyButtonReleased(joy, button)
end



