
#include "gameGlobalInfo.h"
#include "gui/gui2_image.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_selector.h"
#include "playerInfo.h"
#include "radarScreen.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"
#include "screenComponents/radarView.h"
#include "screenComponents/rawScannerDataRadarOverlay.h"
#include "screenComponents/customShipFunctions.h"


RadarScreen::RadarScreen(GuiContainer* owner, ECrewPosition crew_position)
: GuiOverlay(owner, "RADAR_SCREEN", colorConfig.background)
{

    new GuiOverlay(this, "", glm::u8vec4(0,0,0,255));
    // Render the radar shadow and background decorations.
    //background_gradient = new GuiImage(this, "BACKGROUND_GRADIENT", "gui/background/gradientOffset.png");
    //background_gradient->setPosition(glm::vec2(0, 0), sp::Alignment::Center)->setSize(1200, 900);

    //background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    //background_crosses->setTextureTiled("gui/background/crosses.png");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Draw the science radar.
    science_radar = new GuiRadarView(this, "RADAR_RADAR", my_spaceship ? my_spaceship->getLongRangeRadarRange() : 30000.0f, nullptr);
    science_radar->setPosition(-500, 0, sp::Alignment::CenterLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    science_radar->setRangeIndicatorStepSize(5000.0)->longRange()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular)->setFogOfWarStyle(GuiRadarView::NebulaFogOfWar);

    new RawScannerDataRadarOverlay(science_radar, "", my_spaceship ? my_spaceship->getLongRangeRadarRange() : 30000.0f);

    custom_function_sidebar = new GuiCustomShipFunctions(this, scienceOfficer, "");
    custom_function_sidebar->setPosition(-20, 150, sp::Alignment::TopRight)->setSize(500, GuiElement::GuiSizeMax);
}

void RadarScreen::onDraw(sp::RenderTarget& renderer)
{
    GuiOverlay::onDraw(renderer);

    if (!my_spaceship || !isVisible())
        return;

    float view_distance = my_spaceship->getLongRangeRadarRange();
    science_radar->setDistance(view_distance);
}
/*
void RadarScreen::onUpdate()
{
    if (my_spaceship)
    {
    }
}
*/
