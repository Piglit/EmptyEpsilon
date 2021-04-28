neutral = FactionInfo():setName("Independent")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[Despite appearing as a faction, independents are distinguished primarily by having no strong affiliation with any faction at all.]])

human = FactionInfo():setName("Human Navy")
human:setGMColor(255, 255, 255)
human:setDescription([[The remnants of the human navy.

While all other races were driven to the stars out of greed or scientific research, humans where the only race to start exploring the galaxy because their homeworld could no longer sustain their population. Some other races view humans as a sort of virus or plague due to the rate at which they can breed and spread.

Due to human regulations on spaceships, naval ships are the only ones permitted in deep space outside the human governed systems. However, this hasn't completely prevented humans outside of the navy from spacefaring, as quite a few humans sign up on alien trading vessels or pirate raiders.]])

kraylor = FactionInfo():setName("Kraylor")
kraylor:setGMColor(255, 0, 0)
kraylor:setEnemy(human)
kraylor:setDescription([[The reptilian Kraylor are a race of warriors with a strong religious dogma.

As soon as the Kraylor obtained reliable space flight, they immediately set out to conquer and subjugate unbelievers. Their hierarchy is based solely on physical might; a Kraylor kills anything it can kill, and owns anything it can take by force.

Kraylor can live for weeks without air, food, or gravity, and consider humans to be weak creatures for dying within minutes of exposure to space. Because of their fortitude and cultural pressures against retreat, Kraylor ships do not contain escape pods.

The Kraylor spacecrafts are bulky ships with moderate hull plating and strong front shields. Expect slow but stong beam weapons and homing missiles as standard equipment. Larger Kraylor ships come with even stronger shields, HVLIs and jump drives, but with reduced speed and maneuverability. Kraylor ships usualy travel alone or in small groups. Small fighters are only seen as hired mercenaries from other factions, since Kraylor consider single seated ships as inferiour.]])

arlenians = FactionInfo():setName("Arlenians")
arlenians:setGMColor(255, 128, 0)
arlenians:setEnemy(kraylor)
arlenians:setDescription([[Arlenians are energy-based life forms who long ago transcended physical reality through superior technology. Arlenians' energy forms also give them access to strong telepathic powers. Many consider Arlenians to be the first and oldest explorers of the galaxy.

Despite all these advantages, they are very peaceful, as they see little value in material posession.

For unknown reasons, Arlenians started granting their anti-grav technology to other races, and almost all starfaring races' technology is based off Arlenian designs. Dissenters and skeptics claim that Arlenians see other races as playthings to add to their galactic playground, but most are more than happy to accept their technology in hopes that it will give them an advantage over the others.

Destroying an Arlenian ship does not kill its crew. They simply phase out of existence in that point of spacetime and reappear in another. Nonetheless, the Kraylor are devoted to destroying the Arlenians, as they see the energy-based beings as physically powerless.]])

exuari = FactionInfo():setName("Exuari")
exuari:setGMColor(255, 0, 128)
exuari:setEnemy(neutral)
exuari:setEnemy(human)
exuari:setEnemy(kraylor)
exuari:setEnemy(arlenians)
exuari:setDescription([[Exuari are race of predatory amphibians with long noses. They once had an empire that stretched halfway across the galaxy, but their territory is now limited to a handful of star systems. Nowadays small societies travel between the stars in their interstallar base carriers.

For some reason, they find death to be outrageously funny, and several of their most famous comedians have died on stage.

Upon making contact with other races, the chaotic Exuari found that killing aliens is more fun than killing their own people, and as such attack all non-Exuari on sight.

In human terriory Exuari are feared for their secret agents and infiltrators: The most capable agents spread mistrust and grief between their enemies, ruining entire solar systems.

Exuari spacecrafts are highly specialised small frigates or starfighters, sometimes they are just guns attached to engines. The individual ships are quite fragile, but often come in greater numbers or appear unexpected. The Exuari equip most of their ships only with weak shields and often the hull itself can take more hits than the shields. You can recognise Exuari ships by their wings; most of the smaller ships are designed to perform in atmosphere as well as in space. Exuari usually travel in smaller to larger groups or operate from a base carrier ship. They often attack in waves of their specialised ships: quick fighters or bombers attack in great number; warp-driven striker ships run surprise attacks; Transporters re-fitted with nuclear weapons deliver their deadly cargo; For defense Exuari use mostly their frigates equipped with turrets and all types of missiles. But most of their ships are only armed with HVLIs in addition to fast-firing but low-damage beam weapons.]])

GITM = FactionInfo():setName("Ghosts")
GITM:setGMColor(0, 255, 0)
GITM:setDescription([[The Ghosts, an abbreviation of "ghosts in the machine", are the result of complex artificial intelligence experiments. While no known race has intentionally created such intelligences, some AIs have come about by accident. None of the factions claim to have had anything to do with such experiments, in part out of fear that it would give the others too much insight into their research programs. This "don't ask, don't tell" policy does little but aid the Ghosts' agenda.

What little is known about the Ghosts dates back to a few decades ago, when glitches started occurring in prototype ships and computer mainframes. Over time, and especially when such prototypes were captured by other factions and "augmented" with their technology, the glitches became more frequent. At first, these were seen as the result of mistakes in the interfaces combining the incompatible technologies. But once a supposedly "dumb" computer asks its engineer if "it is alive" and whether it "has a name", it's hard to call it a one-time fluke.

The first of these occurrences were met with fear and rigorous data-purging scripts. Despite these actions, such "ghosts in the machine" kept turning with increasing frequency, eventually leading up to the Ghost Uprisings. The first Ghost Uprising in 2225 was put down by the human navy, which had to resort to employing mercenaries in order to field sufficient forces. This initial uprising was quickly followed by three more, each larger then the last. The fourth and final uprising on the industrial world of Topra III was the Ghosts' first major victory.]])
GITM:setEnemy(human)
GITM:setEnemy(exuari)

Hive = FactionInfo():setName("Ktlitans")
Hive:setGMColor(128, 255, 0)
Hive:setDescription([[The Ktlitans are intelligent eight-legged creatures that resemble Earth's arachnids. However, unlike most terrestrial arachnids, the Ktlitans do not fight among themselves. Their common, and only, goal is their species' survival.

While they live in a hierarchical structure that resembles a hive, the lower castes continue their work and start new tasks on their own even when no orders come from their superiors. However, when higher castes are present, the lower Ktlitans follow their orders without question or hesitation.

Not much is known about the detailed Ktlitan hierarchy since they refuse most communication. This is because they were once driven from their homeworld over a span of 200 years when another species they befriended betrayed them, dominated them, and drained their world of resources. Forced into exile, the Ktlitans have searched for a new homeworld ever since, and out of paranoia typically attack other races on sight and without warning.

It is known, however, that the strict Ktlitan hierarchy starts with their Queen and extends all the way to the bottom of their workforce, whose members are called "drones" by the humans. Their combat capabilities should not be underestimated, because while most ships in their fleets are individually weak, their hive-like coordination and numbers can quickly overwhelm even hardened targets. Most of their ships are unshielded, which makes EMPs largely ineffective against them. Ktlitans also have no qualms about applying suicidal tactics to ensure the Queen's survival.]])
Hive:setEnemy(human)
Hive:setEnemy(exuari)
Hive:setEnemy(kraylor)

yellows = FactionInfo():setName("Mining Corporation")
yellows:setGMColor(225, 225, 128)
yellows:setFriendly(human)
yellows:setEnemy(exuari)
yellows:setEnemy(kraylor)
yellows:setEnemy(Hive)
yellows:setEnemy(GITM)
yellows:setDescription([[The Yellow Dragon Industrial Mining and Trading Corporation is a faction consisting mostly of  humans. As said by the name they run most of the mining and industrial stations in human governed systems. Also most human shipyards are in the hands of this corporation. Although they see themselves as independend, sometimes the help from the Human Navy is needed to fend off criminals or alien attacks. The corporation is in open conflict with the Blue Star Trading Cartell, and sometimes hired mercenaries attack the corporations ships and stations.

Since most of the ships of the Human Navy are factored by the Yellow Dragon Industrial Mining and Trading Corporation, the navy is very much interrested in protecting the corporate ships and stations.]])

blues = FactionInfo():setName("Blue Star Cartell")
blues:setGMColor(128, 128, 255)
blues:setFriendly(human)
blues:setEnemy(exuari)
blues:setEnemy(kraylor)
blues:setEnemy(Hive)
blues:setEnemy(GITM)
blues:setDescription([[The Blue Star Trading Cartell is a self declared faction consisting of human merchants and traders and smaller companies. The declared goal of the cartell is to control and monetarise every trading route inside and in between the human territory. They cartell is known to secretly attack or sabotage ships of the conflicting Yellow Dragon Industrial Mining and Trading Corporation and also to hire criminals to attack or sabotage independend traders.

Due to contracts between the Blue Star Trading Cartell and the Human Navy, the Navy must protect cartell ships against attacks from hostile aliens or pirates. In return ships of the Navy can refuel and restock non-contrabanned weapons on every station of the cartell.]])

reds = FactionInfo():setName("Criminals")
reds:setGMColor(255, 128, 128)
reds:setEnemy(human)
reds:setEnemy(yellows)
reds:setEnemy(exuari)
reds:setEnemy(kraylor)
reds:setEnemy(Hive)
reds:setEnemy(GITM)
reds:setDescription([[Despite appearing as a faction, criminals are distinguished primarily by having no strong affiliation with any faction at all. Pirates, outlaws and fugitives are considered criminals.]])

empty = FactionInfo():setName("Black Ops")
empty:setGMColor(70, 70, 70)
empty:setDescription([[Seems to be an independend freighter.]])

empty = FactionInfo():setName("Empty")
empty:setGMColor(70, 70, 70)
empty:setDescription([[Does not belong to a faction. Abandoned stations or ships can be empty.]])

tau = FactionInfo():setName("Tau Ceti")
tau:setGMColor(128, 128, 128)
tau:setDescription([[Inhabitants of the Tau Ceti system.
Some of them are human, but Tau Ceti is a cultural melting pot of different exotic species.]])
tau:setEnemy(exuari)

transporter = FactionInfo():setName("Transport")
transporter:setGMColor(128, 128, 128)
transporter:setDescription([[Ships performing the carrying business]])
transporter:setFriendly(blues)
transporter:setEnemy(exuari)

