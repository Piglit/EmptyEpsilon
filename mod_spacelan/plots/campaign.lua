require("plots/wh_artifacts.lua")
require("luax.lua")	--table.filter

campaign = {
	reputation_done = false,
	artifacts_init = false,
}

function campaign:requestReputation()
	-- once per mission
	if self.reputation_done == false then
		self.reputation_done = true
		sendMessageToCampaignServer("request_reputation", "")
		--[[ calls:
			local player = getPlayerShip(-1)
			player:addReputationPoints(amount)
		--]]
	end
	-- For Multi-Ship-Missions use the following line instead of this function:
	--sendMessageToCampaignServer("request_reputation", ship:getCallSign())
	-- this causes the rep to be spent for follow up calls of this line, but not of this function.
end

function campaign:initScore(difficulty)
	local score = {
		progress = 0,
		artifacts = 0,
	}
	if difficulty ~= nil then
		if type(difficulty) == "string" then
			local difficulties = {
				["Extreme"] = 8,
				["Hard"] = 4,
				["Normal"] = 2,
				["Easy"] = 1,
			}
			difficulty = difficulties[difficulty]
		end
		score.difficulty = difficulty
	end
	sendMessageToCampaignServer("score", toJSON(score))
end

function campaign:victoryScore(progress)
	local score = {
		time = getScenarioTime(),
		progress = progress or 100,
	}
	sendMessageToCampaignServer("score", toJSON(score))
end

function campaign:placeArtifact(x,y,name,descr,callback)
	-- only first call causes artifact, further calls are ignored
	if self.artifacts_init == false then
		self.artifacts_init = true
		wh_artifacts:init()
		local art = wh_artifacts:placeDetailedArtifact(x,y,name,descr,function(art, pl, collected)
			sendMessageToCampaignServer("artifact", toJSON{name = art.resource_name, description = art.resource_descr})
			sendMessageToCampaignServer("score", toJSON({artifacts = collected}))
			if callback ~= nil then
				callback(art, pl, collected)
			end
		end)
		art:setScanningParameters(3, 1)	-- reduced difficulty for single ship campaign missions
		return art
	end
end

function campaign:progressEnemyCount(enemyList, clean_up_list_in_place, on_change)
    local object_count = 0

	if clean_up_list_in_place == true then
		-- remove all objects enemies from the list
		table.filter(enemyList, function(obj)
		    return obj:isValid()
		end)
		object_count = #enemyList
	else
		-- does not modify the list
		for i_, object in ipairs(enemyList) do
			if object:isValid() then
				object_count = object_count + 1
			end
		end
	end
    
    -- if enemy count changed
	if self.enemyCount == nil then
		self.enemyCount = object_count
		self.enemyCountStart = object_count
	end
    if self.enemyCount ~= object_count then
		self.enemyCount = object_count
        sendProgressToCampaignServer(self.enemyCountStart - object_count, self.enemyCountStart)
		if on_change ~= nil then
			on_change()
		end
    end

	return object_count
end
