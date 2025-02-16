#include "main.h"
#include "autoConnectScreen.h"
#include "preferenceManager.h"
#include "epsilonServer.h"
#include "gameGlobalInfo.h"
#include "playerInfo.h"
#include "multiplayer_client.h"
#include "multiplayer_server_scanner.h"
#include "screens/windowScreen.h"

#include "gui/gui2_label.h"


AutoConnectScreen::AutoConnectScreen(string crew_positions_string, bool control_main_screen, string ship_filter)
:control_main_screen(control_main_screen)
{
    if (!game_client)
    {
        scanner = new ServerScanner(VERSION_NUMBER);
        scanner->scanLocalNetwork();
    }

    status_label = new GuiLabel(this, "STATUS", tr("Searching for connection..."), 50);
    status_label->setPosition(0, 300, sp::Alignment::TopCenter)->setSize(0, 50);

    string first_position_name = "Error";
    first_crew_position = max_crew_positions;
    window_degree = -1;
    for(string crew_pos_str: crew_positions_string.split(","))
    {
        if (crew_pos_str.lower() == "mainscreen")
        {
            if (crew_positions.empty())
                first_position_name = tr("Main screen");
            crew_positions.push_back(max_crew_positions);   // max_crew_positions indicates main screen
        }
        else if (crew_pos_str.lower().startswith("window:"))
        {
            std::vector<string> descr = crew_pos_str.split(":", 1);
            string deg_str = descr[1].strip();
            int degree = deg_str.toInt();
            if (crew_positions.empty())
                first_position_name = tr("Ship window");
            crew_positions.push_back(max_crew_positions);
            window_degree = degree;
        }
        else
        {
            ECrewPosition pos = getCrewPositionByName(crew_pos_str.strip());
            if (pos == max_crew_positions)
                LOG(ERROR, "No such crew position: "+crew_pos_str);
            else
            {
                if (crew_positions.empty())
                    first_position_name = getCrewPositionName(pos);
                crew_positions.push_back(pos);
            }
        }
    }
    if (!crew_positions.empty())
    {
        first_crew_position = crew_positions.front();
        (new GuiLabel(this, "POSITION", first_position_name, 50))->setPosition(0, 400, sp::Alignment::TopCenter)->setSize(0, 30);
    }

    for(string filter : ship_filter.split(";"))
    {
        std::vector<string> key_value = filter.split("=", 1);
        string key = key_value[0].strip().lower();
        if (key.length() < 1)
            continue;

        if (key_value.size() == 1)
            ship_filters[key] = "1";
        else if (key_value.size() == 2)
            ship_filters[key] = key_value[1].strip();
        LOG(INFO) << "Auto connect filter: " << key << " = " << ship_filters[key];
    }

    if (PreferencesManager::get("instance_name") != "")
    {
        (new GuiLabel(this, "", PreferencesManager::get("instance_name"), 25))->setAlignment(sp::Alignment::CenterLeft)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(0, 18);
    }
}

AutoConnectScreen::~AutoConnectScreen()
{
    if (scanner)
        scanner->destroy();
}

void AutoConnectScreen::update(float delta)
{
    if (scanner)
    {
        std::vector<ServerScanner::ServerInfo> serverList = scanner->getServerList();
        string autoconnect_address = PreferencesManager::get("autoconnect_address", "");

        if (autoconnect_address != "") {
            status_label->setText(tr("Using autoconnect server ") + autoconnect_address);
            connect_to_address = autoconnect_address;
            new GameClient(VERSION_NUMBER, autoconnect_address);
            scanner->destroy();
        } else if (serverList.size() > 0) {
            status_label->setText(tr("Found connection") + serverList[0].name);
            connect_to_address = serverList[0].address;
            new GameClient(VERSION_NUMBER, serverList[0].address);
            scanner->destroy();
        } else {
            status_label->setText(tr("Searching for connection..."));
        }
    }else{
        switch(game_client->getStatus())
        {
        case GameClient::Connecting:
        case GameClient::Authenticating:
            if (!connect_to_address.getHumanReadable().empty())
                status_label->setText(tr("Connecting: ") + connect_to_address.getHumanReadable()[0]);
            else
                status_label->setText(tr("Connecting..."));
            break;
        case GameClient::WaitingForPassword: //For now, just disconnect when we found a password protected server.
        case GameClient::Disconnected:
            disconnectFromServer();
            scanner = new ServerScanner(VERSION_NUMBER);
            scanner->scanLocalNetwork();
            break;
        case GameClient::Connected:
            if (game_client->getClientId() > 0)
            {
                foreach(PlayerInfo, i, player_info_list)
                    if (i->client_id == game_client->getClientId())
                        my_player_info = i;
                if (my_player_info && gameGlobalInfo)
                {
                    my_player_info->commandSetName(PreferencesManager::get("username"));
                    if (!connect_to_address.getHumanReadable().empty())
                        status_label->setText(tr("Waiting for ship on ") + connect_to_address.getHumanReadable()[0] + "...");
                    else
                        status_label->setText(tr("Waiting for ship..."));
                    if (!my_spaceship)
                    {
                        for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
                        {
                            if (isValidShip(n))
                            {
                                connectToShip(n);
                                break;
                            }
                        }
                    } else {
                        if (my_spaceship->getMultiplayerId() == my_player_info->ship_id && (first_crew_position == max_crew_positions || my_player_info->crew_position[first_crew_position]))
                        {
                            destroy();
                            if (window_degree > 0){
                                uint8_t window_flags = PreferencesManager::get("ship_window_flags", "1").toInt();
                                new WindowScreen(getRenderLayer(), window_degree, window_flags);
                            } else{
                                my_player_info->spawnUI(0, getRenderLayer());
                            }
                        }
                    }
                }else{
                    status_label->setText(tr("Connected, waiting for data..."));
                }
            }
            break;
        }
    }
}

bool AutoConnectScreen::isValidShip(int index)
{
    P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(index);

    if (!ship || !ship->ship_template)
        return false;

    for(auto it : ship_filters)
    {
        if (it.first == "solo")
        {
            int crew_at_position = 0;
            foreach(PlayerInfo, i, player_info_list)
            {
                if (i->ship_id == ship->getMultiplayerId())
                {
                    if (first_crew_position != max_crew_positions && i->crew_position[first_crew_position])
                        crew_at_position++;
                }
            }
            if (crew_at_position > 0)
                return false;
        }
        else if (it.first == "faction")
        {
            if (ship->getFactionId() != FactionInfo::findFactionId(it.second))
                return false;
        }
        else if (it.first == "callsign")
        {
            if (ship->getCallSign().lower() != it.second.lower())
                return false;
        }
        else if (it.first == "type")
        {
            if (ship->getTypeName().lower() != it.second.lower())
                return false;
        }
        else
        {
            LOG(WARNING) << "Unknown ship filter: " << it.first << " = " << it.second;
        }
    }
    return true;
}

void AutoConnectScreen::connectToShip(int index)
{
    P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(index);

    for (ECrewPosition crew_position : crew_positions)
    {
        if (crew_position != max_crew_positions)    //If we are not the main screen, setup the right crew position.
        {
            my_player_info->commandSetCrewPosition(0, crew_position, true);
        } else {
            my_player_info->commandSetMainScreen(0, true);
        }
    }
    my_player_info->commandSetMainScreenControl(0, control_main_screen);
    my_player_info->commandSetShipId(ship->getMultiplayerId());
}
