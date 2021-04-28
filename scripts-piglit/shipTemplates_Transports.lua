--[[----------------------Freighters----------------------]]

for cnt=1,5 do
    template = ShipTemplate():setName("Personnel Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_1_" .. cnt)
    template:setDescription([[These freighters are designed to transport armed troops, military support personnel, and combat gear.]])
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Personnel Jump Freighter " .. cnt)
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName("Goods Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_2_" .. cnt)
    template:setDescription([[Cargo freighters haul large loads of cargo across long distances on impulse power. Their cargo bays include climate control and stabilization systems that keep the cargo in good condition.]])
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Goods Jump Freighter " .. cnt)
        variation:setJumpDrive(true)
    end
    
    template = ShipTemplate():setName("Garbage Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_3_" .. cnt)
    template:setDescription([[These freighters are specially designed to haul garbage and waste. They are fitted with a trash compactor and fewer stabilzation systems than cargo freighters.]])
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Garbage Jump Freighter " .. cnt)
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName("Equipment Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_4_" .. cnt)
    template:setDescription([[Equipment freighters have specialized environmental and stabilization systems to safely carry delicate machinery and complex instruments.]])
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Equipment Jump Freighter " .. cnt)
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName("Fuel Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_5_" .. cnt)
    template:setDescription([[Fuel freighters have massive tanks for hauling fuel, and delicate internal sensors that watch for any changes to their cargo's potentially volatile state.]])
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Fuel Jump Freighter " .. cnt)
        variation:setJumpDrive(true)
    end
end

