-- breaking wormhole mechanics

vf_wormhole_instable = {}

function vf_wormhole_instable.onTeleportation(wh, ship)
	self = vf_wormhole_instable
	if wh.transits == nil then
		wh.transits = 0
	end
	if ship.typeName == "PlayerSpaceship" then
		wh.transits = wh.transits +1
		vf_wormhole_instable:effects(math.random(1,wh.transits), wh, ship)
	end
end

function vf_wormhole_instable:effects(number, wh, ship)
	for i=1,number do
		local effect = math.random(1, 3)
		log(effect)
		if effect == 1 then
			-- shields/system damage
			local x,y = ship:getPosition()
			ship:takeDamage(50, "emp", x,y)
		elseif effect == 2 then
			-- missjump to any other wh destination
			local other_wh = tableSelectRandom(TerrainModuleWormHoles.all_wormholes)
			if other_wh:isValid() then
				local x,y = other_wh:getTargetPosition()
				ship:setPosition(x,y)
			end	-- otherwise just skip it
		elseif effect == 3 then
			-- invert wormhole
			local x0,y0 = wh:getPosition()
			local x1,y1 = wh:getTargetPosition()
			x0, y0 = radialPosition(x0, y0, 5000, random(0, 360))
			x1, y1 = radialPosition(x1, y1, 5000, random(0, 360))
			wh:setPosition(x1,y1)
			wh:setTargetPosition(x0,y0)
		end
	end
	ship:addToShipLog("Wormhole instability detected. Using it is no longer adviced.", "red")
end
