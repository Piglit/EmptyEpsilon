#include <i18n.h>
#include "preferenceManager.h"
#include "scenarioSelectionScreen.h"
#include "shipSelectionScreen.h"
#include "gameGlobalInfo.h"
#include "epsilonServer.h"
#include "multiplayer_proxy.h"
#include "campaign_client.h"
#include "screens/extra/missionControlScreen.h"
#include "gui/scriptError.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "scenarioInfo.h"
#include "main.h"

ScenarioSelectionScreen::ScenarioSelectionScreen()
{
    assert(game_server);

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    // Set defaults from preferences.
    gameGlobalInfo->player_warp_jump_drive_setting = EPlayerWarpJumpDrive(PreferencesManager::get("server_config_warp_jump_drive_setting", "0").toInt());
    gameGlobalInfo->scanning_complexity = EScanningComplexity(PreferencesManager::get("server_config_scanning_complexity", "2").toInt());
    gameGlobalInfo->hacking_difficulty = PreferencesManager::get("server_config_hacking_difficulty", "1").toInt();
    gameGlobalInfo->hacking_games = EHackingGames(PreferencesManager::get("server_config_hacking_games", "2").toInt());
    gameGlobalInfo->use_beam_shield_frequencies = PreferencesManager::get("server_config_use_beam_shield_frequencies", "1").toInt();
    gameGlobalInfo->use_system_damage = PreferencesManager::get("server_config_use_system_damage", "1").toInt();
    gameGlobalInfo->allow_main_screen_tactical_radar = PreferencesManager::get("server_config_allow_main_screen_tactical_radar", "1").toInt();
    gameGlobalInfo->allow_main_screen_long_range_radar = PreferencesManager::get("server_config_allow_main_screen_long_range_radar", "1").toInt();
    gameGlobalInfo->gm_control_code = PreferencesManager::get("server_config_gm_control_code", "").upper();
    game_server->setServerName(PreferencesManager::get("shipname", "Server").lower());

    // Create a two-column layout.
    GuiElement* container = new GuiAutoLayout(this, "", GuiAutoLayout::ELayoutMode::LayoutVerticalColumns);
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    GuiElement* left_container = new GuiElement(container, "");
    GuiElement* right_container = new GuiElement(container, "");

    GuiElement* left_panel = new GuiAutoLayout(left_container, "", GuiAutoLayout::LayoutVerticalTopToBottom);
    left_panel->setPosition(0, 20, ATopCenter)->setSize(550, GuiElement::GuiSizeMax);
    GuiElement* right_panel = new GuiAutoLayout(right_container, "", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_panel->setPosition(0, 20, ATopCenter)->setSize(550, GuiElement::GuiSizeMax);

    // Left column contents.
    // Scenario section.
    (new GuiLabel(left_panel, "SCENARIO_LABEL", tr("Mission"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // List each scenario derived from scenario_*.lua files in Resources.
    GuiListbox* scenario_list = new GuiListbox(left_panel, "SCENARIO_LIST", [this](int index, string value) {
        selectScenario(value);
    });
    scenario_list->setSize(GuiElement::GuiSizeMax, 700);

    // Right column contents.
    (new GuiLabel(right_panel, "BRIEFING_LABEL", tr("Briefing"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // Show the scenario description text.
    GuiPanel* panel = new GuiPanel(right_panel, "SCENARIO_DESCRIPTION_BOX");
    panel->setSize(GuiElement::GuiSizeMax, 500);
    scenario_description = new GuiScrollText(panel, "SCENARIO_DESCRIPTION", "");
    scenario_description->setTextSize(24)->setMargins(15)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // If the scenario has variations, show and select from them.
    variation_container = new GuiAutoLayout(right_panel, "VARIATION_CONTAINER", GuiAutoLayout::LayoutVerticalTopToBottom);
    variation_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    GuiElement* row = new GuiAutoLayout(variation_container, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "VARIATION_LABEL", tr("Variation: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    variation_selection = new GuiSelector(row, "VARIATION_SELECT", [this](int index, string value) {
        gameGlobalInfo->variation = variation_names_list.at(index);
        variation_description->setText(variation_descriptions_list.at(index));
    });
    variation_selection->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    panel = new GuiPanel(variation_container, "VARIATION_DESCRIPTION_BOX");
    panel->setSize(GuiElement::GuiSizeMax, 150);
    variation_description = new GuiScrollText(panel, "VARIATION_DESCRIPTION", "");
    variation_description->setTextSize(24)->setMargins(15)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // If this is a proxied multi-ship mission, add ship type selection.
    // TODO positioning
    GuiElement* ship_container = new GuiElement(right_container, "");
    ship_container = new GuiAutoLayout(right_panel, "SHIP_CONTAINER", GuiAutoLayout::LayoutVerticalTopToBottom);
    ship_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

/*
        // List only ships with templates designated for player use.
        std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::PlayerShip);
        std::sort(template_names.begin(), template_names.end());

        for(string& template_name : template_names)
        {
            P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
            ship_template_selector->addEntry(template_name + " (" + ship_template->getClass() + ":" + ship_template->getSubClass() + ")", template_name);
        }
        ship_template_selector->setSelectionIndex(0);
        ship_template_selector->show();
*/

    GuiElement* ship_row = new GuiAutoLayout(ship_container, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    ship_row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(ship_row, "SHIP_LABEL", tr("ship type: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    GuiSelector* ship_selection= new GuiSelector(ship_row, "SHIP_TEMPLATE_SELECTOR", [this](int index, string value) {
            //TODO
        //gameGlobalInfo->ship = ship_names_list.at(index);
        //ship_description->setText(ship_descriptions_list.at(index));
    });
    ship_selection->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    panel = new GuiPanel(ship_container, "SHIP_DESCRIPTION_BOX");
    panel->setSize(GuiElement::GuiSizeMax, 150);
    GuiScrollText* ship_description = new GuiScrollText(panel, "SHIP_DESCRIPTION", "");
    ship_description->setTextSize(24)->setMargins(15)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->hide();

    ship_container->hide();
    // Buttons beneath the columns.
    // Close server button.
    (new GuiButton(left_container, "BACK", tr("Back"), [this]() {
        destroy();
        disconnectFromServer();
        returnToMainMenu();
    }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    // Start server button.
    (new GuiButton(right_container, "START_SERVER", tr("Start scenario"), [this]() {
        startScenario();
    }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50);

    // Join server via proxy button.
    (new GuiButton(right_container, "JOIN_SERVER", tr("Join scenario"), [this]() {
        joinScenario(); 
    }))->setPosition(0, -50, ABottomCenter)->setSize(300, 50)->hide();


    // We select the same mission as we had previously selected
    // unless that one doesnt exist in which case we select the first by default
    int mission_selected = 0;

    if (campaign_client)
    {
        // Fetch list of available scenario filenames from campaign server
        for (string filename: campaign_client->getScenarios())
        {
            ScenarioInfo info(filename);
            scenario_list->addEntry(info.name, filename);
            if (info.name == gameGlobalInfo->scenario)
            {
                mission_selected=scenario_list->entryCount()-1;
            }
        }
    }
    else
    {
        // Fetch and sort all Lua files starting with "scenario_".
        std::vector<string> scenario_filenames = findResources("scenario_*.lua");
        std::sort(scenario_filenames.begin(), scenario_filenames.end());
        // remove duplicates
        scenario_filenames.erase(std::unique(scenario_filenames.begin(), scenario_filenames.end()), scenario_filenames.end());
        // For each scenario file, extract its name, then add it to the list.
        for(string filename : scenario_filenames)
        {
            ScenarioInfo info(filename);
            scenario_list->addEntry(info.name, filename);
            if (info.name == gameGlobalInfo->scenario)
            {
                mission_selected=scenario_list->entryCount()-1;
            }
        }
    }

    scenario_list->setSelectionIndex(mission_selected);
    scenario_list->scrollTo(mission_selected);
    selectScenario(scenario_list->getSelectionValue());

    gameGlobalInfo->reset();
}

void ScenarioSelectionScreen::selectScenario(string filename)
{
    // When a scenario is selected, display its description and variations.
    selected_scenario_filename = filename;

    // Open the scenario file.
    ScenarioInfo info(selected_scenario_filename);
    scenario_description->setText(info.description);

    // Initialize variables.
    variation_selection->setSelectionIndex(0);
    variation_names_list = {tr("variation", "None")};

    string variation_requested = variation_names_list[0];
    if (gameGlobalInfo->scenario == info.name)
    {
        variation_requested = gameGlobalInfo->variation;
    }

    variation_descriptions_list = {tr("No variation selected. Play the scenario as intended.")};
    variation_description->setText(variation_descriptions_list[0]);

    int selected_variation = 0;
    for(auto variation : info.variations)
    {
        variation_names_list.push_back(variation.first);
        variation_descriptions_list.push_back(variation.second);
        if (variation_requested == variation.first)
        {
            selected_variation=variation_names_list.size()-1;
        }
    }

    variation_selection->setOptions(variation_names_list);

    gameGlobalInfo->scenario = info.name;
    gameGlobalInfo->variation = variation_names_list[selected_variation];

    variation_selection->setSelectionIndex(selected_variation);
    variation_description->setText(variation_descriptions_list[selected_variation]);

    // Show the variation information only if there's more than 1.
    variation_container->setVisible(variation_names_list.size() > 1);
}

void ScenarioSelectionScreen::startScenario()
{
    // Set these settings to use as future defaults.
    PreferencesManager::set("server_config_warp_jump_drive_setting", string(int(gameGlobalInfo->player_warp_jump_drive_setting)));
    PreferencesManager::set("server_config_scanning_complexity", string(int(gameGlobalInfo->scanning_complexity)));
    PreferencesManager::set("server_config_hacking_difficulty", string(int(gameGlobalInfo->hacking_difficulty)));
    PreferencesManager::set("server_config_hacking_games", string(int(gameGlobalInfo->hacking_games)));
    PreferencesManager::set("server_config_use_beam_shield_frequencies", string(int(gameGlobalInfo->use_beam_shield_frequencies)));
    PreferencesManager::set("server_config_use_system_damage", string(int(gameGlobalInfo->use_system_damage)));
    PreferencesManager::set("server_config_allow_main_screen_tactical_radar", string(int(gameGlobalInfo->allow_main_screen_tactical_radar)));
    PreferencesManager::set("server_config_allow_main_screen_long_range_radar", string(int(gameGlobalInfo->allow_main_screen_long_range_radar)));

    // Start the selected scenario.
    gameGlobalInfo->startScenario(selected_scenario_filename);

    // Destroy this screen and move on.
    destroy();
    new MissionControlScreen();
    new ScriptErrorRenderer();
}

void ScenarioSelectionScreen::joinScenario()
{
    string hostname = "192.168.2.3";    // TODO testing; get from scenario info
    disconnectFromServer(); // Test if socket is released immediately
    new GameServerProxy(hostname, defaultServerPort, PreferencesManager::get("password"), defaultServerPort, PreferencesManager::get("shipname"));
    //destroy();
    //new ProxyObservationScreen();
    
}
