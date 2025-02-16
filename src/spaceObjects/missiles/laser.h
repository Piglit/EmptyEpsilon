#ifndef LASER_MISSLE_H
#define LASER_MISSLE_H

#include "missileWeapon.h"

class LaserMissileGreen : public MissileWeapon
{
public:
    LaserMissileGreen();
    virtual void hitObject(P<SpaceObject> object) override;
    virtual void particleEffect() override;
};

class LaserMissileRed: public MissileWeapon
{
public:
    LaserMissileRed();
    virtual void hitObject(P<SpaceObject> object) override;
    virtual void particleEffect() override;
};

#endif//LASER_MISSLE_H
