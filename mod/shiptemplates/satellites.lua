template = ShipTemplate():setName("ANT 615"):setLocaleName(_("ship", "ANT 615")):setModel("combatsat"):setClass(_("class", "Droid"),_("subclass", "Sentinel Droid"))
template:setDescription(_("Military droid from the old days, back when there was a huge battle station in the system. Its original purpose was probably to take out other droids."))
template:setRadarTrace("probe_droid.png")
--                 Arc,Dir,Range,CycleTime, Dmg
template:setBeam(0, 15, 5, 990.0, 4.0, 2)
template:setBeam(1, 15,-5, 1000.0, 4.0, 2)

template:setHull(30)
--template:setShields(30)
template:setSpeed(120, 30, 25)

var = template:copy("Debris")
var:setLocaleName(_("ship", "ANT 615")):setModel("debris-blob"):setClass(_("class", "Debris"),_("subclass", ""))
var:setDescription(_("Space debris floating around"))
var:setRadarTrace("probe.png")
var:setHull(8)
var:setSpeed(120, 30, 25)

