#ifndef MISSION_CONTROL_SCREEN_H
#define MISSION_CONTROL_SCREEN_H 

#include "gui/gui2_overlay.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_advancedscrolltext.h"
#include "gui/gui2_scrolltext.h"

class GuiAdvancedScrollText;
class GuiCustomShipFunctions;
class GuiAutoLayout;
class GuiKeyValueDisplay;

class MissionControlScreen: public GuiCanvas, public Updatable
{
private:
    GuiAdvancedScrollText* log_text;
    GuiCustomShipFunctions* custom_function_sidebar;

    GuiToggleButton* pause_button;
    GuiAutoLayout* info_layout;
    GuiLabel* info_clock;
    GuiLabel* gm_script_label;
    GuiListbox* gm_script_options;
public:
    MissionControlScreen();
    virtual void update(float delta);
    virtual void onKey(sf::Event::KeyEvent key, int unicode);
};

#endif//MISSION_CONTROL_SCREEN_H
