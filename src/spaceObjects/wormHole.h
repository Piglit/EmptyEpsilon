#ifndef WORM_HOLE_H
#define WORM_HOLE_H

#include "nebula.h"
#include "spaceObjectWithSize.h"
#include "pathPlanner.h"

class WormHole : public SpaceObjectWithSize, public virtual IAvoidableSpaceObject
{
private:
    glm::vec2 target_position = glm::vec2(0.0f, 0.0f);
    float update_delta = 0.0f;

    ScriptSimpleCallback on_teleportation;

public:
    WormHole();

    virtual void draw3DTransparent() override;
    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual void update(float delta) override;
    virtual void collide(Collisionable* target, float force) override;
    virtual ERadarLayer getRadarLayer() const override { return ERadarLayer::BackgroundObjects; }

    void setTargetPosition(glm::vec2 v);   /* Where to jump to */
    glm::vec2 getTargetPosition();
    void onTeleportation(ScriptSimpleCallback callback);

    virtual string getExportLine() override { return "WormHole():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + "):setTargetPosition(" + string(target_position.x, 0) + ", " + string(target_position.y, 0) + "):setSize(" + string(getSize(), 0) + ")"; }

    virtual void setSize(float size) override;
    virtual float getReasonableMaxValue() override { return 50000; }
    virtual float getAvoidSize() override;
};

#endif//WORM_HOLE_H
