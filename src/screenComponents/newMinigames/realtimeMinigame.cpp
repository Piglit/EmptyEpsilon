#include "realtimeMinigame.h"
#include "../hackingDialog.h"

RealtimeMinigame::ProxyCanvas::ProxyCanvas(GuiPanel* owner) :
    GuiElement(owner, "MINIGAME") {
}

void RealtimeMinigame::ProxyCanvas::onDraw(sp::RenderTarget& renderer)
{
    if (game)
    {
        game->render(renderer);
    }
}

RealtimeMinigame::RealtimeMinigame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty) :
    MiniGame(owner, parent, difficulty),
    owner(owner)
{
    last_tick_at = engine->getElapsedTime();
    next_tick_at = last_tick_at;
}

RealtimeMinigame::~RealtimeMinigame()
{
    if (proxy_canvas)
    {
        proxy_canvas->game = nullptr;
    }
}

float RealtimeMinigame::getProgress()
{
    return progress;
}

void RealtimeMinigame::createProxyCanvas()
{
    proxy_canvas = new RealtimeMinigame::ProxyCanvas(owner);
    proxy_canvas->setPosition(-25, 0, sp::Alignment::Center);
    proxy_canvas->setSize(500, 500);
}

void RealtimeMinigame::start()
{
    initialize();
    reset();
}

void RealtimeMinigame::initialize()
{
    createProxyCanvas();
    if (proxy_canvas)
    {
        proxy_canvas->game = this;
        board.emplace_back(proxy_canvas);
    }
}

glm::vec2 RealtimeMinigame::getBoardSize()
{
    if (!proxy_canvas)
    {
        return MiniGame::getBoardSize();
    }

    return proxy_canvas->getSize();
}

void RealtimeMinigame::reset()
{
    if (game_complete)
    {
        return;
    }

    onNewGame();
}

void RealtimeMinigame::render(sp::RenderTarget& renderer)
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

void RealtimeMinigame::gameComplete(bool success)
{
    game_complete_success = success;
    parent->onMiniGameComplete(success);
    game_complete = true;
}

void RealtimeMinigame::gameComplete()
{
    gameComplete(true);
}
