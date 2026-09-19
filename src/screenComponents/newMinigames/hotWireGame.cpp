#include "hotWireGame.h"
#include "random.h"
#include <bitset>
#include <i18n.h>
#include "graphics/opengl.h"

#ifdef DEBUG
#include <iostream>
#endif

HotWireGame::HotWireGame(GuiPanel* owner, GuiHackingDialog* parent, int difficulty) :
    RealtimeMinigame(owner, parent, difficulty),
    map(10 + 10 * difficulty, 10 + 10 * difficulty),
    can_fail(difficulty > 0)
{}

const float SLIDER_THICKNESS = 50;
const float SLIDER_MARGIN = 20;
const float MAP_BORDER = SLIDER_THICKNESS / 2.f;
const auto SLIDER_BLOCK = SLIDER_THICKNESS + SLIDER_MARGIN * 2;

void HotWireGame::initialize()
{
    RealtimeMinigame::initialize();

    auto board_size = proxy_canvas->getSize();

    slider_horizontal = new GuiBasicSlider(proxy_canvas, "HOT_WIRE_HORIZONTAL", 0, 1, 0, [this](float value) {
        onSliderChange(value, map.pawn.y);
        });
    slider_horizontal->setSize(board_size.x - SLIDER_BLOCK, SLIDER_THICKNESS);
    slider_horizontal->setPosition(SLIDER_BLOCK * 0.5f, -SLIDER_MARGIN, sp::Alignment::BottomCenter);
    board.emplace_back(slider_horizontal);

    slider_vertical = new GuiBasicSlider(proxy_canvas, "HOT_WIRE_VERTICAL", 0, 1, 0, [this](float value) {
        onSliderChange(map.pawn.x, value);
        });
    slider_vertical->setSize(SLIDER_THICKNESS, board_size.y - SLIDER_BLOCK);
    slider_vertical->setPosition(SLIDER_MARGIN, -SLIDER_BLOCK *0.5f, sp::Alignment::CenterLeft);
    board.emplace_back(slider_vertical);


    // the canvas size would be fine, but we want additional sliders
    //proxy_canvas->setSize()
}

void HotWireGame::updateSliders()
{
    slider_horizontal->setValue(map.pawn.x);
    slider_vertical->setValue(map.pawn.y);
    auto game_over = isGameComplete();
    slider_horizontal->setEnable(!game_over);
    slider_vertical->setEnable(!game_over);
}

void HotWireGame::gameComplete(bool success)
{
    RealtimeMinigame::gameComplete(success);
    updateSliders();
}

void HotWireGame::onSliderChange(float x, float y)
{
    if (game_complete)
    {
        return;
    }

    auto previous_position = map.pawn;
    map.pawn.x = std::clamp(x, 0.f, 1.f);
    map.pawn.y = std::clamp(y, 0.f, 1.f);

    auto tile = map.tryGetMapTile(map.pawn);
    if (tile)
    {
        if (tile->terrain == Terrain::Goal)
        {
            progress = 1;
            gameComplete(true);
        }
        else if (tile->terrain != Terrain::Road)
        {
            if (can_fail)
            {
                progress = 0;
                gameComplete(false);
            }
            else
            {
                // TODO: prevent skipping walls
                // TODO: can_teleport
                map.pawn = previous_position;
            }
        }
        else
        {
            progress = tile->progress;
        }
    }
}

void HotWireGame::onNewGame()
{
    createNewMap();
    finalizeMap();
    updateSliders();
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

void HotWireGame::render(sp::RenderTarget& renderer)
{
    RealtimeMinigame::render(renderer);

    auto& owner_rect = proxy_canvas->getRect();

    // we need to leave some space to the left and bottom, as there are sliders

    float off_x = owner_rect.position.x + SLIDER_BLOCK;
    float off_y = owner_rect.position.y;
    float width = owner_rect.size.x - SLIDER_BLOCK;
    float height = owner_rect.size.y - SLIDER_BLOCK;

    renderer.finish();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glm::u8vec4 wall_color;
    auto now = engine->getElapsedTime();
    if (isGameCompleteSuccess())
    {
        wall_color = glm::u8vec4(0, 128, 0, 255);
    }
    else
    {
        // blink red, blink very fast when failed
        wall_color = glm::u8vec4((int)(100.f * (1.f - std::fabsf(std::sinf(now * (isGameCompleteFailure() ? 10.f : 2.f))))), 0, 0, 255);
    }
    renderer.fillRect(sp::Rect(off_x, off_y, width, height), wall_color);

    // map borders
    width -= MAP_BORDER*2;
    height -= MAP_BORDER*2;
    off_x += MAP_BORDER;
    off_y += MAP_BORDER;

    const float tile_width = width / map.width;
    const float tile_height = height / map.height;

    for (int x = 0; x < map.width; x++)
    {
        for (int y = 0; y < map.height; y++)
        {
            auto terrain = map.getTile({ x, y }).terrain;
            if (terrain == Terrain::Road || terrain == Terrain::Goal)
            {
                renderer.fillRect(sp::Rect(off_x + x * tile_width, off_y + y * tile_height, tile_width, tile_height), terrain == Terrain::Goal ? glm::u8vec4(255, 255, 0, 255) : glm::u8vec4(200, 200, 200, 255));
            }
        }
    }

    const float pawn_size = std::min(tile_width, tile_height) * 0.25f;
    glm::vec2 pawn_pos = glm::vec2(off_x + map.pawn.x * width, off_y + map.pawn.y * height);
    renderer.fillCircle(pawn_pos, pawn_size, glm::u8vec4(0, 0, 255, 255));
    auto ping_progress = std::fmodf(now, 1.f);
    renderer.drawCircleOutline(pawn_pos, pawn_size + ping_progress * 100, pawn_size, glm::u8vec4(255, 255, 255, (int)(128 * (1- ping_progress))));
    renderer.finish();
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
