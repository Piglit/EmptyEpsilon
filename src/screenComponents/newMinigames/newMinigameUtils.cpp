#include "newMinigameUtils.h"


void xy::move(const int direction)
{
    switch (direction)
    {
    case 0: y--; break;
    case 1: x++; break;
    case 2: y++; break;
    case 3: x--; break;
    }
}

bool xy::tryMove(const int direction, const int& width, const int& height)
{
    switch (direction)
    {
    case 0: if (y <= 0) { return false; } y--; break;
    case 1: if (x >= width-1) { return false; }  x++; break;
    case 2: if (y >= height-1) { return false; }  y++; break;
    case 3: if (x <= 0) { return false; }  x--; break;
    }
    return true;
}
