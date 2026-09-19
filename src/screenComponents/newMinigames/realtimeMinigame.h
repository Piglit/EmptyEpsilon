/** 
* Base class for real-time minigames.
 */

#ifndef REALTIMEMINIGAME_H
#define REALTIMEMINIGAME_H

#include "../miniGame.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_element.h"


class RealtimeMinigame : public MiniGame
{
  public:
    /// <summary>
    /// Used to implement custom rendering for minigames.
    /// </summary>
    class ProxyCanvas : public GuiElement {
    public:
        ProxyCanvas(GuiPanel* owner);
        virtual void onDraw(sp::RenderTarget& renderer) override;
        RealtimeMinigame* game = nullptr;
    };

    RealtimeMinigame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual ~RealtimeMinigame();
    virtual void createProxyCanvas();
    virtual float getProgress() override;
    virtual void render(sp::RenderTarget& renderer);
    virtual void start() override;
    virtual void initialize();
    virtual void reset() override;
    virtual glm::vec2 getBoardSize() override;
    bool isGameCompleteSuccess() { return isGameComplete() && game_complete_success; }
    bool isGameCompleteFailure() { return isGameComplete() && !game_complete_success; }
    
  protected:
    GuiPanel* owner;
    ProxyCanvas* proxy_canvas = nullptr;
    virtual void gameComplete(bool success);
    virtual void gameComplete() override;
    virtual void tick(float delta) = 0;
    virtual void onNewGame() = 0;
    float progress = 0;
    float last_tick_at = 0;
    float next_tick_at = 0;
  private:
      bool game_complete_success = false;
};

#endif//REALTIMEMINIGAME_H
