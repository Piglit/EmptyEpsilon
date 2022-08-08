-- Name: Enter Station
-- Description: This scenario simulates the entry door to our space station escape room.
-- Type: Basic

function init()
    -- Spawn a player Atlantis.
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(1000,0):setRotation(0)
    station = SpaceStation():setTemplate('Medium Station'):setRotation(0):setFaction("Human Navy")
	station:setDescription("A space station of medium size. The heat and energy signatures are very low, it may be powered down.", "This science station seems to be powered down since several days. The stations profile shows it as exobiology research station. Energy and heat signatures are low: enough for rudimentary life-support, but not enough to host the several working humans that are listed as crew.") -- unscanned, scanned
-- TODO this is what a player should tell. present as scanner readings
-- Key Values: Human Crew: 3 Obligation: exobiology research (is Obligation the right word?) System last accessed by Operator 56 hours ago. Automated emergengy lock-in system: active. Automated docking system: active. Escape pods remaining: 0/0, laboratory: offline, bridge: offline, storage: offline, ...

    station:sendCommsMessage(player, "This is an automated emergency signal from station Hydra. Life-Support system failure imminent. Human operator is unresponsive. Please send help.")
