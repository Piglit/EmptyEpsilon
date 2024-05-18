#include <i18n.h>
#include "engine.h"
#include "campaignMenu.h"
#include "campaign_client.h"
#include "main.h"
#include "preferenceManager.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceship.h"
#include "menus/serverCreationScreen.h"
//#include "menus/scenarioSelectionScreen.h"
#include "menus/optionsMenu.h"
#include "menus/tutorialMenu.h"
#include "menus/serverBrowseMenu.h"
#include "menus/mainMenus.h"
#include "screens/gm/gameMasterScreen.h"
#include "screenComponents/rotatingModelView.h"

#include "gui/gui2_image.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_textentry.h"

CampaignMenu::CampaignMenu()
{
    constexpr float logo_size_y = 256;
    constexpr float logo_size_x = 1024;
    constexpr float title_y = 100;
    constexpr float pos_x = 100;
    constexpr float input_size_x = 270;

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

    if (PreferencesManager::get("instance_name") != "")
    {
        (new GuiLabel(this, "", PreferencesManager::get("instance_name"), 25))->setAlignment(sp::Alignment::CenterLeft)->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(0, 18);
    }

    (new GuiImage(this, "LOGO", "logo_full.png"))->setPosition(0, title_y, sp::Alignment::TopCenter)->setSize(logo_size_x, logo_size_y);
    (new GuiLabel(this, "VERSION", tr("Space LAN Version: {version}").format({{"version", string(VERSION_NUMBER)}}), 20))->setPosition(0, title_y + logo_size_y, sp::Alignment::TopCenter)->setSize(0, 20);

    float pos_y = title_y + logo_size_y + 40;
    (new GuiLabel(this, "", tr("Ship Name:"), 30))->setAlignment(sp::Alignment::CenterLeft)->setPosition({-50, pos_y}, sp::Alignment::TopCenter)->setSize(300, 50);

    (new GuiTextEntry(this, "SHIPNAME", PreferencesManager::get("shipname")))->callback([](string text) {
        PreferencesManager::set("shipname", text);
        PreferencesManager::set("headless_name", text);
    })->setPosition({pos_x, pos_y}, sp::Alignment::TopCenter)->setSize(input_size_x, 50);
    pos_y += 50;

    (new GuiLabel(this, "", tr("Ship Password:"), 30))->setAlignment(sp::Alignment::CenterLeft)->setPosition({-50, pos_y}, sp::Alignment::TopCenter)->setSize(300, 50);
    (new GuiTextEntry(this, "PASSWORD", PreferencesManager::get("password")))->callback([](string text) {
        PreferencesManager::set("password", text);
        PreferencesManager::set("headless_password", text);
    })->setHidePassword()->setPosition({pos_x, pos_y}, sp::Alignment::TopCenter)->setSize(input_size_x, 50);
    pos_y += 70;

    string label;
    if (campaign_client && !campaign_client->isOnline())
        std::this_thread::sleep_for(std::chrono::milliseconds(100));

    if (campaign_client && campaign_client->isOnline()){
        label = tr("To Mission Selection");
    } else {
        label = tr("Connect");
        (new GuiLabel(this, "SRV_LABEL", tr("Campaign Server:"), 30))->setAlignment(sp::Alignment::CenterLeft)->setPosition({-50, pos_y}, sp::Alignment::TopCenter)->setSize(300, 50);
        (new GuiLabel(this, "SRV_IP", PreferencesManager::get("campaign_server"), 30))->setPosition({pos_x, pos_y}, sp::Alignment::TopCenter)->setSize(input_size_x, 50);
        pos_y += 70;
    }
    (new GuiButton(this, "SELECT_MISSION", label, [this]() {
        new EpsilonServer(defaultServerPort);
        if (game_server)
        {
            game_server->setServerName(PreferencesManager::get("shipname"));
            game_server->setPassword(PreferencesManager::get("password").upper());
            if (campaign_client && campaign_client->isOnline()) {
                gameGlobalInfo->campaign_running = true;
                new ServerCampaignScreen();
                destroy();
            } else {
				campaign_client->notifyCampaignServer("eesrv_status", nlohmann::json {
					{"screen", "quit"}
				});
                disconnectFromServer();
            }
        }
    }))->setPosition({0, pos_y}, sp::Alignment::TopCenter)->setSize(300, 50);
    pos_y += 50;

/*
    (new GuiButton(this, "COLOR", tr("COLOR"), [this]() {
        new ColorSchemeMenu();
        destroy();
    }))->setPosition({370, -50}, sp::Alignment::TopCenter)->setSize(300, 50);
*/
    (new GuiButton(this, "QUIT", tr("Leave Campaign"), [this]() {
           new MainMenu();
           destroy();
    }))->setPosition({0, -50}, sp::Alignment::BottomCenter)->setSize(300, 50);
}

