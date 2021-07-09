#include "shipLogScreen.h"
#include "missionControlScreen.h"
#include "menus/scenarioSelectionScreen.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "screenComponents/customShipFunctions.h"
#include "gameGlobalInfo.h"
#include "gui/gui2_textentry.h"

MissionControlScreen::MissionControlScreen()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    GuiAutoLayout* container = new GuiAutoLayout(this, "MISSION_CONTROL_LAYOUT", GuiAutoLayout::LayoutVerticalColumns);
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    GuiElement* left_container = new GuiElement(container, "");
    GuiElement* right_container = new GuiElement(container, "");

    // server info and controls
    info_layout = new GuiAutoLayout(left_container, "INFO_LAYOUT", GuiAutoLayout::LayoutVerticalTopToBottom);
    info_layout->setPosition(0, 20, ATopLeft)->setSize(550, GuiElement::GuiSizeMax);

    (new GuiLabel(info_layout, "SERVER_INFO_LABEL", tr("Server info"), 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);

    GuiElement* right_panel = new GuiAutoLayout(right_container, "", GuiAutoLayout::LayoutVerticalTopToBottom);
    right_panel->setPosition(0, 20, ATopCenter)->setSize(550, GuiElement::GuiSizeMax);

    // Server name row.
    GuiElement* row = new GuiAutoLayout(info_layout, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "NAME_LABEL", tr("Server name: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiLabel(row, "SERVER_NAME", game_server->getServerName(), 30))->setAlignment(ACenterLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Server IP row.
    row = new GuiAutoLayout(info_layout, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "IP_LABEL", tr("Server IP: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    (new GuiLabel(row, "IP", sf::IpAddress::getLocalAddress().toString(), 30))->setAlignment(ACenterLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Clock
    row = new GuiAutoLayout(info_layout, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    row->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiLabel(row, "CLOCK_LABEL", tr("Mission clock: "), 30))->setAlignment(ACenterRight)->setSize(250, GuiElement::GuiSizeMax);
    info_clock = new GuiLabel(row, "CLOCK", "0", 30);
    info_clock->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Buttons
    pause_button = new GuiToggleButton(info_layout, "PAUSE_BUTTON", tr("button", "Pause"), [this](bool value) {
        if (!value)
            engine->setGameSpeed(1.0f);
        else
            engine->setGameSpeed(0.0f);
    });
    pause_button->setValue(engine->getGameSpeed() == 0.0f)->setPosition(20, 20, ATopCenter)->setSize(250, 50);

    (new GuiButton(info_layout, "QUIT", tr("Quit Mission"), [this]() {
        destroy();
        new ScenarioSelectionScreen();
    }))->setPosition(20, 20, ATopCenter)->setSize(250, 50);


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
                //callback.callback.call();
                return;
            }
            n++;
        }
    });
    gm_script_options->setPosition(0, 20, ACenterRight)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    if (gameGlobalInfo->gm_callback_functions.empty())
    {
        gm_script_options->hide();
        gm_script_label->hide();
    }
/*
    log_text = new GuiAdvancedScrollText(mission_control_layout, "SHIP_LOG");
    log_text->enableAutoScrollDown();
    log_text->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
*/
}

void MissionControlScreen::update(float delta)
{
    // Update mission clock
    info_clock->setText(string(gameGlobalInfo->elapsed_time, 0));

    // Update pause button
    pause_button->setValue(engine->getGameSpeed() == 0.0f);

    bool gm_functions_changed = gm_script_options->entryCount() != int(gameGlobalInfo->gm_callback_functions.size());
    auto it = gameGlobalInfo->gm_callback_functions.begin();
    for(int n=0; !gm_functions_changed && n<gm_script_options->entryCount(); n++)
    {
        if (gm_script_options->getEntryName(n) != it->name)
            gm_functions_changed = true;
        it++;
    }
    if (gm_functions_changed)
    {
        gm_script_options->setOptions({});
        for(const GMScriptCallback& callback : gameGlobalInfo->gm_callback_functions)
        {
            gm_script_options->addEntry(callback.name, callback.name);
        }
    }

    // upate log
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

}

void MissionControlScreen::onKey(sf::Event::KeyEvent key, int unicode)
{
    switch(key.code)
    {
    //TODO: This is more generic code and is duplicated.
    case sf::Keyboard::Escape:
    case sf::Keyboard::Home:
        destroy();
        new ScenarioSelectionScreen();
        break;
    case sf::Keyboard::P:
        if (game_server)
            engine->setGameSpeed(0.0);
        break;
    default:
        break;
    }
}



