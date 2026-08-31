#ifndef SPACE_OBJECT_WITH_SIZE_H
#define SPACE_OBJECT_WITH_SIZE_H

#include "spaceObject.h"

class ISpaceObjectWithSize
{
public:
	virtual ~ISpaceObjectWithSize() = default;
	virtual float getSize() = 0;
	virtual void setSize(float size) = 0;
	virtual float getReasonableMinValue() { return 0.1f; };
	virtual float getReasonableMaxValue() = 0;
};

class SpaceObjectWithSize : public SpaceObject, public virtual ISpaceObjectWithSize
{
public:
	SpaceObjectWithSize(float collision_range, float starting_size, string multiplayer_name, float multiplayer_significant_range = -1);
	virtual float getSize() override;
	virtual void setSize(float size) override;
protected:
	float size;
	void checkSizeMatchesRadius();
	void ensureRadiusIsSize();
};

#endif//SPACE_OBJECT_WITH_SIZE_H
