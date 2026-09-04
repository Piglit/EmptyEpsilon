#ifndef ELECTRIC_EXPLOSION_EFFECT_H
#define ELECTRIC_EXPLOSION_EFFECT_H

#include "spaceObject.h"
#include "glObjects.h"
#include "spaceObjectWithSize.h"

class ElectricExplosionEffect : public SpaceObjectWithSize, public Updatable
{
    constexpr static float maxLifetime = 4.f;
    constexpr static int particleCount = 1000;

    float lifetime;
    glm::vec3 particleDirections[particleCount];
    bool on_radar;

    static constexpr size_t max_quad_count = particleCount;
    gl::Buffers<2> particlesBuffers{ gl::Unitialized{} };
public:
    ElectricExplosionEffect();
    virtual ~ElectricExplosionEffect();

    virtual void draw3DTransparent() override;
    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool longRange) override;
    virtual void update(float delta) override;

    void setOnRadar(bool on_radar) { this->on_radar = on_radar; }
    virtual float getReasonableMaxValue() override { return 100; }
private:
    void initializeParticles();
};

#endif//ELECTRIC_EXPLOSION_EFFECT_H
