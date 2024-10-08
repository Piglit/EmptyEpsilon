#include "GMActions.h"

#include "engine.h"
#include "gameGlobalInfo.h"
#include <SDL_assert.h>

const static int16_t CMD_RUN_SCRIPT = 0x0000;
const static int16_t CMD_SEND_GLOBAL_MESSAGE = 0x0001;

P<GameMasterActions> gameMasterActions;

REGISTER_MULTIPLAYER_CLASS(GameMasterActions, "GameMasterActions")
GameMasterActions::GameMasterActions()
: MultiplayerObject("GameMasterActions")
{
    SDL_assert(!gameMasterActions);
    gameMasterActions = this;
}

void GameMasterActions::onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_RUN_SCRIPT:
        {
            string code;
            packet >> code;
            if (code.length() > 0)
            {
                P<ScriptObject> so = new ScriptObject();
                so->runCode(code);
                so->destroy();
            }
        }
        break;
    case CMD_SEND_GLOBAL_MESSAGE:
        {
            string message;
            packet >> message;
            if (message.length() > 0)
            {
                gameGlobalInfo->global_message = message;
                gameGlobalInfo->global_message_timeout = 5.0;
            }
        }
        break;
    case CMD_CREATE_FIGHTER:
        {
            string ship_template;
            int32_t parent_id;
            packet >> ship_template >> parent_id;
            P<PlayerSpaceship> parent = game_server->getObjectById(parent_id);
            P<PlayerSpaceship> ship = new PlayerSpaceship();
            if (ship && parent)
            {
                ship->setTemplate(ship_template);
                ship->setPosition(parent->getPosition());
                ship->requestDock(parent);
                equipFighter(ship, packet);
            }
        }
        break;
    case CMD_EQUIP_FIGHTER:
        {
            int32_t ship_id;
            packet >> ship_id;
            P<PlayerSpaceship> ship = game_server->getObjectById(ship_id);
            if (ship)
                equipFighter(ship, packet);
        }
        break;

    }
}

void GameMasterActions::equipFighter(P<PlayerSpaceship> ship, sp::io::DataBuffer& packet)
{
    string callsign, password, color, model, equipment;
    packet >> callsign >> password >> color >> model >> equipment;

    if (callsign != "")
        ship->setCallSign(callsign);
    ship->setControlCode(password);
    if (color != "")
        ship->setColor(color);
    if (model != "")
        ship->setModel(model);
    string old_equipment = ship->getEquipment();
    if (equipment != "" && equipment != old_equipment)
    {
        LOG(DEBUG) << "EQUIPMENT strip: " << old_equipment << "\tequip:" << equipment;
        auto ship_template = ship->ship_template;
        if (!ship_template)
            return;
        // strip old equipment
        if ((old_equipment == "+1 Beam") || (old_equipment == "+2 Beams"))
        {
            for(int n=0; n<max_beam_weapons; n++)
            {
                ship->beam_weapons[n].setPosition(ship_template->model_data->getBeamPosition(n));
                ship->beam_weapons[n].setArc(ship_template->beams[n].getArc());
                ship->beam_weapons[n].setDirection(ship_template->beams[n].getDirection());
                ship->beam_weapons[n].setRange(ship_template->beams[n].getRange());
                ship->beam_weapons[n].setTurretArc(ship_template->beams[n].getTurretArc());
                ship->beam_weapons[n].setTurretDirection(ship_template->beams[n].getTurretDirection());
                ship->beam_weapons[n].setTurretRotationRate(ship_template->beams[n].getTurretRotationRate());
                ship->beam_weapons[n].setCycleTime(ship_template->beams[n].getCycleTime());
                ship->beam_weapons[n].setDamage(ship_template->beams[n].getDamage());
                ship->beam_weapons[n].setBeamTexture(ship_template->beams[n].getBeamTexture());
                ship->beam_weapons[n].setEnergyPerFire(ship_template->beams[n].getEnergyPerFire());
                ship->beam_weapons[n].setHeatPerFire(ship_template->beams[n].getHeatPerFire());
            }
        }
        else if (
               (old_equipment == "+2 HVLI-Tubes")
            || (old_equipment == "+4 HVLIs + 1 Tube")
            || (old_equipment == "4 Homings")
            || (old_equipment == "1 Nuke + Tube")
            || (old_equipment == "1 Mine + Tube")
            || (old_equipment == "2 EMP + Tube")
        )
        {
            ship->weapon_tube_count = ship_template->weapon_tube_count;
            for(int n=0; n<max_weapon_tubes; n++)
            {
                ship->weapon_tube[n].setLoadTimeConfig(ship_template->weapon_tube[n].load_time);
                ship->weapon_tube[n].setDirection(ship_template->weapon_tube[n].direction);
                ship->weapon_tube[n].setSize(ship_template->weapon_tube[n].size);
                for(int m=0; m<MW_Count; m++)
                {
                    if (ship_template->weapon_tube[n].type_allowed_mask & (1 << m))
                        ship->weapon_tube[n].allowLoadOf(EMissileWeapons(m));
                    else
                        ship->weapon_tube[n].disallowLoadOf(EMissileWeapons(m));
                }
                if (n >= ship->weapon_tube_count)
                    ship->weapon_tube[n].forceUnload();
            }
            for(int n=0; n<MW_Count; n++)
                ship->setWeaponStorageMax((EMissileWeapons) n, ship_template->weapon_storage[n]);
            ship->auto_reload_tube_enabled = ship_template->auto_reload_tube_enabled;
        }
        else if (old_equipment == "Shield")
        {
            ship->shield_count = ship_template->shield_count;
            ship->setShieldsActive(false);
        }
        else if (old_equipment == "Sensors")
        {
            ship->setLongRangeRadarRange(ship_template->long_range_radar_range);
            ship->setCanScan(ship_template->can_scan);
        }
        else if (old_equipment == "Speed-Booster")
        {
            ship->impulse_max_speed = ship_template->impulse_speed;
            ship->impulse_max_reverse_speed = ship_template->impulse_reverse_speed;
            ship->impulse_acceleration = ship_template->impulse_acceleration;
            ship->impulse_reverse_acceleration = ship_template->impulse_reverse_acceleration;
        }
        else if (old_equipment == "Cut-Las")
        {
            // TODO get ship object right
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_buy_stations = false";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }
        else if (old_equipment == "Puppy-Ray")
        {
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_buy_ships = false";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }

        else if (old_equipment == "Cylon'cher")
        {
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_intimidate_stations= false";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }
        else if (old_equipment == "Psycho-Traktor")
        {
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_intimidate_ships = false";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }


        // place new equipment
        if (equipment == "+1 Beam")
        {
            int offset = 0;
            for(int n=0; n<max_beam_weapons; n++)
                if (ship->beam_weapons[n].getArc() > 0.0f)
                    ++offset;
                else
                    break;

            ship->beam_weapons[offset].setPosition(ship_template->model_data->getBeamPosition(offset));
            ship->beam_weapons[offset].setArc(30);
            ship->beam_weapons[offset].setDirection(0);
            ship->beam_weapons[offset].setRange(900);
            ship->beam_weapons[offset].setTurretArc(0);
            ship->beam_weapons[offset].setTurretDirection(0);
            ship->beam_weapons[offset].setTurretRotationRate(0);
            ship->beam_weapons[offset].setCycleTime(4);
            ship->beam_weapons[offset].setDamage(2.5);
        }
        else if (equipment == "+2 Beams")
        {
            // allowed for Lindworm and Ryu 
            // assume the ship has one beam weapon standard

            int offset = 0;
            for(int n=0; n<max_beam_weapons; n++)
                if (ship->beam_weapons[n].getArc() > 0.0f)
                    ++offset;
                else
                    break;
            for (int n=offset; n<=offset+1; n++)
            {
                ship->beam_weapons[n].setPosition(ship_template->model_data->getBeamPosition(n));
                ship->beam_weapons[n].setArc(30);
                ship->beam_weapons[n].setRange(900);
                ship->beam_weapons[n].setTurretArc(0);
                ship->beam_weapons[n].setTurretDirection(0);
                ship->beam_weapons[n].setTurretRotationRate(0);
                ship->beam_weapons[n].setCycleTime(4);
                ship->beam_weapons[n].setDamage(2.5);
            }
            ship->beam_weapons[offset].setDirection(-5);
            ship->beam_weapons[offset +1].setDirection(5);
        }
        else if (equipment == "+2 HVLI-Tubes")
        {
            // this is for the Hornet, so we need additional HVLIs
            int n = ship->weapon_tube_count;
            ship->weapon_tube_count = ship_template->weapon_tube_count +2;
            ship->weapon_tube[n].setLoadTimeConfig(9);
            ship->weapon_tube[n].setDirection(0);
            ship->weapon_tube[n].setSize(MS_Small);
            ship->weapon_tube[n+1].setLoadTimeConfig(9);
            ship->weapon_tube[n+1].setDirection(0);
            ship->weapon_tube[n+1].setSize(MS_Small);
            ship->setWeaponTubeExclusiveFor(n, MW_HVLI);
            ship->setWeaponTubeExclusiveFor(n+1, MW_HVLI);
            ship->setWeaponStorageMax(MW_HVLI, 8);
        }
        else if (equipment == "+4 HVLIs + 1 Tube")
        {
            int n = ship->weapon_tube_count;
            ship->weapon_tube_count = ship_template->weapon_tube_count +1;
            ship->weapon_tube[n].setLoadTimeConfig(9);
            ship->weapon_tube[n].setDirection(0);
            ship->weapon_tube[n].setSize(MS_Small);
            ship->setWeaponStorageMax(MW_HVLI, ship->getWeaponStorageMax(MW_HVLI) + 4);
        }
        else if (equipment == "4 Homings")
        {
            for(int n=0; n<ship->weapon_tube_count; n++)
                ship->weaponTubeAllowMissle(n, MW_Homing);
            ship->setWeaponStorageMax(MW_Homing, ship->getWeaponStorageMax(MW_Homing) + 4);
            ship->setAutoMissileReload(false);
        }
        else if (equipment == "1 Nuke + Tube")
        {
            int n = ship->weapon_tube_count;
            ship->weapon_tube_count = ship_template->weapon_tube_count +1;
            ship->weapon_tube[n].setLoadTimeConfig(20);
            ship->weapon_tube[n].setDirection(0);
            ship->weapon_tube[n].setSize(MS_Small);
            ship->setWeaponTubeExclusiveFor(n, MW_Nuke);
            ship->setWeaponStorageMax(MW_Nuke, ship->getWeaponStorageMax(MW_Nuke) + 1);
        }
        else if (equipment == "1 Mine + Tube")
        {
            int n = ship->weapon_tube_count;
            ship->weapon_tube_count = ship_template->weapon_tube_count +1;
            ship->weapon_tube[n].setLoadTimeConfig(20);
            ship->weapon_tube[n].setDirection(180);
            ship->weapon_tube[n].setSize(MS_Small);
            ship->setWeaponTubeExclusiveFor(n, MW_Mine);
            ship->setWeaponStorageMax(MW_Mine, ship->getWeaponStorageMax(MW_Mine) + 1);
       
        }
        else if (equipment == "2 EMP + Tube")
        {
            int n = ship->weapon_tube_count;
            ship->weapon_tube_count = ship_template->weapon_tube_count +1;
            ship->weapon_tube[n].setLoadTimeConfig(10);
            ship->weapon_tube[n].setDirection(0);
            ship->weapon_tube[n].setSize(MS_Small);
            ship->setWeaponTubeExclusiveFor(n, MW_EMP);
            ship->setWeaponStorageMax(MW_EMP, ship->getWeaponStorageMax(MW_EMP) + 2);
      
        }
        else if (equipment == "Shield")
        {
            ship->setShieldsMax({40});
        }
        else if (equipment == "Sensors")
        {
            ship->setLongRangeRadarRange(15000);
            ship->setCanScan(true);
        }
        else if (equipment == "Speed-Booster")
        {
            ship->impulse_max_speed = 1.5f * ship_template->impulse_speed;
            ship->impulse_max_reverse_speed = 1.5f * ship_template->impulse_reverse_speed;
            ship->impulse_acceleration = 1.5f * ship_template->impulse_acceleration;
            ship->impulse_reverse_acceleration = 1.5f * ship_template->impulse_reverse_acceleration;
        }
        else if (equipment == "Cut-Las")
        {
            // TODO get ship object right
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_buy_stations = true";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }
        else if (equipment == "Puppy-Ray")
        {
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_buy_ships = true";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }

        else if (equipment == "Cylon'cher")
        {
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_intimidate_stations= true";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }
        else if (equipment == "Psycho-Traktor")
        {
            string code = "getPlayerShip("+string(gameGlobalInfo->getPlayerShipIndexByName(ship->getCallSign())+1)+").special_intimidate_ships = true";
            P<ScriptObject> so = new ScriptObject();
            so->runCode(code);
            so->destroy();
        }

        ship->setEquipment(equipment);
    }
}

void GameMasterActions::commandRunScript(string code)
{
    sp::io::DataBuffer packet;
    packet << CMD_RUN_SCRIPT << code;
    sendClientCommand(packet);
}
void GameMasterActions::commandSendGlobalMessage(string message)
{
    sp::io::DataBuffer packet;
    packet << CMD_SEND_GLOBAL_MESSAGE << message;
    sendClientCommand(packet);
}