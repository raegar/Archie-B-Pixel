-- GLOBALS
GameState = inherited(State)
GameBounds = {x = 80, y = 60, width = 640, height = 480} -- Set up the play areas for each level

TILESIZE = {W = 32, H = 32}
C_VALUE = 3
COLORCHANGE_AMOUNT = {r = C_VALUE, g = C_VALUE, b = C_VALUE}
PLAYER_SPEED = 2
FADE_SPEED = 20
COLOR_RANGE = 25.5
DISPLAY_DURATION = 10

CurrentLevel = 1
Keyboard = {upPressed = false, downPressed = false, leftPressed = false, rightPressed = false, zPressed = false}
prevKeyboard = {upPressed = false, downPressed = false, leftPressed = false, rightPressed = false, zPressed = false}
InteractionState = {activate = false, drain = false, charge = false}

-- LOCALS
local button = _button
local tile = _tile
local hex = _hex
local entity = _entity
local adjacentTiles = {}
local gridX, gridY

function GameState:new()
	local o = State:new()
	o = inherit(self)
	o.buttons = {}
	o.displayDelay = 0
	o.player = {}
	o.objectGrid = {}
	o.entityList = {}
	o.portalList = {}
	o.activeTile = {}
	o.startTile = {pos = {x = 80, y = 60}, color = {r = 255, g = 255, b = 255}}
	o.objectPanelAlpha = 0
	o.selectedPanelAlpha = 0
	audio.stopAllMusic()
	o.currentMap = map[CurrentLevel]
	o.levelComplete = false
	o.tempAmount1 = {r=0,g=0,b=0}
	o.selectedTile = {pos = {x = 0, y = 0}, tile = nil}
	o.displayTimer = 0
	o.gameComplete = false
	o.prevColorRemain = 0
	audio.stopAllMusic()
	local trackNum = math.random(1, 2)
	CurrentMusic = "audio/music"..trackNum..".ogg"
	audio.playMusic(CurrentMusic, MUSIC_VOLUME*Master_Volume, true)
	return o
end

function GameState:close()
end

function GameState:enable()
end

function GameState:disable()
end

function GameState:init()
	local w,h = TILESIZE.W, TILESIZE.H
	local gridSizeX = GameBounds.width/w
	local gridSizeY = GameBounds.height/h
	
	-- Setup Grid
	for indexX = 1, gridSizeX do
		self.objectGrid[indexX] = {}
		for indexY = 1, gridSizeY do
			local hexTile = self.currentMap[indexY][indexX]
			local newTile = {}
			newTile = hex.toTile(hexTile)
			if newTile.type > 100 then -- if tile.type == enemy
				local p = {x = (indexX-1)*TILESIZE.W+GameBounds.x, y = (indexY-1)*TILESIZE.H+GameBounds.y}
				local e = entity:new(newTile.type, newTile.r, newTile.g, newTile.b, p)
				table.insert(self.entityList, e)		
				newTile.type = 0
				newTile.r, newTile.g, newTile.b = 255, 255, 255
			end
			self.objectGrid[indexX][indexY] = tile:new(gameSprites[newTile.type], newTile.type, newTile.r, newTile.g, newTile.b)
			self.objectGrid[indexX][indexY]:init()
			if self.objectGrid[indexX][indexY].tileType == 24 then 
				local tempTile = self.objectGrid[indexX][indexY]
				self.startTile.pos.x = indexX
				self.startTile.pos.y = indexY
				self.startTile.color.r = tempTile.color.r
				self.startTile.color.g = tempTile.color.g
				self.startTile.color.b = tempTile.color.b
			end
		end
	end
	
	-- Initialize player
	self.player = {tileData = tile:new(entitySprites["player"], 100, self.startTile.color.r, self.startTile.color.g, self.startTile.color.b), pos = {x = (self.startTile.pos.x-1)*TILESIZE.W+GameBounds.x, y = (self.startTile.pos.y-1)*TILESIZE.H+GameBounds.y}, grid = {x = (self.startTile.pos.x - GameBounds.x)/TILESIZE.W, y = (self.startTile.pos.y - GameBounds.y)/TILESIZE.H}, scale = 1.0, angle = 0.0, velocity = {x = 0, y = 0}, direction = {up = false, down = false, left = false, right = false}, collisionBox ={}, killed = false}
	self.activeTile = self.objectGrid[self.startTile.pos.x][self.startTile.pos.y]
	
	--initialise entities
	for index, e in pairs(self.entityList) do
		e:init()
		adjacentTiles = self:getAdjacentTiles(self.objectGrid, e.gridPos.x, e.gridPos.y)
		e:updateDirection(adjacentTiles)
	end
	COLORCHANGE_AMOUNT = {r = C_VALUE, g = C_VALUE, b = C_VALUE} 
end

function GameState:update(time)
	if not self.player.killed then

		--Move player to grid
		if math.fmod(self.player.pos.x - GameBounds.x, 32) == 0 and math.fmod(self.player.pos.y - GameBounds.y, 32) == 0 then
			self.player.grid.x = 1+(self.player.pos.x - GameBounds.x)/TILESIZE.W
			self.player.grid.y = 1+(self.player.pos.y - GameBounds.y)/TILESIZE.H
			--Update player collision box
			self.player.collisionBox.left, self.player.collisionBox.right, self.player.collisionBox.top, self.player.collisionBox.bottom = self.player.pos.x, self.player.pos.x + TILESIZE.W, self.player.pos.y, self.player.pos.y + TILESIZE.H
		
			--Move player if possible
			if Keyboard.upPressed and self.player.grid.y-1 >= 1 then
				nextTile = self.objectGrid[self.player.grid.x][self.player.grid.y-1]
				if nextTile.passable then
					if nextTile.typeAsString ~= "Gate" then
						self.player.direction = {up = true, down = false, left = false, right = false}
					else
						if nextTile:compareColor(self.player.tileData.color, COLOR_RANGE) then
							self.player.direction = {up = true, down = false, left = false, right = false}
						else
							self.player.direction = {up = false, down = false, left = false, right = false}
						end
					end
				else
					self.player.direction = {up = false, down = false, left = false, right = false}
				end
				
			elseif Keyboard.downPressed and self.player.grid.y+1 <= GameBounds.height/TILESIZE.H then
				nextTile = self.objectGrid[self.player.grid.x][self.player.grid.y+1]
				if nextTile.passable then
					if nextTile.typeAsString ~= "Gate" then
						self.player.direction = {up = false, down = true, left = false, right = false}
					else
						if nextTile:compareColor(self.player.tileData.color, COLOR_RANGE) then
							self.player.direction = {up = false, down = true, left = false, right = false}
						else
							self.player.direction = {up = false, down = false, left = false, right = false}
						end
					end
				else
					self.player.direction = {up = false, down = false, left = false, right = false}
				end
				
			elseif Keyboard.leftPressed and self.player.grid.x-1 >= 1 then
				nextTile = self.objectGrid[self.player.grid.x-1][self.player.grid.y]
				if nextTile.passable then
					if nextTile.typeAsString ~= "Gate" then
						self.player.direction = {up = false, down = false, left = true, right = false}
					else
						if nextTile:compareColor(self.player.tileData.color, COLOR_RANGE) then
							self.player.direction = {up = false, down = false, left = true, right = false}
						else
							self.player.direction = {up = false, down = false, left = false, right = false}
						end
					end
				else
					self.player.direction = {up = false, down = false, left = false, right = false}
				end
				
			elseif Keyboard.rightPressed and self.player.grid.x+1 <= GameBounds.width/TILESIZE.W then
				nextTile = self.objectGrid[self.player.grid.x+1][self.player.grid.y]
				if nextTile.passable then
					if nextTile.typeAsString ~= "Gate" then
						self.player.direction = {up = false, down = false, left = false, right = true}
					else
					if nextTile:compareColor(self.player.tileData.color, COLOR_RANGE) then
							self.player.direction = {up = false, down = false, left = false, right = true}
						else
							self.player.direction = {up = false, down = false, left = false, right = false}
						end
					end
				else
					self.player.direction = {up = false, down = false, left = false, right = false}
				end
			else
				self.player.direction = {up = false, down = false, left = false, right = false}
			end
		end
		
		--update player direction and velocity
		if self.player.direction.up then self.player.velocity.y = - PLAYER_SPEED
		elseif self.player.direction.down then self.player.velocity.y = PLAYER_SPEED
		else self.player.velocity.y = 0 end
		
		if self.player.direction.left then self.player.velocity.x = - PLAYER_SPEED
		elseif self.player.direction.right then self.player.velocity.x = PLAYER_SPEED
		else self.player.velocity.x = 0 end

		self.player.pos.x = self.player.pos.x + self.player.velocity.x
		self.player.pos.y = self.player.pos.y + self.player.velocity.y
		
		self.player.tileData:update(time)
		
		
		--end
		-- Set active tile and adjust info panel fade
		local w,h = TILESIZE.W, TILESIZE.H
		local gridSizeX = GameBounds.width/w
		local gridSizeY = GameBounds.height/h
		local px, py = self.player.grid.x, self.player.grid.y
		for indexX = 1, gridSizeX do 
			for indexY = 1, gridSizeY do
			self.objectGrid[indexX][indexY]:update(time)
			if self.objectGrid[indexX][indexY].typeAsString == "BarrierClosed" then -- Closed Barrier
				adjacentTiles = self:getAdjacentTiles(self.objectGrid, indexX, indexY) -- Get tiles adjacent to the barrier
				for i, adjacentTile in pairs(adjacentTiles) do
					if adjacentTile ~= nil and adjacentTile.typeAsString ~= "Wall" and adjacentTile.typeAsString ~= "Floor" then -- Ignore walls and floors
						if adjacentTile:compareColor(self.objectGrid[indexX][indexY].color, COLOR_RANGE) then -- If any adjacent tile is within range, open the barrier
							self.objectGrid[indexX][indexY].tileType = 29
							self.objectGrid[indexX][indexY].sprite.image = gameSprites[self.objectGrid[indexX][indexY].tileType]
							audio.playSound("audio/gate.ogg", 1*Master_Volume, 0, 1)
							self.objectGrid[indexX][indexY]:init()
						end
					end
				end
			end
				if indexX == px and indexY == py then
					if self.objectGrid[px][py].tileType ~= 0 then
						if self.activeTile ~= self.objectGrid[px][py] then
							self.activeTile = self.objectGrid[px][py]
							self.activeTile:resetPulse()
						end
						if self.objectPanelAlpha < 255 then 
							if self.objectPanelAlpha + FADE_SPEED > 255 then
								self.objectPanelAlpha = 255
							else
								self.objectPanelAlpha = self.objectPanelAlpha + FADE_SPEED -- Fade in the active object panel
							end
						end
					else
						if self.activeTile ~= self.objectGrid[px][py] then
							self.activeTile = self.objectGrid[px][py]
							self.activeTile:resetPulse()
						end
						if self.objectPanelAlpha > 0 then 
								self.objectPanelAlpha = 0
						end	
					end
				end
			end
		end
		
		-- Initialize info panel
		if daisy.isMouseButtonPressed(0) then
			self.displayTimer = DISPLAY_DURATION 
			self.selectedPanelAlpha = 255
			self.selectedTile.pos.x, self.selectedTile.pos.y = daisy.getMousePosition()
			self.selectedTile.pos.x = self.selectedTile.pos.x - window.width/2+400;
			self.selectedTile.pos.x = math.ceil((self.selectedTile.pos.x - GameBounds.x)/TILESIZE.W)
			self.selectedTile.pos.y = math.ceil((self.selectedTile.pos.y - GameBounds.y)/TILESIZE.H)
			
			if self.selectedTile.pos.x >0 and self.selectedTile.pos.x <= 20 and self.selectedTile.pos.y >0 and self.selectedTile.pos.y <= 15 then
				local px, py = self.selectedTile.pos.x, self.selectedTile.pos.y
				for indexX = 1, px do 
					for indexY = 1, py do
						self.selectedTile.tile = self.objectGrid[indexX][indexY]
					end
				end
			end
		end
		-- Hide panel after timeout
		if self.displayTimer > 0 then
			self.displayTimer = self.displayTimer - time
			if self.displayTimer > 0 and self.displayTimer < 1 then
				if self.selectedPanelAlpha > 20 then
					self.selectedPanelAlpha = self.selectedPanelAlpha - 20
				else
					self.selectedPanelAlpha = 0
				end
			end
		else
			self.displayTimer = 0
		end
		
		
		
		-- Entity updates
		
		for index, e in pairs(self.entityList) do
			e:update(time)
			adjacentTiles = self:getAdjacentTiles(self.objectGrid, e.gridPos.x, e.gridPos.y)
			e:updateDirection(adjacentTiles)
			
			local collision = self:detectCollision(e.collisionBox, self.player.collisionBox)
			
			if collision then
				self.player.killed, self.tempAmount1 = self.player.tileData:removeColor(COLORCHANGE_AMOUNT, e.tileData.color)
				self:playTransferSound()
				if self.player.killed then
					audio.playSound("audio/death.ogg", 1*Master_Volume, 0, 1.0)
				end
			end
		end
		
		
		
		-- Handle Tile abilities
		
		if InteractionState.activate then
			if self.activeTile.properties.charge then
				
				self.player.tileData.color = self.activeTile:transfer(COLORCHANGE_AMOUNT, self.player.tileData.color)
				self:playTransferSound()
			end
			if self.activeTile.properties.drain then
				
				self.activeTile.color = self.player.tileData:transfer(COLORCHANGE_AMOUNT, self.activeTile.color)
				self:playTransferSound()
			end
			if self.activeTile.typeAsString == "End" then
				if not self.levelComplete then
					self.levelComplete = true
					local numLevels = #map
					if CurrentLevel + 1 > numLevels then 
						self.gameComplete = true
					else
						CurrentLevel = CurrentLevel + 1
					end
					if StoryMode and CurrentLevel <= 13 then
						destroyState("game")
						enableState("story")
					elseif not self.gameComplete then 
						destroyState("game")
						addState(GameState:new(), "game")
					end
				end
			end
			if not prevKeyboard.zPressed then -- Check that Activate key is not held down
				if self.activeTile.properties.portal then -- Check for Portal
					for indexX = 1, gridSizeX do
						for indexY = 1, gridSizeY do
							if self.objectGrid[indexX][indexY] ~= nil then
								if self.objectGrid[indexX][indexY].properties.portal then
									if self.objectGrid[indexX][indexY] ~= self.activeTile then -- Ensure portal in grid is not the active one
										if self.activeTile:compareColor(self.objectGrid[indexX][indexY].color, COLOR_RANGE) then -- Check if found portal is in same color range as active
											self.player.pos.x = (indexX-1)*TILESIZE.W+GameBounds.x -- Move player to other portal
											self.player.pos.y = (indexY-1)*TILESIZE.H+GameBounds.y
											audio.playSound("audio/portal.ogg", 1*Master_Volume, 0, 1)
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		
		
		if self.activeTile.properties.sap then
			local pulse_received = false
			self.prevColorRemain = 1/(255*3)*(self.player.tileData.color.r +  self.player.tileData.color.g +  self.player.tileData.color.b)
			
			self.activeTile.color, pulse_received = self.player.tileData:transferOnPulse(COLOR_RANGE, self.activeTile.color, self.activeTile.pulse)
			
			local colorRemain = 1/(255*3)*(self.player.tileData.color.r +  self.player.tileData.color.g +  self.player.tileData.color.b)
			colorRemain = math.clamp(colorRemain, 0, 1)
			if colorRemain ~= self.prevColorRemain then
				audio.playSound("audio/transfer.ogg", 1*Master_Volume, 0, colorRemain)
			end
			self.prevColorRemain = colorRemain
			if pulse_received then
				self.activeTile:resetPulse()
			end
		end
		
	else
		destroyState("game")
		addState(GameState:new(), "game")
		enableState("game")
	end	
	-- Check for keys released
	if not daisy.isKeyPressed(37) then
		Keyboard.leftPressed = false
	end
	if not daisy.isKeyPressed(38) then
		Keyboard.upPressed = false
	end
	if not daisy.isKeyPressed(39) then
		Keyboard.rightPressed = false
	end
	if not daisy.isKeyPressed(40) then
		Keyboard.downPressed = false
	end
	if not daisy.isKeyPressed(90) then -- Z: Activate
		InteractionState.activate = false
		Keyboard.zPressed = false
	end
	
	prevKeyboard.zPressed = Keyboard.zPressed
	
	if self.gameComplete then
		destroyState("game")
		destroyState("story")
		addState(EndGameState:new(), "endgame")
	end
	
end

function GameState:playTransferSound()
	--Scale sfx pitch based on colour levels
	local colorRemain = 1/(255*3)*(self.player.tileData.color.r +  self.player.tileData.color.g +  self.player.tileData.color.b)
	colorRemain = math.clamp(colorRemain, 0, 1)
	audio.playSound("audio/transfer.ogg", 1*Master_Volume, 0, colorRemain+0.2)
end

function GameState:getAdjacentTiles(tileSet, x, y)
	tileList = {}
	
	if y-1 > 0 then tileList.N = tileSet[x][y-1] else tileList.N = nil end
	if y+1 <= GameBounds.height/TILESIZE.H then tileList.S = tileSet[x][y+1] else tileList.S = nil end
	if x+1 <= GameBounds.width/TILESIZE.W then tileList.E = tileSet[x+1][y] else tileList.E = nil end
	if x-1 > 0 then tileList.W = tileSet[x-1][y] else tileList.W = nil end
	return tileList
end


function GameState:renderLightmap()

end

function GameState:render()
	local resolutionOffset = window.width/2 - 400;
	video.renderRectangle(0, 0, window.width, window.height, 255, 40, 40, 40) -- Render background color
	video.renderRectangle(resolutionOffset + GameBounds.x, GameBounds.y, GameBounds.width, GameBounds.height, 255, 255, 255, 255) -- Render GameBounds
	
	-- Render each tile
	local w,h = TILESIZE.W, TILESIZE.H
	local gridSizeX = GameBounds.width/w
	local gridSizeY = GameBounds.height/h
	
	for indexX = 1, gridSizeX do
		for indexY = 1, gridSizeY do
			if self.objectGrid[indexX][indexY] ~= nil then
				local o = self.objectGrid[indexX][indexY]
				local renderColor = o.color
				
				if o.color.r < COLOR_RANGE and o.color.g < COLOR_RANGE and o.color.b < COLOR_RANGE then
					renderColor = o:flicker(renderColor)
				end
				video.renderSpriteState(o.sprite.image, resolutionOffset + (indexX-1)*w+GameBounds.x, (indexY-1)*h+GameBounds.y, 1.0, 0, 255, renderColor.r, renderColor.g, renderColor.b) -- Render floor/object tiles
			end
		end
	end
	
	
	-- ACTIVE TILE INFO PANEL
	if self.activeTile ~= nil then
		if self.activeTile.tileType ~= 0 then
			local renderColor = self.activeTile.color
			if self.activeTile.color.r < COLOR_RANGE and self.activeTile.color.g < COLOR_RANGE and self.activeTile.color.b < COLOR_RANGE then
				renderColor = self.activeTile:flicker(self.activeTile.color)
			end
		
			video.renderRectangle(resolutionOffset + GameBounds.width + GameBounds.x - 320, GameBounds.y - 56, 320, 47, 255, 0, 0, 0) -- Render background panel
			
			video.renderSpriteState(self.activeTile.sprite.image, resolutionOffset + GameBounds.width + GameBounds.x - 319,  GameBounds.y - 56, 1.43, 0, self.objectPanelAlpha, renderColor.r, renderColor.g, renderColor.b)

			

			video.renderRectangle(resolutionOffset + GameBounds.width + GameBounds.x - 256, GameBounds.y - 55, self.activeTile.color.r, 15, 255, 255, 0, 0)
			video.renderRectangle(resolutionOffset + GameBounds.width + GameBounds.x - 256, GameBounds.y - 40, self.activeTile.color.g, 15, 255, 0, 255, 0)
			video.renderRectangle(resolutionOffset + GameBounds.width + GameBounds.x - 256, GameBounds.y - 25, self.activeTile.color.b, 15, 255, 0, 0, 255)
			video.renderText("R: ", resolutionOffset + GameBounds.width + GameBounds.x - 270, GameBounds.y - 53, 0, "font.fnt", self.objectPanelAlpha, 255, 255, 255)
			video.renderText("G: ", resolutionOffset + GameBounds.width + GameBounds.x - 270, GameBounds.y - 38, 0, "font.fnt", self.objectPanelAlpha, 255, 255, 255)
			video.renderText("B: ", resolutionOffset + GameBounds.width + GameBounds.x - 270, GameBounds.y - 23, 0, "font.fnt", self.objectPanelAlpha, 255, 255, 255)
			
			
			local linePos = { x1 = GameBounds.width + GameBounds.x - 1 - COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width + GameBounds.x - 1 - COLOR_RANGE,  y2 = GameBounds.y-5}
			video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
			
			local linePos = { x1 = GameBounds.width + GameBounds.x - 257 + COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width + GameBounds.x - 257 + COLOR_RANGE,  y2 = GameBounds.y-5}
			video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
			
			local linePos = { x1 = GameBounds.width + GameBounds.x - 129 - COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width + GameBounds.x - 129 - COLOR_RANGE,  y2 = GameBounds.y-5}
			video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
			
			local linePos = { x1 = GameBounds.width + GameBounds.x - 129 + COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width + GameBounds.x - 129 + COLOR_RANGE,  y2 = GameBounds.y-5}
			
			video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
			--video.renderText("" .. self.activeTile.typeAsString, GameBounds.x - 40, GameBounds.y + 60, 1, "font.fnt", self.objectPanelAlpha, 255, 255, 255)
		end
	end
	
	-- PLAYER INFO PANEL
	local renderColor = self.player.tileData.color
	if self.player.tileData.color.r< COLOR_RANGE and self.player.tileData.color.g < COLOR_RANGE and self.player.tileData.color.b < COLOR_RANGE then
		renderColor = self.player.tileData:flicker(renderColor)
	end
	
	video.renderRectangle(resolutionOffset + GameBounds.x, GameBounds.y - 56, 320, 47, 255, 0, 0, 0)
	
	video.renderSpriteState(entitySprites["player"], resolutionOffset + GameBounds.width/2 + GameBounds.x - 319,  GameBounds.y - 56, 1.43, 0, 255, renderColor.r, renderColor.g, renderColor.b) -- Render Player Sprite
			
	video.renderRectangle(resolutionOffset + GameBounds.width/2 + GameBounds.x - 256, GameBounds.y - 55, self.player.tileData.color.r, 15, 255, 255, 0, 0)
	video.renderRectangle(resolutionOffset + GameBounds.width/2 + GameBounds.x - 256, GameBounds.y - 40, self.player.tileData.color.g, 15, 255, 0, 255, 0)
	video.renderRectangle(resolutionOffset + GameBounds.width/2 + GameBounds.x - 256, GameBounds.y - 25, self.player.tileData.color.b, 15, 255, 0, 0, 255)
	video.renderText("R: ", resolutionOffset + GameBounds.width/2 + GameBounds.x - 270, GameBounds.y - 53, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("G: ", resolutionOffset + GameBounds.width/2 + GameBounds.x - 270, GameBounds.y - 38, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("B: ", resolutionOffset + GameBounds.width/2 + GameBounds.x - 270, GameBounds.y - 23, 0, "font.fnt", 255, 255, 255, 255)
	
	local linePos = { x1 = GameBounds.width/2 + GameBounds.x - 1 - COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width/2 + GameBounds.x - 1 - COLOR_RANGE,  y2 = GameBounds.y-5}
	video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
	
	local linePos = { x1 = GameBounds.width/2 + GameBounds.x - 257 + COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width/2 + GameBounds.x - 257 + COLOR_RANGE,  y2 = GameBounds.y-5}
	video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
	
	local linePos = { x1 = GameBounds.width/2 + GameBounds.x - 129 - COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width/2 + GameBounds.x - 129 - COLOR_RANGE,  y2 = GameBounds.y-5}
	video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
	
	local linePos = { x1 = GameBounds.width/2 + GameBounds.x - 129 + COLOR_RANGE,  y1 = GameBounds.y - 60, x2 = GameBounds.width/2 + GameBounds.x - 129 + COLOR_RANGE,  y2 = GameBounds.y-5}
	video.renderLine(resolutionOffset + linePos.x1, linePos.y1, resolutionOffset + linePos.x2, linePos.y2, 128, 255, 255, 255)
	

	
	-- SELECTED TILE INFO PANEL
	video.renderRectangle(resolutionOffset + GameBounds.x - 70, GameBounds.y, 62, 352, 255, 0, 0, 0) -- Render player info background panel
	if self.displayTimer > 0 then
		if self.selectedTile.tile ~= nil then
				local renderColor = self.selectedTile.tile.color
				if self.selectedTile.tile.color.r < COLOR_RANGE and self.selectedTile.tile.color.g < COLOR_RANGE and self.selectedTile.tile.color.b < COLOR_RANGE then
					renderColor = self.selectedTile.tile:flicker(self.selectedTile.tile.color)
				end
				video.renderSpriteState(self.selectedTile.tile.sprite.image, resolutionOffset + GameBounds.x - 69,  GameBounds.y + 1, 1.85, 0, self.selectedPanelAlpha, renderColor.r, renderColor.g, renderColor.b)
					
				video.renderText("R", resolutionOffset + GameBounds.x - 57, GameBounds.y + 80, 0, "font.fnt", self.selectedPanelAlpha, 255, 255, 255)
				video.renderText("G", resolutionOffset + GameBounds.x - 44, GameBounds.y + 80, 0, "font.fnt", self.selectedPanelAlpha, 255, 255, 255)
				video.renderText("B", resolutionOffset + GameBounds.x - 30, GameBounds.y + 80, 0, "font.fnt", self.selectedPanelAlpha, 255, 255, 255)
				video.renderText("" .. self.selectedTile.tile.typeAsString, resolutionOffset + GameBounds.x - 40, GameBounds.y + 60, 1, "font.fnt", self.selectedPanelAlpha, 255, 255, 255)
				video.renderRectangle(resolutionOffset + GameBounds.x - 62, GameBounds.y + 95, 15, self.selectedTile.tile.color.r, self.selectedPanelAlpha, 255, 0, 0)
				video.renderRectangle(resolutionOffset + GameBounds.x - 47, GameBounds.y + 95, 15, self.selectedTile.tile.color.g, self.selectedPanelAlpha, 0, 255, 0)
				video.renderRectangle(resolutionOffset + GameBounds.x - 32, GameBounds.y + 95, 15, self.selectedTile.tile.color.b, self.selectedPanelAlpha, 0, 0, 255)
		end
	end
	
	-- Render Entities
	for index, e in pairs(self.entityList) do
		e:render()
	end
	
	-- Render Player
	video.renderSpriteState(self.player.tileData.sprite.image, resolutionOffset + self.player.pos.x, self.player.pos.y, self.player.scale, self.player.angle, 255, renderColor.r, renderColor.g, renderColor.b)
	
	-- Render Controls
	
	video.renderText("Move: Arrow keys", resolutionOffset + 100, window.height - 40, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Activate: Z", resolutionOffset + 200, window.height - 40, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Inspect: Left Mouse Button", resolutionOffset + 500, window.height - 40, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Quit: Esc", resolutionOffset + 100, window.height - 20, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Restart Level: R", resolutionOffset + 200, window.height - 20, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Skip to next level: M   Go to previous level: N", resolutionOffset + 300, window.height - 20, 0, "font.fnt", 255, 255, 255, 255)
	video.renderText("Volume down: O       Volume up: P  ", resolutionOffset + 300, window.height - 40, 0, "font.fnt", 255, 255, 255, 255)
		
	--Debug Info 
	--[[if self.selectedTile.pos.x >0 and self.selectedTile.pos.x <= 20 and self.selectedTile.pos.y >0 and self.selectedTile.pos.y <= 15 then
		video.renderText("x:" .. math.ceil(self.selectedTile.pos.x), 10, GameBounds.height, 0, "font.fnt", 255, 255, 255, 255)
		video.renderText("y:" .. math.ceil(self.selectedTile.pos.y), 10, GameBounds.height - 20, 0, "font.fnt", 255, 255, 255, 255)
		video.renderText("tile:" .. self.selectedTile.tile.tileType, 10, GameBounds.height - 40, 0, "font.fnt", 255, 255, 255, 255)
		
	end]]
end

function GameState:detectCollision(object1, object2) 
        if (object1.bottom <= object2.top) then return false end
        if (object1.top >= object2.bottom) then return false end
        if (object1.right <= object2.left) then return false end
        if (object1.left >= object2.right) then return false end
		
		return true
		
end

function GameState:mouseClick(x,y,button,count)
	
end

function GameState:keyPressed(key)
	if(key) == 27 then
			self:resetLevel()
	end
	--[[  --Debug level select
	if(key) == 49 then
			CurrentLevel = 1
			self:resetLevel()
	end

	if(key) == 50 then
			CurrentLevel = 2
			self:resetLevel()
	end

	if(key) == 51 then
			CurrentLevel = 3
			self:resetLevel()
	end
	
	if(key) == 52 then
			CurrentLevel = 4
			self:resetLevel()
	end
	
	if(key) == 53 then
			CurrentLevel = 5
			self:resetLevel()
	end
	
	if(key) == 54 then
			CurrentLevel = 6
			self:resetLevel()
	end
	
	if(key) == 55 then
			CurrentLevel = 7
			self:resetLevel()
	end
	
	if(key) == 56 then
			CurrentLevel = 8
			self:resetLevel()
	end
	--]]
	if(key) == 57 then
			destroyState("game")
			destroyState("story")
			addState(EndGameState:new(), "endgame")
	end
	
	if(key) == 77 then
			if CurrentLevel < #map then
				CurrentLevel = CurrentLevel + 1
				self:resetLevel()
			end
	end
	if(key) == 78 then
			if CurrentLevel > 1 then
				CurrentLevel = CurrentLevel - 1
				self:resetLevel()
			end
	end
	
	if(key) == 37 then
		self.leftAction()
	end
	
	if(key) == 38 then
		self.upAction()
	end
	
	if(key) == 39 then
		self.rightAction()
	end
	
	if(key) == 40 then
		self.downAction()
	end
	
	if(key) == 90 then -- Z: Activate
		self.activateAction()
	end
	
	if(key) == 82 then -- R: Reset
		destroyState("game")
		addState(GameState:new(), "game")
		enableState("game")
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

function GameState:resetLevel()
		destroyState("game")
		addState(GameState:new(), "game")
		enableState("game")
end

function GameState:activateAction()
	InteractionState.activate = true
	Keyboard.zPressed = true
end

function GameState:leftAction()
	Keyboard.leftPressed, Keyboard.rightPressed, Keyboard.upPressed, Keyboard.downPressed = true, false, false, false
end

function GameState:rightAction()
	Keyboard.leftPressed, Keyboard.rightPressed, Keyboard.upPressed, Keyboard.downPressed = false, true, false, false
end

function GameState:upAction()
	Keyboard.leftPressed, Keyboard.rightPressed, Keyboard.upPressed, Keyboard.downPressed = false, false, true, false
end

function GameState:downAction()
	Keyboard.leftPressed, Keyboard.rightPressed, Keyboard.upPressed, Keyboard.downPressed = false, false, false, true
end


function GameState:joyButtonPressed(joy, button)
	
end

function GameState:joyButtonReleased(joy, button)
end
