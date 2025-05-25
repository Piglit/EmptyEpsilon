neutral = FactionInfo():setName("Independent"):setLocaleName(_("Independent"))
neutral:setGMColor(128, 128, 255)
neutral:setDescription(_([[Despite appearing as a faction, independents are distinguished primarily by having no strong affiliation with any faction at all. Most traders consider themselves independent, though certain voices have started to speak up about creating a merchant faction.]]))

--[[ Disable vanilla faction for shattered, to remove clutter --]]
-- Independent still exist

-- Default player faction, since index == 2
-- Used for friedly player ships
escort = FactionInfo():setName("Escort")
escort:setGMColor(128, 255, 255)
escort:setDescription(_([[Escort craft from Endor]]))
--escort:setFriendly(pc)

-- Default enemy faction, since indes == 3 
enemies = FactionInfo():setName("Raider")
enemies:setGMColor(255, 0, 0)
enemies:setDescription(_([[Raiders that may attack you.]]))
--enemies:setEnemy(pc)
enemies:setEnemy(escort)

-- friendly npc ships that aid agains raiders
sky = FactionInfo():setName("Sky Patrol")
sky:setGMColor(255, 0, 255)
sky:setDescription([[Endor Sky Patrol]])
sky:setEnemy(enemies)

-- special faction, used for CIC and infrastructure. Not targeted by enemies
tantal = FactionInfo():setName("Endor")
tantal:setGMColor(170, 255, 170)
tantal:setDescription(_([[Infrastructure around Endor]]))

-- Attackable by players
natural = FactionInfo():setName("Environment")
natural:setGMColor(128, 128, 128)
natural:setDescription(_([[Debris flying around. Or stuff that you can make to debris...]]))
--natural:setEnemy(pc)
natural:setEnemy(escort)

-- faction for players who want to attack established infrastructure or are hunted by Sky Patrol
-- neutral towards raiders
criminals = FactionInfo():setName("Criminals"):setLocaleName(_("Criminals"))
criminals:setGMColor(255, 128, 255)
criminals:setDescription(_([[Despite appearing as a faction, criminals are distinguished primarily by having no strong affiliation with any faction at all. Pirates, outlaws and fugitives are considered criminals.]]))
criminals:setEnemy(neutral)
criminals:setEnemy(escort)
criminals:setEnemy(tantal)
criminals:setEnemy(sky)
--reds:setEnemy(pc)


-- [[ SW-Factions --]]		
-- all hate raiders and criminals and each other
imp = FactionInfo():setName("Imperial")
imp:setGMColor(128, 255, 128)
imp:setDescription(_([[Remnants of the Imperial Forces]]))
imp:setEnemy(enemies)
imp:setEnemy(criminals)

alliance = FactionInfo():setName("New Republic")
alliance:setGMColor(255, 128, 128)
alliance:setDescription(_([[The New Republic]]))
alliance:setEnemy(imp)
alliance:setEnemy(enemies)
alliance:setEnemy(criminals)
--alliance = FactionInfo():setName("Rebel Alliance")
--alliance:setGMColor(255, 128, 128)
--alliance:setDescription(_([[The Rebel Alliance]]))
--alliance:setEnemy(imp)

blues = FactionInfo():setName("Crimson Dawn")
blues:setGMColor(255, 255, 0)
blues:setDescription([[The Crimson Dawn syndicate]])
blues:setEnemy(imp)
blues:setEnemy(alliance)

sky = FactionInfo():setName("Sky Patrol")
sky:setGMColor(255, 0, 255)
sky:setDescription([[Endor Sky Patrol]])
sky:setEnemy(enemies)

-- faction for players who want to attack established infrastructure or are hunted by Sky Patrol
reds = FactionInfo():setName("Criminals"):setLocaleName(_("Criminals"))
reds:setGMColor(255, 128, 255)
reds:setDescription(_([[Despite appearing as a faction, criminals are distinguished primarily by having no strong affiliation with any faction at all. Pirates, outlaws and fugitives are considered criminals.]]))
reds:setEnemy(imp)
--reds:setEnemy(alliance)
reds:setEnemy(alliance)
--reds:setEnemy(blues)
reds:setEnemy(neutral)
--reds:setEnemy(pc)
--reds:setEnemy(escort)
--reds:setEnemy(tantal)
--reds:setEnemy(sky)
reds:setDescription([[Despite appearing as a faction, criminals are distinguished primarily by having no strong affiliation with any faction at all. Pirates, outlaws and fugitives are considered criminals.]])
--

targets = FactionInfo():setName("Target")
targets:setGMColor(255, 0, 0)
targets:setEnemy(imp)
targets:setDescription([[This is a mission target. It must be destroyed.]])


lost = FactionInfo():setName("Pilot")
lost:setGMColor(128, 128, 128)
lost:setDescription(_([[A TIE pilot drifting around in space.]]))
lost:setFriendly(imp)
--lost:setFriendly(team1)
--lost:setFriendly(team2)
--lost:setFriendly(team3)

-- [[ Different player ship factions: these factions are used for autoconnect and identify the room the players are in:
-- 1: Sim Blue
-- 2: Sim Red
-- 3: Blue Helper (Escort)
-- 4: Red Helper (Fighters)
--]]
player_factions = {}
function player_factions:setFriendly(faction)
	for i, player_faction in ipairs(player_factions) do
		player_faction:setFriendly(faction)
	end
end
function player_factions:setEnemy(faction)
	for i, player_faction in ipairs(player_factions) do
		player_faction:setEnemy(faction)
	end
end
for i=1,4 do
	-- clients in simulator rooms use the faction to connect to their ships.
	-- so each room has its own faction.
	-- You may change the faction of a ship in-game, but only after all clients have connected.
	player_factions[i] = FactionInfo():setName("Transport" .. i):setLocaleName(_("Transport")):setGMColor(255, 255, 255):setDescription(_([[Transport craft from Endor]]))
	for j=1,i do
		player_factions[i]:setFriendly(player_factions[j])
	end
	player_factions[i]:setEnemy(enemies)
	player_factions[i]:setEnemy(natural)
	player_factions[i]:setEnemy(criminals)
	player_factions[i]:setFriendly(escort)
end

-- [[ Skystrike factions --]]

--targets = FactionInfo():setName("Target")
--targets:setGMColor(255, 0, 0)
--targets:setEnemy(imp)
--targets:setDescription([[This is a mission target. It must be destroyed.]])
--
--team1 = FactionInfo():setName("Team Red")
--team1:setGMColor(255, 128, 128)
--team1:setDescription(_([[One of the teams of the current mission.]]))
--team1:setFriendly(imp)
--team1:setEnemy(targets)
--team1:setEnemy(reds)
--team1:setEnemy(alliance)
--
--team2 = FactionInfo():setName("Team Yellow")
--team2:setGMColor(255, 255, 128)
--team2:setDescription(_([[One of the teams of the current mission.]]))
--team2:setEnemy(team1)
--team2:setFriendly(imp)
--team2:setEnemy(targets)
--team2:setEnemy(reds)
--team2:setEnemy(alliance)
--
--team3 = FactionInfo():setName("Team Blue")
--team3:setGMColor(128, 128, 255 )
--team3:setDescription(_([[One of the teams of the current mission.]]))
--team3:setEnemy(team2)
--team3:setEnemy(team1)
--team3:setFriendly(imp)
--team3:setEnemy(targets)
--team3:setEnemy(reds)
--team3:setEnemy(alliance)
--
--lost = FactionInfo():setName("Pilot")
--lost:setGMColor(128, 128, 128)
--lost:setDescription(_([[A TIE pilot drifting around in space.]]))
--lost:setFriendly(imp)
--lost:setFriendly(team1)
--lost:setFriendly(team2)
--lost:setFriendly(team3)

--[[ vanilla - needed for tutorial --]]
hn = FactionInfo():setName("Human Navy")
kr = FactionInfo():setName("Kraylor")
kr:setEnemy(hn)
