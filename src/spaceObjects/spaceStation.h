#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "shipTemplateBasedObject.h"
#include "pathPlanner.h"

class SpaceStation : public ShipTemplateBasedObject, public virtual IAvoidableSpaceObject
{
public:
    SpaceStation();

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual DockStyle canBeDockedBy(P<SpaceObject> obj) override;
    virtual void destroyedByDamage(DamageInfo& info) override;
    virtual void applyTemplateValues() override;
    virtual float getAvoidSize() override;

    virtual string getExportLine() override;
};

#endif//SPACE_STATION_H
