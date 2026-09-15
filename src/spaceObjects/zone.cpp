#include "main.h"
#include "zone.h"
#include "playerInfo.h"
#include "particleEffect.h"
#include "explosionEffect.h"
#include "pathPlanner.h"

#include "math/triangulate.h"
#include "math/centerOfMass.h"

#include "scriptInterface.h"

#define isOutlineRelative(version) ((version % 2) == 0)

/// A Zone is a polygonal area of space defined by a series of coordinates.
/// Although a Zone is a SpaceObject, it isn't affected by physics and isn't rendered in 3D.
/// Zones are drawn on GM, comms, and long-range radar screens, can have a text label, and can return whether a SpaceObject is within their bounds.
/// New Zones can't be created via the exec.lua HTTP API.
/// Example:
/// -- Defines a blue rectangular 200sqU zone labeled "Home" around 0,0
/// zone = Zone():setColor(0,0,255):setPoints(-100000,100000, -100000,-100000, 100000,-100000, 100000,100000):setLabel("Home")
REGISTER_SCRIPT_SUBCLASS(Zone, SpaceObject)
{
	/// Sets the corners of this Zone n-gon to x_1, y_1, x_2, y_2, ... x_n, y_n. Absolute coordinates.
	/// Positive x coordinates are right/"east" of the origin, and positive y coordinates are down/"south" of the origin in space.
	/// Example: zone:setPoints(2000,0, 0,3000, -2000,0) -- defines a triangular zone in absolute space
	REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setPoints);
	/// Sets the corners of this Zone n-gon to x_1, y_1, x_2, y_2, ... x_n, y_n. You can choose if these are absolute or relative to the zone's origin (which is also its text position).
	/// This leaves the zone's origin/text position unaffected. You can call setTextPosition() to set this independently.
	/// A zone that has relative coordinates will move its outline along with its origin.
	/// Example: zone:setOutline(false, 2000,0, 0,3000, -2000,0) -- defines a triangular zone around the zone's origin
	REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setOutline);
	/// Sets the zone's text position.
	/// setPoints() automatically sets this to the zone's center of mass, but when using setOutline() you can choose this however you like.
	/// Example: zone:setTextPosition(100, 100)
	REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setTextPosition);
	/// Sets this Zone's color when drawn on radar.
	/// Defaults to white (255,255,255).
	/// Example: zone:setColor(255,140,0)
	REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setColor);
	/// Sets this Zone's text label, rendered at the zone's center point.
	/// Example: zone:setLabel("Hostile space")
	REGISTER_SCRIPT_CLASS_FUNCTION(Zone, setLabel);
	/// Returns this Zone's text label.
	/// Example: zone:getLabel()
	REGISTER_SCRIPT_CLASS_FUNCTION(Zone, getLabel);
	/// Returns whether the given SpaceObject is inside this Zone.
	/// Example: zone:isInside(obj) -- returns true if `obj` is within the zone's bounds
	REGISTER_SCRIPT_CLASS_FUNCTION(Zone, isInside);
}

REGISTER_MULTIPLAYER_CLASS(Zone, "Zone");
Zone::Zone()
	: SpaceObject(1, "Zone")
{
	has_weight = false;
	color = glm::u8vec4(255, 255, 255, 0);

	registerMemberReplication(&outline);
	registerMemberReplication(&color);
	registerMemberReplication(&label);
	registerMemberReplication(&outline_version);
}

//#define ZONE_DEBUGGING

void Zone::update(float delta)
{
	const auto& position = getPosition();
	if (outline_version != client_outline_version)
	{
#ifdef ZONE_DEBUGGING
		LOG(Info, "Updating zone info ", client_outline_version, " -> ", outline_version);
#endif
		// server has sent an update for the outline - just re-build everything
		auto is_relative_now = isOutlineRelative(outline_version);
		client_old_position = position;
		client_outline_version = outline_version;

		// rebuild the outline triangles
		rebuildTriangles();

		// adjust the zone's radius
		adjustRadius();
	}
	else if (position != client_old_position && !isOutlineRelative(outline_version))
	{
		// the zone has moved and the outline is absolute - that means the radius needs to be rebuilt
		client_old_position = position;
		adjustRadius();
	}
}

void Zone::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
	if (!long_range)
		return;

	if (label.length() > 0)
	{
		float font_size = getRadius() * scale / label.length();
		renderer.drawText(sp::Rect(position.x, position.y, 0, 0), label, sp::Alignment::Center, font_size, main_font, glm::u8vec4(color.r, color.g, color.b, 128));
	}

	if (outline.empty() || color.a == 0)
		return;

	std::vector<glm::vec2> outline_points;
	auto relative_to_pos = isOutlineRelative(outline_version) ? glm::vec2() : getPosition();
	for (auto& p : outline)
	{
		outline_points.push_back(position + rotateVec2((p - relative_to_pos) * scale, -rotation));
	}
	renderer.drawTriangles(outline_points, triangles, glm::u8vec4(color.r, color.g, color.b, 64));
	outline_points.push_back(outline_points[0]);
	renderer.drawLine(outline_points, glm::u8vec4(color.r, color.g, color.b, 128));
}

void Zone::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
	if (long_range && color.a == 0)
	{
		color.a = 255;
		drawOnRadar(renderer, position, scale, rotation, long_range);
		color.a = 0;
	}
}

void Zone::setColor(int r, int g, int b)
{
	color = glm::u8vec4(r, g, b, 255);
}

void Zone::setOutline(bool absolute, const std::vector<glm::vec2>& points)
{
	// increment outline version
	outline_version = ((outline_version >> 1) + 1) << 1;
	if (absolute)
	{
		outline_version |= 1;
	}
	client_outline_version = outline_version;
	outline = points;

	// re-triangulate this new outline
	rebuildTriangles();

	// finally adjust the radius, as both the position and outline changed
	adjustRadius();
}

void Zone::setPoints(const std::vector<glm::vec2>& absolute_points)
{
	// move the zone to the new center
	auto new_position = centerOfMass(absolute_points);
#ifdef ZONE_DEBUGGING
	LOG(Info, getMultiplayerId(), " Zone: Setting points, new center of mass: ", new_position);
#endif
	setPosition(new_position);
	client_old_position = new_position;

	// since we're setting absolute points, no need to adjust anything
	setOutline(true, absolute_points);
}

void Zone::rebuildTriangles()
{
	triangles.clear();
	Triangulate::process(outline, triangles);
}

void Zone::setTextPosition(glm::vec2& position)
{
	setPosition(position);
	client_old_position = position;
	adjustRadius();
}

void Zone::adjustRadius()
{
	// make our radius match the furthest point from the pivot
	float radius = 1;
	auto center = isOutlineRelative(outline_version) ? glm::vec2() : getPosition();
	for (auto& p : outline)
	{
		radius = std::max(radius, glm::distance(p, center));
	}

#ifdef ZONE_DEBUGGING
	LOG(Info, getMultiplayerId(), " Zone radius (@ ", getPosition(), ") adjusted: ", radius);
#endif

	// radius for visibility calculation purposes, but also sets the collision radius
	setRadius(radius);

	// never want to select this by clicking
	setCollisionRadius(1);
}

void Zone::setLabel(string label)
{
	this->label = label;
}

string Zone::getLabel()
{
	return this->label;
}

bool Zone::isInside(P<SpaceObject> obj)
{
	if (!obj)
		return false;

	auto pos = obj->getPosition();
	if (isOutlineRelative(outline_version))
	{
		pos -= getPosition();
	}
	return insidePolygon(outline, pos);
}
