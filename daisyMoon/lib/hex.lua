-- GLOBALS

_hex = {}

-- LOCALS
local hex = _hex

function hex.toTile(hexVal)
	local hexColor = WChar(hexVal)	
	local tile = {}
		
	local hexPair = hexColor:sub(1,2)
	tile.r = hex.toDec(hexPair)
				
	local hexPair = hexColor:sub(3,4)
	tile.g = hex.toDec(hexPair)

	local hexPair = hexColor:sub(5,6)
	tile.b = hex.toDec(hexPair)

	local hexPair = hexColor:sub(7,8)
	tile.type = hex.toDec(hexPair)
	
	return tile
end
	

function hex.toDec(hexPair)
	
	local decValue = 0
	local total = 0
	local hexValue
	local hexString
	
	for i = 1, 2, 1 do
		hexValue = hexPair:sub(i, i)
		hexValue = hexValue:toLower()
		hexString = hexValue:toString()
		if hexString == "a" then
			decValue=10
		elseif hexString == "b" then
			decValue=11
		elseif hexString == "c" then
			decValue=12
		elseif hexString == "d" then
			decValue=13
		elseif hexString == "e" then
			decValue=14
		elseif hexString == "f" then
			decValue=15
		else
			decValue = hexValue:toNumber()
		end
		
		if i == 1 then
			decValue = decValue*16
		end
		total = total + decValue
	end
	return total
end	
	
	
