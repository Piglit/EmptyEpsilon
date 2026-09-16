#include <i18n.h>
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "beamTargetSelector.h"

GuiBeamTargetSelector::GuiBeamTargetSelector(GuiContainer* owner, string id, bool horizontal)
:GuiElement(owner, id)
{
    selector = new GuiSelector(this, "SELECTOR", [](int index, string value) { if (my_spaceship) my_spaceship->commandSetBeamSystemTarget(ESystem(index + SYS_None)); });
    selector->addEntry(tr("target","Hull"), "-1");
    for(int n=0; n<SYS_COUNT; n++)
        selector->addEntry(getLocaleSystemName(ESystem(n)), string(n));
    if (my_spaceship)
        selector->setSelectionIndex(my_spaceship->beam_system_target - SYS_None);

    if (horizontal)
    {
        // tactical sceen config 
        setAttribute("layout", "horizontal");
        selector->setSize(250, GuiElement::GuiSizeMax);
        info = new GuiKeyValueDisplay(this, "DISPLAY", 0.50, tr("Dmg:"), "");
        info->setSize(90, GuiElement::GuiSizeMax);
    }
    else
    {
        // weapon sceen config 
        setAttribute("layout", "vertical");
        selector->setSize(GuiElement::GuiSizeMax, 50);
        info = new GuiKeyValueDisplay(this, "DISPLAY", 0.70, tr("Estimated hull damage:"), "");
        info->setSize(GuiElement::GuiSizeMax, 50);
    }

    if (!gameGlobalInfo->use_system_damage)
        hide();
}

void GuiBeamTargetSelector::onUpdate()
{
    if (my_spaceship && gameGlobalInfo->use_system_damage && isVisible())
    {
        if (keys.weapons_beam_subsystem_target_next.getDown())
        {
            if (selector->getSelectionIndex() >= (int)selector->entryCount() - 1)
                selector->setSelectionIndex(0);
            else
                selector->setSelectionIndex(selector->getSelectionIndex() + 1);
            selector->callback();
        }
        if (keys.weapons_beam_subsystem_target_previous.getDown())
        {
            if (selector->getSelectionIndex() <= 0)
                selector->setSelectionIndex(selector->entryCount() - 1);
            else
                selector->setSelectionIndex(selector->getSelectionIndex() - 1);
        }

        float beam_dps = 0.0;
        for(int n=0; n<max_beam_weapons; n++)
        {
            BeamWeapon& beam = my_spaceship->beam_weapons[n];
            if (beam.getRange() > 0)
            {
                if (beam.getCycleTime() > 0.0f)
                {
                    if (selector->getSelectionIndex() == 0)
                    {
                        beam_dps += beam.getDamage() / beam.getCycleTime();
                    }
                    else
                    {
                        beam_dps += 1 / beam.getCycleTime();
                    }
                }
            }
        }

        beam_dps *= my_spaceship->getSystemEffectiveness(SYS_BeamWeapons);
        info->setValue(tr("{dmg}/s").format({{"dmg", string(beam_dps, 1)}}));
    }
}
