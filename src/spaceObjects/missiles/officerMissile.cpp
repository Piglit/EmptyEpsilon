#include "officerMissile.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

/// It inherits functions and behaviors from its parent MissileWeapon class.
/// Missiles can be fired by SpaceShips or created by scripts, and their damage and blast radius can be modified by missile size.
REGISTER_SCRIPT_SUBCLASS(OfficerMissile, MissileWeapon)
{
  //registered for typeName and creation
}

REGISTER_MULTIPLAYER_CLASS(OfficerMissile, "OfficerMissile");
OfficerMissile::OfficerMissile()
: MissileWeapon("OfficerMissile", MissileWeaponData::getDataFor(MW_Officer))
{
    setRadarSignatureInfo(0.0, 0.1, 0.5);
}

void OfficerMissile::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    object->takeDamage(category_modifier * 1, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * 1);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setRadarSignatureInfo(0.0, 0.0, 0.5);
}
