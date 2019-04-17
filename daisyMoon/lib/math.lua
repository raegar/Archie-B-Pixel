---------- ---------- ---------- ---------- ---------- 
-- Name: math.angleBetweenPoints( X1, Y1, X2, Y2 )
-- Desc: Angle between two points
---------- ---------- ---------- ---------- ---------- 
function math.angleBetweenPoints( X1, Y1, X2, Y2 )
	local dx = X2-X1
	local dy = Y2-Y1
	
	return math.atan2(dy, dx)
end
---------- ---------- ---------- ---------- ---------- 
-- Name: math.Distance( X1, Y1, X2, Y2 )
-- Desc: Distance between two points
---------- ---------- ---------- ---------- ---------- 
function math.distance( X1, Y1, X2, Y2 )
	local XD = X2 - X1
	local YD = Y2 - Y1
	
	return math.sqrt( XD*XD + YD*YD )
end

---------- ---------- ---------- ---------- ---------- 
-- Name: math.distance2( X1, Y1, X2, Y2 )
-- Desc: Squared distance between two points (faster)
---------- ---------- ---------- ---------- ---------- 
function math.distance2( X1, Y1, X2, Y2 )
	local XD = X2 - X1
	local YD = Y2 - Y1
	
	return ( XD*XD + YD*YD )
end

---------- ---------- ---------- ---------- ---------- 
-- Name: math.Clamp( Value, Min, Max )
-- Desc: Clamps value between 2 values
---------- ---------- ---------- ---------- ---------- 
function math.clamp( Value, Min, Max )
	if ( Value < Min ) then return Min end
	if ( Value > Max ) then return Max end
	
	return Value
end

---------- ---------- ---------- ---------- ---------- 
-- Name: math.Rand( Low, High )
-- Desc: Random real number between low and high
---------- ---------- ---------- ---------- ---------- 
function math.rand( Low, High )
	return Low + ( math.random() * ( High - Low ) )
end

---------- ---------- ---------- ---------- ---------- 
-- Name: math.Round( Value [, Digits] )
-- Desc: Rounds any real number to the nearest multiple of the variable 'digits'
-- Examples: 
-- 	math.Round(1.23, 0.1)
-- 	returns 1.2 (round to one decimal)
--
-- 	math.Round(345678, 1000)
-- 	returns 346000 (round to nearest thousand)
---------- ---------- ---------- ---------- ---------- 
function math.round( Value, Digits )
	Digits = Digits or 1
	local Remainder = Value % Digits
	
	if ( Remainder / Digits < 0.5 ) then
		return Value - Remainder
	else
		return Value - Remainder + Digits
	end
end

---------- ---------- ---------- ---------- ---------- 
-- Name: math.Approach( Cur, Target, Inc )
-- Desc: Increment Cur using number Inc until it reaches Target
---------- ---------- ---------- ---------- ---------- 
function math.approach( Cur, Target, Inc )
	Inc = math.abs( Inc )
	
	if ( Cur < Target ) then
		return math.clamp( Cur + Inc, Cur, Target )
	else
		return math.clamp( Cur - Inc, Target, Cur )
 	end
	
 	return Target
end

---------- ---------- ---------- ---------- ---------- 
-- Name: math.NormalizeAngle( Ang )
-- Desc: Converts an angle to -179 to 180 representation
---------- ---------- ---------- ---------- ---------- 
function math.normalizeAngle( Ang )
	while ( Ang < 0 ) do
		Ang = Ang + math.pi*2
	end
	
	while ( Ang >= math.pi*2 ) do
		Ang = Ang - math.pi*2
	end
	
	if ( Ang > math.pi) then
		return Ang - math.pi*2
	end
	
	return Ang
end

---------- ---------- ---------- ---------- ---------- 
-- Name: math.AngleDifference( Ang1, Ang2 )
-- Desc: Difference between two angles
---------- ---------- ---------- ---------- ---------- 
function math.angleDifference( Ang1, Ang2 )
	local Diff = math.normalizeAngle( Ang1 - Ang2 )
	
	if ( Diff < math.pi ) then
		return Diff
	end
	
	return Diff - math.pi*2
end


function math.angleDifferenceAbs( Ang1, Ang2 )
	local Diff = math.normalizeAngle( Ang1 - Ang2 )
	
	if ( Diff < math.pi ) then
		return  math.abs( Diff )
	end
	
	return math.abs(Diff - math.pi*2)
end


---------- ---------- ---------- ---------- ---------- 
-- Name: math.ApproachAngle( Cur, Target, Inc )
-- Desc: Increment angle Cur using number Inc until it reaches angle Target
---------- ---------- ---------- ---------- ---------- 
function math.approachAngle( Cur, Target, Inc )
	local Diff = math.angleDifference( Target, Cur )
	
	return math.approach( Cur, Cur + Diff, Inc )
end


---------- ---------- ---------- ---------- ---------- 
-- Name: math.safeRandom(smallest, largest)
-- Desc: Use this when the random value doesn't need to be synchronous (for example, in rendering)
---------- ---------- ---------- ---------- ---------- 
local safeSeed = os.time()
function math.safeRandom(a, b)

	safeSeed = 40692 * (safeSeed % 52774) - 3791 * math.floor(safeSeed / 52774)
	if safeSeed <= 0 then
		safeSeed = safeSeed + 2147483399
	end
	
	if a then
		if b then
			if  b > a then
				return a + (safeSeed % (b - a))
			else
				return a
			end
		else
			return 1 + (safeSeed % a)
		end
	else
		return (safeSeed % 2147483399) / 2147483399
	end
end

function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

