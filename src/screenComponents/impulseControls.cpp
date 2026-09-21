#include <i18n.h>
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "impulseControls.h"
#include "powerDamageIndicator.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_slider.h"
#include "preferenceManager.h"

// After this many seconds of no input change, the server value (source of truth) overrides the client's value.
const float SEC_RESYNC_TO_SERVER_AFTER = 0.5;

bool canControl()
{
    return my_spaceship && my_spaceship->getDockingState() == DS_NotDocking;
}

GuiImpulseControls::GuiImpulseControls(GuiContainer* owner, string id)
: GuiElement(owner, id),
impulse_control_speed(PreferencesManager::get("impulse_control_speed", "0.75").toFloat())
{
    slider = new GuiSlider(this, id + "_SLIDER", 1.0, -1.0, 0.0, [this](float value) {
        // called when the slider is clicked manually, not called when the slider value is set via setValue()
        if (!canControl())
        {
            return;
        }
        
        // something has changed -> player input detected + send to server
        sw_last_player_input = engine->getElapsedTime();
        my_spaceship->commandImpulse(value);
    });
    slider->addSnapValue(0.0, 0.1)->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(50, GuiElement::GuiSizeMax);

    label = new GuiKeyValueDisplay(this, id, 0.5, tr("slider", "Impulse"), "0%");
    label->setTextSize(30)->setPosition(50, 0, sp::Alignment::TopLeft)->setSize(40, GuiElement::GuiSizeMax);

    (new GuiPowerDamageIndicator(this, id + "_DPI", SYS_Impulse, sp::Alignment::TopCenter))->setSize(50, GuiElement::GuiSizeMax);
}

void GuiImpulseControls::onDraw(sp::RenderTarget& target)
{
    auto controllable = canControl();
    slider->setEnable(controllable);
    if (my_spaceship)
    {
        label->setValue(string(static_cast<int>(std::round(my_spaceship->current_impulse * 100.0f))) + "%");

        // after a while of no player inputs, or while docking, use the server's value
        auto use_server_value = sw_last_player_input + SEC_RESYNC_TO_SERVER_AFTER < engine->getElapsedTime() || !controllable;
        if (use_server_value)
        {
            slider->setValue(my_spaceship->impulse_request);
        }
    }
}

void GuiImpulseControls::onUpdate()
{
    const auto now = engine->getElapsedTime();
    const auto delta = std::clamp(now - sw_last_update, 0.f, 1.f); // max 1 second, larger jumps are sus
    sw_last_update = now;

    if (isVisible() && canControl())
    {
        const auto old_value = slider->getValue();
        auto new_value = old_value;

        const auto oneTickChange = delta / impulse_control_speed;

        const float change = keys.helms_increase_impulse.getValue() - keys.helms_decrease_impulse.getValue();

        if (change != 0.0f)
            new_value += change * oneTickChange;
        if (keys.helms_increase_impulse_1.getDown())
            new_value += oneTickChange;
        if (keys.helms_decrease_impulse_1.getDown())
            new_value -= oneTickChange;
        if (keys.helms_increase_impulse_10.getDown())
            new_value += oneTickChange * 10.f;
        if (keys.helms_decrease_impulse_10.getDown())
            new_value -= oneTickChange * 10.f;
        if (keys.helms_zero_impulse.getDown())
            new_value = 0.0f;
        if (keys.helms_max_impulse.getDown())
            new_value = 1.0f;
        if (keys.helms_min_impulse.getDown())
            new_value = -1.0f;

        float set_value = keys.helms_set_impulse.getValue();
        if (set_value != 0.0f || set_active)
        {
            new_value = set_value;
            set_active = set_value != 0.0f; //Make sure the next update is send, even if it is back to zero.
        }

        new_value = std::clamp(new_value, -1.f, 1.f);

        if (new_value != old_value)
        {
            // something has changed -> player input detected + update slider + send to server
            sw_last_player_input = now;
            slider->setValue(new_value);
            my_spaceship->commandImpulse(new_value);
        }
    }
}
