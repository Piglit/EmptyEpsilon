#include "realtimeMinigame.h"
#include "../hackingDialog.h"

RealtimeMinigame::RealtimeMinigame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)
    : MiniGame(owner, parent, difficulty) {
    last_tick_at = engine->getElapsedTime();
    next_tick_at = engine->getElapsedTime();
}

float RealtimeMinigame::getProgress()
{
    return progress;
}

void RealtimeMinigame::start()
{
    reset();
}

void RealtimeMinigame::reset()
{
    if (game_complete)
    {
        return;
    }

    onNewGame();
}

void RealtimeMinigame::onDraw(sp::RenderTarget& renderer)
{
    const auto now = engine->getElapsedTime();
    if (now >= next_tick_at)
    {
        const auto delta = now - last_tick_at;
        last_tick_at = now;
        // you can do fixed FPS like this: (for 30 fps)
        // next_tick_at += 1.f/30.f;
        // otherwise tick will be called on every frame
        tick(delta);
    }
}

void RealtimeMinigame::gameComplete()
{
    parent->onMiniGameComplete(true);
    game_complete = true;
}
