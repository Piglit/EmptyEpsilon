#include "laser.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

REGISTER_SCRIPT_SUBCLASS(LaserMissileGreen, MissileWeapon){}
REGISTER_SCRIPT_SUBCLASS(LaserMissileRed, MissileWeapon){}
REGISTER_MULTIPLAYER_CLASS(LaserMissileGreen, "LaserMissileGreen");
REGISTER_MULTIPLAYER_CLASS(LaserMissileRed, "LaserMissileRed");

LaserMissileGreen::LaserMissileGreen(): MissileWeapon("LaserMissileGreen", MissileWeaponData::getDataFor(MW_LaserGreen))
{
    setRadarSignatureInfo(0.0, 0.8, 0.0);
    setCollisionBox({10, 30}); // Make it a bit harder to the HVLI to phase trough smaller enemies
    radar_sprite = "radar/laser_bullet.png";
}
LaserMissileRed::LaserMissileRed(): MissileWeapon("LaserMissileRed", MissileWeaponData::getDataFor(MW_LaserRed))
{
    setRadarSignatureInfo(0.0, 0.8, 0.0);
    setCollisionBox({10, 30}); // Make it a bit harder to the HVLI to phase trough smaller enemies
    radar_sprite = "radar/laser_bullet.png";
}

void LaserMissileGreen::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    object->takeDamage(category_modifier * 2, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * 10);
    e->setPosition(getPosition());
}
void LaserMissileRed::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    object->takeDamage(category_modifier * 2, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * 10);
    e->setPosition(getPosition());
}

void LaserMissileGreen::particleEffect()
{
    ParticleEngine::spawn(glm::vec3(getPosition().x, getPosition().y, -10), glm::vec3(getPosition().x, getPosition().y, -10), glm::vec3(0, 0.8, 0), glm::vec3(0, 0, 0), 5, 5, 1.0);
}
void LaserMissileRed::particleEffect()
{
    ParticleEngine::spawn(glm::vec3(getPosition().x, getPosition().y, -10), glm::vec3(getPosition().x, getPosition().y, -10), glm::vec3(0.8, 0, 0), glm::vec3(0, 0, 0), 5, 5, 1.0);
}

