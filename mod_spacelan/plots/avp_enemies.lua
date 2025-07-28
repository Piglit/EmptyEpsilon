avp_enemies = {}

function avp_enemies:spawn(positions)
	for _,pos in ipairs(positions) do
		local ship = CpuShip():setTemplate("Deathbringer"):setFaction("Kraylor"):setPosition(pos[1], pos[2])
	end
end
