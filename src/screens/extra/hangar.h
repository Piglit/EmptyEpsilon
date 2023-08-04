#ifndef HANGAR_H 
#define HANGAR_H

#include "gui/gui2_overlay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_button.h"
#include "screenComponents/rotatingModelView.h"

class HangarScreen: public GuiOverlay
{
private:
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* info_reputation;

    GuiToggleButton* shares_energy_with_docked_toggle;
    GuiToggleButton* repairs_docked_toggle;
    GuiToggleButton* restocks_scan_probes_toggle;
    GuiToggleButton* restocks_weapons_toggle;

    GuiListbox* player_ship_list;
    GuiElement* fighter_create_dialog;
    GuiLabel* select_fighter_label;
    GuiButton* create_fighter_button;

    GuiTextEntry* callsign_entry;
    GuiTextEntry* password_entry;
    GuiSelector* hull_selector;
    GuiSelector* color_selector;
    GuiSelector* equipment_selector;

    GuiScrollText* playership_info;
    GuiElement* playership_visual;
    GuiRotatingModelView* model_view = nullptr;

    GuiButton* abort_button;
    GuiButton* create_ship_button;

    bool creating_fighter;
    string getModelName(string template_name, string color);
    void getAvailableEquipment(string template_name);
    void equipFighter();
    void displayModel();
public:
    HangarScreen(GuiContainer* owner);

    void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};
#endif//HANGAR_H
