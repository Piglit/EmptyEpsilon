#ifndef ZONE_H
#define ZONE_H

#include "spaceObject.h"

class Zone : public SpaceObject, public virtual Updatable
{
public:
    Zone();

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;
    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range) override;

    virtual bool canHideInNebula()  override { return false; }
    virtual ERadarLayer getRadarLayer() const override { return ERadarLayer::BackgroundZone; }
    virtual bool isGMSelectable() const override { return false; }

    // Set the outline of the zone. Can say whether the points are relative to the Zone's position or absolute. The position (text coordinates) stay as they were.
    void setOutline(bool absolute, const std::vector<glm::vec2>& points);
    // Set the outline of the zone via absolute points and its position to the center of mass.
    void setPoints(const std::vector<glm::vec2>& absolute_points);
    // This function should be used to move the zone, as it will automatically adjust the zone's radius as well.
    virtual void setTextPosition(glm::vec2& pos);
    virtual void update(float delta) override;
    void setColor(int r, int g, int b);
    void setLabel(string label);
    string getLabel();
    bool isInside(P<SpaceObject> obj);

    //virtual string getExportLine() override { return "Zone():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }

private:
    void adjustRadius();
    void rebuildTriangles();

    glm::u8vec4 color{255,255,255,255};
    std::vector<glm::vec2> outline;
    std::vector<uint16_t> triangles;
    glm::vec2 client_old_position{};
    std::uint32_t outline_version = 0; // used to sync the client as well as give absolute/relative info
    std::uint32_t client_outline_version = 0; // used to sync the client as well as give absolute/relative info
    string label;
};

#endif//ZONE_H
