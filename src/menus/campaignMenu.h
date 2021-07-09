#ifndef CAMPAIGN_MENU_H
#define CAMPAIGN_MENU_H

#include "gui/gui2_canvas.h"
#include "gui/gui2_button.h"

class CampaignMenu: public GuiCanvas, public Updatable
{
	GuiButton * join_campaign_button;
public:
    CampaignMenu();
    virtual void update(float delta);
};

#endif//CAMPAIGN_MENU_H
