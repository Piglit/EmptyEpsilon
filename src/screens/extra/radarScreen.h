#ifndef RADAR_SCREEN_H
#define RADAR_SCREEN_H

#include "gui/gui2_overlay.h"
#include "playerInfo.h"

class GuiRadarView;
class GuiImage;
class GuiCustomShipFunctions;

class RadarScreen : public GuiOverlay
{
public:
    GuiImage* background_gradient;
    GuiOverlay* background_crosses;

    GuiRadarView* science_radar;
    GuiCustomShipFunctions* custom_function_sidebar;
public:
    RadarScreen(GuiContainer* owner, ECrewPosition crew_position=radar);

    virtual void onDraw(sp::RenderTarget& target) override;
    //virtual void onUpdate() override;
};

#endif//RADAR_SCREEN_H
