_tile = {}
FLICKER_LIGHTLEVEL = 40


local tile = _tile


 function tile:new(sprite, tileType, r, g, b)
	local o = inherited(self)
	o.sprite = {}
	o.sprite.image = sprite
	o.tileType = tileType
	o.color = {r = r or 255, g = g or 255, b = b or 255}
	o.passable = true
	o.typeAsString = ""
	o.properties = {drain = false, charge = false, well = false, sap = false, portal = false} 
	o.pulse = {rate = 1, min = 0.8, max = 1.2, value = 1, grow = true, tick = false}
	o.active = false
	return o
 end

function tile:init()

	if self.tileType == 0 then
		self.typeAsString = "Floor" -- 0x00
	elseif self.tileType == 1 then
		self.typeAsString = "Drain" -- 0x01
		self.properties.drain = true
		self:setPrimaryColors()
	elseif self.tileType == 2 then
		self.typeAsString = "Charge" -- 0x02
		self.properties.charge = true
		self:setPrimaryColors()
	elseif self.tileType == 3 then
		self.typeAsString = ""
	elseif self.tileType == 4 then
		self.typeAsString = ""
	elseif self.tileType == 5 then
		self.typeAsString = ""
	elseif self.tileType == 6 then
		self.typeAsString = ""
	elseif self.tileType == 7 then
		self.typeAsString = ""
	elseif self.tileType == 8 then
		self.typeAsString = "Bus" -- 0x08
		self.properties.portal = true
	elseif self.tileType == 9 then
		self.typeAsString = "" 
	elseif self.tileType == 10 then
		self.typeAsString = ""
	elseif self.tileType == 11 then
		self.typeAsString = ""
		self.properties.well = true
	elseif self.tileType == 12 then
		self.typeAsString = ""
	elseif self.tileType == 13 then
		self.typeAsString = ""
	elseif self.tileType == 14 then
		self.typeAsString = ""
	elseif self.tileType == 15 then
		self.typeAsString = ""
	elseif self.tileType == 16 then
		self.typeAsString = "Sap"  -- 0x10
		self:setPrimaryColors()
		self.active = true
		self.properties.sap = true
	elseif self.tileType == 17 then
		self.typeAsString = ""
	elseif self.tileType == 18 then
		self.typeAsString = "Gate" -- 0x12
	elseif self.tileType == 19 then
		self.typeAsString = ""
	elseif self.tileType == 20 then
		self.typeAsString = ""
	elseif self.tileType == 21 then
		self.typeAsString = ""
	elseif self.tileType == 22 then
		self.typeAsString = ""
	elseif self.tileType == 23 then
		self.typeAsString = "Wall" -- 0x17
		self.passable = false
	elseif self.tileType == 24 then
		self.typeAsString = "Start" -- 0x18
	elseif self.tileType == 25 then
		self.typeAsString = "End" -- 0x19
	elseif self.tileType == 26 then
		self.typeAsString = ""
	elseif self.tileType == 27 then
		self.typeAsString = ""
	elseif self.tileType == 28 then
		self.typeAsString = "BarrierClosed" -- 0x1C
		self.passable = false
	elseif self.tileType == 29 then
		self.typeAsString = "Barrier" -- 0x1D
		self.passable = true
	elseif self.tileType == 30 then
		self.typeAsString = ""
	elseif self.tileType > 100 then
		self.typeAsString = "Enemy" -- 0x65+
	end

end

function tile:setPrimaryColors()
	if self.color.r < 128 then self.color.r = 0 else self.color.r = 255 end
	if self.color.g < 128 then self.color.g = 0 else self.color.g = 255 end
	if self.color.b < 128 then self.color.b = 0 else self.color.b = 255 end
end

function tile:update(time)
	self.pulse.tick = false
	if self.pulse.grow then
		self.pulse.value = self.pulse.value + self.pulse.rate * time
		if self.pulse.value >= self.pulse.max then
			self.pulse.grow = false
			self.pulse.value = self.pulse.max
		end
	else
		self.pulse.value = self.pulse.value - self.pulse.rate * time
		if self.pulse.value <= self.pulse.min then
			self.pulse.tick = true
			self.pulse.grow = true
			self.pulse.value = self.pulse.min
		end
	end
end


function tile:resetPulse()
	self.pulse = {rate = 0.8, min = 0.8, max = 1.2, value = 1, grow = true, tick = true}
end

function tile:render()
	
end

function tile:flicker(renderColor)
	
	local renderColor = renderColor
		if self.pulse.grow then
			renderColor = {r = FLICKER_LIGHTLEVEL, g = FLICKER_LIGHTLEVEL, b = FLICKER_LIGHTLEVEL}
		end
	return renderColor
end

function tile:transferOnPulse(COLOR_RANGE, RGB_receiver, Pulse_receiver)
	local sendPulse = false
	local receiverColor = RGB_receiver
	local transferAmount = {r = COLOR_RANGE, g = COLOR_RANGE, b = COLOR_RANGE}
	if Pulse_receiver.tick then
		receiverColor, transferAmount = self:transfer(transferAmount, receiverColor)
		sendPulse = true
	end
	
	return receiverColor, sendpulse, transferAmount
end

function tile:transfer(RGB_amount, RGB_receiver)
	local receiver = RGB_receiver
	local transferAmount = RGB_amount
	
	if receiver.r + transferAmount.r > 255 then
		transferAmount.r = receiver.r + transferAmount.r - 255
	end 
	if self.color.r - transferAmount.r < 0 then
		local temp = self.color.r - transferAmount.r
		if -temp < transferAmount.r then transferAmount.r = -temp end
	end
	if receiver.r < 255 and self.color.r > 0 then
		receiver.r = receiver.r + transferAmount.r 
		self.color.r = self.color.r - transferAmount.r 
	end
	if receiver.g + transferAmount.g > 255 then
		transferAmount.g = receiver.g + transferAmount.g - 255
	end 
	if self.color.g - transferAmount.g < 0 then
		local temp = self.color.g - transferAmount.g
		if -temp < transferAmount.g then transferAmount.g = -temp end
	end
	if receiver.g < 255 and self.color.g > 0 then
		receiver.g = receiver.g + transferAmount.g
		self.color.g = self.color.g - transferAmount.g
	end
	if receiver.b + transferAmount.b > 255 then
		transferAmount.b = receiver.b + transferAmount.b - 255
	end 
	if self.color.b - transferAmount.b < 0 then
		local temp = self.color.b - transferAmount.b
		if -temp < transferAmount.b then transferAmount.b = -temp end
	end
	if receiver.b < 255 and self.color.b > 0 then
		receiver.b = receiver.b + transferAmount.b
		self.color.b = self.color.b - transferAmount.b
	end
	
	return receiver, transferAmount
end



function tile:removeColor(RGB_amount, RGB_receiver)
	local red = RGB_receiver.r
	local green = RGB_receiver.g
	local blue = RGB_receiver.b
	local transferAmount = RGB_amount
	red = 255 - red 
	green = 255 - green 
	blue = 255 - blue 
	receiver = {r = red, g = green, b = blue}
	local fullyDrained = false

	if receiver.r + transferAmount.r > 255 then
		transferAmount.r = receiver.r + transferAmount.r - 255
	end 
	if self.color.r - transferAmount.r < 0 then
		local temp = self.color.r - transferAmount.r
		if -temp < transferAmount.r then transferAmount.r = -temp end
	end
	if receiver.r < 255 and self.color.r > 0 then
		self.color.r = self.color.r - transferAmount.r 
	end

	if receiver.g + transferAmount.g > 255 then
		transferAmount.g = receiver.g + transferAmount.g - 255
	end 
	if self.color.g - transferAmount.g < 0 then
		local temp = self.color.g - transferAmount.g
		if -temp < transferAmount.g then transferAmount.g = -temp end
	end
	if receiver.g < 255 and self.color.g > 0 then
		self.color.g = self.color.g - transferAmount.g
	end

	if receiver.b + transferAmount.b > 255 then
		transferAmount.b = receiver.b + transferAmount.b - 255
	end 
	if self.color.b - transferAmount.b < 0 then
		local temp = self.color.b - transferAmount.b
		if -temp < transferAmount.b then transferAmount.b = -temp end
	end
	if receiver.b < 255 and self.color.b > 0 then
		self.color.b = self.color.b - transferAmount.b
	end
	
	if RGB_receiver.r ~= 0 then
		if self.color.r == 0 then
			fullyDrained = true
		end
	end
	if RGB_receiver.b ~= 0 then
		if self.color.b == 0 then
			fullyDrained = true
		end
	end
	if RGB_receiver.g ~= 0 then
		if self.color.g == 0 then
			fullyDrained = true
		end
	end

	return fullyDrained, receiver
end





function tile:compareColor(tileColor, range)
local range = range + 1
	if self.color.r >= tileColor.r-range and self.color.r <= tileColor.r+range and self.color.g >= tileColor.g-range and self.color.g <= tileColor.g+range and self.color.b >= tileColor.b-range and self.color.b <= tileColor.b+range then
		return true
	else
		return false
	end
end
