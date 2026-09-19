/**
* Utilities useful for multiple games.
 */

#ifndef NEWMINIGAMEUTILS_H
#define NEWMINIGAMEUTILS_H

#include <vector>
#include <optional>
#include <assert.h>
#include "SDL_messagebox.h"

//typedef std::pair<int, int> xy;
struct xy
{
    int x;
    int y;

    void move(const int direction);
    bool tryMove(const int direction, const int& width, const int& height);
};


template<typename T>
class BlockMap
{
public:
    int width;
    int height;
    int length;
    std::vector<T> tiles;
    BlockMap(int width, int height, T default_value) :
        width(width),
        height(height),
        length(width * height),
        tiles(length, default_value)
    {
        tiles.shrink_to_fit();
    }

    const std::optional<xy> tryGetCoords(const int index) const
    {
        if (index < 0 || index >= length)
        {
            return {};
        }
        return { {index % width, index / width } };
    }

    const std::optional<int> tryGetIndex(const xy& coords) const
    {
        auto& [x, y] = coords;
        if (x < 0 || y < 0 || x >= width || y >= height)
        {
            return {};
        }
        return { x + y * width };
    }

    xy getCoords(const int index) const
    {
        if (index < 0 || index >= length)
        {
            SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", "getCoords provided with bad index", nullptr);
            throw "BAD";
        }
        return {index % width, index / width };
    }

    int getIndex(const xy& coords) const
    {
        auto& [x, y] = coords;
        if (x < 0 || y < 0 || x >= width || y >= height)
        {
            SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", "getIndex provided with bad coordinates", nullptr);
            throw "BAD";
        }
        return x + y * width;
    }

    bool tryMoveCoords(xy* coords, const int direction) const
    {
        return coords->tryMove(direction, width, height);
    }

    void moveCoords(xy* coords, const int direction) const
    {
        coords->move(direction);
    }

    T& getTileRef(const xy& coords)
    {
        auto index = getIndex(coords);
        return tiles[index];
    }

    const T& getTile(const xy& coords) const
    {
        auto index = getIndex(coords);
        return tiles[index];
    }

    T* tryGetTile(const xy& coords)
    {
        auto index = tryGetIndex(coords);
        if (!index)
        {
            return nullptr;
        }
        return &tiles[*index];
    }

    void setTile(const xy& coords, T terrain)
    {
        auto index = getIndex(coords);
        tiles[index] = terrain;
    }

    static std::optional<xy> tryGetCoords(const int width, const int height, const int index)
    {
        if (index < 0 || index >= length)
        {
            return {};
        }
        return { {index % width, index / width } };
    }
    static std::optional<int> tryGetIndex(const int width, const int height, const xy coords)
    {
        auto [x, y] = coords;
        if (x < 0 || y < 0 || x >= width || y >= height)
        {
            return {};
        }
        return { x + y * width };
    }
};

#endif//NEWMINIGAMEUTILS_H
