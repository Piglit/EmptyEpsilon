map_shattered = {
	moving_debris = {},
	ground = nil,
	flight_control = nil,
	gm_dummy = nil,
    sectors = {},	-- contains sectors containing asteroid positions
	probes = {},	-- all probes, fired from player ships
}

function map_shattered:init()
    local orbit=35000
    local radius=12300
 
    -- create system
    self.planet = Planet():setPosition(0, 0):setPlanetRadius(radius):setDistanceFromMovementPlane(-3000):setPlanetSurfaceTexture("planets/planet-4-hd.png"):setPlanetCloudTexture("planets/clouds-2-hd.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.0,0.5,0.5):setDescriptions(_("Endor"),_("Forest Moon of Endor")):setCallSign(_("Endor")):setFaction("Environment")

    Planet():setPosition(-5000, 2.5*orbit):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)

    self.atmo = Zone():setColor(0,0,128)
    local zx = {}
    local zy = {}
    for i=0,15 do
        local x,y = vectorFromAngle(i*360/16, 20000)
        table.insert(zx, x)
        table.insert(zy, y)
    end
    self.atmo:setPoints(
        zx[1], zy[1],
        zx[2], zy[2],
        zx[3], zy[3],
        zx[4], zy[4],
        zx[5], zy[5],
        zx[6], zy[6],
        zx[7], zy[7],
        zx[8], zy[8],
        zx[9], zy[9],
        zx[10], zy[10],
        zx[11], zy[11],
        zx[12], zy[12],
        zx[13], zy[13],
        zx[14], zy[14],
        zx[15], zy[15],
        zx[16], zy[16]
    )

    -- create stations and global accessible ships
    self.flight_control = PlayerSpaceship():setTemplate("NavSat"):setCallSign("FC-03"):setFaction("Endor"):setPosition(3000, -30000)
    self.flight_control:setDescription(_("A navigation satellite - the all-seeing eye of Tantal-3 flight control."))
    self.flight_control:setLongRangeRadarRange(60000):setRotation(-90):commandTargetRotation(-90):setCanScan(false)

    self.buoy = CpuShip():setTemplate("NavSat"):setCallSign(_("Green Buoy")):setFaction("Endor"):setPosition(-400, -20000)
    self.buoy:setDescription(_("A navigation buoy that marks the line between atmosphere and space."))
    self.buoy:setRotation(-90):orderIdle():setScanned(true):setCommsFunction(nil):setCanBeDestroyed(false)
    self.buoy2 = CpuShip():setTemplate("NavSat"):setCallSign(_("Red Buoy")):setFaction("Endor"):setPosition(zx[14], zy[14])
    self.buoy2:setDescription(_("A navigation buoy that marks the line between atmosphere and space."))
    self.buoy2:setRotation(-90):orderIdle():setScanned(true):setCommsFunction(nil):setCanBeDestroyed(false)
    self.buoy3 = CpuShip():setTemplate("NavSat"):setCallSign(_("Magenta Bouy")):setFaction("Endor"):setPosition(zx[12], zy[12])
    self.buoy3:setDescription(_("A navigation buoy that marks the line between atmosphere and space."))
    self.buoy3:setRotation(-90):orderIdle():setScanned(true):setCommsFunction(nil):setCanBeDestroyed(false)

    self.gm_dummy = CpuShip():setTemplate("NavSat"):setCallSign(_("Tantal Observatory")):setFaction("Endor"):setPosition(9999999,9999999):orderIdle():setCommsFunction(nil)

    self.ground=SpaceStation():setTemplate("Medium Station"):setFaction("Endor"):setCallSign("Tantal-3"):setPosition(0, -radius-1300)
    self.ground:setDescription(_("A ground station on Endor. It has a spaceport."))
    self.ground:setRotation(-90)

    self.freighter_imp=CpuShip():setTemplate(" Action IV"):setFaction("Imperial"):setCallSign("Glory-1"):setPosition(33064, -2*orbit):setDescription(_("A long haul freighter")):setScanState(SS_SIMPLE_SCAN)
    self.freighter_nr=CpuShip():setTemplate(" Action IV"):setFaction("New Republic"):setCallSign("Pioneer-7"):setPosition(-2*orbit, -33064):setDescription(_("A long haul freighter")):setScanState(SS_SIMPLE_SCAN)
    self.freighter_cd=CpuShip():setTemplate(" Action IV"):setFaction("Crimson Dawn"):setCallSign("Serpent-3"):setPosition(33064, 2*orbit):setDescription(_("A long haul freighter")):setScanState(SS_SIMPLE_SCAN)

    -- place escort fighters for the freighters
    local px,py = self.freighter_nr:getPosition()
    CpuShip():setFaction("New Republic"):setTemplate("X-Wing"):setPosition(px+3000,py):orderDefendTarget(self.freighter_nr):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate("X-Wing"):setPosition(px-3000,py):orderDefendTarget(self.freighter_nr):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate("BTL-A4 Y-Wing"):setPosition(px,py-3000):orderDefendTarget(self.freighter_nr):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate("BTL-B Y-Wing"):setPosition(px,py+3000):orderDefendTarget(self.freighter_nr):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    px,py = self.freighter_imp:getPosition()
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(px+3000,py):orderDefendTarget(self.freighter_imp):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(px-3000,py):orderDefendTarget(self.freighter_imp):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Bomber"):setPosition(px,py-3000):orderDefendTarget(self.freighter_imp):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Interceptor"):setPosition(px,py+3000):orderDefendTarget(self.freighter_imp):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    px,py = self.freighter_cd:getPosition()
    CpuShip():setFaction("Crimson Dawn"):setTemplate(" A-24"):setPosition(px+3000,py):orderDefendTarget(self.freighter_cd)
    CpuShip():setFaction("Crimson Dawn"):setTemplate(" G9"):setPosition(px-3000,py):orderDefendTarget(self.freighter_cd)
    CpuShip():setFaction("Crimson Dawn"):setTemplate(" YV-929"):setPosition(px,py-3000):orderDefendTarget(self.freighter_cd)

    -- place asteroids and satellites
    px,py = self.planet:getPosition()
    self:addPositionsAroundPoint(Asteroid,3000,orbit+radius,2*orbit+radius,px,py)
    self:addPositionsAroundPoint(VisualAsteroid,1000,orbit+radius,2*orbit+radius+5000,px,py)
    self:addPositionsAroundPoint(Asteroid,50,16000,orbit+radius,px,py)
    self:placeArtifactsAroundPoint (16,orbit+radius,orbit+radius+500,px,py, true)    -- broken ones
    self:placeArtifactsAroundPoint (16,orbit+radius,orbit+radius+500,px,py, false)   -- working ones
    for dist=orbit+radius+8000,2*orbit,500 do
        px,py = vectorFromAngle(random(0,360), dist)
        self:addPositionsAroundPoint(Asteroid,50,1000,5000,px,py)
    end
    px,py = self.freighter_nr:getPosition()
    self:addPositionsAroundPoint(Asteroid,50,4000,8000,px,py)
    px,py = self.freighter_imp:getPosition()
    self:addPositionsAroundPoint(Asteroid,50,4000,8000,px,py)
    px,py = self.freighter_cd:getPosition()
    self:addPositionsAroundPoint(Asteroid,50,4000,8000,px,py)
    self:createMovingDebris(20, 0, 2*orbit, 5000)

    -- set database entry
    mission_data = ScienceDatabase():setName(_('Mission data'))
    item = mission_data:addEntry(_('Kessler Syndrome'))
    item:setLongDescription(_([[The Kessler Syndrome is a no longer theoretical Scenario. It describes the situation where the density of objects a planet's orbit is high enough to cause a chain reaction of collisions. Each collision will create a huge debris field of multiple objects, and many of them will collide with other objects. Ultimately, the Orbit will be full of tiny objects destroying satellites and making space flight very hard, if not impossible. Also, much of our daily life depends on satellites, like communication and navigation. The Kessler Syndrome is a serious threat to all of this. This is why clearing space debris, and preventing that kind of scenario is extremely important.
]]))
    item:setImage("kessler_syndrome.png")
end

function map_shattered:addPositionsAroundPoint(type, amount, dist_min, dist_max, x0, y0)
    for n = 1, amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
		local sector = getSectorName(x,y)
		if self.sectors[sector] == nil then
			self.sectors[sector] = {
				shown = false
			}
		end
        table.insert(self.sectors[sector], {x, y, type})
    end
end

function map_shattered:showAsteroidsInSector(sectorName, show)
	local positions = self.sectors[sectorName]
	if positions == nil then
		return
	end
	if show and positions.shown == false then
		positions.shown = true
		for i, position in ipairs(positions) do
			local x,y,type = table.unpack(position)
			positions[i] = type():setPosition(x,y)
		end
	elseif show == false and positions.shown then
		local new_positions = {
			shown = false
		}
		for i=1, #positions do
			asteroid = positions[i]
			if asteroid:isValid() then
				local x,y = asteroid:getPosition()
				local type = asteroid.typeName
				if type == "Asteroid" then
					type = Asteroid
				elseif type == "VisualAsteroid" then
					type = VisualAsteroid
				else
					assert(false, "Type not implemented")
				end
				table.insert(new_positions, {x, y, type})
				asteroid:destroy()
			end
		end
		self.sectors[sectorName] = new_positions
	end
end
--[[ -- Those only work when update does not overwrite em
function map_shattered.showAsteroids()
	self = map_shattered
	for sector, positions in pairs(self.sectors) do
		self:showAsteroidsInSector(sector, true)
	end
end
function map_shattered.hideAsteroids()
	self = map_shattered
	for sector, positions in pairs(self.sectors) do
		self:showAsteroidsInSector(sector, false)
	end
end
--]]
function map_shattered:gm_menu()
    addGMFunction(_("buttonGM", "Spawn moving debris"), map_shattered.triggerMovingDebris)
    addGMFunction(_("buttonGM", "Clear moving debris"), map_shattered.clearMovingDebris)
--    addGMFunction(_("buttonGM", "Show Asteroids"), map_shattered.showAsteroids)
--    addGMFunction(_("buttonGM", "Hide Asteroids"), map_shattered.hideAsteroids)
end

function map_shattered:onProbeLaunch(ship, probe)
	arrayFilter(self.probes,
		function(obj)
			return obj:isValid()
		end
	)
	table.insert(self.probes, probe)
end

function map_shattered:updateAsteroidVisibility()
	for sectorName, sector in pairs(self.sectors) do
		sector.showNext = false
	end
	for _, ship in ipairs(getActivePlayerShips()) do
		local vision_dist = ship:getLongRangeRadarRange()
		local x,y = ship:getPosition()
		for s_x = x - vision_dist, x + vision_dist, 20000 do
			for s_y = y - vision_dist, y + vision_dist, 20000 do
				local d_x = (s_x - x) / 20000
				local d_y = (s_y - y) / 20000
				local d_v = math.ceil(vision_dist / 20000) +1
				if d_x * d_x + d_y * d_y <= d_v * d_v then	-- optimization for large ranges
					local sectorName = getSectorName(s_x, s_y)
					if self.sectors[sectorName] ~= nil then
						self.sectors[sectorName].showNext = true
					end
				end
			end
		end
	end
	for _, probe in ipairs(self.probes) do
		if probe:isValid() then
			local x,y = probe:getPosition()
			local vision_dist = 5000
			for _, s_x in ipairs({x - vision_dist, x + vision_dist}) do
				for _, s_y in ipairs({y - vision_dist, y + vision_dist}) do
					local sectorName = getSectorName(s_x, s_y)
					if self.sectors[sectorName] ~= nil then
						self.sectors[sectorName].showNext = true
					end
				end
			end
		end
	end
	for sectorName, sector in pairs(self.sectors) do
		self:showAsteroidsInSector(sectorName, sector.showNext)
	end

end

function map_shattered:update(delta)
	self:moveDebris(delta)
	self:updateAsteroidVisibility()
end


function map_shattered:createMovingDebris(amount, px, py, rad)
    local objs = placeRandomAroundPoint(Asteroid,amount,0,rad,-px,-py)
    for i,o in ipairs(objs) do
        o.speed = random(0.2, 1.0)
        o.angle = angleRotation(o, self.planet)
        o.distance = distance(o, self.planet)
        o:setSize(50)
        table.insert(self.moving_debris, o)
    end
end

function map_shattered:moveDebris(delta)
    local px, py = self.planet:getPosition()
	local moving_debris = self.moving_debris
    for i=1,#moving_debris do
        local ta = moving_debris[i]
        if ta ~= nil and ta:isValid() then
            ta.angle = ta.angle + ta.speed * delta
            if ta.angle >= 360 then 
                ta.angle = 0
            end
            local pmx, pmy = vectorFromAngle(ta.angle, ta.distance)
            ta:setPosition(px+pmx,py+pmy)
        end
    end
end

function map_shattered.triggerMovingDebris()
    onGMClick(function(x,y) 
        onGMClick(nil)
        map_shattered:createMovingDebris(10, x, y, 1000)
    end)
end

function map_shattered.clearMovingDebris()
    for _, obj in ipairs(map_shattered.moving_debris) do
		if obj ~= nil and obj:isValid() then
			obj:destroy()
		end
	end
	map_shattered.moving_debris = {}
end

function map_shattered:placeArtifactsAroundPoint( amount, dist_min, dist_max, x0, y0, broken)
    local callsign_counter =1000
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance

        if broken then
            local freq = math.floor(random(20, 40)) * 20
            callsign_counter = callsign_counter + math.floor(random(1,200))
            local callsign = callsign_counter
            debris = Artifact():setPosition(x, y):setDescriptions(_("A piece of space junk. Scan to find out the capturing frequency"), _("Capturing frequency:").." "..freq):setScanningParameters(1, 2)
            debris.freq=freq
            if freq < 595 then
                debris:setModel("debris-cubesat")
            else
                debris:setModel("debris-blob")
            end
            debris:allowPickup(true)
            debris:setCallSign(callsign):setFaction("Endor"):setRadarTraceIcon("asteroid.png"):setRadarTraceColor(64,64,150)

            debris:onPickUp(function(art, player)
                shieldfreq= 400+(player:getShieldsFrequency())*20
                local ax, ay = art:getPosition()
                local x, y = player:getPosition()
                if shieldfreq == art.freq and player:getShieldsActive() == true then
                    ElectricExplosionEffect():setPosition(x,y):setSize(200)
                    player:takeDamage(1, "kinetic",ax,ay )
                    player:addReputationPoints(10)
					player:addToShipLog(_("Debris captured."), "cyan")
                else
                    ExplosionEffect():setPosition(ax,ay):setSize(200)
                    player:takeDamage(50, "kinetic",ax,ay )
					player:addToShipLog(_("Debris was destroyed by impact"), "red")
                end
            end)

        else
            callsign="TTY"..string.format("%02d",n)
            sat = Artifact():setPosition(x, y):setDescriptions(_("An operational satellite"),_("This satellite is fully operational. Do not capture!")):setScanningParameters(1, 2)
            sat:setModel("cubesat"):setCallSign(callsign):setRadarTraceIcon("satellite.png"):setRadarTraceScale(1)
            sat:allowPickup(true)

            sat:onPickUp(function(art, player)
                local ax, ay = art:getPosition()
                local x, y = player:getPosition()
                ExplosionEffect():setPosition(ax,ay):setSize(200)
                player:takeDamage(50, "kinetic",ax,ay )
                player:setReputationPoints((player:getReputationPoints()-10))
				player:addToShipLog(_("Satellite was destroyed by impact"), "red")
            end)
        end
    end
end

