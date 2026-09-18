/**
* A game where you must carefully move your pawn on a maze-like map to a goal using X and Y sliders while avoiding touching the walls.
*
* Comes in a linear and a labyrinth version.
* 
* by AyCe
 */

#ifndef HOTWIREGAME_H
#define HOTWIREGAME_H

#include "realtimeMinigame.h"
#include "gui/gui2_label.h"
#include "newMinigameUtils.h"

class HotWireGame : public RealtimeMinigame
{
public:
    HotWireGame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual glm::vec2 getBoardSize() override;

    enum Terrain
    {
        Wall,
        Road,
        Goal,
        /// <summary>
        /// Like a wall, but used during map generation to space out paths.
        /// </summary>
        Border
    };
    struct Tile
    {
        Terrain terrain;
        float progress;

        Tile(Terrain terrain);
    };
    class Map final : public BlockMap<Tile> {
    public:
        Map(int width, int height);
        Tile* tryGetMapTile(glm::vec2 pos);

        struct GenerationResult
        {
            bool success;
            int score;
        };

        // generate the rough map
        GenerationResult generate(int difficulty, bool labyrinth);

        // make this map ready to play
        Map finalize(bool score_based_on_actual_pf_distance);

        glm::vec2 pawn {0, 0};

#ifdef DEBUG
        static void debugWireMapGeneration();
        void dumpToConsole();
#endif
    };
protected:
    virtual void onNewGame() override;
    virtual void tick(float delta) override;
    virtual void createNewMap();
    virtual Map::GenerationResult generateMap(int attempt);
    virtual void finalizeMap();
    Map map;
private:
    GuiLabel* label;
    int frames = 0;
};

class Labyrinth : public HotWireGame
{
public:
    Labyrinth(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
protected:
    virtual Map::GenerationResult generateMap(int attempt) override;
    virtual void finalizeMap() override;
};

#endif//HOTWIREGAME_H
