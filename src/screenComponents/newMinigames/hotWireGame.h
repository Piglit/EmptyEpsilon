/**
* Hot Wire: A game where you must carefully move your pawn to a goal using X and Y sliders while avoiding touching the walls.
* Maze/Labyrinth: Similar to Hot Wire, but the walls are harmless and the map is full of branching dead-ends.
* 
* Special: In Hot Wire difficulty 0 the walls are harmless and below difficulty 2 you can "teleport" across walls - small easter egg. :)
* 
* by AyCe
 */

#ifndef HOTWIREGAME_H
#define HOTWIREGAME_H

#include "realtimeMinigame.h"
#include "gui/gui2_label.h"
#include "newMinigameUtils.h"
#include "gui/gui2_slider.h"

class HotWireGame : public RealtimeMinigame
{
public:
    HotWireGame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);

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

        Tile(const Terrain terrain);
        bool isPassable() const;
    };
    class Map final : public BlockMap<Tile> {
    public:
        Map(const int width, const int height);
        xy toXY(const glm::vec2& pos) const;
        Tile* tryGetMapTile(const glm::vec2& pos);

        struct GenerationResult
        {
            bool success;
            int score;
        };

        // generate the rough map
        GenerationResult generate(const int difficulty, const bool labyrinth);

        // make this map ready to play
        Map finalize(const bool score_based_on_actual_pf_distance);

        glm::vec2 pawn {0, 0};
        void setPawn(const xy& coords);

#ifdef DEBUG
        static void debugWireMapGeneration();
        void dumpToConsole();
#endif
    };
protected:
    virtual void initialize() override;
    virtual void onNewGame() override;
    virtual void tick(float delta) override {};
    virtual void createNewMap();
    virtual Map::GenerationResult generateMap(int attempt);
    virtual void finalizeMap();
    virtual void onSlider(float value, bool horizontal);
    virtual void setPawnPosition(float x, float y, bool teleport);
    virtual void updateSliders();
    virtual void gameComplete(bool success) override;
    virtual void render(sp::RenderTarget& renderer) override;
    Map map;
    GuiBasicSlider* slider_horizontal = nullptr;
    GuiBasicSlider* slider_vertical = nullptr;
    bool can_fail;
    bool can_teleport = false;
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
