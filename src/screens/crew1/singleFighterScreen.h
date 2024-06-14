#ifndef SINGLE_FIGHTER_SCREEN_H
#define SINGLE_FIGHTER_SCREEN_H

#include "gui/gui2_overlay.h"
#include "screenComponents/targetsContainer.h"
#include "gui/joystickConfig.h"

class GuiViewport3D;
class GuiMissileTubeControls;
class GuiRadarView;
class GuiKeyValueDisplay;
class GuiToggleButton;
class GuiRotationDial;
class GuiCombatManeuver;

class SingleFighterScreen : public GuiOverlay
{
private:
    GuiViewport3D* viewport;

    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* heading_display;
    GuiKeyValueDisplay* velocity_display;
    GuiKeyValueDisplay* hull_display;
    GuiKeyValueDisplay* shields_display;
    GuiElement* warp_controls;
    GuiElement* jump_controls;
    GuiCombatManeuver* combat_maneuver;

    TargetsContainer targets;
    GuiRadarView* radar;
    GuiMissileTubeControls* tube_controls;
public:
    SingleFighterScreen(GuiContainer* owner);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//SINGLE_FIGHTER_SCREEN_H
