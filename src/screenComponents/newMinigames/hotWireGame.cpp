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
    can_fail(difficulty > 0),
    can_teleport(difficulty < 2)
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
        onSlider(value, true);
        });
    slider_horizontal->setSize(board_size.x - SLIDER_BLOCK, SLIDER_THICKNESS);
    slider_horizontal->setPosition(SLIDER_BLOCK * 0.5f, -SLIDER_MARGIN, sp::Alignment::BottomCenter);
    board.emplace_back(slider_horizontal);

    slider_vertical = new GuiBasicSlider(proxy_canvas, "HOT_WIRE_VERTICAL", 0, 1, 0, [this](float value) {
        onSlider(value, false);
        });
    slider_vertical->setSize(SLIDER_THICKNESS, board_size.y - SLIDER_BLOCK);
    slider_vertical->setPosition(SLIDER_MARGIN, -SLIDER_BLOCK * 0.5f, sp::Alignment::CenterLeft);
    board.emplace_back(slider_vertical);


    // the canvas size would be fine, but we want additional sliders
    //proxy_canvas->setSize()
}

void HotWireGame::onSlider(float value, bool horizontal)
{
    setPawnPosition(horizontal ? value : map.pawn.x, !horizontal ? value : map.pawn.y, can_teleport);
    updateSliders();
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

void HotWireGame::setPawnPosition(float x, float y, bool teleport)
{
    if (game_complete)
    {
        return;
    }

    x = std::clamp(x, 0.f, 0.9999f);
    y = std::clamp(y, 0.f, 0.9999f);

    auto target_coords = map.toXY({ x, y });
    HotWireGame::Tile const* target_tile = map.tryGetTile(target_coords);
    assert(target_tile);

    auto current_coords = map.toXY(map.pawn);
    auto current_tile = map.tryGetTile(current_coords);
    if (!teleport && current_tile)
    {
        bool unimpeded = true;
        while (current_tile != target_tile)
        {
            // Moving diagonally isn't really a thing, but if it were, we should make sure to move "fairer" than this.
            auto diff_x = target_coords.x - current_coords.x;
            auto diff_y = target_coords.y - current_coords.y;
            auto moved_x = std::abs(diff_x) > std::abs(diff_y);
            bool moved_positive;
            if (moved_x)
            {
                // move x
                moved_positive = target_coords.x > current_coords.x;
                current_coords.x += moved_positive ? 1 : -1;
            }
            else
            {
                // move y
                moved_positive = target_coords.y > current_coords.y;
                current_coords.y += moved_positive ? 1 : -1;
            }
            auto& next_tile = map.getTileRef(current_coords);
            if (!next_tile.isPassable())
            {
                // uh oh
                if (can_fail)
                {
                    target_tile = &next_tile;
                    // right up into that tile so we get detected as failed
                    if (moved_x)
                    {
                        map.pawn.x = (current_coords.x + (moved_positive ? 0.01f : 0.99f)) / map.width;
                    }
                    else
                    {
                        map.pawn.y = (current_coords.y + (moved_positive ? 0.01f : 0.99f)) / map.height;
                    }
                }
                else
                {
                    target_tile = current_tile;
                    // move right up to the tile, but not into it
                    if (moved_x)
                    {
                        map.pawn.x = (current_coords.x + (moved_positive ? -0.01f : 1.01f)) / map.width;
                    }
                    else
                    {
                        map.pawn.y = (current_coords.y + (moved_positive ? -0.01f : 1.01f)) / map.height;
                    }
                }
                unimpeded = false;
                break;
            }
            else if (&next_tile != target_tile)
            {
                // just move into the center of the tile
                if (moved_x)
                {
                    map.pawn.x = (current_coords.x + 0.5f) / map.width;
                }
                else
                {
                    map.pawn.y = (current_coords.y + 0.5f) / map.height;
                }
            }
            current_tile = &next_tile;
        }
        if (unimpeded)
        {
            map.pawn.x = x;
            map.pawn.y = y;
        }

        // TODO: proper diagonal movement
        //int num_tiles_to_travel = std::abs(target_coords.x - current_coords.x) + std::abs(target_coords.y - current_coords.y); // taxi!
        //float total_x_quota = map.pawn.y == previous_position.y ? 1.f : (std::fabs(map.pawn.x - previous_position.x) / std::fabs(map.pawn.y - previous_position.y));
        //while(current_tile != target_tile)
        //{
        //    float current_x_quota = current_coords.y == target_coords.y ? 1.f : (std::fabs(target_coords.x - current_coords.x) / std::fabs(target_coords.y - current_coords.y));
        //    // quota explanation:
        //    // when only y changes: =0
        //    // when only x changes: >=1
        //    // when both change equally: =1
        //    // when x changes more: >1
        //    // when y changes more: <1

        //    // but what really matters is the difference between total_x_quota and current_x_quota, determining if we change x or y next
        //    bool change_x_next = total_x_quota - current_x_quota >= 0;
        //}
    }
    else if (can_fail || target_tile->isPassable() || !current_tile)
    {
        // Easy, just go right there. If we're inside a wall, too bad.
        map.pawn = { x,y };
    }
    else
    {
        // otherwise we just stay where we were
        target_tile = current_tile;
    }

    if (target_tile->terrain == Terrain::Goal)
    {
        progress = 1;
        gameComplete(true);
    }
    else if (target_tile->terrain != Terrain::Road)
    {
        // if we're inside a wall, we lose
        progress = 0;
        gameComplete(false);
    }
    else
    {
        progress = target_tile->progress;
    }
}

void HotWireGame::onNewGame()
{
    createNewMap();
    finalizeMap();
    setPawnPosition(map.pawn.x, map.pawn.y, true);
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
    else if (can_fail)
    {
        // blink red, blink very fast when failed
        wall_color = glm::u8vec4((int)(100.f * (1.f - std::fabsf(std::sinf(now * (isGameCompleteFailure() ? 10.f : 2.f))))), 0, 0, 255);
    }
    else
    {
        wall_color = glm::u8vec4(0, 0, 0, 255);
    }
    renderer.fillRect(sp::Rect(off_x, off_y, width, height), wall_color);

    // map borders
    width -= MAP_BORDER * 2;
    height -= MAP_BORDER * 2;
    off_x += MAP_BORDER;
    off_y += MAP_BORDER;

    const float tile_width = width / map.width;
    const float tile_height = height / map.height;

    for (int x = 0; x < map.width; x++)
    {
        for (int y = 0; y < map.height; y++)
        {
            auto& tile = map.getTile({ x, y });
            if (tile.isPassable())
            {
                renderer.fillRect(sp::Rect(off_x + x * tile_width, off_y + y * tile_height, tile_width, tile_height), tile.terrain == Terrain::Goal ? glm::u8vec4(255, 255, 0, 255) : glm::u8vec4(200, 200, 200, 255));
            }
        }
    }

    const float pawn_size = std::min(tile_width, tile_height) * 0.25f;
    glm::vec2 pawn_pos = glm::vec2(off_x + map.pawn.x * width, off_y + map.pawn.y * height);
    renderer.fillCircle(pawn_pos, pawn_size, glm::u8vec4(0, 0, 255, 255));
    auto ping_progress = std::fmodf(now, 1.f);
    renderer.drawCircleOutline(pawn_pos, pawn_size + ping_progress * 100, pawn_size, glm::u8vec4(255, 255, 255, (int)(128 * (1 - ping_progress))));
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

Labyrinth::Labyrinth(GuiPanel* owner, GuiHackingDialog* parent, int difficulty) :
    HotWireGame(owner, parent, difficulty)
{
    // labyrinths are much more maze-like, but you also can't fail due to touching walls
    can_fail = false;
    can_teleport = false;
}

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

HotWireGame::Tile* HotWireGame::Map::tryGetMapTile(const glm::vec2& pos)
{
    auto index = tryGetIndex(toXY(pos));
    if (!index)
    {
        return nullptr;
    }
    return &tiles[*index];
}

void HotWireGame::Map::setPawn(const xy& coords)
{
    pawn = { (coords.x + 0.5f) / width, (coords.y + 0.5f) / height };
}

xy HotWireGame::Map::toXY(const glm::vec2& pos) const
{
    return { (int)(pos.x * width), (int)(pos.y * height) };
}

HotWireGame::Tile::Tile(const Terrain terrain) :
    terrain(terrain),
    progress(0)
{}

bool HotWireGame::Tile::isPassable() const
{
    return terrain == Terrain::Road || terrain == Terrain::Goal;
}

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
            std::cout << (tile.terrain == Terrain::Road ? " #" : tile.terrain == Terrain::Goal ? " X" : tile.terrain == Terrain::Border ? " °" : "  ");
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
                int num = tile.progress * 100.f;
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
            auto result = map.generate(2, true);

            // check for 2x2s
            for (int x = 0; x < map.width - 1; x++)
            {
                for (int y = 0; y < map.height - 1; y++)
                {
                    if (map.getTile({ x, y }).isPassable() && map.getTile({ x + 1, y }).isPassable() && map.getTile({ x, y + 1 }).isPassable() && map.getTile({ x + 1, y + 1 }).isPassable())
                    {
                        std::cout << "SQARE @ " << x << "," << y << std::endl;
                        best_map = map;
                        goto found_square;
                    }
                }
            }

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
        found_square:

        map = *best_map;// ->finalize(true);
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

    auto createSnakeyPath = [this](int num_bends, xy& pos)
    {
        while (num_bends > 0)
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
            while (--travel_length >= 0)
            {
                for (int i = 0; i < 4; i++)
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
                auto& tile_ref = getTileRef(probe);
                if (tile_ref.terrain == Terrain::Wall)
                {
                    tile_ref.terrain = Terrain::Border;
                }
            }

            num_bends--;
        }

        // mark all wall around the final tile as borders as well
        for (int i = 0; i < 4; i++)
        {
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

        return num_bends;
    };

    // pick random start
    xy cursor = { irandom(0, width - 1), irandom(0, height - 1) };

    // set start
    setTile(cursor, Terrain::Road);
    setPawn(cursor);

    int main_path_bends = irandom(4, 6) + difficulty * 6;
    auto result = createSnakeyPath(main_path_bends, cursor);
    auto score = main_path_bends - result;
    auto success = result == 0;

    // last tile is the goal
    setTile(cursor, Terrain::Goal);

    if (labyrinth)
    {
        std::vector<xy> starting_tiles;
        while (true)
        {
            starting_tiles.clear();
            // create additional branches, that never connect back into themselves (for now)
            // First, find all eligible starting points.
            // A starting point must be a border tile that has exactly 1 adjacent road.
            for (int i = 0; i < length; i++)
            {
                auto& tile = tiles[i];
                if (tile.terrain != Terrain::Border)
                {
                    continue;
                }
                int adjacentRoadDirection = -1;
                xy cursor = getCoords(i);
                for (int direction = 0; direction < 4; direction++)
                {
                    xy neighbour_pos = cursor;
                    if (tryMoveCoords(&neighbour_pos, direction))
                    {
                        auto& neighbour = getTile(neighbour_pos);
                        if (neighbour.terrain == Terrain::Goal)
                        {
                            // this tile is not good, it would connect into a goal
                            adjacentRoadDirection = -1;
                            break;
                        }
                        if (neighbour.terrain == Terrain::Road)
                        {
                            if (adjacentRoadDirection == -1)
                            {
                                adjacentRoadDirection = direction;
                            }
                            else
                            {
                                // this tile is not good, it would have more than 1 road connection
                                adjacentRoadDirection = -1;
                                break;
                            }
                        }
                    }
                }
                if (adjacentRoadDirection != -1)
                {
                    starting_tiles.push_back(cursor);
                }
            }
            if (starting_tiles.empty())
            {
                // map is full
                break;
            }
            auto& starting_tile = starting_tiles[irandom(0, starting_tiles.size() - 1)];
            setTile(starting_tile, Terrain::Road);
            createSnakeyPath(irandom(1, main_path_bends), starting_tile);
        }
    }

    return {
        success,
        score
    };
}
