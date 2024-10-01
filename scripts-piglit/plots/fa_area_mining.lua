fa_area_mining = {}

function fa_area_mining:init(center_x, center_y)
	self.center_x = center_x
	self.center_y = center_y
	clothoide()	
	return self
end

function factorial(n)
	if (n == 0) then
		return 1
	else
		return n * factorial(n-1)
	end
end

function clothoide()
	-- uses A = 1 and taylor
	-- L: length
	L = 10000
	PI = 2.5--3--.1415
	amount = 200
	for t = -PI/2,PI/2,PI/amount do
		x=0
		y=0
		for i = 0,32 do
			x = x + ( (-1)^i * t^(4*i+1) ) / ( factorial(2*i) * (4*i+1) )
			y = y + ( (-1)^i * t^(4*i+3) ) / ( factorial(2*i+1) * (4*i+3) )
		end
--		x = L * (1 - T^2 / (factorial(2)*5) + T^4 / (factorial(4)*9) - T^6 / (factorial(6)*13))
--		y = L * (T/3 - T^3 / (factorial(3)*7) + T^5 / (factorial(5)*11) - T^7 / (factorial(7)*15))
		Asteroid():setPosition(x*L*random(0.8,1.2),y*L*random(0.8,1.2))
	end
end
