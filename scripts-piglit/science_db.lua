--[[
	Everything in the science database files is just readable data for the science officer.
	This data does not affect the game in any other way and just contributes to the lore.
--]]
space_objects = ScienceDatabase():setName('Natural')
item = space_objects:addEntry('Asteroid')
item:setLongDescription([[Asteroids are minor planets, usually smaller than a few kilometers. Larger variants are sometimes refered to as planetoids.]])

item = space_objects:addEntry('Nebula')
item:setLongDescription([[Nebulae are the birthing places of new stars. These gas fields, usually created by the death of an old star, slowly form new stars due to the gravitational pull of its gas molecules. Because of the ever-changing nature of gas nebulae, most radar and scanning technologies are unable to penetrate them. Science officers are therefore advised to rely on probes and visual observations.]])

item = space_objects:addEntry('Black hole')
item:setLongDescription([[A black hole is a point of supercondensed mass with a gravitational pull so powerful that not even light can escape it. It has no locally detectable features, and can only be seen indirectly by blocking the view and distorting its surroundings, creating a strange circular mirror image of the galaxy. The black disc in the middle marks the event horizon, the boundary where even light can't escape it anymore. 
	
On the sensors, a black hole appears as a disc indicating the zone where the gravitational pull is getting dangerous, and soon will be stronger then the ship's impulse engines. An object that crosses a black hole is drawn toward its center and quickly ripped apart by the gravitational forces.]])

item = space_objects:addEntry('Wormhole')
item:setLongDescription([[A wormhole, also known as an Einstein-Rosen bridge, is a phenomena that connects two points of spacetime. Jump drives operate in a similar fashion, but instead of being created at will, a wormhole occupies a specific location in space. Objects that enter a wormhole instantaneously emerge from the other end, which might be anywhere from a few feet to thousands of light years away. 

Wormholes are rare, and most can move objects in only one direction. Traversable wormholes, which are stable and allow for movement in both directions, are even rarer. All wormholes generate tremendous sensor activity, which an astute science officer can detect even through disruptions such as nebulae.]])

weapons = ScienceDatabase():setName('Weapons')
item = weapons:addEntry('Homing missile')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Damage', '35')
item:setLongDescription([[This target-seeking missile is the workhorse of many space combat arsenals. It's compact enough to be fitted on frigates, and packs enough punch to be used on larger ships, though usually in more than a single missile tube.]])

item = weapons:addEntry('Nuke')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[A nuclear missile is similar to a homing missile in that it can seek a target, but it moves and turns more slowly and explodes a greatly increased payload. Its nuclear explosion spans 1U of space and can take out multiple ships in a single shot.

Some captains oppose the use of nuclear weapons because their large explosions can lead to 'fragging', or unintentional friendly fire. Shields should protect crews from harmful radiation, but because these weapons are often used in the thick of battle, there's no way of knowing if hull plating or shields can provide enough protection.]])

item = weapons:addEntry('Mine')
item:addKeyValue('Drop distance', '1.2u')
item:addKeyValue('Trigger distance', '0.6u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[Mines are often placed in defensive perimeters around stations. There are also old minefields scattered around the galaxy from older wars.

Some fearless captains use mines as offensive weapons, but their delayed detonation and blast radius make this use risky at best.]])

item = weapons:addEntry('EMP')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Blast radius', '1u')
item:addKeyValue('Damage at center', '160')
item:addKeyValue('Damage at edge', '30')
item:setLongDescription([[The electromagnetic pulse missile (EMP) reproduces the disruptive effects of a nuclear explosion, but without the destructive properties. This causes it to only affect shields within its blast radius, leaving their hulls intact. The EMP missile is also smaller and easier to store than heavy nukes. Many captains (and pirates) prefer EMPs over nukes for these reasons, and use them to knock out targets' shields before closing to disable them with focused beam fire.]])

item = weapons:addEntry('HVLI')
item:addKeyValue('Range', '5.4u')
item:addKeyValue('Damage', '7 each, 35 total')
item:addKeyValue('Burst', '5')
item:setLongDescription([[A high-velocity lead impactor (HVLI) fires a simple slug of lead at a high velocity. This weapon is usually found in simpler ships since it does not require guidance computers. This also means its projectiles fly in a straight line from its tube and can't pursue a target.

Each shot from an HVLI fires a burst of 5 projectiles, which increases the chance to hit but requires precision aiming to be effective.]])

item = weapons:addEntry('Kraylor beam')
item:addKeyValue('Range', '1.0-1.5u')
item:addKeyValue('Damage', '8')
item:addKeyValue('Reload Time', '6s')
item:addKeyValue('Damage per Second', '1.33')
item:setLongDescription([[The Kraylor particle beam weapon fires a pulse ray of accelerated high energy particles towards it's target. High damage is dealt with single blasts at moderate reload time. 

The weapon itself is a several meters long linear particle accelerator consisting of a plasma filled pipe, a particle source, a series of electrodes for accelerating the particles, and magnets for beam focusing and bending. All the components are placed inside the ships hulk, with only the far end exposed to space, often utilising the length of the ship. 
The beams fired consist of high-energy atomic or subatomic particles that do damage by disrupting the targets atomic and molecular structure.

It is sayed that there is a shield penetrating beam coming with the Doombringer prototype.]])

item = weapons:addEntry('Kraylor turbo beam')
item:addKeyValue('Range', '3.0-4u')
item:addKeyValue('Damage', '10')
item:addKeyValue('Reload Time', '3s')
item:addKeyValue('Damage per Second', '3.33')
item:setLongDescription([[Like the Kraylor particle beam weapon, the turbo beam fires bursts of accelerated high energy particles towards it's target. Very high damage is dealt with quick blasts, but the energy consumption is imense, even when not firing. It is only found on stations, since it is too big for ships.

The weapon itself is a cyclic particle accelerator consisting of linear accelerators as source, an accelerator to further increade the beams' energy, a storage ring to keep beams ready for rapid firing and several linera accelerators as cannons. The cannons usualy are arranged from the outside of the ring towards the outside of the station.
The beams fired consist of atomic and subatomic particles are accelerated to near-light speed and then shot at a target. These particles have tremendous kinetic energy on impact, causing near-instantaneous and catastrophic superheating on the target, and when penetrating deeper, ionization effects which can harm electronics whithin the target.

Alltogether each turbo beam cannon does about 2.5 times the damage of standard Kraylor beams over time.]])

item = weapons:addEntry('Exuari Fighter Gun')
item:addKeyValue('Fire Arc', '60 deg')
item:addKeyValue('Range', '1.0u')
item:addKeyValue('Damage', '4')
item:addKeyValue('Reload Time', '4s')
item:addKeyValue('Damage per Second', '1.0')
item:setLongDescription([[The Exuari Fighter Gun is a rapid firing laser cannon that can run on battery. It is mass produced and is easily attached to small spacecraft. The wide fire arc and low in-combat energy consumption made it extremly popular among the Exuari, so you can see this gun on almost every Exuari fighter or bomber.]])

item = weapons:addEntry('Exuari Striker Gun')
item:addKeyValue('Fire Arc', '40 deg')
item:addKeyValue('Range', '1.0u')
item:addKeyValue('Damage', '6')
item:addKeyValue('Reload Time', '6s')
item:addKeyValue('Damage per Second', '1.0')
item:setLongDescription([[The Exuari Striker Gun is a low cost laser cannon. It is produced from recycled materials. It will not last for many operations without beeing replaced. The moderate need of energy and the short lifetime make it the ideal weapon for Exuari Strikers on suicide missions. The gun is often mounted in twin-pairs on both sides of a ship to comprehend the (in the eyes of the Exuari) small firing arc and the low rate of fire.]])

item = weapons:addEntry('Exuari Turret Gun')
item:addKeyValue('Fire Arc', '20 deg')
item:addKeyValue('Rotation Arc', '180°')
item:addKeyValue('Range', '1.2u')
item:addKeyValue('Damage', '2/4/6')
item:addKeyValue('Reload Time', '3/6/9s')
item:addKeyValue('Damage per Second', '0.66')
item:setLongDescription([[The Exuari Turret Gun is a laser cannon mounted on a rotatable turret. This is the main weapon of Exuari frigates, since they focus on defense rather than attack.]])

item = weapons:addEntry('Ktlitan beam')
item:addKeyValue('Range', '0.6-1.2u')
item:addKeyValue('Damage', '6')
item:addKeyValue('Reload Time', '4s')
item:addKeyValue('Damage per Second', '1.5')
item:setLongDescription([[The Ktlitan spacecrafts use a reversed gravitational impulse beam to tear apart their enemies hull platings. The details of this technology is mostly unknown to other species, the nearest equivalent beeing tractor beams. The damage is done hard and fast, and over time even more devastive than Kraylor particle beam damage. However the downside of this weapons is it's short range.]])


item = weapons:addEntry('Human beam')
item:addKeyValue('Range', '1.2u')
item:addKeyValue('Arc', '90 deg')
item:addKeyValue('Damage', '6')
item:addKeyValue('Reload Time', '8s')
item:addKeyValue('Damage per Second', '0.75')
item:setLongDescription([[The human race currently uses energy-wave beams for space combat. Those weapons emit great amounts of directed energy in form of electromagnetic radiation as waves towards a desired target. 

The beam's source is a specialiced vacuum tube that generates waves of electrons.

While in default configuration this weapon does less damage than other alien beam weapons, but keen users of this technology may cause great harm: One may alter the wavelength of the beam to match the enemies shield frequencies weakest configuration or one may concentrate fire on a single ship system to increase its heat and possibly overload it.]])



