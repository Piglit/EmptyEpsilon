#include "engineeringAdvancedScreen.h"

#include "gameGlobalInfo.h"
#include "screenComponents/shieldFreqencySelect.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/powerDamageIndicator.h"
#include "screenComponents/beamFrequencySelector.h"
#include "gui/gui2_label.h"

EngineeringAdvancedScreen::EngineeringAdvancedScreen(GuiContainer* owner)
: EngineeringScreen(owner, engineeringAdvanced)
{
    if (gameGlobalInfo->use_beam_shield_frequencies)
    {
        //The shield frequency selection includes a shield enable button.
        (new GuiShieldFrequencySelect(this, "SHIELD_FREQ"))->setPosition(20, 310, sp::Alignment::TopLeft)->setSize(240, 100);

        GuiElement* beam_info_box = new GuiElement(this, "BEAM_INFO_BOX");
        beam_info_box->setPosition(20, 410, sp::Alignment::TopLeft)->setSize(240, 50);
        (new GuiLabel(beam_info_box, "BEAM_INFO_LABEL", tr("Beams"), 30))->addBackground()->setPosition(20, 0, sp::Alignment::TopLeft)->setSize(80, 50);
        (new GuiBeamFrequencySelector(beam_info_box, "BEAM_FREQUENCY_SELECTOR"))->setPosition(120, 0, sp::Alignment::TopLeft)->setSize(120, 50);
        (new GuiPowerDamageIndicator(beam_info_box, "", SYS_BeamWeapons, sp::Alignment::CenterLeft))->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(240, 50);
    }else{
        (new GuiShieldsEnableButton(this, "SHIELDS_ENABLE"))->setPosition(20, 310, sp::Alignment::TopLeft)->setSize(240, 50);
    }


}
