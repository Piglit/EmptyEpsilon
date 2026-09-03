#include <i18n.h>
#include "preferenceManager.h"
#include "serverCreationScreen.h"
#include "campaignMenu.h"
#include "shipSelectionScreen.h"
#include "gameGlobalInfo.h"
#include "epsilonServer.h"
#include "multiplayer_proxy.h"
#include "multiplayer_client.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "scenarioInfo.h"
#include "main.h"
#include "campaign_client.h"
#include "screens/missionControlScreen.h"
#include "serverBrowseMenu.h"
#include "joinServerMenu.h"


ServerSetupScreen::ServerSetupScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    // Create main layout
    GuiElement* main_panel = new GuiElement(this, "");
    main_panel->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(750, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    // Left column contents.
    // General section.
    (new GuiLabel(main_panel, "GENERAL_LABEL", tr("Server configuration"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    // Server name row.
    GuiElement* row = new GuiElement(main_panel, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "NAME_LABEL", tr("Server name: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_name = new GuiTextEntry(row, "SERVER_NAME", PreferencesManager::get("headless_name", "server"));
    server_name->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server password row.
    row = new GuiElement(main_panel, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "PASSWORD_LABEL", tr("Server password: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_password = new GuiTextEntry(row, "SERVER_PASSWORD", "");
    server_password->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // GM control code row.
    row = new GuiElement(main_panel, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "GM_CONTROL_CODE_LABEL", tr("GM control code: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    gm_password = new GuiTextEntry(row, "GM_CONTROL_CODE", "");
    gm_password->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // LAN/Internet row.
    row = new GuiElement(main_panel, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "LAN_INTERNET_LABEL", tr("List on master server: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_visibility = new GuiSelector(row, "LAN_INTERNET_SELECT", [](int index, string value) { });
    server_visibility->setOptions({tr("No"), tr("Yes")})->setSelectionIndex(0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    row = new GuiElement(main_panel, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "SERVER_PORT", tr("Server port: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(250, GuiElement::GuiSizeMax);
    server_port = new GuiTextEntry(row, "SERVER_PORT", string(defaultServerPort));
    server_port->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    (new GuiLabel(main_panel, "GENERAL_LABEL", tr("Server info"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    string reverse_proxy_value;
    if((reverse_proxy_value = PreferencesManager::get("serverproxy")) != "")
    {   
        GuiPanel* panel = new GuiPanel(main_panel, "SERVERPROXY_MESSAGE_BOX");
        panel->setSize(GuiElement::GuiSizeMax, 80);
        //Serverproxy (reverse proxy) is directly configured in options or command line   
        (new GuiLabel(panel, "SERVERPROXY_LABEL", tr("Server was configured to connect to reverse proxy:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
        string ips;
        string sep="";
        for(auto proxy_ip : reverse_proxy_value.split(":"))
        {
            ips = ips + sep + "[" + proxy_ip+ "]";
            sep = ",";   
        }
        (new GuiLabel(panel, "SERVERPROXY_IPS", ips, 30))->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0,30);
    }

    // Server IP row.
    row = new GuiElement(main_panel, "");
    row->setSize(GuiElement::GuiSizeMax, 350)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "IP_LABEL", tr("Server IP: "), 30))->setAlignment(sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
    auto ips = new GuiListbox(row, "IP", [](int index, string value){});
    ips->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    ips->setTextSize(20);
    for(auto addr_str : sp::io::network::Address::getLocalAddress().getHumanReadable())
    {
        if (addr_str == "::1" || addr_str == "127.0.0.1") continue;
        ips->addEntry(addr_str, addr_str);
    }

    //======== Bottom buttons
    // Close server button.
    (new GuiButton(this, "CLOSE_SERVER", tr("Close"), [this]() {
        destroy();
        returnToMainMenu(getRenderLayer());
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    (new GuiButton(this, "START_SERVER", tr("Start server"), [this]() {
        int port = server_port->getText().toInt();
        if (port < 1)
            port = defaultServerPort;
        new EpsilonServer(port);
        game_server->setServerName(server_name->getText());
        game_server->setPassword(server_password->getText().upper());
        gameGlobalInfo->gm_control_code = gm_password->getText().upper();
        if (server_visibility->getSelectionIndex() == 1)
        {
            game_server->registerOnMasterServer(PreferencesManager::get("registry_registration_url", "http://daid.eu/ee/register.php"));
            new ServerSetupMasterServerRegistrationScreen();
        }
        else
        {
            new ServerScenarioSelectionScreen();
        }
        destroy();
    }))->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);
}

ServerSetupMasterServerRegistrationScreen::ServerSetupMasterServerRegistrationScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    info_label = new GuiLabel(this, "INFO", "", 30);
    info_label->setPosition({0, 0}, sp::Alignment::Center);

    (new GuiButton(this, "CLOSE_SERVER", tr("Close"), [this]() {
        disconnectFromServer();
        new ServerSetupScreen();        
        destroy();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    continue_button = new GuiButton(this, "CONTINUE", tr("Continue"), [this]() {
        new ServerScenarioSelectionScreen();
        destroy();
    });
    continue_button->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);
}

void ServerSetupMasterServerRegistrationScreen::update(float delta)
{
    switch(game_server->getMasterServerState())
    {
    case GameServer::MasterServerState::Disabled:
        info_label->setText("Not connecting to masterserver?");
        continue_button->enable();
        break;
    case GameServer::MasterServerState::Registering:
        info_label->setText("Connecting to master server");
        continue_button->disable();
        break;
    case GameServer::MasterServerState::Success:
        info_label->setText("Master server connection successful");
        continue_button->enable();
        break;
    case GameServer::MasterServerState::FailedToReachMasterServer:
        info_label->setText("Failed to reach the master server.");
        continue_button->disable();
        break;
    case GameServer::MasterServerState::FailedPortForwarding:
        info_label->setText("Port forwarding check failed.");
        continue_button->disable();
        break;
    }
}

ServerScenarioSelectionScreen::ServerScenarioSelectionScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    GuiElement* container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");

    GuiElement* left = new GuiElement((new GuiElement(container, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax), "");
    left->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(400, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    (new GuiLabel(left, "GENERAL_LABEL", tr("Category"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    category_list = new GuiListbox(left, "SCENARIO_CATEGORY", [this](int index, string value) {
        loadScenarioList(value);
    });
    category_list->setSize(GuiElement::GuiSizeMax, 700);
    for(const auto& category : ScenarioInfo::getCategories())
        category_list->addEntry(category, category);
    GuiElement* middle = new GuiElement((new GuiElement(container, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax), "");
    middle->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(400, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    GuiElement* right = new GuiElement((new GuiElement(container, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax), "");
    right->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(400, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    (new GuiLabel(middle, "GENERAL_LABEL", tr("Scenario"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    scenario_list = new GuiListbox(middle, "SCENARIO_LIST", [this](int index, string value)
    {
        ScenarioInfo info(value);
        description_text->setText(info.description);
        start_button->enable();
        start_button->setText(tr("Start scenario"));
    });
    scenario_list->setSize(GuiElement::GuiSizeMax, 700);
    (new GuiLabel(right, "GENERAL_LABEL", tr("Description"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    description_text = new GuiScrollText(right, "SCENARIO_DESCRIPTION", tr("Select a scenario..."));
    description_text->setSize(GuiElement::GuiSizeMax, 700);


    //======== Bottom buttons
    // Close server button.
    (new GuiButton(this, "CLOSE_SERVER", tr("Close"), [this]() {
        destroy();
        disconnectFromServer();
        new ServerSetupScreen();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    start_button = new GuiButton(this, "START_SCENARIO", tr("Start scenario"), [this]() {
        if (scenario_list->getSelectionIndex() == -1)
            return;
        auto filename = scenario_list->getEntryValue(scenario_list->getSelectionIndex());
        ScenarioInfo info(filename);

        if (info.settings.empty())
        {
            // Start the selected scenario.
            gameGlobalInfo->scenario = info.name;
            gameGlobalInfo->startScenario(filename);

            // Destroy this screen and move on to ship selection.
            destroy();
            if (gameGlobalInfo->campaign_running) {
                new MissionControlScreen(getRenderLayer(), glm::vec2(info.spawn_x, info.spawn_y), info.spawn_rot);
            } else {
                returnToShipSelection(getRenderLayer());
            }
        }
        else
        {
            new ServerScenarioOptionsScreen(filename);
            destroy();
        }
    });
    start_button->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50)->disable();

    // Select the previously selected scenario.
    for(const auto& info : ScenarioInfo::getScenarios()) {
        if (info.name == gameGlobalInfo->scenario) {
            for(int n=0; n<category_list->entryCount(); n++) {
                if (info.hasCategory(category_list->getEntryValue(n))) {
                    category_list->setSelectionIndex(n);
                    category_list->scrollTo(n);
                    loadScenarioList(category_list->getEntryValue(n));
                    break;
                }
                for(int n=0; n<scenario_list->entryCount(); n++) {
                    if (info.filename == scenario_list->getEntryValue(n))
                    {
                        scenario_list->setSelectionIndex(n);
                        scenario_list->scrollTo(n);
                        description_text->setText(info.description);
                        start_button->enable();
                        break;
                    }
                }
            }
        }
    }

    gameGlobalInfo->reset();
    gameGlobalInfo->scenario_settings.clear();
}

ServerCampaignScreen::ServerCampaignScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    GuiElement* container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");



    GuiElement* middle = new GuiElement((new GuiElement(container, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax), "");
    middle->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(400, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    right = (new GuiElement(container, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    layout = new GuiElement(right, "");
    layout ->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(600, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    // infos
    (new GuiLabel(middle, "GENERAL_LABEL", tr("Info"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    first_list = new GuiListbox(middle, "INFO_LIST", [this](int index, string value)
    {
        if (crew_text_label)
        {
            crew_text_label->destroy();
            crew_amount_label->destroy();
            crew_text_label = nullptr;
            crew_amount_label = nullptr;
        }
        layout->destroy();
        layout = new GuiElement(right, "");
        layout->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(600, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

        start_button->disable()->hide();
        scenario_list->setSelectionIndex(-1);
        proxy_list->setSelectionIndex(-1);
        if (value == "Instructions")
        {
            (new GuiLabel(layout, "GENERAL_LABEL", tr("Instructions"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
            (new GuiScrollText(layout, "SCENARIO_DESCRIPTION", briefing_text))->setTextSize(25)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
        else if (value == "Network")
        {
            auto name = game_server->getServerName();
            auto ip = sp::io::network::Address::getLocalAddress().getHumanReadable()[0];
            auto version = string(VERSION_NUMBER);
            (new GuiLabel(layout, "SERVER_INFO", tr("Server"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
            (new GuiKeyValueDisplay(layout, "SERVER_INFO_NAME", 0.4, tr("Server Name:"), name))->setMarginTop(-10)->setSize(GuiElement::GuiSizeMax, 50);
            (new GuiKeyValueDisplay(layout, "SERVER_INFO_IP", 0.4, tr("Server IP:"), ip))->setMarginTop(-10)->setSize(GuiElement::GuiSizeMax, 50);
            (new GuiKeyValueDisplay(layout, "SERVER_INFO_VERSION", 0.4, tr("Server Version:"), version))->setMarginTop(-10)->setSize(GuiElement::GuiSizeMax, 50);
/*
            std::vector<string> players;
            foreach(PlayerInfo, i, player_info_list)
            {
                if (!i->name.empty())
                    players.push_back(i->name);
            }
            std::sort(players.begin(), players.end());
            players.resize(std::distance(players.begin(), std::unique(players.begin(), players.end())));
            crew_text = string(", ").join(players) + "";

            unsigned int amount = players.size();
*/
            if (!crew_text_label)
            {
                crew_amount_label = new GuiLabel(layout, "CREW", tr("Crew"), 30);
                crew_amount_label->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
                crew_text_label = new GuiLabel(layout, "CREW_CONNECTED", "No one is connected", 25);
                crew_text_label->setSize(GuiElement::GuiSizeMax, 50);
            }

            (new GuiLabel(layout, "HELP", tr("Help"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
            (new GuiScrollText(layout, "HELP_DESCRIPTION", "If the server is not shown in the client's server selection menu, try to enter the Server IP manually."))->setTextSize(25)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
        }
        else if (value == "Chat")
        {
            //({{"Nope", "Not implemented yet"}});
        }
    });
    first_list->setSize(GuiElement::GuiSizeMax, 160);

    // scenarios
    (new GuiLabel(middle, "GENERAL_LABEL", tr("Scenario"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    scenario_list = new GuiListbox(middle, "SCENARIO_LIST", [this](int index, string value)
    {

        ScenarioInfo info(value);
        score = campaign_client->getScenarioScore(value);
        displayDetails(info.name, info.detailed_description);
        start_button->enable()->show();
        first_list->setSelectionIndex(-1);
        proxy_list->setSelectionIndex(-1);
//        if (info.proxy != "") {
//            start_button->setText(tr("Join scenario"));
//        } else {
            start_button->setText(tr("Start scenario"));
//        }
    });
    scenario_list->setSize(GuiElement::GuiSizeMax, 250);

    // proxies
    (new GuiLabel(middle, "GENERAL_LABEL", tr("Support"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    proxy_list = new GuiListbox(middle, "PROXY_LIST", [this](int index, string value)
    {
        displayDetails(proxies[value], {{"Description", "Support another ship on its current mission.\nSince you don't have any information on the mission and what to expect, make sure to contact the ship you support as soon as possible."}});
        start_button->enable()->show();
        start_button->setText(tr("Join scenario"));
        first_list->setSelectionIndex(-1);
        scenario_list->setSelectionIndex(-1);
    });
    proxy_list->setSize(GuiElement::GuiSizeMax, 200);

    //======== Bottom buttons
    // Close server button.
    (new GuiButton(this, "CLOSE_SERVER", tr("Close"), [this]() {
        campaign_client->notifyCampaignServerScreen("login");
        destroy();
        disconnectFromServer();
        new CampaignMenu();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    start_button = new GuiButton(this, "START_SCENARIO", tr("Start scenario"), [this]() {
        if (scenario_list->getSelectionIndex() != -1)
        {
            auto filename = scenario_list->getEntryValue(scenario_list->getSelectionIndex());
            ScenarioInfo info(filename);
            if (info.settings.empty())
            {
                // Start the selected scenario.
                gameGlobalInfo->scenario = info.name;
                gameGlobalInfo->startScenario(filename);

                // Destroy this screen and move on to control screen 
                destroy();
                new MissionControlScreen(getRenderLayer(), glm::vec2(info.spawn_x, info.spawn_y), info.spawn_rot);
            }
            else
            {
                new ServerScenarioOptionsScreen(filename);
                destroy();
            }
        }
        else if (proxy_list->getSelectionIndex() != -1)
        {
            string host_name = proxy_list->getEntryValue(proxy_list->getSelectionIndex());
            // FIXME proxy must be able to resolve the servers hostname!
            // otherwise host is empty, resulting in a segfault
            auto host = sp::io::network::Address(host_name);
            PreferencesManager::set("proxy_addr", host.getHumanReadable()[0]);
            int port = defaultServerPort;
            string password = "";
            int listenPort = game_server->getPort();
            PreferencesManager::set("proxy_listen_port", std::to_string(listenPort));
            string proxyName = PreferencesManager::get("shipname", "");

            nlohmann::json info = {
                {"proxy", {
                        {"host_name", host_name.c_str()},
                        {"crew_name", proxies[host_name].c_str()}
                    }
                }
            };
            campaign_client->notifyCampaignServer("joinedproxy", info);
            disconnectFromServer();
            new GameServerProxy(host, port, password, listenPort, proxyName);
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            destroy();
            new ProxyJoinScreen(host, listenPort);
        }
    });
    start_button->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50)->disable()->hide();

    scenario_list->setSelectionIndex(-1);
    proxy_list->setSelectionIndex(-1);
    loadCampaign();
//    campaign_client->notifyCampaignServerScreen("scenario selection");

    if (!briefing_text.empty()) {
        splash_briefing = new GuiHelpOverlay(this, "Instructions");
        splash_briefing->frame->setSize(1000, 800)->setVisible(true);
        splash_briefing->moveToFront();
        splash_briefing->text->setSize(950, 620);
        splash_briefing->setText(briefing_text);
        first_list->addEntry("Instructions", "Instructions");

    }

    // add other stuff to info panel
    first_list->addEntry("Network Info", "Network");
    //first_list->addEntry("Contact Fleet Command", "Chat");

    if (!briefing_text.empty()) {
        first_list->setSelectionIndex(1);
        first_list->callback();
    }

    gameGlobalInfo->reset();
    gameGlobalInfo->scenario_settings.clear();
}

void ServerScenarioSelectionScreen::loadScenarioList(const string& category)
{
    scenario_list->setSelectionIndex(-1);
    scenario_list->setOptions({});
    for(const auto& info : ScenarioInfo::getScenarios(category))
        scenario_list->addEntry(info.name, info.filename);
    start_button->disable();
    description_text->setText(tr("Select a scenario..."));
}

void ServerCampaignScreen::loadCampaign()
{
    nlohmann::json campaign = campaign_client->getCampaign();
    LOG(INFO) << campaign.dump();

    briefing_text = campaign["briefing"].get<std::string>();

    scenario_list->setOptions({});
    for (auto scenario : campaign["scenarios"])
    {
        string filename = scenario.get<std::string>();
        ScenarioInfo info(filename);
        scenario_list->addEntry(info.name, info.filename);
    }
	if (scenario_list->getSelectionIndex() > scenario_list->entryCount())
		scenario_list->setSelectionIndex(-1);

    proxy_list->setOptions({});
    for (auto const& [key, value]: campaign["proxies"].items())
    {
        proxies[key] = value;
        proxy_list->addEntry(value, key);
    }
	if (proxy_list->getSelectionIndex() > proxy_list->entryCount())
		proxy_list->setSelectionIndex(-1);

    auto score_json = campaign["score"];
    for (auto const& [key, value]: score_json.items())
    {
        score[key] = value;
    }
}

void ServerCampaignScreen::displayDetails(string caption, std::vector<std::pair<string, string> > details)
{
        if (crew_text_label)
        {
            crew_text_label->destroy();
            crew_amount_label->destroy();
            crew_text_label = nullptr;
            crew_amount_label = nullptr;
        }
        layout->destroy();
        layout = new GuiElement(right, "");
        layout->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(600, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

        (new GuiLabel(layout, "SCENARIO_NAME", tr(caption), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        auto last = details.back();
        details.pop_back();
        for(const auto& [key, value] : details){
            (new GuiKeyValueDisplay(layout, key, 0.25, tr(key), tr(value)))->setMarginTop(-10)->setSize(GuiElement::GuiSizeMax, 50);
        }

        (new GuiLabel(layout, last.first, tr(last.first), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        (new GuiScrollText(layout, "DETAILS_SCROLL", tr(last.second)))->setTextSize(25)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

        // Score
        if (score_layout)
            score_layout->destroy();

        if (proxy_list->getSelectionIndex() != -1)
            return;
        score_layout = new GuiElement(layout, "");
        score_layout->setAttribute("layout", "vertical");
        score_layout->setPosition(0, -130, sp::Alignment::BottomCenter);
        int v_size = 0;
        (new GuiLabel(score_layout, "SCORE_HEADING", tr("Score"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        if (score.find("current_progress") != score.end())
        {
            auto line = new GuiElement(score_layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            (new GuiKeyValueDisplay(line, "SCORE_PROGRESS_BEST", 0.35, tr("Progress:"), score["best_progress"]))->setSize(275, 50);
            (new GuiKeyValueDisplay(line, "SCORE_PROGRESS_FLEET", 0.3, tr("Fleet best:"), score["fleet_progress"] + score["fleet_progress_name"]))->setSize(325, 50);
            v_size++;
        }
        if (score.find("current_time") != score.end())
        {
            auto line = new GuiElement(score_layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            (new GuiKeyValueDisplay(line, "SCORE_TIME_BEST", 0.37, tr("Best Time:"), score["best_time"]))->setSize(275, 50);
            (new GuiKeyValueDisplay(line, "SCORE_TIME_FLEET", 0.3, tr("Fleet best:"), score["fleet_time"] + score["fleet_time_name"]))->setSize(325, 50);
            v_size++;
        }
        if (score.find("current_artifacts") != score.end())
        {
            auto line = new GuiElement(score_layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            (new GuiKeyValueDisplay(line, "SCORE_ARTIFACTS_BEST", 0.35, tr("Artifacts:"), score["best_artifacts"]))->setSize(275, 50);
            (new GuiKeyValueDisplay(line, "SCORE_ARTIFACTS_FLEET", 0.3, tr("Fleet best:"), score["fleet_artifacts"] + score["fleet_artifacts_name"]))->setSize(325, 50);
            v_size++;
        }
        if (score.find("reputation") != score.end())
        {
            auto line = new GuiElement(score_layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            (new GuiKeyValueDisplay(line, "SCORE_REPUTATION", 0.55, tr("Reputation Bonus:"), score["reputation"]))->setSize(275, 50);
//	            (new GuiLabel(line, "SCORE_REP_HINT", tr("You will start future missions with this bonus. The reputation bonus depends on your highest progress."), 30))->setSize(300, 50); //TODO difficulty
            v_size++;
        }
        if (v_size > 0)
        {
            v_size++;
            score_layout->setSize(GuiElement::GuiSizeMax, v_size*40);
        }
        else
        {
            score_layout->setSize(GuiElement::GuiSizeMax, 50);
            score_layout->hide();
        }
}

ServerScenarioOptionsScreen::ServerScenarioOptionsScreen(string filename)
{
    ScenarioInfo info(filename);
    scenario_settings = {};
    if (gameGlobalInfo->campaign_running) {
        info.filterSettings(campaign_client->getScenarioSettings(filename));
    }

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    GuiElement* column_container = new GuiElement(this, "");
    column_container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");

    GuiElement* container = nullptr;
    int count = 0;
    for(auto& setting : info.settings)
    {
        if (!container || count == 2)
        {
            container = new GuiElement((new GuiElement(column_container, ""))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax), "");
            container->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(350, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
            count = 0;
        }
        (new GuiLabel(container, "", setting.key_localized, 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        auto selector = new GuiSelector(container, "", [this, info, setting](int index, string value) {
            this->scenario_settings[setting.key] = value;
            for(auto& option : setting.options)
                if (option.value == value)
                    description_per_setting[setting.key]->setText(option.description);
            start_button->setEnable(this->scenario_settings.size() >= info.settings.size());
        });
        selector->setSize(GuiElement::GuiSizeMax, 50);
        for(auto& option : setting.options)
        {
            selector->addEntry(option.value_localized, option.value);
            if (option.value == setting.default_option)
            {
                selector->setSelectionIndex(selector->entryCount() - 1);
                this->scenario_settings[setting.key] = option.value;
            }
        }
        auto description = new GuiScrollText(container, "", setting.description);
        description->setSize(GuiElement::GuiSizeMax, 300);
        count++;

        description_per_setting[setting.key] = description;
    }

    //======== Bottom buttons
    // Close server button.
    (new GuiButton(this, "BACK", tr("Back"), [this]() {
        new ServerScenarioSelectionScreen();
        destroy();
    }))->setPosition(-250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);

    // Start server button.
    start_button = new GuiButton(this, "START_SCENARIO", tr("Start scenario"), [this, info, filename]() {
        // Start the selected scenario.
        gameGlobalInfo->scenario = info.name;
        gameGlobalInfo->startScenario(filename, this->scenario_settings);

        // Destroy this screen and move on to ship selection.
        destroy();

        if (gameGlobalInfo->campaign_running) {
			new MissionControlScreen(getRenderLayer(), glm::vec2(info.spawn_x, info.spawn_y), info.spawn_rot);
        } else {
            returnToShipSelection(getRenderLayer());
        }
    });
    start_button->setPosition(250, -50, sp::Alignment::BottomCenter)->setSize(300, 50);
    start_button->setEnable(scenario_settings.size() >= info.settings.size());
}

void ServerCampaignScreen::update(float delta) 
{
	if (crew_text_label && crew_amount_label && crew_text_label->isVisible())
	{
		std::vector<string> players;
		foreach(PlayerInfo, i, player_info_list)
		{
			if (!i->name.empty())
				players.push_back(i->name);
		}
		std::sort(players.begin(), players.end());
		players.resize(std::distance(players.begin(), std::unique(players.begin(), players.end())));
        unsigned int amount = players.size();
        crew_amount_label->setText(tr("Crew") +" (" + string(amount) + ")");
        if (amount > 0)
        {
            crew_text = string(", ").join(players) + "";
            crew_text_label->setText(crew_text);
        }
        else
        {
            crew_text_label->setText("No one is connected");
        }
	}
	update_timer -= delta;
	if (update_timer < 0.0f)
	{
		update_timer = 10.0f;
		nlohmann::json campaign = campaign_client->getCampaign();
		//if (campaign["scenarios"].size() != scenario_list->entryCount())
		//{
			loadCampaign();
			// what about selection index?
		//}
		// what about adding one but removing another scenario?
	}

}

ProxyJoinScreen::ProxyJoinScreen(sp::io::network::Address host, int listenPort): host(host), listenPort(listenPort)
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    auto container = new GuiElement(this, "");
    container->setPosition(0,0,sp::Alignment::Center)->setSize(510+50, 420+50+50)->setAttribute("layout", "horizontal");
    auto panel = new GuiPanel(container, "");
    panel->setPosition(50 ,50, sp::Alignment::TopLeft)->setSize(510, 420);
     
    // ship creation panel
    auto ship_content = new GuiElement(panel, "");
    ship_content->setMargins(25)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    ship_content->setAttribute("layout", "vertical");
    ship_content->setAttribute("alignment", "topleft");

    (new GuiLabel(ship_content, "SHIP_CONFIG_LABEL", tr("Ship configuration"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
    // Ship type selection
    (new GuiLabel(ship_content, "SELECT_SHIP_LABEL", tr("Select ship type:"), 30))->setSize(GuiElement::GuiSizeMax, 50);

    ship_template_selector = new GuiSelector(ship_content, "CREATE_SHIP_SELECTOR", nullptr);

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

	ship_created = new GuiLabel(ship_content, "SHIP_CREATED", tr("Schiff ist bereit!"), 30);
	ship_created->setSize(GuiElement::GuiSizeMax, 50)->hide();
    // Spawn a ship of the selected template near 0,0 and give it a random heading.
    ship_create_button = new GuiButton(ship_content, "CREATE_SHIP_BUTTON", tr("Create ship"), [this, host, listenPort]() {
        ship_create_button->disable();
        if (!proxySpawn(ship_template_selector->getSelectionValue(), ship_drive_selector->getSelectionValue()))
            ship_create_button->enable();
        else
        {
			ship_created->show();
            std::this_thread::sleep_for(std::chrono::milliseconds(500));
            ship_create_button->enable();
//            new ProxyConnectedScreen(host, listenPort, PreferencesManager::get("shipname"));
//            destroy();
        }
    });
    ship_create_button->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);

	// Close server button.
	(new GuiButton(ship_content, "CLOSE_SERVER", tr("Close"), [this]() {
		campaign_client->notifyCampaignServerScreen("login");
		destroy();
		disconnectFromServer();
		new CampaignMenu();
	}))->setPosition(20, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, 50);
}

bool ProxyJoinScreen::proxySpawn(string templ, string drive)
{
    string callsign = PreferencesManager::get("shipname", "");
    string instance = PreferencesManager::get("instance_name", "");
    string password = PreferencesManager::get("password", "");
    string script = "getScriptStorage().onProxySpawn(\""
        + instance + "\", \""
        + callsign + "\", \""
        + templ + "\", \""
        + drive + "\", \""
        + password + "\")";

    string server = PreferencesManager::get("proxy_addr");
    string path = "/exec.lua";
    sp::io::http::Request request(server, 8080);    // XXX Port is hardcoded!
//    request.setHeader("Content-Type", "application/json");
    
    LOG(INFO) << "Sending Http request: " << server << ":8080" << path;

    sp::io::http::Request::Response response;
    response = request.request("get", path, script);
    // warning: this will block until response is received
    // start this function in a thread to avoid blocking
    if (!response.success)
    {
        LOG(WARNING) << "Http request failed. (status " << response.status << ")";
        return false;
    }
    return true;
}

ProxyConnectedScreen::ProxyConnectedScreen(sp::io::network::Address host, int listenPort, string callsign): host(host), listenPort(listenPort), callsign(callsign)
{
    //if (!game_client)
    //{
    //    new GameClient(VERSION_NUMBER, host, listenPort);
    //    LOG(DEBUG) << "created new client";
    //}
    //new GuiOverlay(this, "", colorConfig.background);
    //(new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");
    //status_label = new GuiLabel(this, "STATUS", tr("Searching for connection..."), 50);
    //status_label->setPosition(0, 300, sp::Alignment::TopCenter)->setSize(0, 50);
	// Close server button.
	(new GuiButton(this, "CLOSE_SERVER", tr("Disconnect"), [this]() {
		//campaign_client->notifyCampaignServerScreen("login");
		destroy();
		disconnectFromServer();
		new CampaignMenu();
	}))->setPosition(0, -50, sp::Alignment::BottomCenter)->setSize(200, 50);
}
/*
void ProxyConnectedScreen::update(float delta)
{
    if (!game_client)
        status_label->setText(tr("Connecting."));
    else if (game_client->getStatus() != GameClient::Connected)
        status_label->setText(tr("Connecting.."));
    else if (game_client->getClientId() <= 0)
        status_label->setText(tr("Connecting..."));
    else
    {

        foreach(PlayerInfo, i, player_info_list)
            if (i->client_id == game_client->getClientId())
                my_player_info = i;
        if (!my_player_info)
            status_label->setText(tr("Waiting for ship."));
        else if (!gameGlobalInfo)
            status_label->setText(tr("Waiting for ship.."));
        else if (!my_spaceship)
        {
            status_label->setText(tr("Waiting for ship..."));
            for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
            {
                P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
                if (ship->getCallSign().lower() == callsign.lower())
                {
                    my_player_info->commandSetShipId(ship->getMultiplayerId());
                    break;
                }
            }
        }
        else
            status_label->setText(tr("Connected"));
    }
}
*/
