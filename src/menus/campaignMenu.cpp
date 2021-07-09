#include <i18n.h>
#include "engine.h"
#include "campaignMenu.h"
#include "main.h"
#include "preferenceManager.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceship.h"
#include "mouseCalibrator.h"
#include "menus/scenarioSelectionScreen.h"
#include "menus/optionsMenu.h"
#include "menus/colorScheme.h"
#include "menus/tutorialMenu.h"
#include "menus/serverBrowseMenu.h"
#include "screens/gm/gameMasterScreen.h"
#include "screenComponents/rotatingModelView.h"

#include "gui/gui2_image.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_textentry.h"

CampaignMenu::CampaignMenu()
{
    constexpr float logo_size = 256;
    constexpr float logo_size_y = 256;
    constexpr float logo_size_x = 1024;
    constexpr float title_y = 160;
	constexpr float pos_x = 100;
	constexpr float input_size_x = 270;

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    (new GuiImage(this, "LOGO", "logo_full"))->setPosition(0, title_y, ATopCenter)->setSize(logo_size_x, logo_size_y);
    (new GuiLabel(this, "VERSION", tr("Space LAN Version: {version}").format({{"version", string(VERSION_NUMBER)}}), 20))->setPosition(0, title_y + logo_size, ATopCenter)->setSize(0, 20);

	float pos_y = -400;
    (new GuiLabel(this, "", tr("Ship Name:"), 30))->setAlignment(ACenterLeft)->setPosition(sf::Vector2f(-50, pos_y), ABottomCenter)->setSize(300, 50);

    (new GuiTextEntry(this, "SHIPNAME", PreferencesManager::get("shipname")))->callback([](string text) {
        PreferencesManager::set("shipname", text);
    })->setPosition(sf::Vector2f(pos_x, pos_y), ABottomCenter)->setSize(input_size_x, 50);
	pos_y += 50;

    (new GuiLabel(this, "", tr("Ship Password:"), 30))->setAlignment(ACenterLeft)->setPosition(sf::Vector2f(-50, pos_y), ABottomCenter)->setSize(300, 50);
    (new GuiTextEntry(this, "PASSWORD", PreferencesManager::get("password")))->callback([](string text) {
        PreferencesManager::set("password", text);
    })->setPosition(sf::Vector2f(pos_x, pos_y), ABottomCenter)->setSize(input_size_x, 50);
	pos_y += 70;

    (new GuiButton(this, "SELECT_MISSION", tr("To Mission Selection"), [this]() {
        new EpsilonServer();
        if (game_server)
        {
            new ScenarioSelectionScreen();
            destroy();
        }
    }))->setPosition(sf::Vector2f(0, pos_y), ABottomCenter)->setSize(300, 50);
	pos_y += 50;

/*
    join_campaign_button = (new GuiButton(this, "JOIN_CAMPAIGN", tr("Join Campaign"), [this]() {
        new ServerBrowserMenu(ServerBrowserMenu::Local);
        destroy();
    }));
	join_campaign_button->setPosition(sf::Vector2f(0, pos_y), ABottomCenter)->setSize(300, 50);//->hide();

    (new GuiButton(this, "COLOR", tr("COLOR"), [this]() {
        new ColorSchemeMenu();
        destroy();
    }))->setPosition(sf::Vector2f(370, -50), ABottomCenter)->setSize(300, 50);
*/
    (new GuiButton(this, "QUIT", tr("Quit"), [this]() {
        engine->shutdown();
    }))->setPosition(sf::Vector2f(0, -50), ABottomCenter)->setSize(300, 50);
}

void CampaignMenu::update(float delta)
{}
