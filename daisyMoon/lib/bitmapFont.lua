--[[
	String to bitmap font method by Jamie Myland,
	
	This function converts a string into individual characters 
	and then renders each one as a sprite. The function requires
	a sprite library containing each of the characters to be 
	rendered. You can optionally adjust the font scale, tint and 
	kerning (spacing parameter).
]]

-- GLOBALS

_bitmapFont = {}

-- LOCALS
local bitmapFont = _bitmapFont


function bitmapFont.getSize(str, spriteLibrary, spacing, scale)
	local width = 0
	local height = 0
	local largest = 0
	str = WChar(str)
	local numLoop = str:length()
	
	for index = 1, numLoop, 1 do
		local char = str:sub(index,index) 
		char = char:toString()
		if char == " " then char = "space" end
		if char == "," then char = "comma" end
		if char == "." then char = "dot" end
		if char == ":" then char = "colon" end
		if char == ";" then char = "semicolon" end
		if char == "?" then char = "question" end
		local charSprite = spriteLibrary[char]
		local w, h = video.getSpriteStateSize(charSprite)
		width = width + (w * scale) + (spacing * scale)
		if h > largest then largest = h end
	end
	height = largest * scale
	return width, height
end

function bitmapFont.drawString(str, x, y, spriteLibrary, spacing, scale, align, a, r, g, b, warnings)
	spacing = spacing or 4 -- Default kerning of 4px
	scale = scale or 1.0
	a, r, g, b = a or 255, r or 255, g or 255, b or 255
	warnings = warnings or false
	align = align or 0
	x = x
	y = y
	str = WChar(str)
	local numLoop = str:length()
	local width = 0
	local height = 0
	if align == 1 then --Centre align
		width, height = bitmapFont.getSize(str, spriteLibrary, spacing, scale) 
		width = width/2
		--height = height/2 --Enable to align height to centre
	end
	if align == 2 then --Right align
		width, height = bitmapFont.getSize(str, spriteLibrary, spacing, scale) 
		height = 0
	end
	
	
	for index = 1, numLoop, 1 do
		local char = str:sub(index,index)
		char = char:toString()
		if char == " " then char = "space" end
		if char == "," then char = "comma" end
		if char == "." then char = "dot" end
		if char == ":" then char = "colon" end
		if char == ";" then char = "semicolon" end
		if char == "?" then char = "question" end
		local charSprite = spriteLibrary[char]
		if charSprite == nil then
			if warnings then
				print ("Char: " .. char .." not found " ) --ERROR: Character not found
			end
		else
			local w, h = video.getSpriteStateSize(charSprite)	
			--video.setForcePointSampling(true) -- Not working??
			video.renderSpriteState(charSprite, x-width, y-height, scale, 0, a, r, g, b, false)
			--video.setForcePointSampling(false)
			x = x + w*scale + spacing*scale
		end
	end
	return 0
end