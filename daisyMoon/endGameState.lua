-- GLOBALS
EndGameState = inherited(State)

-- LOCALS

function EndGameState:new()
	audio.stopAllMusic()
	CurrentMusic = "audio/end.ogg"
	audio.playMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume, true)
	local o = State:new()
	o = inherit(self)
	o.fadeIn = true
	o.load = false
	o.titleAlpha = 0
	o.fadeSpeed = 5
	o.nextPart = false
	audio.stopAllMusic()
	return o
end

function EndGameState:close()
end

function EndGameState:enable()
end

function EndGameState:disable()
end

function EndGameState:init()	
end

function EndGameState:update(time)

	if self.fadeIn then
			if self.titleAlpha <= 255 then 
				if self.titleAlpha + self.fadeSpeed > 255 then
					self.titleAlpha = 255
					self.fadeIn = false
				else
					self.titleAlpha = self.titleAlpha + self.fadeSpeed
				end
			end
		end
	
	if self.load then
		addState(MenuState:new(), "menu")
		destroyState("endgame")
	end
end

function EndGameState:renderLightmap()
end

function EndGameState:render()
	video.renderRectangle(0, 0, window.width, window.height, 255, 0, 0, 0)
	video.renderSpriteState(guiSprites["end"], 0, 0, 1, 0, self.titleAlpha)
end

function EndGameState:mouseClick(x,y,button,count)
	self.nextPart = true
	self.load = true
end

function EndGameState:keyPressed(key)
	self.nextPart = true
	self.load = true
end
