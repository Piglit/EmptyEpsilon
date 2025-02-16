#include "main.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "singleFighterScreen.h"
#include "preferenceManager.h"
#include "gameGlobalInfo.h"

#include "screenComponents/viewport3d.h"

#include "screenComponents/alertOverlay.h"
#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"

#include "screenComponents/missileTubeControls.h"
#include "screenComponents/aimLock.h"
#include "screenComponents/shieldsEnableButton.h"
#include "screenComponents/beamFrequencySelector.h"
#include "screenComponents/beamTargetSelector.h"
#include "screenComponents/powerDamageIndicator.h"

#include "screenComponents/openCommsButton.h"
#include "screenComponents/commsOverlay.h"

#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_rotationdial.h"
#include "gui/gui2_image.h"
#include "gui/gui2_label.h"

SingleFighterScreen::SingleFighterScreen(GuiContainer* owner)
: GuiOverlay(owner, "SINGLEPILOT_SCREEN", colorConfig.background)
{
    viewport = new GuiViewport3D(this, "VIEWPORT");
    viewport->setPosition(0, 0, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    //viewport->showCallsigns();
    //viewport->showHeadings();
    viewport->showSpacedust();

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    // Ship stats at top left 
    auto stats = new GuiElement(this, "STATS");
    stats->setPosition(20, 100, sp::Alignment::TopLeft)->setSize(240, 260)->setAttribute("layout", "vertical");
    callsign_display = new GuiKeyValueDisplay(stats, "CALLSIGN_DISPLAY", 0.45, tr("Callsign"), "");
    callsign_display->setIcon("gui/icons/station-relay")->setTextSize(20)->setSize(240, 40)->setMargins(0,0,0,-8);
    energy_display = new GuiKeyValueDisplay(stats, "ENERGY_DISPLAY", 0.45, tr("Energy"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setSize(240, 40)->setMargins(0,0,0,-8);
    heading_display = new GuiKeyValueDisplay(stats, "HEADING_DISPLAY", 0.45, tr("Heading"), "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setSize(240, 40)->setMargins(0,0,0,-8);
    velocity_display = new GuiKeyValueDisplay(stats, "VELOCITY_DISPLAY", 0.45, tr("Speed"), "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setSize(240, 40)->setMargins(0,0,0,-8);

    hull_display = new GuiKeyValueDisplay(stats, "HULL_DISPLAY", 0.45, tr("health","Hull"), "");
    hull_display->setIcon("gui/icons/hull")->setTextSize(20)->setSize(240, 40)->setMargins(0,0,0,-8);
    shields_display = new GuiKeyValueDisplay(stats, "SHIELDS_DISPLAY", 0.45, tr("Shields"), "");
    shields_display->setIcon("gui/icons/shields")->setTextSize(20)->setSize(240, 40);
    // shields button below shields display
    (new GuiShieldsEnableButton(stats, "SHIELDS_ENABLE"))->setSize(240, 50);

    // Engine layout in bottom left
    auto engine_layout = new GuiElement(this, "ENGINE_LAYOUT");
    engine_layout->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(500, 300)->setAttribute("layout", "horizontal");
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);
    combat_maneuver = new GuiCombatManeuver(engine_layout, "COMBAT_MANEUVER");
    combat_maneuver->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(200, 150)->setVisible(my_spaceship && my_spaceship->getCanCombatManeuver());

    // Docking, comms buttons below radar.
    auto interaction_layout = new GuiElement(this, "INTERACTION_LAYOUT");
    interaction_layout->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(300, 400)->setAttribute("layout", "verticalbottom");
    (new GuiDockingButton(interaction_layout, "DOCKING"))->setSize(GuiElement::GuiSizeMax, 50);
    (new GuiOpenCommsButton(interaction_layout, "OPEN_COMMS_BUTTON", tr("Open Comms"), &targets))->setSize(GuiElement::GuiSizeMax, 50);

    // 5U tactical radar with piloting features.
    radar = new GuiRadarView(interaction_layout, "TACTICAL_RADAR", &targets);
    radar->setStyle(GuiRadarView::CircularMasked)->setSize(300, 300)->setMargins(0,0,0,8);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators();
    radar->setCallbacks(
        [this](sp::io::Pointer::Button button, glm::vec2 position) {
            targets.setToClosestTo(position, 250, TargetsContainer::Targetable);
            if (my_spaceship && targets.get())
                my_spaceship->commandSetTarget(targets.get());
            else if (my_spaceship)
                my_spaceship->commandTargetRotation(vec2ToAngle(position - my_spaceship->getPosition()));
        },
        [](glm::vec2 position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(vec2ToAngle(position - my_spaceship->getPosition()));
        },
        [](glm::vec2 position) {
            if (my_spaceship)
                my_spaceship->commandTargetRotation(vec2ToAngle(position - my_spaceship->getPosition()));
        }
    );
    radar->setAutoRotating(PreferencesManager::get("single_pilot_radar_lock","1")=="1");


    // Beam controls beneath the missile controls.
    auto weapons_layout = new GuiElement(this, "WEAPONS_LAYOUT");
    weapons_layout->setPosition(0, -20, sp::Alignment::BottomCenter)->setSize(460, GuiElement::GuiSizeMax)->setAttribute("layout", "verticalbottom");

    beam_info_box = new GuiElement(weapons_layout, "BEAM_INFO_BOX");
    beam_info_box->setSize(460, 50);
    (new GuiLabel(beam_info_box, "BEAM_INFO_LABEL", tr("Beams Target"), 30))->addBackground()->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(160, 50);
    (new GuiPowerDamageIndicator(beam_info_box, "", SYS_BeamWeapons, sp::Alignment::CenterLeft))->setPosition(0, 0, sp::Alignment::BottomLeft)->setSize(160, 50);
    (new GuiBeamTargetSelector(beam_info_box, "BEAM_TARGET_SELECTOR"))->setPosition(0, 0, sp::Alignment::BottomRight)->setSize(288, 50);

    // Weapon tube controls.
    tube_controls = new GuiMissileTubeControls(weapons_layout, "MISSILE_TUBES");
    radar->enableTargetProjections(tube_controls);

    // Custom Functions
    (new GuiCustomShipFunctions(this, singlePilot, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);

    (new GuiCommsOverlay(this))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void SingleFighterScreen::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        if (my_spaceship->docking_state == DS_Docked)
        {
            float target_camera_yaw = my_spaceship->getRotation();
            float camera_ship_distance = 420.0f;
            float camera_ship_height = 420.0f;

            auto cameraPosition2D = my_spaceship->getPosition() + vec2FromAngle(target_camera_yaw) * -camera_ship_distance;
            glm::vec3 targetCameraPosition(cameraPosition2D.x, cameraPosition2D.y, camera_ship_height);

            camera_position = camera_position * 0.9f + targetCameraPosition * 0.1f;
            camera_yaw += angleDifference(camera_yaw, target_camera_yaw) * 0.1f;
            camera_pitch += angleDifference(camera_pitch, 30.0f) * 0.1f;
        }
        else
        {
            camera_pitch = 0.0f;
            camera_yaw = my_spaceship->getRotation();
            auto position = my_spaceship->getPosition() + rotateVec2(glm::vec2(my_spaceship->getRadius(), 0), camera_yaw);

            camera_position.x = position.x;
            camera_position.y = position.y;
            camera_position.z = 0.0;
        }

        callsign_display->setValue(string(my_spaceship->callsign));
        energy_display->setValue(string(int(my_spaceship->energy_level)));
        heading_display->setValue(string(my_spaceship->getHeading(), 1));
        float velocity = glm::length(my_spaceship->getVelocity()) / 1000 * 60;
        velocity_display->setValue(tr("{value} {unit}/min").format({{"value", string(velocity, 1)}, {"unit", DISTANCE_UNIT_1K}}));

        warp_controls->setVisible(my_spaceship->has_warp_drive);
        jump_controls->setVisible(my_spaceship->has_jump_drive);

        beam_info_box->setVisible(my_spaceship->hasSystem(SYS_BeamWeapons) && gameGlobalInfo->use_system_damage && (my_spaceship->beam_weapons[0].getArc() > 0.0f));

        hull_display->setValue(string(int(nearbyint(100.0f * my_spaceship->hull_strength / my_spaceship->hull_max))) + "%");
        if (my_spaceship->hull_strength < my_spaceship->hull_max / 4.0f)
            hull_display->setColor(glm::u8vec4(255, 0, 0, 255));
        else
            hull_display->setColor(glm::u8vec4{255,255,255,255});

        string shields_value = string(my_spaceship->getShieldPercentage(0)) + "%";
        if (my_spaceship->hasSystem(SYS_RearShield))
        {
            shields_value += " " + string(my_spaceship->getShieldPercentage(1)) + "%";
        }
        shields_display->setValue(shields_value);
        if (my_spaceship->hasSystem(SYS_FrontShield) || my_spaceship->hasSystem(SYS_RearShield))
        {
            shields_display->show();
        } else {
            shields_display->hide();
        }

        targets.set(my_spaceship->getTarget());
    }
    GuiOverlay::onDraw(renderer);
}

void SingleFighterScreen::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        auto angle = (keys.helms_turn_right.getValue() - keys.helms_turn_left.getValue());
        if (angle != 0.0f)
        {
            my_spaceship->commandTargetRotation(my_spaceship->getRotation() + angle);
        }

        if (keys.weapons_enemy_next_target.getDown())
        {
            bool current_found = false;
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == my_spaceship)
                    continue;
                if (obj == targets.get())
                {
                    current_found = true;
                    continue;
                }
                if (current_found && glm::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && my_spaceship->isEnemy(obj) && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    continue;
                }
                if (my_spaceship->isEnemy(obj) && glm::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && my_spaceship->getScannedStateFor(obj) >= SS_FriendOrFoeIdentified && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
        }
        if (keys.weapons_next_target.getDown())
        {
            bool current_found = false;
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get())
                {
                    current_found = true;
                    continue;
                }
                if (obj == my_spaceship)
                    continue;
                if (current_found && glm::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
            foreach(SpaceObject, obj, space_object_list)
            {
                if (obj == targets.get() || obj == my_spaceship)
                    continue;
                if (glm::length(obj->getPosition() - my_spaceship->getPosition()) < my_spaceship->getShortRangeRadarRange() && obj->canBeTargetedBy(my_spaceship))
                {
                    targets.set(obj);
                    my_spaceship->commandSetTarget(targets.get());
                    return;
                }
            }
        }
    }
}
