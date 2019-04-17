_entity = {}

local entity = _entity
local tile = _tile

function entity:new(aiType, r, g, b, pos)
	local o = inherited(self)
	o.aiType = aiType
	o.typeAsString = ""
	o.pos = pos
	o.gridPos = {x = 0, y = 0}
	o.collisionBox = {}
	o.direction = {up = false, down = false, left = false, right = false}
	o.tilesMoved = 0
	o.velocity = {x = 1, y = 1}
	o.speed = 1
	if aiType == 101 or aiType == 102 then
		o.tileData = tile:new(entitySprites["enemy1"], aiType, r, g, b)
	elseif aiType == 103 or aiType == 104 then
		o.tileData = tile:new(entitySprites["enemy2"], aiType, r, g, b)
	else
		o.tileData = tile:new(entitySprites["enemy1"], aiType, r, g, b)
	end
	return o
end

function entity:init()

	self.gridPos = {x = 1+(self.pos.x - GameBounds.x)/TILESIZE.W, y = 1+(self.pos.y - GameBounds.y)/TILESIZE.H}
	self.speed = 1
	if self.aiType == 101 then
		self.typeAsString = "Vertical" -- 0x65
		self.direction = {up = false, down = true, left = false, right = false}
	elseif self.aiType == 102 then
		self.typeAsString = "Horizontal" -- 0x66
		self.direction = {up = false, down = false, left = false, right = true}
	elseif self.aiType == 103 then
		self.typeAsString = "Clockwise" -- 0x67
		self.direction = {up = false, down = false, left = false, right = true}
	elseif self.aiType == 104 then
		self.typeAsString = "Anticlockwise" -- 0x68
		self.direction = {up = true, down = false, left = false, right = false}
	end
end

function entity:update(time)
	if self.direction.down then
		self.velocity.x = 0
		self.velocity.y = 1
	elseif self.direction.up then
		self.velocity.x = 0
		self.velocity.y = -1
	elseif self.direction.right then
		self.velocity.x = 1
		self.velocity.y = 0
	elseif self.direction.left then
		self.velocity.x = -1
		self.velocity.y = 0
	end
	
	self.pos.x = self.pos.x + self.velocity.x*self.speed
	self.pos.y = self.pos.y + self.velocity.y*self.speed

	self.collisionBox.left, self.collisionBox.right, self.collisionBox.top, self.collisionBox.bottom = self.pos.x, self.pos.x + TILESIZE.W, self.pos.y, self.pos.y + TILESIZE.H
	
	if math.fmod(self.pos.x - GameBounds.x, 32) == 0 and math.fmod(self.pos.y - GameBounds.y, 32) == 0 then
		self.gridPos = {x = 1+(self.pos.x - GameBounds.x)/TILESIZE.W, y = 1+(self.pos.y - GameBounds.y)/TILESIZE.H}
	end
	self.tileData:update(time)
end

function entity:updateDirection(adjacentTiles)
	
	if self.typeAsString == "Vertical" then
		if self.direction.down then
			if adjacentTiles.S ~= nil and adjacentTiles.S.typeAsString ~= "Wall" and adjacentTiles.S.typeAsString ~= "BarrierClosed" then
				--Continue
			else
				self.direction = {up = true, down = false, left = false, right = false}
			end
		else
			if adjacentTiles.N ~= nil and adjacentTiles.N.typeAsString ~= "Wall" and adjacentTiles.N.typeAsString ~= "BarrierClosed" then
				--Continue
			else
				self.direction = {up = false, down = true, left = false, right = false}
			end
		end
	
	elseif self.typeAsString == "Horizontal" then
		if self.direction.right then
			if adjacentTiles.E ~= nil and adjacentTiles.E.typeAsString ~= "Wall" and adjacentTiles.E.typeAsString ~= "BarrierClosed" then
				--Continue
			else
				self.direction = {up = false, down = false, left = true, right = false}
			end
		else
			if adjacentTiles.W ~= nil and adjacentTiles.W.typeAsString ~= "Wall" and adjacentTiles.W.typeAsString ~= "BarrierClosed" then
				--Continue
			else
				self.direction = {up = false, down = false, left = false, right = true}
			end
		end
	
	elseif self.typeAsString == "Clockwise" then
		if math.fmod(self.pos.x - GameBounds.x, 32) == 0 and math.fmod(self.pos.y - GameBounds.y, 32) == 0 then
			
			if self.tilesMoved == 2 then
				self.tilesMoved = 0
				if self.direction.right then
					self.direction.right = false
					self.direction.down = true
				elseif self.direction.down then
					self.direction.down = false
					self.direction.left = true
				elseif self.direction.left then
					self.direction.left = false
					self.direction.up = true
				elseif self.direction.up then
					self.direction.up = false
					self.direction.right = true
				end
			end
			self.tilesMoved = self.tilesMoved + 1
		end
	elseif self.typeAsString == "Anticlockwise" then
		
		if math.fmod(self.pos.x - GameBounds.x, 32) == 0 and math.fmod(self.pos.y - GameBounds.y, 32) == 0 then
			
			if self.tilesMoved == 2 then
				self.tilesMoved = 0
				if self.direction.right then
					self.direction.right = false
					self.direction.up = true
				elseif self.direction.up then
					self.direction.up = false
					self.direction.left = true
				elseif self.direction.left then
					self.direction.left = false
					self.direction.down = true
				elseif self.direction.down then
					self.direction.down = false
					self.direction.right = true
				end
			end
			self.tilesMoved = self.tilesMoved + 1
		end
	
	end
end

function entity:render()
	local renderColor = self.tileData.color
	if self.tileData.color.r < COLOR_RANGE and self.tileData.color.g < COLOR_RANGE and self.tileData.color.b < COLOR_RANGE then
		renderColor = self.tileData:flicker(renderColor)
	end
	video.renderSpriteState(self.tileData.sprite.image, window.width/2 - 400 + self.pos.x,  self.pos.y, 1.0, 0, 255, renderColor.r, renderColor.g, renderColor.b)
end