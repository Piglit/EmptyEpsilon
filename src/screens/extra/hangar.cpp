#include "GMActions.h"
#include "gameGlobalInfo.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"
#include "hangar.h"
#include "modelData.h"
#include "playerInfo.h"
#include "screenComponents/alertOverlay.h"
#include "shipTemplate.h"
#include "spaceObjects/playerSpaceship.h"
#include <i18n.h>

extern P<GameMasterActions> gameMasterActions;

HangarScreen::HangarScreen(GuiContainer* owner)
: GuiOverlay(owner, "HANGAR_SCREEN", colorConfig.background), creating_fighter(false)
{
    // Render the background decorations.
    auto background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiled("gui/background/crosses.png");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Draw a container with two columns.
    auto container = new GuiElement(this, "");
    container->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "horizontal");
    auto left_col= new GuiElement(container, "");
    left_col->setPosition(20, 100, sp::Alignment::TopLeft)->setSize(300, GuiElement::GuiSizeMax)->setMargins(0,0,0,20)->setAttribute("layout", "vertical");
    auto right_col= new GuiElement(container, "");
    right_col->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Energy display.
    energy_display = new GuiKeyValueDisplay(left_col, "ENERGY_DISPLAY", 0.45, tr("Energy") + ":", "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setSize(240, 40);

    // Reputation display.
    info_reputation = new GuiKeyValueDisplay(left_col, "INFO_REPUTATION", 0.45f, tr("Reputation") + ":", "");
    info_reputation->setTextSize(20)->setSize(240, 40);

    // Shares energy with docked bool
    (new GuiLabel(left_col, "", tr("Docked ship services:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    shares_energy_with_docked_toggle = new GuiToggleButton(left_col, "", tr("Share energy"), [this](bool value) {
        my_spaceship->commandSetSharesEnergyWithDocked(value);
    });
    shares_energy_with_docked_toggle->setSize(GuiElement::GuiSizeMax, 40);

    // Repairs docked ships bool
    repairs_docked_toggle = new GuiToggleButton(left_col, "", tr("Repair hull"), [this](bool value) {
        my_spaceship->commandSetRepairDocked(value);
    });
    repairs_docked_toggle->setSize(GuiElement::GuiSizeMax, 40);

    // Restocks player scan probes bool
    restocks_scan_probes_toggle = new GuiToggleButton(left_col, "", tr("Restock scan probes"), [this](bool value) {
        my_spaceship->commandSetRestocksScanProbes(value);
    });
    restocks_scan_probes_toggle->setSize(GuiElement::GuiSizeMax, 40);

    // Restocks missiles selector 
    restocks_weapons_toggle= new GuiToggleButton(left_col, "", tr("Restock missiles"), [this](bool value) {
        if (value)
            my_spaceship->commandSetRestocksMissilesDocked(R_Fighters);
        else
            my_spaceship->commandSetRestocksMissilesDocked(R_None);
    });
    restocks_weapons_toggle->setSize(GuiElement::GuiSizeMax, 40);

    // fighter selector
    (new GuiLabel(left_col, "", tr("Ships in Hangar:"), 30))->setSize(GuiElement::GuiSizeMax, 50);
    auto fighter_selection_panel = new GuiPanel(left_col, "FIGHTER_SELECTION_PANEL");
    fighter_selection_panel->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    auto fighter_selection_content = new GuiElement(fighter_selection_panel, "");
    fighter_selection_content->setMargins(10)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    player_ship_list = new GuiListbox(fighter_selection_content, "FIGHTER_LIST", [this](int index, string value)
    {
        creating_fighter = false;
        fighter_create_dialog->show();
        select_fighter_label->hide();
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship && value != "")
        {
            callsign_entry->setText(ship->getCallSign());
            password_entry->setText(ship->control_code);
            string color = ship->getColor();
            string hull = ship->getTypeName();
            string equipment = ship->getEquipment();
            hull_selector->setSelectionIndex(hull_selector->indexByValue(hull));
            getAvailableEquipment(hull);
            color_selector->setSelectionIndex(color_selector->indexByValue(color));
            equipment_selector->setSelectionIndex(equipment_selector->indexByValue(equipment));

            P<ShipTemplate> ship_template = ShipTemplate::getTemplate(ship->getTypeName());
            if(ship_template)
            {
                playership_info->setText(ship_template->getDescription());
                displayModel();
            }
        } else {
            callsign_entry->setText("");
            password_entry->setText("");
            hull_selector->setSelectionIndex(0);
            color_selector->setSelectionIndex(0);
            displayModel();
        }
    });
    player_ship_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Create Fighter Button
    create_fighter_button = new GuiButton(left_col, "CREATE_FIGHTER_BUTTON", tr("Create new fighter"), [this]() {
        if (gameGlobalInfo->allow_new_player_ships)
        {
            player_ship_list->setSelectionIndex(-1);
            creating_fighter = true;
            fighter_create_dialog->show();
            select_fighter_label->hide();
            callsign_entry->setText("");
            password_entry->setText("");

            hull_selector->setSelectionIndex(0);
            color_selector->setSelectionIndex(0);
            getAvailableEquipment(hull_selector->getSelectionValue());
            equipment_selector->setSelectionIndex(0);
            P<ShipTemplate> ship_template = ShipTemplate::getTemplate(hull_selector->getSelectionValue());
            if(ship_template)
            {
                playership_info->setText(ship_template->getDescription());
                displayModel();
            }
        } else {
            create_fighter_button->hide();
        }
    });
    create_fighter_button->setSize(GuiElement::GuiSizeMax, 40);
    if (my_spaceship && my_spaceship->getPlayerShipType() == PST_Station)
        create_fighter_button->setText(tr("Create new ship"));
    if (!gameGlobalInfo->allow_new_player_ships)
        create_fighter_button->hide();

    // RIGHT PANEL
    right_col->setMargins(47, 80, 40, 60);
    auto right_panel = new GuiPanel(right_col, "FIGHTER_CREATION_PANEL");
    right_panel->setPosition(0, 0, sp::Alignment::TopCenter)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    fighter_create_dialog = new GuiElement(right_panel, "");
    fighter_create_dialog->setMargins(50)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    // No fighter selected label
    select_fighter_label = new GuiLabel(this, "FIGHTER_SELECT_LABEL", tr("Select or create a fighter"), 50);
    select_fighter_label->setPosition(650, 300)->setSize(250, 60);

    int left_col_width = 200;
    // Callsign row
    GuiElement* row = new GuiElement(fighter_create_dialog, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "CALLSIGN_LABEL", tr("Callsign: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(left_col_width, GuiElement::GuiSizeMax);
    callsign_entry = new GuiTextEntry(row, "CALLSIGN_ENTRY", "");
    callsign_entry->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    callsign_entry->callback([this](string text){
        equipFighter();
        string value = player_ship_list->getSelectionValue();
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship && (value != ""))
            player_ship_list->setEntryName(player_ship_list->getSelectionIndex(), ship->getTypeName() + " " + text);
    });

    // Password row
    row = new GuiElement(fighter_create_dialog, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "PASSWORD_LABEL", tr("Control Code: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(left_col_width, GuiElement::GuiSizeMax);
    password_entry = new GuiTextEntry(row, "PASSWORD_ENTRY", "");
    password_entry->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    password_entry->setHidePassword(true);
    password_entry->callback([this](string text){
        equipFighter();
    });

    // Hull row - only visible when spawning a new ship
    row = new GuiElement(fighter_create_dialog, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "HULL_LABEL", tr("Hull: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(left_col_width, GuiElement::GuiSizeMax);
    hull_selector = new GuiSelector(row, "HULL_SELECTOR", [this](int index, string value)
    {
        getAvailableEquipment(value);
        equipment_selector->setSelectionIndex(0);
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(value);
        if(ship_template)
        {
            playership_info->setText(ship_template->getDescription());
            displayModel();
        }
    });
    hull_selector->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    // determine wich ships can be spawned. Only avail in shipTemplate, since i am too lazy to sync a vector to shipTemplateBased.
    string templ_name = my_spaceship->getTypeName();
    auto templ = ShipTemplate::getTemplate(templ_name);
    if (templ) {
        auto spawnable = templ->spawnable_ships;
        if (!spawnable.empty())
        {
            hull_selector->setOptions(spawnable);
            hull_selector->setSelectionIndex(0);
        } else {
            create_fighter_button->hide();
            hull_selector->setSelectionIndex(-1);
        }
    }

    // Color row
    row = new GuiElement(fighter_create_dialog, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "COLOR_LABEL", tr("Color: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(left_col_width, GuiElement::GuiSizeMax);
    color_selector = new GuiSelector(row, "COLOR_SELECTOR", [this](int index, string value)
    {
        displayModel();
        equipFighter();
    });
    color_selector->setOptions({"White", "Yellow", "Blue", "Red", "Green", "Grey"})->setSelectionIndex(0);
    color_selector->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Equipment row
    row = new GuiElement(fighter_create_dialog, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    (new GuiLabel(row, "EQUIPMENT_LABEL", tr("Equipment: "), 30))->setAlignment(sp::Alignment::CenterRight)->setSize(left_col_width, GuiElement::GuiSizeMax);
    equipment_selector= new GuiSelector(row, "EQUIPMENT_SELECTOR", [this](int index, string value)
    {
        equipFighter();
    });
    equipment_selector->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);


    // info
    row = new GuiElement(fighter_create_dialog, "");
    row->setSize(GuiElement::GuiSizeMax, 350)->setAttribute("layout", "horizontal");
    playership_info = new GuiScrollText(row, "PLAYERSHIP_INFO", tr("Ship info..."));
    playership_info->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    string template_name = hull_selector->getSelectionValue();
    if (template_name != "")
    {
        P<ShipTemplate> ship_template = ShipTemplate::getTemplate(template_name);
        if (ship_template)
            playership_info->setText(ship_template->getDescription());
    }

    // 3D model view
    playership_visual = new GuiElement(row, "VISUAL_ELEMENT");
    playership_visual->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // action row
    row = new GuiElement(fighter_create_dialog, "");
    row->setSize(GuiElement::GuiSizeMax, 50)->setAttribute("layout", "horizontal");
    abort_button = new GuiButton(row, "ABORT", tr("Cancel"), [this]() {
        player_ship_list->setSelectionIndex(-1);
        creating_fighter = false;
        fighter_create_dialog->hide();
        select_fighter_label->show();
    });
    abort_button->setSize(150,50);
    create_ship_button = new GuiButton(row, "CREATE_SHIP_BUTTON", tr("Build Fighter"), [this]() {
        string templ = hull_selector->getSelectionValue();
        string callsign = callsign_entry->getText();
        string model_name = getModelName(hull_selector->getSelectionValue(), color_selector->getSelectionValue());
        gameMasterActions->commandCreateFighter(templ, my_spaceship->getMultiplayerId(), callsign, password_entry->getText(), color_selector->getSelectionValue(), model_name, equipment_selector->getSelectionValue());
        creating_fighter = false;
        fighter_create_dialog->hide();
        select_fighter_label->show();
    });
    create_ship_button->setSize(150,50);
    if (my_spaceship && my_spaceship->getPlayerShipType() == PST_Station)
        create_ship_button->setText(tr("Build Ship"));

    fighter_create_dialog->hide();
    select_fighter_label->show();
}

void HangarScreen::equipFighter()
{
    string value = player_ship_list->getSelectionValue();
    if (value != "") {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(value.toInt());
        if (ship)
        {
            int32_t id = ship->getMultiplayerId();
            string callsign = callsign_entry->getText();
            if (callsign == "")
                callsign = "PL"+string(id);
            string model_name = "";
            if ((hull_selector->getSelectionValue() != "") && (color_selector->getSelectionValue() != ""))
            {
                model_name = getModelName(hull_selector->getSelectionValue(), color_selector->getSelectionValue());
            }
            gameMasterActions->commandEquipFighter(id, callsign, password_entry->getText(), color_selector->getSelectionValue(), model_name, equipment_selector->getSelectionValue());
        }
    }
}

void HangarScreen::displayModel()
{
    string model_name = getModelName(hull_selector->getSelectionValue(), color_selector->getSelectionValue());
    if (model_view)
        model_view->destroy();
    model_view = new GuiRotatingModelView(playership_visual, "MODEL_VIEW", ModelData::getModel(model_name));
    model_view->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void HangarScreen::getAvailableEquipment(string template_name)
{
    if (template_name == "MP52 Hornet")
        equipment_selector->setOptions({"None", "+1 Beam", "+2 HVLI-Tubes", "Shield", "Sensors"});
    else if (template_name == "ZX-Lindworm")
        equipment_selector->setOptions({"None", "+2 Beams", "+4 HVLIs + 1 Tube", "4 Homings", "1 Nuke + Tube", "1 Mine + Tube", "2 EMP + Tube", "Speed-Booster", "Sensors"});
    else if (template_name == "Ryu")
        equipment_selector->setOptions({"None", "+2 Beams", "+2 HVLI-Tubes", "Speed-Booster", "Sensors"});
    else
        equipment_selector->setOptions({"None", "Cut-Las", "Puppy-Ray", "Cylon'cher", "Psycho-Traktor"});
        //equipment_selector->setOptions({"None"});

}

string HangarScreen::getModelName(string template_name, string color){
    string prefix = "";
    if (template_name == "MP52 Hornet")
        prefix = "WespeFighter";
    else if (template_name == "ZX-Lindworm")
        prefix = "LindwurmFighter";
    else if (template_name == "Ryu")
        prefix = "AdlerLongRangeFighter";
    else if (template_name == "Adder MK7")
        prefix = "AdlerLongRangeScout";
    else if (template_name == "Phobos M3P")
        prefix = "MultiGunCorvette";
    else if (template_name == "Hathcock")
        prefix = "LaserCorvette";
    else if (template_name == "Piranha M5P")
        prefix = "HeavyCorvette";
    else if (template_name == "Nautilus")
        prefix = "MineLayerCorvette";
    else if (template_name == "Atlantis")
        prefix = "AtlasHeavyDreadnought";
    else if (template_name == "Crucible")
        prefix = "AtlasMissileDreadnought";
    else if (template_name == "Maverick")
        prefix = "AtlasLaserDreadnought";
    else if (template_name == "Poseidon")
        prefix = "AtlasCarrierDreadnought";
    else
        prefix = "";
    return prefix + color;
}

void HangarScreen::onUpdate()
{
    if (!my_spaceship)
        return;
    // Update the player ship list with all player ships.
    for(int n = 0; n < GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        // ifDocked works only on server, since docking_target is only valid on server
        if (ship && ship->isDocked(my_spaceship) && my_spaceship->canBeDockedBy(ship) == DockStyle::Internal)
        {
            string ship_name = ship->getTypeName() + " " + ship->getCallSign();

            int index = player_ship_list->indexByValue(string(n));
            // If a player ship isn't in already in the list, add it.
            if (index == -1)
            {
                index = player_ship_list->addEntry(ship_name, string(n));
            }
        }else{
            int index = player_ship_list->indexByValue(string(n));
            if (index == player_ship_list->getSelectionIndex() && !creating_fighter){
                fighter_create_dialog->hide();
                select_fighter_label->show();
            }
            if (index != -1)
                player_ship_list->removeEntry(player_ship_list->indexByValue(string(n)));
        }
    }
}

void HangarScreen::onDraw(sp::RenderTarget& renderer)
{
    if (!my_spaceship)
        return;
    GuiOverlay::onDraw(renderer);

    // update stat displays
    info_reputation->setValue(string(my_spaceship->getReputationPoints(), 0));
    energy_display->setValue(string(int(nearbyint((my_spaceship->energy_level)))));
    if (my_spaceship->energy_level < 100.0f)
        energy_display->setColor(glm::u8vec4(255, 0, 0, 255));
    else
        energy_display->setColor(glm::u8vec4{255,255,255,255});

    // update buttons
    shares_energy_with_docked_toggle->setValue(my_spaceship->getSharesEnergyWithDocked());
    repairs_docked_toggle->setValue(my_spaceship->getRepairDocked());
    restocks_scan_probes_toggle->setValue(my_spaceship->getRestocksScanProbes());
    restocks_weapons_toggle->setValue(my_spaceship->getRestocksMissilesDocked() == R_Fighters);

    if (creating_fighter){
       hull_selector->enable();
       //color_selector->enable();
       create_ship_button->show();
       abort_button->show();
    } else {
       hull_selector->disable();
       //color_selector->disable();
       create_ship_button->hide();
       abort_button->hide();
    }

}

