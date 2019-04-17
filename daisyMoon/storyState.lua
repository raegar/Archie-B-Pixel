-- GLOBALS
StoryState = inherited(State)
-- LOCALS
local entity = _entity

function StoryState:new()
	audio.stopAllMusic()
	CurrentMusic = "audio/end.ogg"
	audio.playMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume, true)
	local o = State:new()
	o = inherit(self)
	o.titleAlpha = 0
	o.fadeSpeed = 5
	o.storyPart = 1
	o.storyFrom = 1
	o.storyTo = 5
	o.nextPart = false
	o.fadeIn = true
	o.archie = {r=0, g=0, b=0, phase=1}
	local p = {x = GameBounds.x + (32*8), y = GameBounds.y + (32*6)}
	o.badPixel = entity:new(103, 255, 0, 0, p)
	return o
end

function StoryState:close()
end

function StoryState:enable()
	audio.stopAllMusic()
	CurrentMusic = "audio/end.ogg"
	audio.playMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume, true)
end

function StoryState:disable()
end

function StoryState:init()
	self.badPixel:init()
end

function StoryState:update(time)
	
	if CurrentLevel == 2 then
		self.storyFrom = 6
		self.storyTo = 7
	end
	if CurrentLevel == 3 then
		self.storyFrom = 8
		self.storyTo = 8
	end
	if CurrentLevel == 8 then
		self.storyFrom = 9
		self.storyTo = 9
	end
	if CurrentLevel == 9 then
		self.storyFrom = 10
		self.storyTo = 10
	end
	if CurrentLevel == 10 then
		self.storyFrom = 11
		self.storyTo = 11
	end
	if CurrentLevel == 11 then
		self.storyFrom = 12
		self.storyTo = 12
	end
	if CurrentLevel == 12 then
		self.storyFrom = 13
		self.storyTo = 13
	end
	
	
	if self.storyPart >= self.storyFrom and self.storyPart <= self.storyTo then
		if self.fadeIn then
			if self.titleAlpha <= 255 then 
				if self.titleAlpha + self.fadeSpeed > 255 then
					self.titleAlpha = 255
					self.fadeIn = false
				else
					self.titleAlpha = self.titleAlpha + self.fadeSpeed
				end
			end
		else
			if self.nextPart then
				if self.titleAlpha > 0 then 
					if self.titleAlpha - self.fadeSpeed <= 0 then
						self.titleAlpha = 0
						self.storyPart = self.storyPart + 1
						self.nextPart = false
						self.fadeIn = true
					else
						self.titleAlpha = self.titleAlpha - self.fadeSpeed
					end
				end
			end
		end
	else
		disableState("story")
		addState(GameState:new(), "game")
	end
	
	if self.storyPart == 3 then
		if self.archie.phase == 1 then
			self.archie.b = 0
			if self.archie.r < 250 then self.archie.r = self.archie.r + 5 else self.archie.phase = 2 end
		elseif self.archie.phase == 2 then
			if self.archie.r > 5 then self.archie.r = self.archie.r - 5 else self.archie.phase = 3 end
		elseif self.archie.phase == 3 then
			self.archie.r = 0
			if self.archie.g < 250 then self.archie.g = self.archie.g + 5 else self.archie.phase = 4 end
		elseif self.archie.phase == 4 then
			if self.archie.g > 5 then self.archie.g = self.archie.g - 5 else self.archie.phase = 5 end
		elseif self.archie.phase == 5 then
			self.archie.g = 0
			if self.archie.b < 250 then self.archie.b = self.archie.b + 5 else self.archie.phase = 6 end
		elseif self.archie.phase == 6 then
			if self.archie.b > 5 then self.archie.b = self.archie.b - 5 else self.archie.phase = 1 end	
		end
	end
	
	if self.storyPart == 11 then
		self.badPixel:updateDirection()
		self.badPixel:update(time)
	end
	
end

function StoryState:renderLightmap()

end

function StoryState:render()
	video.renderRectangle(0, 0, window.width, window.height, 255, 0, 0, 0)
	video.renderSpriteState(guiSprites["story"..self.storyPart], window.width/2 - 400, 0, 1, 0, self.titleAlpha, 255, 255, 255)
	
	if self.storyPart == 3 then
		video.renderSpriteState(entitySprites["player"], window.width/2 - 400 + 400-32, 500, 2, 0, self.titleAlpha, self.archie.r, self.archie.g, self.archie.b)
	end
	
		if self.storyPart == 11 then
		self.badPixel:render()
	end
end

function StoryState:mouseClick(x,y,button,count)
	self.nextPart = true
end

function StoryState:keyPressed(key)
	if(key) == 79 then
		Master_Volume = Master_Volume - 0.1
		Master_Volume = math.clamp(Master_Volume, 0, 1)
		audio.updateMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume)
	elseif(key) == 80 then
		Master_Volume = Master_Volume + 0.1
		Master_Volume = math.clamp(Master_Volume, 0, 1)
		audio.updateMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume)
	else
		self.nextPart = true
	end
end

function StoryState:joyButtonPressed(joy, button)
end

function StoryState:joyButtonReleased(joy, button)
end



