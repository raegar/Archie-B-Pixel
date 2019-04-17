-- GLOBALS

_vectorMath = {}

-- LOCALS
local vectorMath = _vectorMath

vectorMath.cross2 = function(x, y, z)
	return y * z, -x * z
end

vectorMath.cross22 = function(x1, y1, x2, y2)
	return x1 * y2 - y1 * x2
end

vectorMath.dot2 = function(x1, y1, x2, y2)
	return x1 * x2 + y1 * y2
end

vectorMath.normalize2 = function(x, y)
	local length = math.sqrt(vectorMath.dot2(x, y, x, y))
	return x / length, y / length
end
	

vectorMath.xFormMultiply = function(formX, formY, formCX1, formCY1, formCX2, formCY2, x, y)

	local newX = formCX1 * x + formCX2 * y
	local newY = formCY1 * x + formCY2 * y

	return newX + formX, newY + formY
end

vectorMath.xFormInvert = function(formX, formY, formCX1, formCY1, formCX2, formCY2, x, y)

	x = x - formX
	y = y - formY

	local d = formCX1 * formCY2 - formCY1 * formCX2

	local oldX = (formCY2 * x - formCX2 * y) / d
	local oldY = (formCX1 * y - formCY1 * x) / d

	return oldX, oldY
end

vectorMath.pointToLineSquareDistance = function(x, y, x1, y1, x2, y2)

	-- get vector from start to test point and to end
	local px, py = x - x1, y - y1
	local vx, vy = x2 - x1, y2 - y1

	-- also get vectors from the other end, to see if the test point is between
	local px2, py2 = x - x2, y - y2
	local vx2, vy2 = x1 - x2, y1 - y2

	-- the dots between these vectors must have equal signs
	local dot1 = vectorMath.dot2(px, py, vx, vy)
	local dot2 = vectorMath.dot2(px2, py2, vx2, vy2)
	if (dot1 < 0 and dot2 > 0) or (dot1 > 0 and dot2 < 0) then
		-- return the distance to the closest end point
		local dist1 = px * px + py * py
		local dist2 = px2 * px2 + py2 * py2
		if dist1 < dist2 then
			return dist1
		end
		return dist2
	end


	-- project the test vector on the line vector, and calculate rejection
	local scale = dot1 / (vx*vx + vy*vy)
	local nx, ny = vx * scale - px, vy * scale - py

	return nx * nx + ny * ny
end

vectorMath.rotate = function(x, y, angle)

	local real = math.cos(angle)
	local im = math.sin(angle)
	
	return x * real - y * im, y * real + x * im
end


vectorMath.project = function(ax, ay, bx, by)

	local scale = vectorMath.dot2(ax, ay, bx, by) / vectorMath.dot2(bx, by, bx, by)
	return bx * scale, by * scale
	
end
