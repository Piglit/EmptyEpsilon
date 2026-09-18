/** 
* Base class for real-time minigames.
 */

#ifndef REALTIMEMINIGAME_H
#define REALTIMEMINIGAME_H

#include "../miniGame.h"
#include "gui/gui2_panel.h"


class RealtimeMinigame : public MiniGame
{
  public:
    RealtimeMinigame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual float getProgress() override;
    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual void start() override;
    virtual void reset() override;
    
  protected:
    virtual void gameComplete() override;
    virtual void tick(float delta) = 0;
    virtual void onNewGame() = 0;
    float progress = 0;
    float last_tick_at = 0;
    float next_tick_at = 0;
};

#endif//REALTIMEMINIGAME_H
