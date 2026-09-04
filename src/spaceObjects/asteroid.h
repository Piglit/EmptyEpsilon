#ifndef ASTEROID_H
#define ASTEROID_H

#include "spaceObject.h"
#include "spaceObjectWithSize.h"

class AbstractAsteroid : public SpaceObjectWithSize
{
public:
    float rotation_speed;
    float z;
    int model_number;

    AbstractAsteroid(string multiplayerName);
    virtual ~AbstractAsteroid() = default;

    virtual void draw3D() override;
    virtual void setSize(float size) override;
    virtual float getReasonableMaxValue() override { return 1000; }

    virtual string getExportLineStart() = 0;
    virtual string getExportLine() override { return getExportLineStart() + ":setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" + ":setSize(" + string(getSize(), 0) + ")"; }

protected:
    glm::mat4 getModelMatrix() const override;
};

class Asteroid : public AbstractAsteroid
{
public:
    Asteroid();

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual void collide(Collisionable* target, float force) override;

    virtual string getExportLineStart() override { return "Asteroid()"; }
};

class VisualAsteroid : public AbstractAsteroid
{
public:
    VisualAsteroid();

    virtual string getExportLineStart() override { return "VisualAsteroid()"; }
};

#endif//ASTEROID_H
