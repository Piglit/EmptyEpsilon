#ifndef MINIGAMES_H
#define MINIGAMES_H

#include "screenComponents/miniGame.h"

typedef uint32_t EHackingGames; // just a bitset
//{
//    HG_Mine,
//    HG_Lights,
//    HG_SlidingTilePuzzle,
//    HG_All
//};

class HackingGame
{
public:
    static const EHackingGames None = 0;
    static const EHackingGames All = -1;

    //// no need to 
    //static const EHackingGames OnlyMines = 1 << 0;
    //static const EHackingGames OnlyLights = 1 << 1;
    //static const EHackingGames OnlySlidingPuzzle = 1 << 2;

    typedef std::function<std::shared_ptr<MiniGame>(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)> hacking_minigame_initializer;
    HackingGame(string name, string pretty_name, hacking_minigame_initializer factory);
    const string name;
    const string pretty_name;
    const hacking_minigame_initializer factory;
};

extern const std::vector<HackingGame> available_hacking_games;

#endif//MINIGAMES_H
