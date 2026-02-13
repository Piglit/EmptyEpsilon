-- Name: Exfiltration
-- Description: Exfiltrate an ISB-Agent from an enemy ship
-- Type: Larp

TEST = false
require("utils.lua")
require("plot_manager.lua")
require("utils_customElements.lua")

function init()
	-- collection of scripts from different sources for the plot_manager
	plot_manager:init({
		"gravity_util",
		"map_ice_planet",
		"map_ambush",
		"rescue_capsule_util",
		"proximity_scan",
		"script_hangar",
		"fighter_utils",
		{"exfil", ss_exfil},	-- from this file
	})
end

SYSTEMS = {
	"reactor",
	"beamweapons",
	"missilesystem",
	"maneuver",
	"impulse",
	"warp",
	"jumpdrive",
	"frontshield",
	"rearshield",
	"sensors",
	"communication",
	"hangar",
	"bridge",
	"airlock",
}
ss_exfil = {}

--[[ Scenario plot:
Design Goal:
* Communication between carrier and sqadron.
* Full crew experience

Mission:
* QoW takes fighters from station onboard
* QoW explores target area
* QoW jumps to target area
* Enemy starts launching fighters and decoy
* Fighter vs. Fighter; QoW may help
* Enemy is powerful on front
* Work together to blast shields on one side open and unlock airlock
* ISB exits from airlock
* Fighter captures ISB, returns them to QoW
* QoW returns to station

ISB - view:
* Engineering of enemy ship / Cockpit of rescue pod
* Eject Buttion in Engi View + Info if eject is possible
* When shields down and trying to eject: surprise - need a hit on airlock to unlock
* when airlock hit: eject and "switch" to pilot view
Technical: 
* ISB is ship somewhere hidden. Same model as target.
* target shields/hull/system health is transferred to ISB.
* Info and custom buttons shown
* cockpit view is blocked by sth. technical, like stations.
* no movement possible.
* On Eject: switch ship to new ISB-Pilot, at breach pos
* med velocity escape speed
--]]
function ss_exfil:init()

	self.state = 0
	-- imperial forces:
	local x,y = 20000, -5000
	local station = map_ice_planet.station_high
	local carrier = PlayerSpaceship():setTemplate("Gozanti Mk Ic"):setCallSign("QoW"):setDescription("Queen of Watch"):setFaction("Imperial"):setCanBeDestroyed(false):setJumpDrive(true):setPosition(x+5000, y)
	station:sendCommsMessage(carrier, _([[Missionsziel:
Das Crimson Dawn Vergnügungsschiff "The Sanguine Soirée" durchquert diesen Sektor nahe Wegpunkt 1.
Die Queen of Watch nimmt eine Staffel Jäger auf, um einen ISB-Agent aus diesem Schiff zu exfiltieren.]]))
	carrier:commandAddWaypoint(x,y+25000)

	-- TIEs
	for i=1,fighter_utils.number_of_rhos do
		local rho = fighter_utils:createRho(i)
		fighter_utils:placeFighterInCarrier(rho, station, i)	-- misleading: station is the carrier here!
	end

	-- target
	local x,y = 20000-7500, 26000
	local target = CpuShip():setTemplate("Pheasant"):setPosition(x,y):orderDefendLocation(x,y):setFaction("Crimson Dawn"):setCallSign("TSS"):setDescription("The Sanguine Soirée"):setCanBeDestroyed(false):setShieldsMax(100, 100, 100, 100):setShields(100, 100, 100, 100)
	script_hangar:create(target, "Matron", 1)
	script_hangar:append(target, "Widow", 2)
	script_hangar:append(target, "Goldfinch", 3)
	script_hangar:config(target, "cooldownMax", 18.0)
	script_hangar:config(target, "arc", 270)
	self.target = target
	
	customElements:modifyOperatorPositions("Engineering", {"Engineering", "Engineering+", "DamageControl"})
	self.isb = PlayerSpaceship():setTemplate("Pheasant"):setFaction("Independent"):setPosition(-999999,-999999):setCanBeDestroyed(false):setCallSign("ISB")
--	customElements:addCustomButton(self.isb, "Engineering", "EJECT_BUTTON", _("Luftschleuse öffnen"), function()
--		local breach_shield_level = ss_exfil.target:getShieldLevel(1)
--		customElements:addCustomInfo(ss_exfil.isb, "Engineering", "EJECT_INFO", string.format(_("Schleuse blockiert: Schilde aktiv (%i)%%"), math.ceil(breach_shield_level)), 2)
--	end,51)


end

function ss_exfil:isbEscapes()
	if self.state >= 5 then
		return
	end
	self.state = 5
	removeGMFunction("ISB escape")
	local x,y = self.target:getPosition()
	local pod = rescue_capsule_util.spawnNewPilotPod(x,y)
	local dir = 90
	dir = self.target:getRotation() + dir
	setCirclePos(pod, x,y, dir, 200)
	pod:setRotation(dir+180)
	pod:commandTargetRotation(dir)
	pod:setImpulseMaxSpeed(5)
	pod:commandImpulse(-1)
	pod:setCallSign("ISB")
	pod:setFaction("Pilot")
	self.isb:transferPlayersToShip(pod)
	self.isb:destroy()
	self.isb = isb
end

function ss_exfil:gm_menu()
	if self.state < 5 then
		addGMFunction("ISB escape", function()
			ss_exfil:isbEscapes()
		end)
	end
end

function ss_exfil:update(dt)
	local target = self.target
	local isb = self.isb
	if target ~= nil and target:isValid() and isb ~= nil and isb:isValid() then
		if self.state < 5 then
			-- isb has not yet escaped; transfer health
			for _,sys in ipairs(SYSTEMS) do
				isb:setSystemHealth(sys, target:getSystemHealth(sys))
			end
			isb:setHull(target:getHull())
			local breach_shield_level = target:getShieldLevel(1)
			isb:setShields(target:getShieldLevel(0),breach_shield_level,target:getShieldLevel(2),target:getShieldLevel(3))
			if self.state == 0 then
				-- await shield breach
				customElements:addCustomInfo(isb, "Engineering", "EJECT_INFO", _("Schleuse blockiert:"),2)
				customElements:addCustomInfo(isb, "Engineering", "EJECT_INFO_2", string.format(_("Schilde aktiv (Steuerbord %i%%)"), math.ceil(breach_shield_level)), 3)
				if breach_shield_level <= 0 then
					-- shield is breached
					self.state = 1
					target:setShieldsMax(100, 0, 100, 100)
					customElements:addCustomInfo(isb, "Engineering", "EJECT_INFO", _("Schilde inaktiv"), 2)
					customElements:removeCustom(isb, "EJECT_INFO_2")
					customElements:addCustomButton(isb, "Engineering", "EJECT_BUTTON", _("Luftschleuse öffnen"), function()
						-- pushed the exit button
						ss_exfil.state = 2
						ss_exfil.countdown = 1.5
						isb:commandSetAlertLevel("yellow")
						customElements:removeCustom(ss_exfil.isb, "EJECT_BUTTON")
						customElements:addCustomInfo(ss_exfil.isb, "Engineering", "EJECT_INFO", _("Luftschleuse wird geöffnet..."), 1)

					end, 1)
				end
			elseif self.state == 2 then
				-- exit button was pushed
				self.countdown = self.countdown - dt
				if self.countdown < 0 then
					self.state = 3
					local airlock_health = target:getSystemHealth("airlock")
					if airlock_health < 0 then
						airlock_health = 0.1
						target:setSystemHealth("airlock", airlock_health)
					end
					target:setSystemHealthMax("airlock", airlock_health)
					self.airlock_health = airlock_health
					isb:commandSetAlertLevel("red")
					customElements:addCustomInfo(isb, "Engineering", "EJECT_INFO", _("Luftschleuse klemmt!"), 2)
					customElements:addCustomInfo(isb, "Engineering", "EJECT_INFO_2", _("Laserbeschuss könnte helfen."), 3)
				end
			elseif self.state == 3 then
				-- need for fire assist
				local airlock_health = target:getSystemHealth("airlock")
				if airlock_health < self.airlock_health then
					self.state = 4
					self.countdown = 1.0
					isb:commandSetAlertLevel("yellow")
					customElements:removeCustom(isb, "EJECT_INFO_2")
					customElements:addCustomInfo(isb, "Engineering", "EJECT_INFO", _("Luftschleuse wird geöffnet..."), 1)
				end
			elseif self.state == 4 then
				-- opening
				self.countdown = self.countdown - dt
				if self.countdown < 0 then
					self:isbEscapes()
				end
			end
		end
	end
end
