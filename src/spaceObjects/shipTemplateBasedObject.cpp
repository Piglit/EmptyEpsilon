#include "shipTemplateBasedObject.h"

#include "scriptInterface.h"

#include "tween.h"
#include "i18n.h"
#include "cpuShip.h"
#include "playerSpaceship.h"

/// A ShipTemplateBasedObject (STBO) is an object class created from a ShipTemplate.
/// This is the parent class of SpaceShip (CpuShip, PlayerSpaceship) and SpaceStation objects, which inherit all STBO functions and can be created by scripts.
/// Objects of this class can't be created by scripts, but SpaceStation and child classes of SpaceShip can.
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(ShipTemplateBasedObject, SpaceObject)
{
    /// Sets this ShipTemplate that defines this STBO's traits, and then applies them to this STBO.
    /// ShipTemplates define the STBO's class, weapons, hull and shield strength, 3D appearance, and more.
    /// See the ShipTemplate class for details, and files in scripts/shiptemplates/ for the default templates.
    /// WARNING: Using a string that is not a valid ShipTemplate name crashes the game!
    /// ShipTemplate string names are case-sensitive.
    /// Examples:
    /// CpuShip():setTemplate("Phobos T3")
    /// PlayerSpaceship():setTemplate("Phobos M3P")
    /// SpaceStation():setTemplate("Large Station")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTemplate);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setTemplate().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShipTemplate);
    /// Sets this STBO's vessel classification name, such as "Starfighter" or "Cruiser".
    /// This overrides the vessel class name provided by the ShipTemplate.
    /// Example: stbo:setTypeName("Prototype")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTypeName);
    /// Returns this STBO's vessel classification name.
    /// Example:
    /// stbo:setTypeName("Prototype")
    /// stbo:getTypeName() -- returns "Prototype"
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getTypeName);
    /// Returns this STBO's hull points.
    /// Example: stbo:getHull()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHull);
    /// Returns this STBO's maximum limit of hull points.
    /// Example: stbo:getHullMax()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHullMax);
    /// Sets this STBO's hull points.
    /// If set to a value larger than the maximum, this sets the value to the limit.
    /// If set to a value less than 0, this sets the value to 0.
    /// Note that setting this value to 0 doesn't immediately destroy the STBO.
    /// Example: stbo:setHull(100) -- sets the hull point limit to either 100, or the limit if less than 100
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHull);
    /// Sets this STBO's maximum limit of hull points.
    /// Note that SpaceStations can't repair their own hull, so this only changes the percentage of remaining hull.
    /// Example: stbo:setHullMax(100) -- sets the hull point limit to 100
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHullMax);
    /// Defines whether this STBO can be destroyed by damage.
    /// Defaults to true.
    /// Example: stbo:setCanBeDestroyed(false) -- prevents the STBO from being destroyed by damage
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setCanBeDestroyed);
    /// Returns whether the STBO can be destroyed by damage.
    /// Example: stbo:getCanBeDestroyed()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getCanBeDestroyed);
    /// Returns the shield points for this STBO's shield segment with the given index.
    /// Shield segments are 0-indexed.
    /// Example for a ship with two shield segments:
    /// stbo:getShieldLevel(0) -- returns front shield points
    /// stbo:getShieldLevel(1) -- returns rear shield points
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldLevel);
    /// Returns this STBO's number of shield segments.
    /// Each segment divides the 360-degree shield arc equally for each segment, up to a maximum of 8 segments.
    /// The segments' order starts with the front-facing segment, then proceeds clockwise.
    /// Example: stbo:getShieldCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldCount);
    /// Returns the maximum shield points for the STBO's shield segment with the given index.
    /// Example: stbo:getShieldMax(0) -- returns the max shield strength for segment 0
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldMax);
    /// Sets this STBO's shield points.
    /// Each number provided as a parameter sets the points for a corresponding shield segment.
    /// Note that the segments' order starts with the front-facing segment, then proceeds clockwise.
    /// If more parameters are provided than the ship has shield segments, the excess parameters are discarded.
    /// Example:
    /// -- On a ship with 4 segments, this sets the forward shield segment to 50, right to 40, rear 30, left 20
    /// -- On a ship with 2 segments, this sets forward 50, rear 40
    /// stbo:setShields(50,40,30,20)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShields);
    /// Sets this STBO's maximum shield points per segment, and can also create new segments.
    /// The number of parameters defines the STBO's number of shield segments, to a maximum of 8 segments.
    /// The segments' order starts with the front-facing segment, then proceeds clockwise.
    /// If more parameters are provided than the STBO has shield segments, the excess parameters create new segments with the defined max but 0 current shield points.
    /// A STBO with one shield segment has only a front shield generator system, and a STBO with two or more segments has only front and rear generator systems.
    /// Setting a lower maximum points value than the segment's current number of points also reduces the points to the limit.
    /// However, increasing the maximum value to a higher value than the current points does NOT automatically increase the current points,
    /// which requires a separate call to ShipTemplateBasedObject:setShield().
    /// Example:
    /// -- On a ship with 4 segments, this sets the forward shield max to 50, right to 40, rear 30, left 20
    /// -- On a ship with 2 segments, this does the same, but its current rear shield points become right shield points, and the new rear and left shield segments have 0 points
    /// stbo:setShieldsMax(50,40,30,20)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShieldsMax);
    /// Sets this STBO's trace image.
    /// Valid values are filenames of PNG images relative to the resources/radar directory.
    /// Radar trace images should be white with a transparent background.
    /// Example: stbo:setRadarTrace("arrow.png") -- sets the radar trace to resources/radar/arrow.png
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRadarTrace);
    /// Sets this STBO's impulse engine sound effect.
    /// Valid values are filenames of WAV files relative to the resources/ directory.
    /// Use a looping sound file that tolerates being pitched up and down as the ship's impulse speed changes.
    /// Example: stbo:setImpulseSoundFile("sfx/engine_fighter.wav") -- sets the impulse sound to resources/sfx/engine_fighter.wav
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setImpulseSoundFile);
    /// Defines whether this STBO's shields are activated.
    /// Always returns true except for PlayerSpaceships, because only players can deactivate shields.
    /// Example stbo:getShieldsActive() -- returns true if up, false if down
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldsActive);
    /// Returns whether this STBO supplies energy to docked PlayerSpaceships.
    /// Example: stbo:getSharesEnergyWithDocked()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getSharesEnergyWithDocked);
    /// Defines whether this STBO supplies energy to docked PlayerSpaceships.
    /// Example: stbo:getSharesEnergyWithDocked(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setSharesEnergyWithDocked);
    /// Returns whether this STBO repairs docked SpaceShips.
    /// Example: stbo:getRepairDocked()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRepairDocked);
    /// Defines whether this STBO repairs docked SpaceShips.
    /// Example: stbo:setRepairDocked(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRepairDocked);
    /// Returns whether the STBO restocks scan probes for docked PlayerSpaceships.
    /// Example: stbo:getRestocksScanProbes()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksScanProbes);
    /// Defines whether the STBO restocks scan probes for docked PlayerSpaceships.
    /// Example: stbo:setRestocksScanProbes(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksScanProbes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setPlayerShipType);
    /// Returns whether this STBO restocks missiles for docked CpuShips.
    /// Example: stbo:getRestocksMissilesDocked()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksMissilesDocked);
    /// Defines whether this STBO restocks missiles for docked CpuShips.
    /// To restock docked PlayerSpaceships' weapons, use a comms script. See ShipTemplateBasedObject:setCommsScript() and :setCommsFunction().
    /// Example: stbo:setRestocksMissilesDocked(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksMissilesDocked);
    /// Returns this STBO's long-range radar range.
    /// Example: stbo:getLongRangeRadarRange()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getLongRangeRadarRange);
    /// Sets this STBO's long-range radar range.
    /// PlayerSpaceships use this range on the science and operations screens' radar.
    /// AI orders of CpuShips use this range to detect potential targets.
    /// Example: stbo:setLongRangeRadarRange(20000) -- sets the long-range radar range to 20U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setLongRangeRadarRange);
    /// Returns this STBO's short-range radar range.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShortRangeRadarRange);
    /// Sets this STBO's short-range radar range.
    /// PlayerSpaceships use this range on the helms, weapons, and single pilot screens' radar.
    /// AI orders of CpuShips use this range to decide when to disengage pursuit of fleeing targets.
    /// This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this SpaceShip can detect objects.
    /// Example: stbo:setShortRangeRadarRange(4000) -- sets the short-range radar range to 4U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShortRangeRadarRange);
    /// Returns the amount of a resource.
    /// Returns 0, if the resource was never set before.
    /// Example: stbo:getResourceAmount("empty cargo space")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getResourceAmount);
    /// Sets the amount of a resource. The amount may be negative.
    /// Example: stbo:setResourceAmount("empty cargo space", 10)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setResourceAmount);
    /// Increases the amount of a resource by the specified amount.
    /// Example: stbo:increaseResourceAmount("empty cargo space", 1)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, increaseResourceAmount);
    /// Decreases the amount of a resource by the specified amount.
    /// The amount may get negative.
    /// Example: stbo:decreaseResourceAmount("empty cargo space", 1)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, decreaseResourceAmount);
    /// Decreases the amount of a resource by the specified amount, if enough of the resource is available. If the amount of the resource would get negative, this function does nothing.
    /// Returns true, if the operation was sucessfull; false otherwise.
    /// Example: stbo:tryDecreaseResourceAmount("empty cargo space", 1)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, tryDecreaseResourceAmount);
    /// Decreases the amount of resource_name_from by amount_from and increases the amount of resource_name_to by amount_to.
    /// The amounts may get negative.
    /// Example: stbo:transformResource("empty cargo space", 1, "trade item", 1) -- decreased "empty cargo space" and increases "trade item" by 1.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, transformResource);
    /// Decreases the amount of resource_name_from by amount_from and increases the amount of resource_name_to by amount_to. If the amount of the decreased resource would get negative, this function does nothing.
    /// Returns true, if the operation was sucessfull; false otherwise.
    /// Example: stbo:tryTransformResource("empty cargo space", 1, "trade item", 1) -- decreased "empty cargo space" and increases "trade item" by 1, if at least 1 "empty cargo space" is available.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, tryTransformResource);
    /// Decreases the amount of a resource on this ShipTemplateBasedObject and increases the same resource about the same amount on another ShipTemplateBasedObject.
    /// The amount may get negative.
    /// Example: stbo:transferResource("trade item", 1, otherShip)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, transferResource);
    /// Decreases the amount of a resource on this ShipTemplateBasedObject and increases the same resource about the same amount on another ShipTemplateBasedObject. If the amount of the decreased resource would get negative, this function does nothing.
    /// Returns true, if the operation was sucessfull; false otherwise.
    /// Example: stbo:tryTransferResource("trade item", 1, otherShip)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, tryTransferResource);
    /// Sets a category for a resource for this ship
    /// Example: stbo:setResourceCategory("empty cargo space", "Cargo")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setResourceCategory);
    /// Gets the category for a resource for this ship
    /// Example: stbo:getResourceCategory("empty cargo space")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getResourceCategory);
    /// Sets a description for a resource for this ship
    /// Example: stbo:setResourceCategory("empty cargo space", "Can be filled with cargo")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setResourceDescription);
    /// Gets the description for a resource for this ship
    /// Example: stbo:getResourceCategory("empty cargo space")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getResourceDescription);
    /// Returns all resources of a given category.
    /// Example: stbo:getResources("cargo")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getResources);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:getShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShieldMax);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShieldMax);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:getShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShieldMax);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldLevel() with an index value.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShield);
    /// [DEPRECATED]
    /// Use ShipTemplateBasedObject:setShieldsMax().
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShieldMax);
    /// Defines a function to call when this STBO takes damage.
    /// Passes the object taking damage and the instigator SpaceObject (or nil) to the function.
    /// Example: stbo:onTakingDamage(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was damaged by " .. instigator:getCallSign()) end)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onTakingDamage);
    /// Defines a function to call when this STBO is destroyed by taking damage.
    /// Passes the object taking damage and the instigator SpaceObject that delivered the destroying damage (or nil) to the function.
    /// Example: stbo:onTakingDamage(function(this_stbo,instigator) print(this_stbo:getCallSign() .. " was destroyed by " .. instigator:getCallSign()) end)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onDestruction);
}

ShipTemplateBasedObject::ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: SpaceObject(collision_range, multiplayer_name, multiplayer_significant_range)
{
    setCollisionPhysics(true, true);

    shield_count = 0;
    for(int n=0; n<max_shield_count; n++)
    {
        shield_level[n] = 0.0;
        shield_max[n] = 0.0;
        shield_hit_effect[n] = 0.0;
    }
    hull_strength = hull_max = 100.0;

    long_range_radar_range = 30000.0f;
    short_range_radar_range = 5000.0f;
    restocks_missiles_docked = R_None;
    player_ship_type = PST_Ship;
    model_name = "";

    registerMemberReplication(&template_name);
    registerMemberReplication(&type_name);
    registerMemberReplication(&shield_count);
    for(int n=0; n<max_shield_count; n++)
    {
        registerMemberReplication(&shield_level[n], 0.5);
        registerMemberReplication(&shield_max[n]);
        registerMemberReplication(&shield_hit_effect[n], 0.5);
    }
    registerMemberReplication(&radar_trace);
    registerMemberReplication(&impulse_sound_file);
    registerMemberReplication(&hull_strength, 0.5);
    registerMemberReplication(&hull_max);
    registerMemberReplication(&long_range_radar_range, 0.5);
    registerMemberReplication(&short_range_radar_range, 0.5);

    callsign = "[" + string(getMultiplayerId()) + "]";

    can_be_destroyed = true;
    registerMemberReplication(&can_be_destroyed);
    registerMemberReplication(&player_ship_type);
    registerMemberReplication(&restocks_missiles_docked, 0.5);
    registerMemberReplication(&restocks_scan_probes, 0.5);
    registerMemberReplication(&shares_energy_with_docked, 0.5);
    registerMemberReplication(&repair_docked, 0.5);

    registerMemberReplication(&resources);
}

void ShipTemplateBasedObject::drawShieldsOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, float sprite_scale, bool show_levels)
{
    if (!getShieldsActive())
        return;
    if (shield_count == 1)
    {
        glm::u8vec4 color = glm::u8vec4(255, 255, 255, 64);
        if (show_levels)
        {
            float level = shield_level[0] / shield_max[0];
            color = Tween<glm::u8vec4>::linear(level, 1.0f, 0.0f, glm::u8vec4(128, 128, 255, 128), glm::u8vec4(255, 0, 0, 64));
        }
        if (shield_hit_effect[0] > 0.0f)
        {
            color = Tween<glm::u8vec4>::linear(shield_hit_effect[0], 0.0f, 1.0f, color, glm::u8vec4(255, 0, 0, 128));
        }
        renderer.drawSprite("shield_circle.png", position, sprite_scale * 0.25f * 1.5f * 256.0f, color);
    }else if (shield_count > 1) {
        float direction = getRotation()-rotation;
        float arc = 360.0f / float(shield_count);

        for(int n=0; n<shield_count; n++)
        {
            glm::u8vec4 color = glm::u8vec4(255, 255, 255, 64);
            if (show_levels)
            {
                float level = shield_level[n] / shield_max[n];
                color = Tween<glm::u8vec4>::linear(level, 1.0f, 0.0f, glm::u8vec4(128, 128, 255, 128), glm::u8vec4(255, 0, 0, 64));
            }
            if (shield_hit_effect[n] > 0.0f)
            {
                color = Tween<glm::u8vec4>::linear(shield_hit_effect[n], 0.0f, 1.0f, color, glm::u8vec4(255, 0, 0, 128));
            }

            glm::vec2 delta_a = vec2FromAngle(direction - arc / 2.0f);
            glm::vec2 delta_b = vec2FromAngle(direction);
            glm::vec2 delta_c = vec2FromAngle(direction + arc / 2.0f);
            
            auto p0 = position + delta_b * sprite_scale * 32.0f * 0.05f;
            renderer.drawTexturedQuad("shield_circle.png",
                p0,
                p0 + delta_a * sprite_scale * 32.0f * 1.5f,
                p0 + delta_b * sprite_scale * 32.0f * 1.5f,
                p0 + delta_c * sprite_scale * 32.0f * 1.5f,
                glm::vec2(0.5, 0.5),
                glm::vec2(0.5, 0.5) + delta_a * 0.5f,
                glm::vec2(0.5, 0.5) + delta_b * 0.5f,
                glm::vec2(0.5, 0.5) + delta_c * 0.5f,
                color);
            direction += arc;
        }
    }
}

void ShipTemplateBasedObject::draw3DTransparent()
{
    if (shield_count < 1)
        return;

    float angle = 0.0;
    float arc = 360.0f / shield_count;
    const auto model_matrix = getModelMatrix();
    for(int n = 0; n<shield_count; n++)
    {
        if (shield_hit_effect[n] > 0)
        {
            if (shield_count > 1)
            {
                model_info.renderShield(model_matrix, (shield_level[n] / shield_max[n]) * shield_hit_effect[n], angle);
            }else{
                model_info.renderShield(model_matrix, (shield_level[n] / shield_max[n]) * shield_hit_effect[n]);
            }
        }
        angle += arc;
    }
}

void ShipTemplateBasedObject::update(float delta)
{
    // All ShipTemplateBasedObjects should have a valid template.
    // If this object lacks a template, or has an inconsistent template...
    if (!ship_template || ship_template->getName() != template_name)
    {
        // Attempt to align the object's template to its reported template name.
        ship_template = ShipTemplate::getTemplate(template_name);

        // If the template still doesn't exist, destroy the object.
        if (!ship_template)
        {
            LOG(ERROR) << "ShipTemplateBasedObject with ID " << string(getMultiplayerId()) << " lacked a template, so it was destroyed.";
            destroy();
            return;
        }

        // If it does exist, set up its collider and model.
        ship_template->setCollisionData(this);
        model_info.setData(ship_template->model_data);
    }

    for(int n=0; n<shield_count; n++)
    {
        if (shield_level[n] < shield_max[n])
        {
            shield_level[n] = std::min(shield_max[n], shield_level[n] + delta * getShieldRechargeRate(n));
        }
        if (shield_hit_effect[n] > 0)
        {
            shield_hit_effect[n] -= delta;
        }
    }
}

std::unordered_map<string, string> ShipTemplateBasedObject::getGMInfo()
{
    std::unordered_map<string, string> ret;
    ret[trMark("gm_info", "CallSign")] = callsign;
    ret[trMark("gm_info", "Type")] = type_name;
    ret[trMark("gm_info", "Hull")] = string(hull_strength) + "/" + string(hull_max);
    for(int n=0; n<shield_count; n++)
    {
        // Note, translators: this is a compromise.
        // Because of the deferred translation the variable parameter can't be forwarded, so it'll always be a suffix.
        ret[trMark("gm_info", "Shield") + string(n + 1)] = string(shield_level[n]) + "/" + string(shield_max[n]);
    }
    return ret;
}

bool ShipTemplateBasedObject::canRestockMissiles(P<SpaceShip> receiver) {
    switch (restocks_missiles_docked) {
        case R_None:
            return false;
        case R_All:
            return true;
        case R_CpuShips:
            if (P<CpuShip>(receiver))
                return true;
            else
                return false;
        case R_PlayerShips:
            if (P<PlayerSpaceship>(receiver))
                return true;
            else
                return false;
        case R_Fighters:
			// assume that internal docking ships are fighters
            return (canBeDockedBy(receiver) == DockStyle::Internal);
    }
    return false;
}

bool ShipTemplateBasedObject::hasShield()
{
    for(int n=0; n<shield_count; n++)
    {
        if (shield_level[n] < shield_max[n] / 50)
            return false;
    }
    return true;
}

void ShipTemplateBasedObject::takeDamage(float damage_amount, DamageInfo info)
{
    if (shield_count > 0 && getShieldsActive())
    {
        float angle = angleDifference(getRotation(), vec2ToAngle(info.location - getPosition()));
        if (angle < 0)
            angle += 360.0f;
        float arc = 360.0f / float(shield_count);
        int shield_index = int((angle + arc / 2.0f) / arc);
        shield_index %= shield_count;

        float shield_damage = damage_amount * getShieldDamageFactor(info, shield_index);
        damage_amount -= shield_level[shield_index];
        shield_level[shield_index] -= shield_damage;
        if (shield_level[shield_index] < 0)
        {
            shield_level[shield_index] = 0.0;
        } else {
            shield_hit_effect[shield_index] = 1.0;
        }
        if (damage_amount < 0.0f)
        {
            damage_amount = 0.0;
        }
    }

    if (info.type != DT_EMP && damage_amount > 0.0f)
    {
        takeHullDamage(damage_amount, info);
    }

    if (hull_strength > 0)
    {
        if (on_taking_damage.isSet())
        {
            if (info.instigator)
            {
                on_taking_damage.call<void>(P<ShipTemplateBasedObject>(this), P<SpaceObject>(info.instigator));
            } else {
                on_taking_damage.call<void>(P<ShipTemplateBasedObject>(this));
            }
        }
    }
}

void ShipTemplateBasedObject::takeHullDamage(float damage_amount, DamageInfo& info)
{
    hull_strength -= damage_amount;
    if (hull_strength <= 0.0f && !can_be_destroyed)
    {
        hull_strength = 1;
    }
    if (hull_strength <= 0.0f)
    {
        destroyedByDamage(info);
        if (on_destruction.isSet())
        {
            if (info.instigator)
            {
                on_destruction.call<void>(P<ShipTemplateBasedObject>(this), P<SpaceObject>(info.instigator));
            } else {
                on_destruction.call<void>(P<ShipTemplateBasedObject>(this));
            }
        }
        destroy();
    }
}

float ShipTemplateBasedObject::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    return 1.0f;
}

float ShipTemplateBasedObject::getShieldRechargeRate(int shield_index)
{
    return 0.3;
}

void ShipTemplateBasedObject::setTemplate(string template_name)
{
    P<ShipTemplate> new_ship_template = ShipTemplate::getTemplate(template_name);
    if (!new_ship_template) return;
    this->template_name = template_name;
    ship_template = new_ship_template;
    type_name = template_name;

    hull_strength = hull_max = ship_template->hull;
    shield_count = ship_template->shield_count;
    for(int n=0; n<shield_count; n++)
        shield_level[n] = shield_max[n] = ship_template->shield_level[n];

    // Set the ship's radar ranges.
    long_range_radar_range = ship_template->long_range_radar_range;
    short_range_radar_range = ship_template->short_range_radar_range;

    radar_trace = ship_template->radar_trace;
    impulse_sound_file = ship_template->impulse_sound_file;

    shares_energy_with_docked = ship_template->shares_energy_with_docked;
    repair_docked = ship_template->repair_docked;

    ship_template->setCollisionData(this);
    model_info.setData(ship_template->model_data);
    player_ship_type = ship_template->player_ship_type;

    //Call the virtual applyTemplateValues function so subclasses can get extra values from the ship templates.
    applyTemplateValues();
}

void ShipTemplateBasedObject::setShields(const std::vector<float>& amounts)
{
    for(int n=0; n<std::min(int(amounts.size()), shield_count); n++)
    {
        shield_level[n] = amounts[n];
    }
}

void ShipTemplateBasedObject::setShieldsMax(const std::vector<float>& amounts)
{
    shield_count = std::min(max_shield_count, int(amounts.size()));
    for(int n=0; n<shield_count; n++)
    {
        shield_max[n] = amounts[n];
        shield_level[n] = std::min(shield_level[n], shield_max[n]);
    }
}

ESystem ShipTemplateBasedObject::getShieldSystemForShieldIndex(int index)
{
    if (shield_count < 2)
        return SYS_FrontShield;
    float angle = index * 360.0f / shield_count;
    if (std::abs(angleDifference(angle, 0.0f)) < 90)
        return SYS_FrontShield;
    return SYS_RearShield;
}

void ShipTemplateBasedObject::onTakingDamage(ScriptSimpleCallback callback)
{
    this->on_taking_damage = callback;
}

void ShipTemplateBasedObject::onDestruction(ScriptSimpleCallback callback)
{
    this->on_destruction = callback;
}

string ShipTemplateBasedObject::getShieldDataString()
{
    string data = "";
    for(int n=0; n<shield_count; n++)
    {
        if (n > 0)
            data += ":";
        data += string(int(shield_level[n])) + "/" + string(int(shield_max[n]));
    }
    return data;
}

bool ShipTemplateBasedObject::tryDecreaseResourceAmount(string resource_name, int amount)
{
    if (resources[resource_name] < amount)
        return false;
    decreaseResourceAmount(resource_name, amount);
    return true;
}

void ShipTemplateBasedObject::transformResource(string resource_name_from, int amount_from, string resource_name_to, int amount_to)
{
    decreaseResourceAmount(resource_name_from, amount_from);
    increaseResourceAmount(resource_name_to, amount_to);
}

bool ShipTemplateBasedObject::tryTransformResource(string resource_name_from, int amount_from, string resource_name_to, int amount_to)
{
    if (!tryDecreaseResourceAmount(resource_name_from, amount_from))
        return false;
    increaseResourceAmount(resource_name_to, amount_to);
    return true;
}

void ShipTemplateBasedObject::transferResource(string resource_name, int amount, P<ShipTemplateBasedObject> other)
{
    decreaseResourceAmount(resource_name, amount);
    other->increaseResourceAmount(resource_name, amount);
}

bool ShipTemplateBasedObject::tryTransferResource(string resource_name, int amount, P<ShipTemplateBasedObject> other)
{
    if (!tryDecreaseResourceAmount(resource_name, amount))
        return false;
    other->increaseResourceAmount(resource_name, amount);
    return true;
}

std::vector<string> ShipTemplateBasedObject::getResources(string category)
{
    std::vector<string> ret;
    for (auto const& [name,amout] : resources) {
        if (resource_categories.find(name) != resource_categories.end() && resource_categories[name] == category && amout != 0)
            ret.push_back(name);
    }
    return ret;
}

