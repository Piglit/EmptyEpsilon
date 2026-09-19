#include "minigames.h"
#include "screenComponents/mineSweeper.h"
#include "screenComponents/lightsOut.h"
#include "screenComponents/newMinigames/slidingTilePuzzle.h"
#include "screenComponents/newMinigames/hotWireGame.h"

HackingGame::HackingGame(string name, string pretty_name, hacking_minigame_initializer factory) :
    name(name),
    pretty_name(pretty_name),
    factory(factory)
{}

template<typename T>
HackingGame hacking_minigame(string name, string pretty_name)
{
    return HackingGame(
        name,
        pretty_name,
        [](GuiPanel* owner, GuiHackingDialog* parent, int difficulty) -> std::shared_ptr<MiniGame>
        {
            return std::make_shared<T>(owner, parent, difficulty);
        }
    );
}

const std::vector<HackingGame> available_hacking_games = {
    hacking_minigame<MineSweeper>("mines", "Mine"),
    hacking_minigame<LightsOut>("lights", "Lights"),
    hacking_minigame<SlidingTilePuzzle>("slidingTilePuzzle", "Sliding Tile Puzzle"),
    hacking_minigame<HotWireGame>("hotWire", "Hot Wire"),
    hacking_minigame<Labyrinth>("maze", "Maze"),
};
