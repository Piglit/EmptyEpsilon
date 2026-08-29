/** 
* Sliding Puzzle minigame by AyCe
 */

#ifndef SLIDINGTILEPUZZLE_H
#define SLIDINGTILEPUZZLE_H

#include "../miniGame.h"
#include "gui/gui2_togglebutton.h"


class SlidingTilePuzzle : public MiniGame {
  public:
    SlidingTilePuzzle(GuiPanel* owner, GuiHackingDialog* parent, int difficulty);
    virtual void reset() override;
    virtual void disable() override;
    virtual float getProgress() override;
    virtual glm::vec2 getBoardSize() override;
    class TileData
    {
    public:
        TileData(size_t terrain_index, bool is_free);

        size_t terrain_index;
        bool is_free;
    };
    class TerrainInfo
    {
    public:
        TerrainInfo(string sprite, float rotation);

        string sprite;
        float rotation;
    };
  protected:
    virtual void gameComplete() override;
  private:
    void onFieldClick(int index);
    int width;
    int height;
    std::vector<size_t> map;
    std::vector<TerrainInfo> terrain;

    float progress;
    class FieldItem : public GuiToggleButton
    {
    public:
        FieldItem(GuiContainer* owner, string id, string text, func_t func);

        SlidingTilePuzzle::TileData tile_data;
    };
    FieldItem* getFieldItem(int idx);
    void checkGameState();
    std::optional<std::pair<int, int>> tryGetCoords(int index);
    std::optional<int> tryGetIndex(std::pair<int, int> coords);
    void moveCoords(std::pair<int, int>* coords, int direction);
};

#endif//SLIDINGTILEPUZZLE_H
