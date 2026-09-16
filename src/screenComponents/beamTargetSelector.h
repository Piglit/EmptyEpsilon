#ifndef BEAM_TARGET_SELECTOR_H
#define BEAM_TARGET_SELECTOR_H

#include "gui/gui2_selector.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_element.h"

class GuiBeamTargetSelector : public GuiElement
{
private:
    GuiSelector* selector;
    GuiKeyValueDisplay* info;
public:
    GuiBeamTargetSelector(GuiContainer* owner, string id, bool horizontal);

    virtual void onUpdate() override;
};

#endif//BEAM_TARGET_SELECTOR_H
