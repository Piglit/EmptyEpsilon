#ifndef SPACE_OBJECT_WITH_SIZE_H
#define SPACE_OBJECT_WITH_SIZE_H

#include "spaceObject.h"
#include "Updatable.h"

class ISpaceObjectWithSize
{
public:
	virtual ~ISpaceObjectWithSize() = default;
	virtual float getSize() = 0;
	virtual void setSize(float size) = 0;
	virtual float getReasonableMinValue() { return 0.1f; };
	virtual float getReasonableMaxValue() = 0;
};

class SpaceObjectWithSize : public SpaceObject, public virtual ISpaceObjectWithSize, public Updatable
{
public:
	SpaceObjectWithSize(float collision_range, float starting_size, string multiplayer_name, float multiplayer_significant_range = -1);
	SpaceObjectWithSize(float size_and_radius, string multiplayer_name, float multiplayer_significant_range = -1);
	virtual float getSize() override;
	virtual void setSize(float size) override;
	virtual void update(float delta) override;
protected:
	float size;
	// by default, uses getRadius() to compare with size
	virtual void updateSize();
};

#endif//SPACE_OBJECT_WITH_SIZE_H
