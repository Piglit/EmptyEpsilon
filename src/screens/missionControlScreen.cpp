#include "missionControlScreen.h"
#include "menus/serverCreationScreen.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "screenComponents/customShipFunctions.h"
#include "gameGlobalInfo.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "campaign_client.h"
#include "preferenceManager.h"
#include "random.h"

MissionControlScreen::MissionControlScreen(RenderLayer* render_layer)
: MissionControlScreen(render_layer, glm::vec2(random(-100, 100), random(-100, 100)), random(0, 360)) {}

MissionControlScreen::MissionControlScreen(RenderLayer* render_layer, glm::vec2 spawnPos, int spawnRota): GuiCanvas(render_layer)
{
    spawn_pos = spawnPos;
    spawn_rota= spawnRota;
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Draw a container with two columns.
    auto container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");
    auto left_panel = new GuiPanel(container, "");
    left_panel->setPosition(50 ,50, sp::Alignment::TopLeft)->setSize(350, 280);
    auto right_panel = new GuiPanel(container, "");
    right_panel->setPosition(50 ,50, sp::Alignment::TopLeft)->setSize(510, 370);

    string callsign = PreferencesManager::get("shipname", "");

    // mission info

    auto mission_info_container = new GuiElement(left_panel, "");
    mission_info_container->setMargins(25)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    (new GuiLabel(mission_info_container, "SCENARIO_INFO_LABEL", tr("Mission control"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    if (game_server) {
        string name = gameGlobalInfo->scenario;
        (new GuiKeyValueDisplay(mission_info_container, "SCENARIO_INFO_NAME", 0.4, tr("Mission Name"), name))->setTextSize(20)->setMarginTop(-10)->setSize(GuiElement::GuiSizeMax, 50);
    } else {
        left_panel->setSize(350, 100);
    }

    clock = new GuiKeyValueDisplay(mission_info_container, "CLOCK", 0.4, tr("Mission Time"), "0");
    clock->setTextSize(20)->setMarginTop(-10)->setSize(GuiElement::GuiSizeMax, 50);

    // Buttons and controls
    if (game_server) {
        pause_button = new GuiToggleButton(mission_info_container, "PAUSE_BUTTON", tr("button", "Pause"), [this](bool value) {
            if (!value) {
                gameGlobalInfo->setPause(false);
            } else {
                gameGlobalInfo->setPause(true);
            }
        });
        pause_button->setValue(engine->getGameSpeed() == 0.0f)->setSize(GuiElement::GuiSizeMax, 50);
        if (!game_server) {
            pause_button->hide();
        } else {
            (new GuiButton(mission_info_container, "QUIT", tr("Quit Mission"), [this]() {
                destroy();
                new ServerCampaignScreen();
            }))->setSize(GuiElement::GuiSizeMax, 50);
        }

    }

    // Right side, Dynamic content: ship

    // Ship Info
    ship_infos = new GuiElement(right_panel, "");
    ship_infos->setPosition(0,0)->setMargins(25)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
;

    (new GuiLabel(ship_infos, "SHIP_INFO_LABEL", tr("Ship info"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    ship_name = new GuiKeyValueDisplay(ship_infos, "SHIP_NAME", 0.4, tr("Ship Name"), callsign);
    ship_name->setMarginTop(-10)->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 50);

    ship_drive = new GuiKeyValueDisplay(ship_infos, "SHIP_DRIVE", 0.4, tr("Ship Drive"), "");
    ship_drive->setMarginTop(-10)->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 50);

    ship_type = new GuiKeyValueDisplay(ship_infos, "SHIP_TYPE", 0.4, tr("Ship Type"), "");
    ship_type->setMarginTop(-10)->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 50);

    ship_class = new GuiKeyValueDisplay(ship_infos, "SHIP_CLASS", 0.4, tr("Ship Class"), "");
    ship_class->setMarginTop(-10)->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 50);

    ship_subclass = new GuiKeyValueDisplay(ship_infos, "SHIP_SUBCLASS", 0.4, tr("Ship Subclass"), "");
    ship_subclass->setMarginTop(-10)->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 50);

    // ship creation panel

    ship_content = new GuiElement(right_panel, "");
    ship_content->setMargins(25)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    ship_content->setAttribute("layout", "vertical");
    ship_content->setAttribute("alignment", "topleft");

    (new GuiLabel(ship_content, "SHIP_CONFIG_LABEL", tr("Ship configuration"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // Ship type selection
    (new GuiLabel(ship_content, "SELECT_SHIP_LABEL", tr("Select ship type:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    ship_template_selector = new GuiSelector(ship_content, "CREATE_SHIP_SELECTOR", [this](int index, string value){
        if (database_view->findAndDisplayEntry(value))
            LOG(INFO) << value << " found";
        else
            LOG(INFO) << value << " not found";
    });
    // List only ships with templates designated for player use.
    std::vector<string> template_names = campaign_client->getShips();

    for(string& template_name : template_names)
    {
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
        ship_template_selector->addEntry(template_name + " (" + ship_template->getClass() + ": " + ship_template->getSubClass() + ")", template_name);
    }
    ship_template_selector->setSelectionIndex(0);
    ship_template_selector->setSize(GuiElement::GuiSizeMax, 50);

    // Ship drive selection

    (new GuiLabel(ship_content, "SELECT_DRIVE_LABEL", tr("Select drive type:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    ship_drive_selector = new GuiSelector(ship_content, "SHIP_DRIVE_SELECTOR", nullptr);
    ship_drive_selector->addEntry("Jump drive", "jump");
    ship_drive_selector->addEntry("Warp drive", "warp");
    ship_drive_selector->setSelectionIndex(0);
    ship_drive_selector->setSize(GuiElement::GuiSizeMax, 50);

    // Spawn a ship of the selected template near 0,0 and give it a random
    // heading.
    ship_create_button = new GuiButton(ship_content, "CREATE_SHIP_BUTTON", tr("Create ship"), [this]() {
        if ((!gameGlobalInfo->allow_new_player_ships) || (my_spaceship))
            return;
        string callsign = PreferencesManager::get("shipname", "");
        if (game_server) {
            P<PlayerSpaceship> ship = new PlayerSpaceship();
            string templ = ship_template_selector->getSelectionValue();
            if (ship)
            {
                // set the position before the template so that onNewPlayerShip has as much data as possible
                ship->setRotation(spawn_rota);
                ship->target_rotation = spawn_rota;
                ship->setPosition(spawn_pos);
                ship->setCallSign(callsign);
                ship->setTemplate(templ);
                if (ship_drive_selector->getSelectionValue() == "jump") {
                    ship->setJumpDrive(true);
                    ship->setWarpDrive(false);
                } else {
                    ship->setJumpDrive(false);
                    ship->setWarpDrive(true);
                }
                my_player_info->commandSetShipId(ship->getMultiplayerId());
                ship_create_button->disable();
            }
        } else {
            // proxy
            campaign_client->spawnShipOnProxy(PreferencesManager::get("proxy_addr"), callsign, ship_template_selector->getSelectionValue(), ship_drive_selector->getSelectionValue(), PreferencesManager::get("password"), spawn_pos.x, spawn_pos.y, spawn_rota);
            ship_create_button->disable();
        }
    });
    ship_create_button->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);


    if (!my_spaceship) {
        int index = gameGlobalInfo->getPlayerShipIndexByName(callsign); // -1 if not found
        if (index >= 0) {
            auto ship = gameGlobalInfo->getPlayerShip(index);
            my_player_info->commandSetShipId(ship->getMultiplayerId()); // sets my_spaceship
        }
    }

    // Station Info

    station_content = new GuiElement(right_panel, "");
    station_content->setMargins(25)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    station_content->setAttribute("layout", "vertical");
    station_content->setAttribute("alignment", "topleft");

    (new GuiLabel(station_content, "STATION_INFO_LABEL", tr("Ship configuration"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    //station_name = new GuiKeyValueDisplay(station_content, "STATION_NAME", 0.4, tr("Docked with "), callsign);
    //station_name->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 50);

    ship_destroy_button = new GuiButton(station_content, "DESTROY_SHIP_BUTTON", tr("Change ship"), [this]() {
        if ((!gameGlobalInfo->allow_new_player_ships) || !(my_spaceship))
            return;
        spawn_pos = my_spaceship->getPosition();
        spawn_rota = my_spaceship->getRotation();
        if (game_server) {
            my_spaceship->destroy();
        } else {
            //proxy
            campaign_client->destroyShipOnProxy(PreferencesManager::get("proxy_addr"), my_spaceship->getCallSign());
        }
        destroy();
        new MissionControlScreen(getRenderLayer(), spawn_pos, spawn_rota);
    });
    ship_destroy_button->setSize(GuiElement::GuiSizeMax, 50);

    database_container = new GuiElement(this, "");
    database_container->setPosition(370, 480)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    database_view = new DatabaseViewComponent(database_container, false);
    database_view->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

}

void MissionControlScreen::update(float delta)
{

    unsigned int seconds = gameGlobalInfo->elapsed_time;
    unsigned int minutes = (seconds / 60) % 60;
    unsigned int hours = (seconds / 60 / 60) % 24;
    seconds = seconds % 60;
    char buf[9];
    std::snprintf(buf, 9, "%02d:%02d:%02d", hours, minutes, seconds);

    // Update mission clock
    clock->setValue(string(buf));

    // Update pause button
    if (game_server)
        pause_button->setValue(engine->getGameSpeed() == 0.0f);

    // States of dynamic panel:
    /* no ship  -> show ship_content
                -> hide ship_infos
                -> hide station_content
        ship    -> show ship_infos
                -> hide ship_content
       docking  -> show station_content
       not dock -> hide station_content
    */

    // set my_spaceship
    if (!my_spaceship) {
        string callsign = PreferencesManager::get("shipname", "");
        int index = gameGlobalInfo->getPlayerShipIndexByName(callsign); // -1 if not found
        if (index >= 0) {
            auto ship = gameGlobalInfo->getPlayerShip(index);
            my_player_info->commandSetShipId(ship->getMultiplayerId()); // sets my_spaceship
        }
    }

    if (my_spaceship) {
        // Update ship_content
        ship_content->hide();
        ship_create_button->enable();   // but is hidden. Was disabled through button pressed. Kept is disabled until ship arrived

        // Update ship_infos 
        ship_infos->show();
        ship_name->setValue(my_spaceship->getCallSign());
        string templ_name = my_spaceship->getTypeName();
        ship_type->setValue(templ_name);
        auto templ = ShipTemplate::getTemplate(templ_name);
        if (templ) {
            ship_class->setValue(templ->getClass());
            ship_class->show();
            ship_subclass->setValue(templ->getSubClass());
            ship_subclass->show();
        } else {
            ship_class->hide();
            ship_subclass->hide();
        }
        string drive = "Impulse";
        if (my_spaceship->hasJumpDrive()){
            drive = "Jump";
        }
        if (my_spaceship->hasWarpDrive()){
            drive = "Warp";
        }
        if (my_spaceship->hasJumpDrive() && my_spaceship->hasWarpDrive()){
            drive = "Jump & Warp";
        }
        ship_drive->setValue(drive);

        // station content when docked
        bool docked = my_spaceship->docking_state == DS_Docked;
        station_content->setVisible(docked);

    } else {
        // !my_spaceship
        // ship was probably destroyed or has never existed
        station_content->hide();
        ship_content->setVisible(!!gameGlobalInfo->allow_new_player_ships);
        ship_infos->hide();
    }
}

