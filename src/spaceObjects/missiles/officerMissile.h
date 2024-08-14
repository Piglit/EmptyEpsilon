#ifndef OFFICER_MISSLE_H
#define OFFICER_MISSLE_H

#include "missileWeapon.h"

class OfficerMissile : public MissileWeapon
{
public:
    OfficerMissile();

    virtual void hitObject(P<SpaceObject> object) override;
};

#endif//OFFICER_MISSLE_H
