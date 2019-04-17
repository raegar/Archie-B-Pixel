-- GLOBALS
TitleState = inherited(State)

-- LOCALS

function TitleState:new()
	local o = State:new()
	o = inherit(self)
	audio.stopAllMusic()
	o.titleAlpha = 0
	o.fadeSpeed = 5
	o.displayDelay = 0
	o.fadeIn = true
	o.titleNumber = 1
	return o
end

function TitleState:close()
end

function TitleState:enable()
end

function TitleState:disable()
end

function TitleState:init()
	
end

function TitleState:update(time)
	

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
			if self.displayDelay < 1.3 then
				self.displayDelay = self.displayDelay + time
			else
				if self.titleAlpha > 0 then 
					if self.titleAlpha - self.fadeSpeed <= 0 then
						self.titleAlpha = 0
						if self.titleNumber == 2 then
							destroyState("title")
							addState(MenuState:new(), "menu")
						else
							self.titleNumber = self.titleNumber + 1
							self.fadeIn = true
							self.displayDelay = 0
						end
					else
						self.titleAlpha = self.titleAlpha - self.fadeSpeed
					end
				end
			end
		end

end

function TitleState:renderLightmap()

end

function TitleState:render()
	video.renderRectangle(0, 0, window.width, window.height, 255, 0, 0, 0)
	if self.titleNumber == 1 then
		video.renderSpriteState(guiSprites["MG_logo"], window.width/2 - 400, 0, 1, 0, self.titleAlpha, 255, 255, 255)
	elseif self.titleNumber == 2 then
		video.renderSpriteState(guiSprites["title"], window.width/2 - 400, 0, 1, 0, self.titleAlpha, 255, 255, 255)
	end
end

function TitleState:mouseClick(x,y,button,count)
	if self.titleNumber == 1 then
		self.titleNumber = self.titleNumber + 1
		self.fadeIn = true
		self.titleAlpha = 0
		self.displayDelay = 0
	else
		destroyState("title")
		addState(MenuState:new(), "menu")
	end
end

function TitleState:keyPressed(key)
	if self.titleNumber == 1 then
		self.titleNumber = self.titleNumber + 1
		self.fadeIn = true
		self.titleAlpha = 0
		self.displayDelay = 0
	else
		destroyState("title")
		addState(MenuState:new(), "menu")
	end
end

function TitleState:joyButtonPressed(joy, button)
end

function TitleState:joyButtonReleased(joy, button)
end



