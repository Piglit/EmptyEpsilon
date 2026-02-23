-- nebulae mechanic
-- Gain or lose coolant from nebula
vf_nebulae = {
	coolant_nebula = {},
	adverseEffect = 0.9,
}

function vf_nebulae:addNebulaEffect(nebula, effect)
	assert(effect ~= nil and type(effect) == "number" and effect ~= 0)
	assert(effect > -1.0)
	assert(effect < 1.0)
	if effect > 0 then
		-- effect is added to current cooling once per second
		-- adverseEffect is by chance multiplied with system health (-> [0,1])
		-- 0.1 adds 1 coolant every 10 sec
		-- and adds 10% system damage sometimes
		nebula.gain = effect
		nebula.adverseEffect = effect	-- the faster the coolant gain, the stronger the damage
	elseif effect < 0 then
		-- inverse of effect is substracted from current cooling once per second
		-- -0.1 costs 1 coolant every 10 sec
		nebula.lose = -effect
	end
	table.insert(self.coolant_nebula, nebula)
	--log("add nebula effect "..tostring(effect).." - "..tostring(nebula:getRadius()))
end

function vf_nebulae:coolantNebulae(delta, p)
	local inside_gain_coolant_nebula = false
	local inside_drain_coolant_nebula = false
	for _, nebula in ipairs(self.coolant_nebula) do
		if distance(p,nebula) < nebula:getRadius() then
			if nebula.lose then
				inside_drain_coolant_nebula = true
				p:setMaxCoolant(p:getMaxCoolant() - (nebula.lose*delta))
				if not p.losing_coolant then
					customElements:addCustomInfo(p, "Engineering","losing_coolant","Coolant loss detected")
					p.losing_coolant = true
				end
			end
			if nebula.gain then
				if p.gathering_coolant then
					-- can collect from multiple overlapping nebulae
					self:updateCoolantGivenPlayer(p, nebula, delta)
				end
				inside_gain_coolant_nebula = true
			end
		end
	end
	if not inside_drain_coolant_nebula and p.losing_coolant then
		customElements:removeCustom(p,"losing_coolant")
		p.losing_coolant = false
	end
	if inside_gain_coolant_nebula then
		if p.get_coolant then
			if p.coolant_trigger then
				self:updateCoolantStatus(p, delta)
				if not p.stop_coolant then
					customElements:addCustomButton(p, "Engineering", "stop_coolant_button", "Stop collecting Coolant",function()
						customElements:removeCustom(p, "stop_coolant_button")
						customElements:removeCustom(p, "gather_coolant")
						p.get_coolant = false
						p.coolant_trigger = false
						p.stop_coolant = false
						p.configure_coolant_timer = nil
						p.deploy_coolant_timer = nil
						p.gathering_coolant = false
					end)
					p.stop_coolant = true
				end
			end
		else
			customElements:addCustomButton(p, "Engineering", "get_coolant_button", "Get Coolant",function()
				customElements:removeCustom(p, "get_coolant_button")
				p.coolant_trigger = true
				p.stop_coolant = false
			end)
			p.get_coolant = true
		end
	else
		p.get_coolant = false
		p.coolant_trigger = false
		p.stop_coolant = false
		p.configure_coolant_timer = nil
		p.deploy_coolant_timer = nil
		p.gathering_coolant = false
		customElements:removeCustom(p,"get_coolant_button")
		customElements:removeCustom(p,"gather_coolant")
		customElements:removeCustom(p,"stop_coolant_button")
	end
end

function vf_nebulae:updateCoolantStatus(p, delta)
	if p.configure_coolant_timer == nil then
		p.configure_coolant_timer = delta + 5
	end
	p.configure_coolant_timer = p.configure_coolant_timer - delta
	if p.configure_coolant_timer < 0 then
		if p.deploy_coolant_timer == nil then
			p.deploy_coolant_timer = delta + 5
		end
		p.deploy_coolant_timer = p.deploy_coolant_timer - delta
		if p.deploy_coolant_timer < 0 then
			gather_coolant_status = "Gathering Coolant" 
			p.gathering_coolant = true

		else
			gather_coolant_status = string.format("Deploying Collectors %i",math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format("Configuring Collectors %i",math.ceil(p.configure_coolant_timer - delta))
	end
	customElements:addCustomInfo(p, "Engineering","gather_coolant",gather_coolant_status)
end

function vf_nebulae:updateCoolantGivenPlayer(p, nebula, delta)
	p:setMaxCoolant(p:getMaxCoolant() + nebula.gain*delta)
	-- Slowly shrink the nebula
	local r = nebula:getRadius() 
	nebula:setRadius(r- 100*nebula.gain*delta)
	if random(10, 110) > p:getMaxCoolant() then
		-- each coolant point adds 1% to the failure change each tick
		local engine_choice = arraySelectRandom({"impulse", "warp", "jumpdrive"})
		local current = p:getSystemHealth(engine_choice)
		if current > 0 then
			log(current, nebula.adverseEffect)
			current = current *(1-nebula.adverseEffect*delta)
			p:setSystemHealth(engine_choice,current)
		end
	end
	if r < 100 then
		nebula:destroy()
	end
end

function vf_nebulae:update(delta)
	-- remove deleted
	arrayFilter(self.coolant_nebula, function(obj) 
		return obj ~= nil and obj:isValid()
	end)
end

function vf_nebulae:updatePlayerShip(delta, ship)
	vf_nebulae:coolantNebulae(delta, ship)
end
