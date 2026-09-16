-- interactive help: show hint for low energy handling

require("utils_customElements.lua")	-- customElements (unified custom info)

interactive_help = {
	custom_elements_index_base = {
		help = 90,		-- +4
	},
}

function interactive_help:updatePlayerShip(delta, ship)
	if ship == nil or not ship:isValid() then
		return
	end

	local energy = ship:getEnergyLevel() / ship:getEnergyLevelMax()
	if energy < 0.3 then
		customElements:addCustomInfo(ship, "Engineering","help_engi_energy_0","Warnung: Energie niedrig", self.custom_elements_index_base.help)
		customElements:addCustomInfo(ship, "Engineering","help_engi_energy_1","Mögliche Maßnahmen:", self.custom_elements_index_base.help + 1)
		customElements:addCustomInfo(ship, "Engineering","help_engi_energy_2","Reaktorleistung erhöhen", self.custom_elements_index_base.help + 2)
		if energy < 0.1 then
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_0","Energielevel kritisch", self.custom_elements_index_base.help)
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_3","Systeme herunterfahren", self.custom_elements_index_base.help + 3)
		else
			customElements:removeCustom(ship, "help_engi_energy_3")
		end
		if ship:getShieldsActive() then
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_4","Schilde deaktivieren", self.custom_elements_index_base.help + 4)
		else
			customElements:removeCustom(ship, "help_engi_energy_4")
		end
	else
		customElements:removeCustom(ship, "help_engi_energy_0")
		customElements:removeCustom(ship, "help_engi_energy_1")
		customElements:removeCustom(ship, "help_engi_energy_2")
		customElements:removeCustom(ship, "help_engi_energy_3")
		customElements:removeCustom(ship, "help_engi_energy_4")
	end
end	




