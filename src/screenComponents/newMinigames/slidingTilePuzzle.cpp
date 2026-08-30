#include "random.h"
#include "slidingTilePuzzle.h"
#include "../hackingDialog.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_label.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_panel.h"

SlidingTilePuzzle::SlidingTilePuzzle(GuiPanel* owner, GuiHackingDialog* parent, int difficulty)
	: MiniGame(owner, parent, difficulty) {
	// 0: 2x3
	// 1: 3x3
	// 2: 3x4
	// 3: 4x4
	//width = 3 + difficulty / 2;
	//height = 3 + (difficulty + 1) / 2;
	width = 2 + (difficulty + 1) / 2;
	height = 3 + (difficulty) / 2;
	if (irandom(0, 1) == 0)
	{
		std::swap(width, height);
	}
	map = std::vector<size_t>(width * height);
	terrain = std::vector<SlidingTilePuzzle::TerrainInfo>();

	// terrain:
	terrain.push_back(SlidingTilePuzzle::TerrainInfo("corner", 0)/*"\xDA"*/); // top left
	terrain.push_back(SlidingTilePuzzle::TerrainInfo("corner", 90)/*"\xBF"*/); // top right
	terrain.push_back(SlidingTilePuzzle::TerrainInfo("", 0)); // center
	terrain.push_back(SlidingTilePuzzle::TerrainInfo("edge", 0)/*"\xC4"*/); // top and bottom
	terrain.push_back(SlidingTilePuzzle::TerrainInfo("edge", 90)/*"\xB3"*/); // left and right
	terrain.push_back(SlidingTilePuzzle::TerrainInfo("corner", 270)/*"\xC0"*/); // bottom left
	terrain.push_back(SlidingTilePuzzle::TerrainInfo("corner", 180)/*"\xD9"*/); // bottom right

	for (int i = 0; i < width * height; i++)
	{
		auto [x, y] = tryGetCoords(i).value();

		// build a box
		int terrain_id;
		if (y == 0)
		{
			if (x == 0)
			{
				terrain_id = 0;
			}
			else if (x == width - 1)
			{
				terrain_id = 1;
			}
			else
			{
				terrain_id = 3;
			}
		}
		else if (y == height - 1)
		{
			if (x == 0)
			{
				terrain_id = 5;
			}
			else if (x == width - 1)
			{
				terrain_id = 6;
			}
			else
			{
				terrain_id = 3;
			}
		}
		else if (x == 0 || x == width - 1)
		{
			terrain_id = 4;
		}
		else
		{
			terrain_id = 2;
		}
		map[i] = terrain_id;

		FieldItem* item = new FieldItem(owner, "", "", [this, i](bool b) { onFieldClick(i); });
		item->setSize(50, 50);
		item->setPosition(x * 50 - width * 25, 25 + y * 50 - height * 25, sp::Alignment::Center);
		board.emplace_back(item);
	}
	reset();
}

void SlidingTilePuzzle::disable()
{
	MiniGame::disable();
	for (size_t i = 0; i < board.size(); i++)
	{
		auto item = getFieldItem(i);
		item->disable();
	}
}

void SlidingTilePuzzle::reset()
{
	MiniGame::reset();

	// create the board (without actual GUI yet)
	auto num_tiles = width * height;
	std::vector<TileData> tiles {};
	for (int i = 0; i < num_tiles; i++)
	{
		tiles.push_back(TileData(map[i], false));
	}

	// pick the free spot (could be multiple in theory)
	// auto free_index = irandom(0, num_tiles - 1);
	// pick one of the inner tiles
	auto free_index = tryGetIndex({ irandom(1, width - 2), irandom(1, height - 2) }).value();
	tiles[free_index].is_free = true;

	// shuffle
	auto shuffles = 100 * difficulty;
	while (shuffles-- > 0)
	{
		// move the free spot randomly, swap values
		auto coords = tryGetCoords(free_index).value();
		moveCoords(&coords, irandom(0, 3));
		auto maybe_index = tryGetIndex(coords);

		if (!maybe_index.has_value())
		{
			// bad, try again
			continue;
		}

		// good, swap tiles
		auto new_index = maybe_index.value();
		std::swap(tiles[new_index], tiles[free_index]);
		free_index = new_index;
	}

	// put state into UI buttons
	for (int i = 0; i < num_tiles; i++)
	{
		auto item = getFieldItem(i);
		item->tile_data = tiles[i];
	}

	checkGameState();
}

float SlidingTilePuzzle::getProgress()
{
	return progress;
}

void SlidingTilePuzzle::gameComplete()
{
	parent->onMiniGameComplete(true);
	game_complete = true;
}

void SlidingTilePuzzle::checkGameState()
{
	if (game_complete)
	{
		return;
	}

	int num_tiles_in_place = 0;
	int num_free_tiles = 0;

	auto num_tiles = width * height;
	for (int i = 0; i < num_tiles; i++)
	{
		auto button = getFieldItem(i);
		auto& tile = button->tile_data;

		button->setVisible(!tile.is_free);

		if (tile.is_free)
		{
			num_free_tiles++;
		}
		else
		{
			auto is_in_place = tile.terrain_index == map[i];

			button->disable();
			button->setValue(is_in_place);
			auto& tile_terrain = terrain[tile.terrain_index];
			button->setIcon(tile_terrain.sprite.empty() ? "" : "custom/newMinigames/slidingTilePuzzle/" + tile_terrain.sprite + ".png", sp::Alignment::Center, tile_terrain.rotation);

			if (is_in_place)
			{
				num_tiles_in_place++;
			}
		}
	}

	auto num_tiles_that_count = num_tiles - num_free_tiles;

	progress = static_cast<float>(num_tiles_in_place) / static_cast<float>(num_tiles_that_count);

	if (num_tiles_in_place == num_tiles_that_count)
	{
		gameComplete();
		for (int i = 0; i < num_tiles; i++)
		{
			auto button = getFieldItem(i);
			button->setValue(false);
		}
	}
	else
	{
		// mark movable tiles (support for multiple spaces)
		for (int i = 0; i < num_tiles; i++)
		{
			auto button = getFieldItem(i);
			if (button->tile_data.is_free)
			{
				// mark adjacent as movable
				auto coords = tryGetCoords(i).value();
				for (int i = 0; i < 4; i++)
				{
					auto neighbour_coords = coords;
					moveCoords(&neighbour_coords, i);
					auto neighbour_index = tryGetIndex(neighbour_coords);
					if (!neighbour_index.has_value()) {
						// on the edge
						continue;
					}
					// this neighbour button is clickable! (will move into the free space)
					auto neighbour = getFieldItem(neighbour_index.value());
					neighbour->enable();
				}
			}
		}
	}
}

glm::vec2 SlidingTilePuzzle::getBoardSize()
{
	return glm::vec2(width * 50, height * 50);
}

void SlidingTilePuzzle::onFieldClick(int index)
{
	if (game_complete)
	{
		return;
	}
	auto button = getFieldItem(index);
	if (!button->isEnabled() || button->tile_data.is_free)
	{
		return;
	}

	// move into a free neighbour
	auto coords = tryGetCoords(index).value();
	for (int i = 0; i < 4; i++)
	{
		auto neighbour_coords = coords;
		moveCoords(&neighbour_coords, i);
		auto neighbour_idx = tryGetIndex(neighbour_coords);
		if (neighbour_idx.has_value()) {
			auto neighbour = getFieldItem(neighbour_idx.value());
			if (neighbour->tile_data.is_free) {
				// swap them!
				std::swap(neighbour->tile_data, button->tile_data);
				checkGameState();
				break;
			}
		}
	}
}

std::optional<std::pair<int, int>> SlidingTilePuzzle::tryGetCoords(int index) {
	if (index < 0 || index >= width * height)
	{
		return {};
	}
	return { {index % width, index / width } };
}

std::optional<int> SlidingTilePuzzle::tryGetIndex(std::pair<int, int> coords)
{
	auto [x, y] = coords;
	if (x < 0 || y < 0 || x >= width || y >= height)
	{
		return {};
	}
	return { x + y * width };
}

void SlidingTilePuzzle::moveCoords(std::pair<int, int>* coords, int direction)
{
	auto& [x, y] = *coords;
	switch (direction)
	{
	case 0: y--; break;
	case 1: x++; break;
	case 2: y++; break;
	case 3: x--; break;
	}
}

SlidingTilePuzzle::FieldItem* SlidingTilePuzzle::getFieldItem(int idx)
{
	return dynamic_cast<SlidingTilePuzzle::FieldItem*>(board[idx]);
}

SlidingTilePuzzle::FieldItem::FieldItem(GuiContainer* owner, string id, string text, func_t func)
	: GuiToggleButton(owner, id, text, func), tile_data({ 0, false })
{
}

SlidingTilePuzzle::TileData::TileData(size_t terrain_index, bool is_free)
	: terrain_index(terrain_index), is_free(is_free)
{
}

SlidingTilePuzzle::TerrainInfo::TerrainInfo(string sprite, float rotation)
	: sprite(sprite), rotation(rotation)
{
}
