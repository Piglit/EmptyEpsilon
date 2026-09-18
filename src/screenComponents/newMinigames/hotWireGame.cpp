#include "hotWireGame.h"
#include "random.h"
#include <bitset>
#include <i18n.h>

#ifdef DEBUG
#include <iostream>
#endif

HotWireGame::HotWireGame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty) :
    RealtimeMinigame(owner, parent, difficulty),
    map(10 + 5 * difficulty, 10 + 5 * difficulty)
{
    label = new GuiLabel(owner, "", "", 30);
    label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    label->setPosition(0, 0, sp::Alignment::Center);
    board.emplace_back(label);
}

void HotWireGame::onNewGame()
{
    createNewMap();
    finalizeMap();
}

void HotWireGame::createNewMap()
{
    int best_score = -1;
    std::optional<Map> best_map;
    for (auto attempt = 0; attempt < 50; attempt++)
    {
        // regenerate the map
        auto result = generateMap(attempt);

        if (result.success)
        {
            return;
        }

        if (best_score < 0 || result.score > best_score)
        {
            best_score = result.score;
            best_map = map;
        }

        attempt++;
    }
    map = best_map.value();
}

glm::vec2 HotWireGame::getBoardSize()
{
    return glm::vec2(700, 700);
}

void HotWireGame::tick(float delta)
{
    auto pawn_tile = map.tryGetMapTile(map.pawn);
    if (pawn_tile)
    {
        progress = pawn_tile->progress;
    }

    frames++;
    label->setText(tr("frames: {frames}").format({ {"frames", string(frames)} }));
    next_tick_at += 0.1f;
}

HotWireGame::Map::GenerationResult HotWireGame::generateMap(int attempt)
{
    return map.generate(difficulty, false);
}

void HotWireGame::finalizeMap()
{
    map = map.finalize(true);
}

Labyrinth::Labyrinth(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)
    : HotWireGame(owner, parent, difficulty)
{}

HotWireGame::Map::GenerationResult Labyrinth::generateMap(int attempt)
{
    return map.generate(difficulty, true);
}

void Labyrinth::finalizeMap()
{
    map = map.finalize(false);
}

HotWireGame::Map::Map(int width, int height) :
    BlockMap(width, height, Tile(Terrain::Border)) { }

//bool HotWireGame::Map::hasGoal()
//{
//	for (auto& tile : tiles)
//	{
//		if (tile == Terrain::Goal)
//		{
//			return true;
//		}
//	}
//	return false;
//}

HotWireGame::Tile* HotWireGame::Map::tryGetMapTile(glm::vec2 pos)
{
    auto index = tryGetIndex({ (int)(pos.x * width), (int)(pos.y * height) });
    if (!index)
    {
        return nullptr;
    }
    return &tiles[*index];
}

HotWireGame::Tile::Tile(Terrain terrain) :
    terrain(terrain),
    progress(0)
{}

#ifdef DEBUG
void HotWireGame::Map::dumpToConsole()
{
    std::cout << "\nMap:\n\n+";
    for (int x = 0; x < width; x++)
    {
        std::cout << "--";
    }
    std::cout << "-+\n";
    for (int y = 0; y < height; y++)
    {
        std::cout << "|";
        for (int x = 0; x < width; x++)
        {
            auto& tile = getTile({ x, y });
            std::cout << (tile.terrain == Terrain::Road ? " O" : tile.terrain == Terrain::Goal ? " X" : "  ");
        }
        std::cout << " |\n";
    }
    std::cout << "+";
    for (int x = 0; x < width; x++)
    {
        std::cout << "--";
    }
    std::cout << "-+\n\n+";

    // now the values
    for (int x = 0; x < width; x++)
    {
        std::cout << "---";
    }
    std::cout << "-+\n";
    for (int y = 0; y < height; y++)
    {
        std::cout << "|";
        for (int x = 0; x < width; x++)
        {
            auto& tile = getTile({ x, y });
            if (tile.progress == 1)
            {
                std::cout << "XX";
            }
            else if (tile.progress == 0.f)
            {
                std::cout << "  ";
            }
            else
            {
                int num = tile.progress * 100;
                if (num < 10)
                {
                    std::cout << "0";
                }
                std::cout << string(num);
            }
            std::cout << " ";
        }
        std::cout << " |\n";
    }
    std::cout << "+";
    for (int x = 0; x < width; x++)
    {
        std::cout << "---";
    }
    std::cout << "-+\n\n" << std::endl;
}

void HotWireGame::Map::debugWireMapGeneration()
{
    while (true)
    {
        int attempts = 0;
        int max_attempts = 50;
        std::optional<HotWireGame::Map> best_map;
        int best_score = -1;
        HotWireGame::Map map(25, 25);

        do
        {
            attempts++;
            auto result = map.generate(3, true);
            if (result.success)
            {
                best_map = map;
                break;
            }
            if (result.score > best_score || best_score < 0)
            {
                best_score = result.score;
                best_map = map;
            }
        } while (attempts < max_attempts);

        map = best_map->finalize(true);
        std::cout << "Attempts: " << attempts;
        map.dumpToConsole();
        std::cin.get();
    }

    std::terminate();
}
#endif // DEBUG

HotWireGame::Map HotWireGame::Map::finalize(bool score_based_on_actual_pf_distance)
{
    Map copy = *this;

    // set borders to walls
    // the map may well not start at 0;0 and end at width;height, so find out the real dimensions
    //xy smallest = { width, height };
    //xy largest = { 0,0 };
    std::vector<int> open_list;
    for (int i = 0; i < length; i++)
    {
        auto& tile = copy.tiles[i];
        if (tile.terrain == Terrain::Border)
        {
            tile.terrain = Terrain::Wall;
        }
        //if (terrain == Terrain::Wall)
        //{
        //    continue;
        //}

        if (tile.terrain == Terrain::Goal)
        {
            open_list.push_back(i);
            tile.progress = 1; // must not be 0, initially the distance, then calculated into the actual progress
        }

        //auto c = getCoords(i);
        //if (c.x < smallest.x)
        //    smallest.x = c.x;
        //if (c.y < smallest.y)
        //    smallest.y = c.y;
        //if (c.x > largest.x)
        //    largest.x = c.x;
        //if (c.y > largest.y)
        //    largest.y = c.y;
    }

    // set progress per tile -> dijkstra
    float largest_distance = 0;
    size_t open_list_index = 0;
    while (open_list_index < open_list.size())
    {
        auto idx = open_list[open_list_index];
        open_list_index++;
        auto distance = copy.tiles[idx].progress + 1;

        // mark all neighbours
        xy coords = copy.getCoords(idx);
        for (int i = 0; i < 4; i++)
        {
            xy neighbour_coords = coords;
            if (!copy.tryMoveCoords(&neighbour_coords, i))
            {
                continue;
            }
            auto neighbour_idx = copy.getIndex(neighbour_coords);
            auto& neighbour = copy.tiles[neighbour_idx];
            if (neighbour.progress != 0 || (score_based_on_actual_pf_distance && neighbour.terrain != Terrain::Road))
            {
                // already handled or unvisitable
                continue;
            }
            neighbour.progress = distance;
            open_list.push_back(neighbour_idx);

            if ((score_based_on_actual_pf_distance || neighbour.terrain == Road) && distance > largest_distance)
            {
                largest_distance = distance;
            }
        }
    }

    if (largest_distance <= 1)
    {
        // prevent division by 0
        largest_distance = 2;
    }

    // now we scale all progresses based on the largest plausible distance
    for (auto& tile : copy.tiles)
    {
        if (tile.progress > 0)
        {
            tile.progress = std::max(0.f, 1.f - (tile.progress - 1) / (largest_distance - 1));
        }
    }

    return copy;
}

HotWireGame::Map::GenerationResult HotWireGame::Map::generate(int difficulty, bool labyrinth)
{
    // clear map
    std::fill(tiles.begin(), tiles.end(), Tile(Terrain::Wall));

    // TODO: Labyrith mode support

    auto tilewidth = 1.f / width;
    auto tileheight = 1.f / height;

    // pick random start
    xy pos = { irandom(0, width - 1), irandom(0, height - 1) };

    // set start
    setTile(pos, Terrain::Road);
    pawn = { tilewidth * (pos.x + 0.5f), tileheight * (pos.y + 0.5f) };

    int remaining_bends = irandom(4, 6) + difficulty * 6;
    int score = 0;

    while (remaining_bends > 0)
    {
        // pick a random direction and move towards it, creating a bend
        int num_directions_available = 0;
        char move_mask = 0;
        for (int i = 0; i < 4; i++)
        {
            // check if that direction has at least 1 travellable tile
            xy probe = pos;
            if (tryMoveCoords(&probe, i) && getTile(probe).terrain == Terrain::Wall)
            {
                move_mask |= 1 << i;
                num_directions_available++;
            }
        }

        if (num_directions_available == 0)
        {
            // nowhere to go :(
            break;
        }

        int direction = irandom(0, num_directions_available - 1);
        for (int i = 0; i < 4; i++)
        {
            if (move_mask & (1 << i))
            {
                if (direction == 0)
                {
                    direction = i;
                    break;
                }
                direction--;
            }
        }

        // check how far we could travel in that direction
        int available_length = 0;
        {
            xy probe = pos;
            while (tryMoveCoords(&probe, direction))
            {
                auto& tile = getTile(probe);
                if (tile.terrain != Terrain::Wall)
                {
                    break;
                }
                available_length++;
            }
        }

        // choose a length at random
        int travel_length = irandom(1, available_length);

        // Travel there, marking all surrounding wall tiles as "undesired" to avoid further connections.
        // On the last tile, block the immediate front (if not at the map's edge).
        while(--travel_length >= 0)
        {
            for (int i=0;i<4;i++)
            {
                if (i == direction)
                {
                    // not in the direction that we travel (but backwards yes - so we block the start tile too)
                    continue;
                }
                xy neighbour = pos;
                if (tryMoveCoords(&neighbour, i))
                {
                    auto& tile = getTileRef(neighbour);
                    if (tile.terrain == Terrain::Wall)
                    {
                        tile = Terrain::Border;
                    }
                }
            }
            moveCoords(&pos, direction);
            setTile(pos, Terrain::Road);
        }

        // and past the end, mark a border, so we don't just continue that way
        xy probe = pos;
        if (tryMoveCoords(&probe, direction))
        {
            setTile(probe, Terrain::Border);
        }

        remaining_bends--;
        score++;
    }

    // last tile is the goal
    setTile(pos, Terrain::Goal);

    return {
        remaining_bends == 0,
        score
    };
}
