--[[
	Button class by Jamie Myland
]]

-- GLOBALS

_button = {}

-- LOCALS
local button = _button

function button:new(spriteBase, spriteActive, x, y, enabled)
	local o = {}
	o.sprite = {}
	o.sprite.base = spriteBase
	o.sprite.active = spriteActive
	o.sprite.width, o.sprite.height = 0, 0
	o.pos = {x = x, y = y}
	o.hitBox = {x1 = 0, x2 = 0, y1 =0 , y2 =0}
	o.selected = false
	o.hover = false
	o.enabled = enabled
	setmetatable(o, self)
	self.__index = self
	return o
end

function button:update(mx, my)
		if self.enabled then
			if self.hover then
				self.sprite.width, self.sprite.height = video.getSpriteStateSize(self.sprite.active)
			else
				self.sprite.width, self.sprite.height = video.getSpriteStateSize(self.sprite.base)
			end
			self.hitBox = {x1 = self.pos.x - self.sprite.width/2, y1 = self.pos.y - self.sprite.height/2, x2 = self.pos.x +  self.sprite.width/2, y2 = self.pos.y  + self.sprite.height/2}
			
			if mx > self.hitBox.x1 and mx < self.hitBox.x2 and my > self.hitBox.y1 and my < self.hitBox.y2 then self.hover = true else self.hover = false end
		end
	return 0
end

function button:render()
	if self.enabled then
		if self.hover then
			video.renderSpriteState(self.sprite.active, self.pos.x, self.pos.y)
		else
			video.renderSpriteState(self.sprite.base, self.pos.x, self.pos.y)
		end
	else
		video.renderSpriteState(self.sprite.base, self.pos.x, self.pos.y)
	end
end

function button:checkSelected()
	if self.enabled then
		return self.hover
	end
end

function button:enable()
	self.enabled = true
end

function button:disable()
	self.enabled = false
end