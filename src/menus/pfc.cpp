#include <i18n.h>
#include "menus/pfc.h"
#include "preferenceManager.h"
#include "playerInfo.h"
#include "tutorialGame.h"
#include "main.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_button.h"
#include "gui/gui2_label.h"

/* pre-flight-check menu
	Station
	PFC starten
	PFC überspringen
*/


PFCMenu::PFCMenu()
{
	string crew_positions_string = PreferencesManager::get("autoconnect");	// may be empty
    auto positions = crew_positions_string.split(",");
	if (positions.empty())
	{
		LOG(ERROR, "No crew positions given: "+crew_positions_string);
		destroy();
		returnToMainMenu(getRenderLayer());
	}
    string first_position_name = positions[0].strip();
    ECrewPosition first_crew_position = getCrewPositionByName(first_position_name);
	if (first_crew_position == max_crew_positions)
	{
		LOG(ERROR, "No such crew position: "+ first_position_name);
		destroy();
		returnToMainMenu(getRenderLayer());
	}

	string tutorial_filename = "";
	switch (first_crew_position) {
	case helmsOfficer:
		tutorial_filename = "02_helm.lua";
		break;
	case weaponsOfficer:
		tutorial_filename = "03_weapons.lua";
		break;
	case engineering:
	case engineeringAdvanced:
		tutorial_filename = "04_engineering.lua";
		break;
	case scienceOfficer:
	case operationsOfficer:
		tutorial_filename = "05_science.lua";
		break;
	case relayOfficer:
		tutorial_filename = "06_relay.lua";
		break;
	case tacticalOfficer:
		tutorial_filename = "09_tactical.lua";
		break;
	case singlePilot:
		tutorial_filename = "07_pilot.lua";
		break;
	case singleFighter:
		tutorial_filename = "08_fighter_operator.lua";
		break;
	default:
		LOG(ERROR, "No PFC for: "+ first_position_name);
		destroy();
		returnToMainMenu(getRenderLayer());
	}

    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");
    // Draw a one-column autolayout container with margins.
    auto container = new GuiElement(this, "PFC_CONTAINER");
    container->setPosition(0, 0, sp::Alignment::Center)->setSize(400, 300)->setMargins(50)->setAttribute("layout", "vertical");

    (new GuiLabel(container, "PFC_LABEL", tr("title", getCrewPositionName(first_crew_position)), 50))->addBackground()->setSize(400, 100);

    // Start tutorial button.
    (new GuiButton(container, "START_TUTORIAL", tr("button", "Start Preflight-Check"), [this, tutorial_filename]() {
        destroy();
        new TutorialGame(false, tutorial_filename);
    }))->setSize(400, 50);

    // Back button.
    (new GuiButton(container, "BACK", tr("button", "Skip Preflight-Check"), [this]()
    {
        // Close this menu, stop the music, and return to the main menu.
        destroy();
        returnToMainMenu(getRenderLayer());
    }))->setSize(400, 50);
}
