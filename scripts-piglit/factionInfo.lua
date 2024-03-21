neutral = FactionInfo():setName("Independent"):setLocaleName(_("Independent"))
neutral:setGMColor(128, 128, 255)
neutral:setDescription(_([[Despite appearing as a faction, independents are distinguished primarily by having no strong affiliation with any faction at all. Most traders consider themselves independent, though certain voices have started to speak up about creating a merchant faction.]]))

pc = FactionInfo():setName("Transport")
pc:setGMColor(128, 255, 128)
pc:setDescription(_([[Transport craft from Endor]]))

escort = FactionInfo():setName("Escort")
escort:setGMColor(128, 255, 255)
escort:setDescription(_([[Escort craft from Endor]]))
escort:setFriendly(pc)

tantal = FactionInfo():setName("Endor")
tantal:setGMColor(170, 255, 170)
tantal:setDescription(_([[Endor flight control]]))

enemies = FactionInfo():setName("Raider")
enemies:setGMColor(255, 0, 0)
enemies:setDescription(_([[Raiders that may attack you.]]))
enemies:setEnemy(pc)
enemies:setEnemy(escort)

natural = FactionInfo():setName("Environment")
natural:setGMColor(128, 128, 128)
natural:setDescription(_([[Debris flying around.]]))
natural:setEnemy(pc)
natural:setEnemy(escort)

imp = FactionInfo():setName("Imperial")
imp:setGMColor(128, 255, 128)
imp:setDescription(_([[Remnants of the Imperial Forces]]))

alliance = FactionInfo():setName("New Republic")
alliance:setGMColor(255, 128, 128)
alliance:setDescription(_([[The New Republic]]))
alliance:setEnemy(imp)

blues = FactionInfo():setName("Syndicate")
blues:setGMColor(255, 255, 0)
blues:setDescription([[The Crimson Dawn syndicate]])
blues:setEnemy(imp)
blues:setEnemy(alliance)

sky = FactionInfo():setName("Sky Patrol")
sky:setGMColor(255, 0, 255)
sky:setDescription([[Endor Sky Patrol]])
sky:setEnemy(enemies)

-- faction for players who want to attack established infrastrucure
reds = FactionInfo():setName("Criminals")
reds:setGMColor(128, 255, 255)
reds:setEnemy(imp)
reds:setEnemy(alliance)
reds:setEnemy(blues)
reds:setEnemy(neutral)
reds:setEnemy(pc)
reds:setEnemy(escort)
reds:setEnemy(tantal)
reds:setEnemy(sky)
reds:setDescription([[Despite appearing as a faction, criminals are distinguished primarily by having no strong affiliation with any faction at all. Pirates, outlaws and fugitives are considered criminals.]])
--

