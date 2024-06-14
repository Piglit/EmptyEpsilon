#ifndef _SHIPTEMPLATE_HPP_
#define _SHIPTEMPLATE_HPP_

/* Define script conversion function for the ESystem enum. */
template<> void convert<ESystem>::param(lua_State* L, int& idx, ESystem& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "reactor")
        es = SYS_Reactor;
    else if (str == "beamweapons")
        es = SYS_BeamWeapons;
    else if (str == "missilesystem")
        es = SYS_MissileSystem;
    else if (str == "maneuver")
        es = SYS_Maneuver;
    else if (str == "impulse")
        es = SYS_Impulse;
    else if (str == "warp")
        es = SYS_Warp;
    else if (str == "jumpdrive")
        es = SYS_JumpDrive;
    else if (str == "frontshield")
        es = SYS_FrontShield;
    else if (str == "rearshield")
        es = SYS_RearShield;
    else
        es = SYS_None;
}

/* Define script conversion function for the ShipTemplate::TemplateType enum. */
template<> void convert<ShipTemplate::TemplateType>::param(lua_State* L, int& idx, ShipTemplate::TemplateType& tt)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "ship")
        tt = ShipTemplate::Ship;
    else if (str == "playership")
        tt = ShipTemplate::PlayerShip;
    else if (str == "station")
        tt = ShipTemplate::Station;
    else
        tt = ShipTemplate::Ship;
}

/* Define script conversion function for the ERestockMissileBehaviour enum. */
template<> void convert<ERestockMissileBehaviour>::param(lua_State* L, int& idx, ERestockMissileBehaviour& er)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "all")
        er = R_None;
    else if (str == "cpuships")
        er = R_CpuShips;
    else if (str == "fighters")
        er = R_Fighters;
    else if (str == "playerships")
        er = R_PlayerShips;
    else
        er = R_None;
}

/* Define script conversion function for the EPlayerShipType enum. */
template<> void convert<EPlayerShipType>::param(lua_State* L, int& idx, EPlayerShipType& er)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "ship")
        er = PST_Ship;
    else if (str == "fighter")
        er = PST_Fighter;
    else if (str == "station")
        er = PST_Station;
    else
        er = PST_Ship;
}

#endif /* _SHIPTEMPLATE_HPP_ */
