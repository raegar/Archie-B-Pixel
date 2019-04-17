
Color = {}

function Color:new(a, r, g, b)

	local color = {}
	
	color.a = a
	color.r = r
	color.g = g
	color.b = b

	color = setmetatable(color, self)
	self.__index = self
	return color
end

function Color:getColor(index)
	if index == 1 then
		return self.a
	elseif index == 2 then
		return self.r
	elseif index == 3 then
		return self.g
	else
		return self.b
	end
end

function Color:save(file)
	file:writeInt(self.a)
	file:writeInt(self.r)
	file:writeInt(self.g)
	file:writeInt(self.b)
end

function Color:load(file)

	local a,r,g,b = 0,0,0,0
	
	a = file:readInt()
	r = file:readInt()
	g = file:readInt()
	b = file:readInt()

	return Color:new(a,r,g,b)
end