#include "spaceObjects/explosionEffect.h"
#include "spaceObjects/spaceStation.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "factionInfo.h"
#include "mesh.h"
#include "main.h"
#include "pathPlanner.h"

#include "scriptInterface.h"

/// A SpaceStation is an immobile ship-like object that repairs, resupplies, and recharges ships that dock with it.
/// It sets several ShipTemplateBasedObject properties upon creation:
/// - Its default callsign begins with "DS".
/// - It restocks scan probes and CpuShip weapons by default.
/// - It uses the scripts/comms_station.lua comms script by default.
/// - When destroyed by damage, it awards or deducts a number of reputation points relative to its total shield strength and segments.
/// - Any non-hostile SpaceShip can dock with it by default.
REGISTER_SCRIPT_SUBCLASS(SpaceStation, ShipTemplateBasedObject)
{
}

REGISTER_MULTIPLAYER_CLASS(SpaceStation, "SpaceStation");
SpaceStation::SpaceStation()
: ShipTemplateBasedObject(300, "SpaceStation")
{
    restocks_scan_probes = true;
    restocks_missiles_docked = R_CpuShips;
    comms_script_name = "comms_station.lua";
    setRadarSignatureInfo(0.2, 0.5, 0.5);

    callsign = "DS" + string(getMultiplayerId());
}

void SpaceStation::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    // ships and space stations should follow the same rules when drawing their minimap icon (radar trace):
    // - in close range mode, draw the radar trace as accurate as possible
    // - in long range mode, don't draw extra stuff (shields, beam arcs, etc)
    // - in long range mode, draw icons at a constant size, EXCEPT:
    // --- when the real size of the icon would be larger than the constant size, use the real size (so large objects still look large in long range mode)

    float sprite_scale = scale * getRadarTraceScale(RADIUS_MULTIPLIER_STATION);

    if (long_range)
    {
        // in long range mode, we can't get smaller than a certain size
        sprite_scale = std::max(sprite_scale, getLongRangeRadarTraceScale());
    }
    else
    {
        // shields are only drawn when close range
        // allow overriding of the shield distance, as large radar sprites could otherwise really screw with this
        float shield_scale = radar_trace_shield_scale <= 0 ? sprite_scale : radar_trace_shield_scale;

        // this /32.0f is pure magic, and is fed into a mess of a formula. oh well. as long as it looks ok... :)
        drawShieldsOnRadar(renderer, position, scale, rotation, shield_scale / 32.0f, true);
    }
    //sprite_scale = std::max(0.15f * 32.0f, sprite_scale);
    glm::u8vec4 color{255,255,255,255};
    if (factionInfo[getFactionId()])
        color = factionInfo[getFactionId()]->getGMColor();
    if (my_spaceship)
    {
        if (isEnemy(my_spaceship))
            color = glm::u8vec4(255, 0, 0, 255);
        else if (isFriendly(my_spaceship))
            color = glm::u8vec4(128, 255, 128, 255);
        else
            color = glm::u8vec4(128, 128, 255, 255);
    }
    renderer.drawRotatedSprite(radar_trace, position, sprite_scale, getRotation() - rotation, color);
}

void SpaceStation::applyTemplateValues()
{
    PathPlannerManager::getInstance()->addAvoidObject(this, getRadius() * 1.5f);
}

void SpaceStation::destroyedByDamage(DamageInfo& info)
{
    ExplosionEffect* e = new ExplosionEffect();
    e->setSize(getRadius());
    e->setPosition(getPosition());
    e->setRadarSignatureInfo(0.0, 0.4, 0.4);

    if (info.instigator)
    {
        float points = 0;
        if (shield_count > 0)
        {
            for(int n=0; n<shield_count; n++)
            {
                points += shield_max[n] * 0.1f;
            }
            points /= shield_count;
        }
        points += hull_max * 0.1f;
        if (isEnemy(info.instigator))
            info.instigator->addReputationPoints(points);
        else
            info.instigator->removeReputationPoints(points);
    }
}

DockStyle SpaceStation::canBeDockedBy(P<SpaceObject> obj)
{
    if (isEnemy(obj))
        return DockStyle::None;
    P<SpaceShip> ship = obj;
    if (!ship)
        return DockStyle::None;
    return DockStyle::External;
}

string SpaceStation::getExportLine()
{
    string ret = "SpaceStation()";
    ret += ":setTemplate(\"" + template_name + "\")";

    if (getShortRangeRadarRange() != ship_template->short_range_radar_range)
    {
        ret += ":setShortRangeRadarRange(" + string(getShortRangeRadarRange(), 0) + ")";
    }

    if (getLongRangeRadarRange() != ship_template->long_range_radar_range)
    {
        ret += ":setLongRangeRadarRange(" + string(getLongRangeRadarRange(), 0) + ")";
    }

    ret += ":setFaction(\"" + getFaction() + "\")";
    ret += ":setCallSign(\"" + getCallSign() + "\")";
    ret += ":setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";

    return ret;
}
