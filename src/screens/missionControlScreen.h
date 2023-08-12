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
#include "gui/gui2_textentry.h"
#include "spaceObjects/spaceStation.h"
#include "screenComponents/databaseView.h"

class GuiAdvancedScrollText;
class GuiCustomShipFunctions;
class GuiAutoLayout;
class GuiKeyValueDisplay;

class MissionControlScreen: public GuiCanvas, public Updatable
{
private:
    GuiKeyValueDisplay* clock;
    GuiKeyValueDisplay* victory;
    GuiToggleButton* pause_button;

    GuiElement* ship_infos;
    GuiKeyValueDisplay* ship_name;
    GuiKeyValueDisplay* ship_class;
    GuiKeyValueDisplay* ship_subclass;
    GuiKeyValueDisplay* ship_type;
    GuiKeyValueDisplay* ship_drive;

    GuiPanel* ship_panel;
    GuiSelector* ship_template_selector; 
    GuiSelector* ship_drive_selector;
    GuiButton* ship_create_button;

    GuiPanel* station_panel;
    GuiKeyValueDisplay* station_name;
    GuiButton* ship_destroy_button;

    GuiElement* database_container;
    DatabaseViewComponent* database_view;

    glm::vec2 spawn_pos;
    int spawn_rota;
public:
    MissionControlScreen(RenderLayer* render_layer);
    MissionControlScreen(RenderLayer* render_layer, glm::vec2 spawn_pos, int spawn_rota);
    virtual void update(float delta) override;
};

#endif//MISSION_CONTROL_SCREEN_H
