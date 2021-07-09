#include <i18n.h>
#include "engine.h"
#include "alternativeMainMenu.h"
#include "main.h"
#include "preferenceManager.h"
#include "epsilonServer.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/spaceship.h"
#include "mouseCalibrator.h"
#include "menus/serverCreationScreen.h"
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

AltMainMenu::AltMainMenu()
{
    constexpr float logo_size = 256;
    constexpr float logo_size_y = 256;
    constexpr float logo_size_x = 1024;
    constexpr float title_y = 160;

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    (new GuiImage(this, "LOGO", "logo_full"))->setPosition(0, title_y, ATopCenter)->setSize(logo_size_x, logo_size_y);
    (new GuiLabel(this, "VERSION", tr("Version: {version}").format({{"version", string(VERSION_NUMBER)}}), 20))->setPosition(0, title_y + logo_size, ATopCenter)->setSize(0, 20);

    (new GuiLabel(this, "", tr("Your name:"), 30))->setAlignment(ACenterLeft)->setPosition(sf::Vector2f(50, -400), ABottomLeft)->setSize(300, 50);
    (new GuiTextEntry(this, "USERNAME", PreferencesManager::get("username")))->callback([](string text) {
        PreferencesManager::set("username", text);
    })->setPosition(sf::Vector2f(50, -350), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_SERVER", tr("Start server"), [this]() {
        new EpsilonServer();
        if (game_server)
        {
            new ServerCreationScreen();
            destroy();
        }
    }))->setPosition(sf::Vector2f(50, -230), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "START_CLIENT", tr("Start client"), [this]() {
        new ServerBrowserMenu(ServerBrowserMenu::Local);
        destroy();
    }))->setPosition(sf::Vector2f(50, -170), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "OPEN_OPTIONS", tr("Options"), [this]() {
        new OptionsMenu();
        destroy();
    }))->setPosition(sf::Vector2f(50, -110), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "COLOR", tr("COLOR"), [this]() {
        new ColorSchemeMenu();
        destroy();
    }))->setPosition(sf::Vector2f(370, -110), ABottomLeft)->setSize(300, 50);

    (new GuiButton(this, "QUIT", tr("Quit"), [this]() {
        engine->shutdown();
    }))->setPosition(sf::Vector2f(50, -50), ABottomLeft)->setSize(300, 50);

    if (PreferencesManager::get("instance_name") != "")
    {
        (new GuiLabel(this, "", PreferencesManager::get("instance_name"), 25))->setAlignment(ACenterLeft)->setPosition(20, 20, ATopLeft)->setSize(0, 18);
    }

}
