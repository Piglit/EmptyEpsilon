#include "objectCreationView.h"
#include "GMActions.h"
#include "factionInfo.h"
#include "shipTemplate.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_selector.h"
#include "gameGlobalInfo.h"

const string PLACEHOLDER_FACTION_ID = "%FACTIONID%";

GuiObjectCreationView::GuiObjectCreationView(GuiContainer* owner)
    : GuiOverlay(owner, "OBJECT_CREATE_SCREEN", glm::u8vec4(0, 0, 0, 128))
{
    GuiPanel* box = new GuiPanel(this, "FRAME");
    box->setPosition(0, 0, sp::Alignment::Center)->setSize(1000, 500);

    faction_selector = new GuiSelector(box, "FACTION_SELECTOR", nullptr);
    for (P<FactionInfo> info : factionInfo)
        if (info)
            faction_selector->addEntry(info->getLocaleName(), info->getName());
    faction_selector->setSelectionIndex(0);
    faction_selector->setPosition(20, 20, sp::Alignment::TopLeft)->setSize(300, 50);

    player_cpu_selector = new GuiSelector(box, "NPC_PC_SELECTOR", [this](int index, string)
    {
        if (index == 1)
        {
            cpu_ship_listbox->hide();
            player_ship_listbox->show();
        }
        else
        {
            cpu_ship_listbox->show();
            player_ship_listbox->hide();
        }
    });
    player_cpu_selector->addEntry(tr("create", "cpu ship"), "cpu ship");
    player_cpu_selector->addEntry(tr("create", "player ship"), "player ship");
    player_cpu_selector->setSelectionIndex(0);
    player_cpu_selector->setPosition(20, 70, sp::Alignment::TopLeft)->setSize(300, 50);

    auto misc_listbox = new GuiListbox(box, "CREATE_OBJECTS", [this](int index, string value)
    {
        if (value.length() == 0)
        {
            return;
        }

        // the value is the command that we execute
        auto faction_id = string(faction_selector->getSelectionIndex());
        setCreateScript(value.replace(PLACEHOLDER_FACTION_ID, faction_id));
    });
    misc_listbox->setTextSize(20)->setButtonHeight(30)->setPosition(-350, 20, sp::Alignment::TopRight)->setSize(300, 460);

    // list all stations
    misc_listbox->addEntry(" --- s t a t i o n s ---", "");
    std::vector<string> template_names = ShipTemplate::getTemplateNameList(ShipTemplate::Station);
    std::sort(template_names.begin(), template_names.end());
    for (string template_name : template_names)
    {
        auto stationTemplate = ShipTemplate::getTemplate(template_name);
        if (stationTemplate)
        {
            if (!stationTemplate->visible)
                continue;

            auto ship_template = ShipTemplate::getTemplate(template_name);
            auto new_index = misc_listbox->addEntry(ship_template->getLocaleName(), "SpaceStation():setRotation(random(0, 360)):setFactionId(" + PLACEHOLDER_FACTION_ID + "):setTemplate(\"" + template_name + "\")");

            if (ship_template->radar_trace != "")
                misc_listbox->setEntryIcon(new_index, ship_template->radar_trace);
        }
    }

    // misc objects
    misc_listbox->addEntry(" --- o b j e c t s ---", "");
    misc_listbox->addEntry(tr("create", "Artifact"), "Artifact()");
    misc_listbox->addEntry(tr("create", "Warp Jammer"), "WarpJammer():setRotation(random(0, 360)):setFactionId(" + PLACEHOLDER_FACTION_ID + ")");
    misc_listbox->addEntry(tr("create", "Mine"), "Mine():setFactionId(" + PLACEHOLDER_FACTION_ID + ")");
    misc_listbox->addEntry(tr("create", "Supply Drop"), "SupplyDrop():setFactionId(" + PLACEHOLDER_FACTION_ID + "):setEnergy(500):setWeaponStorage('Nuke', 1):setWeaponStorage('Homing', 4):setWeaponStorage('Mine', 2):setWeaponStorage('EMP', 1)");
    misc_listbox->addEntry(tr("create", "Asteroid"), "Asteroid()");
    misc_listbox->addEntry(tr("create", "Visual Asteroid"), "VisualAsteroid()");
    misc_listbox->addEntry(tr("create", "Planet"), "Planet()");
    misc_listbox->addEntry(tr("create", "BlackHole"), "BlackHole()");
    misc_listbox->addEntry(tr("create", "Nebula"), "Nebula()");
    misc_listbox->addEntry(tr("create", "Worm Hole"), "WormHole()");

    // cpu ships
    template_names = ShipTemplate::getTemplateNameList(ShipTemplate::Ship);
    std::sort(template_names.begin(), template_names.end());
    cpu_ship_listbox = new GuiListbox(box, "CREATE_SHIPS", [this](int index, string value)
    {
        setCreateScript("CpuShip():setRotation(random(0, 360)):setFactionId(" + string(faction_selector->getSelectionIndex()) + "):setTemplate(\"" + value + "\"):orderRoaming()");
    });
    cpu_ship_listbox->setTextSize(20)->setButtonHeight(30)->setPosition(-20, 20, sp::Alignment::TopRight)->setSize(300, 460);
    for (string template_name : template_names)
    {
        auto ship_template = ShipTemplate::getTemplate(template_name);
        if (ship_template)
        {
            if (!ship_template->visible)
                continue;
            auto new_index = cpu_ship_listbox->addEntry(ShipTemplate::getTemplate(template_name)->getLocaleName(), template_name);
            if (ship_template->radar_trace != "")
                cpu_ship_listbox->setEntryIcon(new_index, ship_template->radar_trace);
        }
    }

    // player ships
    auto player_template_names = ShipTemplate::getTemplateNameList(ShipTemplate::PlayerShip);
    std::sort(player_template_names.begin(), player_template_names.end());
    player_ship_listbox = new GuiListbox(box, "CREATE_PLAYER_SHIPS", [this](int index, string value)
    {
        setCreateScript("PlayerSpaceship():setFactionId(" + string(faction_selector->getSelectionIndex()) + ")",":setTemplate(\"" + value + "\")");
    });
    player_ship_listbox->setTextSize(20)->setButtonHeight(30)->setPosition(-20, 20, sp::Alignment::TopRight)->setSize(300, 460);
    for (const auto& template_name : player_template_names)
    {
        auto ship_template = ShipTemplate::getTemplate(template_name);
        if (ship_template)
        {
            if (!ship_template->visible)
                continue;
            auto new_index = player_ship_listbox->addEntry(ShipTemplate::getTemplate(template_name)->getLocaleName(), template_name);
            if (ship_template->radar_trace != "")
                player_ship_listbox->setEntryIcon(new_index, ship_template->radar_trace);
        }
    }
    player_ship_listbox->hide();

    (new GuiButton(box, "CLOSE_BUTTON", tr("button", "Cancel"), [this]() {
        this->hide();
    }))->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(300, 50);
}

void GuiObjectCreationView::onDraw(sp::RenderTarget& target)
{
    if (gameGlobalInfo->allow_new_player_ships)
    {
        player_cpu_selector->show();
    } else {
        player_cpu_selector->hide();
        cpu_ship_listbox->show();
        player_ship_listbox->hide();
    }
}

bool GuiObjectCreationView::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{   //Catch clicks.
    return true;
}

void GuiObjectCreationView::setCreateScript(const string create, const string configure)
{
    gameGlobalInfo->on_gm_click = [create, configure](glm::vec2 position)
    {
        gameMasterActions->commandRunScript(create + ":setPosition(" + string(position.x) + "," + string(position.y) + ")" + configure);
    };
}
