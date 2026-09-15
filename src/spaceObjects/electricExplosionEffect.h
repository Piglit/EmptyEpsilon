#ifndef ELECTRIC_EXPLOSION_EFFECT_H
#define ELECTRIC_EXPLOSION_EFFECT_H

#include "explosionEffect.h"
#include "glObjects.h"
#include "spaceObjectWithSize.h"

class ElectricExplosionEffect : public AbstractExplosionEffect
{
    constexpr static float maxLifetime = 4.f;
    constexpr static int particleCount = 1000;

    glm::vec3 particleDirections[particleCount];

    static constexpr size_t max_quad_count = particleCount;
    gl::Buffers<2> particlesBuffers{ gl::Unitialized{} };
public:
    ElectricExplosionEffect();
    virtual ~ElectricExplosionEffect();

    virtual void draw3DTransparent() override;
    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool longRange) override;
protected:
    virtual void playSpawnSound() override; 
private:
    void initializeParticles();
};

#endif//ELECTRIC_EXPLOSION_EFFECT_H
