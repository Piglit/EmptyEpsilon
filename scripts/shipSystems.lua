
--    (H)oriz, (V)ert        HC,VC,HS,VS, system    (C)oordinate (S)ize
--    template:addRoomSystem(3, 0, 1, 1, "Maneuver");
--    (H)oriz, (V)ert  H, V, true = horizontal
--    template:addDoor(3, 1, true);

function addSystemsWespe(template)
    --TODO
    template:addRoomSystem(3, 0, 1, 1, "Maneuver");
    template:addRoomSystem(1, 0, 2, 1, "BeamWeapons");
    template:addRoomSystem(0, 1, 1, 2, "RearShield");
    template:addRoomSystem(1, 1, 2, 2, "Reactor");
    template:addRoomSystem(3, 1, 2, 1, "Warp");
    template:addRoomSystem(3, 2, 2, 1, "JumpDrive");
    template:addRoomSystem(5, 1, 1, 2, "FrontShield");
    template:addRoomSystem(1, 3, 2, 1, "MissileSystem");
    template:addRoomSystem(3, 3, 1, 1, "Impulse");
    template:addDoor(2, 1, true);
    template:addDoor(3, 1, true);
    template:addDoor(1, 1, false);
    template:addDoor(3, 1, false);
    template:addDoor(3, 2, false);
    template:addDoor(3, 3, true);
    template:addDoor(2, 3, true);
    template:addDoor(5, 1, false);
    template:addDoor(5, 2, false);
end

function addSystemsLindwurm(template)
    --TODO maybe
    template:addRoomSystem(0,0,1,3,"RearShield")
    template:addRoomSystem(1,1,3,1,"MissileSystem")
    template:addRoomSystem(4,1,2,1,"Beamweapons")
    template:addRoomSystem(3,2,2,1,"Reactor")
    template:addRoomSystem(2,3,2,1,"Warp")
    template:addRoomSystem(4,3,5,1,"JumpDrive")
    template:addRoomSystem(0,4,1,3,"Impulse")
    template:addRoomSystem(3,4,2,1,"Maneuver")
    template:addRoomSystem(1,5,3,1,"FrontShield")
    template:addRoom(4,5,2,1)
    template:addDoor(1,1,false)
    template:addDoor(1,5,false)
    template:addDoor(3,2,true)
    template:addDoor(4,2,true)
    template:addDoor(3,3,true)
    template:addDoor(4,3,true)
    template:addDoor(3,4,true)
    template:addDoor(4,4,true)
    template:addDoor(3,5,true)
    template:addDoor(4,5,true)
end

function addSystemsAdler(template)
    --TODO
    template:addRoomSystem(3, 0, 1, 1, "Maneuver");
    template:addRoomSystem(1, 0, 2, 1, "BeamWeapons");
    template:addRoomSystem(0, 1, 1, 2, "RearShield");
    template:addRoomSystem(1, 1, 2, 2, "Reactor");
    template:addRoomSystem(3, 1, 2, 1, "Warp");
    template:addRoomSystem(3, 2, 2, 1, "JumpDrive");
    template:addRoomSystem(5, 1, 1, 2, "FrontShield");
    template:addRoomSystem(1, 3, 2, 1, "MissileSystem");
    template:addRoomSystem(3, 3, 1, 1, "Impulse");
    template:addDoor(2, 1, true);
    template:addDoor(3, 1, true);
    template:addDoor(1, 1, false);
    template:addDoor(3, 1, false);
    template:addDoor(3, 2, false);
    template:addDoor(3, 3, true);
    template:addDoor(2, 3, true);
    template:addDoor(5, 1, false);
    template:addDoor(5, 2, false);
end

function addSystemsMulitGun(template)
    template:addRoomSystem(4, 2, 2, 1, "Maneuver");
    template:addRoomSystem(2, 1, 2, 1, "BeamWeapons");
    template:addRoom(2, 2, 2, 1);
    template:addRoomSystem(0, 3, 1, 2, "RearShield");
    template:addRoomSystem(1, 3, 2, 2, "Reactor");
    template:addRoomSystem(3, 3, 2, 2, "Warp");
    template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
    template:addRoom(6, 3, 2, 1);
    template:addRoom(6, 4, 2, 1);
    template:addRoomSystem(8, 3, 1, 2, "FrontShield");
    template:addRoom(2, 5, 2, 1);
    template:addRoomSystem(2, 6, 2, 1, "MissileSystem");
    template:addRoomSystem(4, 5, 2, 1, "Impulse");
    template:addDoor(4, 3, true);
    template:addDoor(2, 2, true);
    template:addDoor(3, 3, true);
    template:addDoor(1, 3, false);
    template:addDoor(3, 4, false);
    template:addDoor(3, 5, true);
    template:addDoor(2, 6, true);
    template:addDoor(4, 5, true);
    template:addDoor(5, 3, false);
    template:addDoor(6, 3, false);
    template:addDoor(6, 4, false);
    template:addDoor(8, 3, false);
    template:addDoor(8, 4, false);
end

function addSystemsLaser(template)
    template:addRoomSystem( 0, 3, 2, 2, "Impulse")
    template:addRoomSystem( 2, 3, 2, 2, "Reactor")
    template:addRoomSystem( 2, 0, 2, 2, "JumpDrive")
    template:addRoomSystem( 2, 6, 2, 2, "Warp")
    template:addRoomSystem( 4, 5, 2, 1, "RearShield")
    template:addRoomSystem( 4, 2, 2, 1, "MissileSystem")
    template:addRoomSystem( 6, 3, 2, 1, "Maneuver")
    template:addRoomSystem( 8, 2, 2, 4, "Beamweapons")
    template:addRoomSystem(10, 3, 1, 2, "FrontShield")
    template:addRoom( 1, 2, 3, 1)
    template:addRoom( 1, 5, 3, 1)
    template:addRoom( 4, 3, 2, 2)
    template:addRoom( 6, 4, 2, 1)
    template:addDoor( 2, 2, true)
    template:addDoor( 1, 3, true)
    template:addDoor( 1, 5, true)
    template:addDoor( 3, 6, true)
    template:addDoor( 4, 5, true)
    template:addDoor( 6, 4, true)
    template:addDoor( 2, 4, false)
    template:addDoor( 4, 2, false)
    template:addDoor( 4, 5, false)
    template:addDoor( 6, 4, false)
    template:addDoor( 8, 4, false)
    template:addDoor(10, 4, false)
end

function addSystemsHeavy(template)
    --TODO maybe
    template:addRoomSystem(0, 2, 2, 1, "BeamWeapons");
    template:addRoomSystem(4, 2, 2, 1, "FrontShield");
    template:addRoom(2, 2, 2, 1);
    template:addRoomSystem(0, 3, 2, 2, "Impulse");
    template:addRoomSystem(2, 3, 1, 2, "Warp");
    template:addRoomSystem(3, 3, 2, 2, "Reactor");
    template:addRoomSystem(5, 3, 2, 2, "JumpDrive");
    template:addRoomSystem(7, 3, 1, 2, "Maneuver");
    template:addRoom(2, 5, 2, 1);
    template:addRoomSystem(4, 5, 2, 1, "MissileSystem");
    template:addRoomSystem(0, 5, 2, 1, "RearShield");
    template:addDoor(1, 3, true);
    template:addDoor(4, 3, true);
    template:addDoor(3, 3, true);
    template:addDoor(2, 3, false);
    template:addDoor(3, 4, false);
    template:addDoor(3, 5, true);
    template:addDoor(4, 5, true);
    template:addDoor(1, 5, true);
    template:addDoor(5, 3, false);
    template:addDoor(7, 3, false);
    template:addDoor(7, 4, false);
end

function addSystemsLight(template)
    -- cool 
    template:addRoom(1, 0, 6, 1)
    template:addRoom(1, 5, 6, 1)
    template:addRoomSystem(0, 1, 2, 2, "RearShield")
    template:addRoomSystem(0, 3, 2, 2, "MissileSystem")
    template:addRoomSystem(2, 1, 2, 2, "Beamweapons")
    template:addRoomSystem(2, 3, 2, 2, "Reactor")
    template:addRoomSystem(4, 1, 2, 2, "Warp")
    template:addRoomSystem(4, 3, 2, 2, "JumpDrive")
    template:addRoomSystem(6, 1, 2, 2, "Impulse")
    template:addRoomSystem(6, 3, 2, 2, "Maneuver")
    template:addRoomSystem(8, 2, 2, 2, "FrontShield")
    template:addDoor(1, 1, true)
    template:addDoor(3, 1, true)
    template:addDoor(4, 1, true)
    template:addDoor(6, 1, true)
    template:addDoor(4, 3, true)
    template:addDoor(5, 3, true)
    template:addDoor(8, 2, false)
    template:addDoor(8, 3, false)
    template:addDoor(1, 5, true)
    template:addDoor(2, 5, true)
    template:addDoor(5, 5, true)
    template:addDoor(6, 5, true)
end

function addSystemsLightAlt(template)
    -- nope
    template:addRoomSystem( 0, 1, 2, 4, "Impulse")
    template:addRoomSystem( 2, 0, 2, 2, "RearShield")
    template:addRoomSystem( 2, 2, 2, 2, "Warp")
    template:addRoom( 2, 4, 2, 2)
    template:addRoomSystem( 4, 1, 1, 4, "Maneuver")
    template:addRoom( 5, 0, 2, 2)
    template:addRoomSystem( 5, 2, 2, 2, "JumpDrive")
    template:addRoomSystem( 5, 4, 2, 2, "Beamweapons")
    template:addRoomSystem( 7, 1, 3, 2, "Reactor")
    template:addRoomSystem( 7, 3, 3, 2, "MissileSystem")
    template:addRoomSystem(10, 2, 2, 2, "FrontShield")
    template:addDoor( 2, 2, false)
    template:addDoor( 2, 4, false)
    template:addDoor( 3, 2, true)
    template:addDoor( 4, 3, false)
    template:addDoor( 5, 2, false)
    template:addDoor( 5, 4, true)
    template:addDoor( 7, 3, false)
    template:addDoor( 7, 1, false)
    template:addDoor( 8, 3, true)
    template:addDoor(10, 2, false)
end

function addSystemsMineLayer(template)
    template:addRoomSystem( 0, 1, 1, 2, "Impulse")
    template:addRoomSystem( 1, 0, 2, 1, "RearShield")
    template:addRoomSystem( 1, 1, 2, 2, "JumpDrive")
    template:addRoomSystem( 1, 3, 2, 1, "FrontShield")
    template:addRoomSystem( 3, 0, 2, 1, "Beamweapons")
    template:addRoomSystem( 3, 1, 3, 1, "Warp")
    template:addRoomSystem( 3, 2, 3, 1, "Reactor")
    template:addRoomSystem( 3, 3, 2, 1, "MissileSystem")
    template:addRoomSystem( 6, 1, 1, 2, "Maneuver")
    template:addDoor( 1, 1, false)
    template:addDoor( 2, 1, true)
    template:addDoor( 1, 3, true)
    template:addDoor( 3, 2, false)
    template:addDoor( 4, 3, true)
    template:addDoor( 6, 1, false)
    template:addDoor( 4, 2, true)
    template:addDoor( 4, 1, true)
end

function addSystemsAtlas(template)
    --TODO
    template:addRoomSystem(1, 0, 2, 1, "Maneuver");
    template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
    template:addRoom(2, 2, 2, 1);
    template:addRoomSystem(0, 3, 1, 2, "RearShield");
    template:addRoomSystem(1, 3, 2, 2, "Reactor");
    template:addRoomSystem(3, 3, 2, 2, "Warp");
    template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
    template:addRoom(6, 3, 2, 1);
    template:addRoom(6, 4, 2, 1);
    template:addRoomSystem(8, 3, 1, 2, "FrontShield");
    template:addRoom(2, 5, 2, 1);
    template:addRoomSystem(1, 6, 2, 1, "MissileSystem");
    template:addRoomSystem(1, 7, 2, 1, "Impulse");
    template:addDoor(1, 1, true);
    template:addDoor(2, 2, true);
    template:addDoor(3, 3, true);
    template:addDoor(1, 3, false);
    template:addDoor(3, 4, false);
    template:addDoor(3, 5, true);
    template:addDoor(2, 6, true);
    template:addDoor(1, 7, true);
    template:addDoor(5, 3, false);
    template:addDoor(6, 3, false);
    template:addDoor(6, 4, false);
    template:addDoor(8, 3, false);
    template:addDoor(8, 4, false);
end 

function addSystemsLaserAlt(template)
    template:addRoomSystem(2, 0, 2, 1, "Maneuver");
    template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
    template:addRoomSystem(0, 2, 3, 2, "RearShield");
    template:addRoomSystem(1, 4, 2, 1, "Reactor");
    template:addRoomSystem(2, 5, 2, 1, "Warp");
    template:addRoomSystem(3, 1, 3, 2, "JumpDrive");
    template:addRoomSystem(3, 3, 3, 2, "FrontShield");
    template:addRoom(6, 2, 6, 2);
    template:addRoomSystem(9, 1, 2, 1, "MissileSystem");
    template:addRoomSystem(9, 4, 2, 1, "Impulse");
    template:addDoor(2, 1, true)
    template:addDoor(1, 2, true)
    template:addDoor(1, 4, true)
    template:addDoor(2, 5, true)
    template:addDoor(3, 2, false)
    template:addDoor(4, 3, true)
    template:addDoor(6, 3, false)
    template:addDoor(9, 2, true)
    template:addDoor(10,4, true)
end

function addSystemsTransport(template)
    --TODO
    template:addRoomSystem(3,0,2,3, "Reactor")
    template:addRoomSystem(3,3,2,3, "Warp")
    template:addRoomSystem(6,0,2,3, "JumpDrive")
    template:addRoomSystem(6,3,2,3, "MissileSystem")
    template:addRoomSystem(5,2,1,2, "Maneuver")
    template:addRoomSystem(2,2,1,2, "RearShield")
    template:addRoomSystem(0,1,2,4, "Beamweapons")
    template:addRoomSystem(8,2,1,2, "FrontShield")
    template:addRoomSystem(9,1,2,4, "Impulse")
    template:addDoor(3, 3, true)
    template:addDoor(6, 3, true)
    template:addDoor(5, 2, false)
    template:addDoor(6, 3, false)
    template:addDoor(3, 2, false)
    template:addDoor(2, 3, false)
    template:addDoor(8, 2, false)
    template:addDoor(9, 3, false)
end

function addSystemsAtlasAlt(template)
    template:addRoomSystem(1, 0, 3, 1, "Maneuver");
    template:addRoom(0, 1, 2, 1);
    template:addRoom(2, 1, 1, 1);
    template:addRoom(3, 1, 2, 1);
    template:addRoom(2, 2, 2, 1);
    template:addRoomSystem(6, 2, 2, 1, "MissileSystem");
    template:addRoomSystem(1, 3, 1, 2, "RearShield");
    template:addRoomSystem(2, 3, 2, 2, "Reactor");
    template:addRoomSystem(4, 3, 2, 2, "JumpDrive");
    template:addRoomSystem(6, 3, 2, 2, "Warp");
    template:addRoomSystem(8, 3, 1, 2, "FrontShield");
    template:addRoom(2, 5, 2, 1);
    template:addRoomSystem(6, 5, 2, 1, "BeamWeapons");
    template:addRoom(0, 6, 2, 1);
    template:addRoom(2, 6, 1, 1);
    template:addRoom(3, 6, 2, 1);
    template:addRoomSystem(1, 7, 3, 1, "Impulse");
    template:addDoor(2, 1, true);
    template:addDoor(2, 1, false);
    template:addDoor(3, 1, false);
    template:addDoor(2, 2, true); 
    template:addDoor(3, 3, true);
    template:addDoor(3, 5, true);
    template:addDoor(2, 6, true);
    template:addDoor(2, 6, false);
    template:addDoor(3, 6, false);
    template:addDoor(2, 7, true); 
    template:addDoor(2, 3, false);
    template:addDoor(4, 4, false);
    template:addDoor(6, 3, false);
    template:addDoor(8, 4, false);
    template:addDoor(7, 3, true);
    template:addDoor(7, 5, true);
end
