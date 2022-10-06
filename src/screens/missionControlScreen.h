#ifndef MISSION_CONTROL_SCREEN_H
#define MISSION_CONTROL_SCREEN_H 

#include "gui/gui2_overlay.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_advancedscrolltext.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_button.h"

class GuiAdvancedScrollText;
class GuiCustomShipFunctions;
class GuiAutoLayout;
class GuiKeyValueDisplay;

class MissionControlScreen: public GuiCanvas, public Updatable
{
private:
    GuiKeyValueDisplay* info_clock;
    GuiKeyValueDisplay* victory;
    GuiToggleButton* pause_button;
    GuiPanel* ship_panel;
    GuiElement* ship_content_with_ship;
    GuiSelector* ship_template_selector; 
    GuiSelector* ship_drive_selector;
    GuiKeyValueDisplay* ship_name;
    GuiKeyValueDisplay* ship_class;
    GuiKeyValueDisplay* ship_subclass;
    GuiKeyValueDisplay* ship_type;
    GuiKeyValueDisplay* ship_drive;
    GuiButton* create_ship_button;
    bool updatedShip;
public:
    MissionControlScreen(RenderLayer* render_layer);
    virtual void update(float delta) override;
};

#endif//MISSION_CONTROL_SCREEN_H
