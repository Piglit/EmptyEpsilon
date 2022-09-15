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
: GuiCanvas(render_layer)
{

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Draw a container with two columns.
    auto container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");
    auto left_container = new GuiElement(container, "");
    left_container->setSize(350, GuiElement::GuiSizeMax);
    auto right_container = new GuiElement(container, "");
    right_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    auto right_panel = new GuiPanel(right_container, "DIRECT_OPTIONS_PANEL");
    right_panel->setPosition(0, 50, sp::Alignment::TopCenter)->setSize(550, 560);
    auto right_content = new GuiElement(right_panel, "");
    right_content->setMargins(50)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");


    string callsign = PreferencesManager::get("shipname", "");
    int posy = 20;

    // server info

    (new GuiLabel(left_container, "SERVER_INFO_LABEL", tr("Server info"), 30))->addBackground()->setPosition(20, posy, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 40;

    // Server name row.
    string name;
    if (game_server) {
        name = game_server->getServerName();
    } else {
        name = callsign;
    }

    (new GuiKeyValueDisplay(left_container, "SERVER_NAME", 0.4, tr("Server Name"), name))->setTextSize(20)->setPosition(20,posy,sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 40;
    auto ip = sp::io::network::Address::getLocalAddress().getHumanReadable()[0];
    (new GuiKeyValueDisplay(left_container, "SERVER_IP", 0.4, tr("Server Ip"), ip))->setTextSize(20)->setPosition(20,posy,sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 40;

    // mission info

    posy += 40;
    (new GuiLabel(left_container, "SCENARIO_INFO_LABEL", tr("Mission info"), 30))->addBackground()->setPosition(20, posy, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 40;

    name = gameGlobalInfo->scenario;
    (new GuiKeyValueDisplay(left_container, "SCENARIO_INFO_NAME", 0.4, tr("Mission Name"), name))->setTextSize(20)->setPosition(20,posy,sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 40;

    info_clock = new GuiKeyValueDisplay(left_container, "CLOCK", 0.4, tr("Mission Time"), "0");
    info_clock->setTextSize(20)->setPosition(20,posy,sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 40;

    
    // Buttons and controls
    
    posy += 40;
    (new GuiLabel(left_container, "BUTTON_LABEL", tr("Mission control"), 30))->addBackground()->setPosition(20,posy, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 50;
    pause_button = new GuiToggleButton(left_container, "PAUSE_BUTTON", tr("button", "Pause"), [this](bool value) {
        if (!value)
            engine->setGameSpeed(1.0f);
        else
            engine->setGameSpeed(0.0f);
    });
    pause_button->setValue(engine->getGameSpeed() == 0.0f)->setPosition(20, posy, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    posy += 50;
    if (!game_server) {
        pause_button->hide();
    } else {
        (new GuiButton(left_container, "QUIT", tr("Quit Mission"), [this]() {
            destroy();
            new ServerScenarioSelectionScreen();
        }))->setPosition(20, posy, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
    }

    posy += 50;

    posy += 50;

    // If this is the server, add a panel to create player ships.
    //Add buttons and a selector to create player ships.


    if ((gameGlobalInfo->allow_new_player_ships) && (gameGlobalInfo->getPlayerShipIndexByName(callsign) == -1))
    {
        (new GuiLabel(left_container, "SHIP_CONFIG_LABEL", tr("Ship selection"), 30))->addBackground()->setPosition(20, posy, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
        GuiSelector* ship_template_selector = new GuiSelector(left_container, "CREATE_SHIP_SELECTOR", nullptr);
        posy += 50;
        // List only ships with templates designated for player use.
        std::vector<string> template_names = campaign_client->getShips();

        for(string& template_name : template_names)
        {
            P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
            ship_template_selector->addEntry(template_name + " (" + ship_template->getClass() + ":" + ship_template->getSubClass() + ")", template_name);
        }
        ship_template_selector->setSelectionIndex(0);
        ship_template_selector->setPosition(0, posy, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
        posy += 50;

/*
        // Spawn a ship of the selected template near 0,0 and give it a random
        // heading.
        (new GuiButton(left_content, "CREATE_SHIP_BUTTON", tr("Spawn player ship"), [this, ship_template_selector]() {
            string callsign = PreferencesManager::get("shipname", "");
            if ((!gameGlobalInfo->allow_new_player_ships) || (gameGlobalInfo->getPlayerShipIndexByName(callsign) != -1))
                return;
            if (game_server) {
                P<PlayerSpaceship> ship = new PlayerSpaceship();

                if (ship)
                {
                    // set the position before the template so that onNewPlayerShip has as much data as possible
                    ship->setRotation(random(0, 360));
                    ship->target_rotation = ship->getRotation();
                    ship->setPosition(glm::vec2(random(-100, 100), random(-100, 100)));
                    ship->setCallSign(callsign);
                    ship->setTemplate(ship_template_selector->getSelectionValue());
                    my_player_info->commandSetShipId(ship->getMultiplayerId());
                }
            } else {
                // proxy
                campaign_client->spawnShipOnProxy(PreferencesManager::get("proxy_addr"), callsign, ship_template_selector->getSelectionValue(), PreferencesManager::get("password"));
            }
        }))->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(250, 50);

        */
    }


    // mission control
    /*
    gm_script_label = new GuiLabel(right_panel, "SERVER_GM_LABEL", tr("Mission control"), 30);
    gm_script_label->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    gm_script_options = new GuiListbox(right_panel, "GM_SCRIPT_OPTIONS", [this](int index, string value)
    {
        gm_script_options->setSelectionIndex(-1);
        int n = 0;
        for(GMScriptCallback& callback : gameGlobalInfo->gm_callback_functions)
        {
            if (n == index)
            {
                gm_script_options->setSelectionIndex(n);
                gm_script_button_response_time = 0.1;
                callback.callback.call<void>();
                return;
            }
            n++;
        }
    });
    gm_script_options->setPosition(0, 20, sp::Alignment::TopRight)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    if (!game_server || gameGlobalInfo->gm_callback_functions.empty())
    {
        gm_script_options->hide();
        gm_script_label->hide();
    }
    gm_script_button_response_time = 0.0;
*/
/*
    log_text = new GuiAdvancedScrollText(mission_control_layout, "SHIP_LOG");
    log_text->enableAutoScrollDown();
    log_text->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
*/
}

void MissionControlScreen::update(float delta)
{
    if (!game_server)
        return;
    int seconds = gameGlobalInfo->elapsed_time;
    int minutes = (seconds / 60) % 60;
    int hours =(seconds / 60 / 60);
    seconds = (seconds % 60);
    char buf[9];
    std::snprintf(buf, 9, "%02d:%02d:%02d", hours, minutes, seconds);

    // Update mission clock
    info_clock->setValue(string(buf));

    // Update pause button
    pause_button->setValue(engine->getGameSpeed() == 0.0f);

/*
    bool gm_functions_changed = gm_script_options->entryCount() != int(gameGlobalInfo->gm_callback_functions.size());
    auto it = gameGlobalInfo->gm_callback_functions.begin();
    for(int n=0; !gm_functions_changed && n<gm_script_options->entryCount(); n++)
    {
        if (gm_script_options->getEntryName(n) != it->name)
            gm_functions_changed = true;
        it++;
    }
    if (gm_script_button_response_time > 0.0)
    {
        gm_script_button_response_time -= delta;
        if (gm_script_button_response_time <= 0.0)
        {
            gm_functions_changed = true;
        }
    }
    if (gm_functions_changed)
    {
        gm_script_options->setOptions({});
        for(const GMScriptCallback& callback : gameGlobalInfo->gm_callback_functions)
        {
            gm_script_options->addEntry(callback.name, callback.name);
        }
        gm_script_options->setSelectionIndex(-1);
    }
*/
    // upate log
    /*
    if (my_spaceship)
    {

        const std::vector<PlayerSpaceship::ShipLogEntry>& logs = my_spaceship->getShipsLog();
        if (log_text->getEntryCount() > 0 && logs.size() == 0)
            log_text->clearEntries();

        while(log_text->getEntryCount() > logs.size())
        {
            log_text->removeEntry(0);
        }

        if (log_text->getEntryCount() > 0 && logs.size() > 0 && log_text->getEntryText(0) != logs[0].text)
        {
            bool updated = false;
            for(unsigned int n=1; n<log_text->getEntryCount(); n++)
            {
                if (log_text->getEntryText(n) == logs[0].text)
                {
                    for(unsigned int m=0; m<n; m++)
                        log_text->removeEntry(0);
                    updated = true;
                    break;
                }
            }
            if (!updated)
                log_text->clearEntries();
        }

        while(log_text->getEntryCount() < logs.size())
        {
            int n = log_text->getEntryCount();
            log_text->addEntry(logs[n].prefix, logs[n].text, logs[n].color);
        }
    }
*/
}

