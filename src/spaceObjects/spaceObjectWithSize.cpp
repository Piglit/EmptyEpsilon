#include "spaceObjectWithSize.h"
#include "scriptInterface.h"

/// SpaceObject is the base class for every object in the game universe.
/// Scripts can't create SpaceObjects directly, but all objects of SpaceObject subclasses can also access these core functions.
/// Each object has a position, rotation, and collision shape.
/// The Collisionable class is provided by SeriousProton.
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(SpaceObjectWithSize, SpaceObject)
{
    /// Sets this objects's size (usually its radius).
    /// Default values:
    /// Asteroids: between 110 and 130
    /// Nebulas: 5000
    /// Explosions: 1
    /// Example: asteroid:setSize(150)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObjectWithSize, setSize);
    /// Returns this objects's size (usually its radius).
    /// Example: asteroid:getSize()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObjectWithSize, getSize);
}

SpaceObjectWithSize::SpaceObjectWithSize(float collision_range, float starting_size, string multiplayer_name, float multiplayer_significant_range)
    :SpaceObject::SpaceObject(collision_range, multiplayer_name, multiplayer_significant_range), size(starting_size)
{
    registerMemberReplication(&size);
}

void SpaceObjectWithSize::setSize(float s)
{
    size = s;
}

float SpaceObjectWithSize::getSize()
{
    return size;
}

// Calls setSize() if the radius doesn't match the size. That means you have to call setRadius() if you want to "fix" it!
void SpaceObjectWithSize::checkSizeMatchesRadius()
{
    // size is synced, but radius is up to the object
    if (size != getRadius())
    {
        setSize(size);
    }
}

// If the radius is not the same as size, sets the radius to size.
void SpaceObjectWithSize::ensureRadiusIsSize()
{
    // size is synced, but radius is up to the object
    if (size != getRadius())
    {
        setRadius(size);
    }
}
