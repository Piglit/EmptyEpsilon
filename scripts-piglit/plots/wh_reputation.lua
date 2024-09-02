wh_reputation = {
	done = false,
}

function wh_reputation:requestReputation()
	-- once per mission
	if self.done == false then
		sendMessageToCampaignServer("request_reputation", "")
		--[[ calls:
			local player = getPlayerShip(-1)
			player:addReputationPoints(amount)
		--]]
		self.done == true
	end
end

function wh_reputation:requestReputationShip(ship)
	-- once for every new ship. Do not call for respawns, there is no protection against it.
	-- not used, called directly from wh_players
	sendMessageToCampaignServer("request_reputation", ship:getCallSign())
end
