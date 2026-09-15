#ifndef EXPLOSION_EFFECT_H
#define EXPLOSION_EFFECT_H

#include "spaceObject.h"
#include "glObjects.h"
#include "spaceObjectWithSize.h"

class AbstractExplosionEffect : public SpaceObjectWithSize
{
protected:
    bool on_radar;
    float lifetime;
    float max_lifetime;

    virtual void playSpawnSound() = 0;
public:
    AbstractExplosionEffect(string multiplayer_name, float max_lifetime);
    void setOnRadar(bool on_radar) { this->on_radar = on_radar; }
    virtual float getReasonableMaxValue() override { return 100; }
    virtual void update(float delta) override;
};

class ExplosionEffect : public AbstractExplosionEffect
{
    constexpr static float maxLifetime = 2.f;
    constexpr static int particleCount = 1000;

    string explosion_sound;
    glm::vec3 particleDirections[particleCount];
    // Fit elements in a uint8 - at 4 vertices per quad, that's (256 / 4 =) 64 quads.
    static constexpr size_t max_quad_count = particleCount * 4;
    gl::Buffers<2> particlesBuffers{ gl::Unitialized{} };
public:
    ExplosionEffect();
    virtual ~ExplosionEffect();

    virtual void draw3DTransparent() override;
    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool longRange) override;

    void setExplosionSound(string sound) { this->explosion_sound = sound; }
protected:
    virtual void playSpawnSound() override;
private:
    void initializeParticles();
};

#endif//EXPLOSION_EFFECT_H
