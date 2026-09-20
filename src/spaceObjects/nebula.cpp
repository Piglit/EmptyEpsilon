#include <graphics/opengl.h>

#include "main.h"
#include "nebula.h"
#include "playerInfo.h"
#include "random.h"
#include "textureManager.h"

#include "scriptInterface.h"

#include "glObjects.h"
#include "shaderRegistry.h"

#include <glm/ext/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <random>

struct VertexAndTexCoords
{
    glm::vec3 vertex;
    glm::vec2 texcoords;
};


/// A Nebula is a piece of space terrain with a 5U radius that blocks long-range radar, but not short-range radar.
/// This hides any SpaceObjects inside of a Nebula, as well as SpaceObjects on the other side of its radar "shadow", from any SpaceShip outside of it.
/// Likewise, a SpaceShip fully inside of a nebula has effectively no long-range radar functionality.
/// In 3D space, a Nebula resembles a dense cloud of colorful gases.
/// Example: nebula = Nebula():setPosition(1000,2000)
REGISTER_SCRIPT_SUBCLASS(Nebula, SpaceObjectWithSize)
{
}

PVector<Nebula> Nebula::nebula_list;

REGISTER_MULTIPLAYER_CLASS(Nebula, "Nebula")
Nebula::Nebula()
: SpaceObjectWithSize(5000, "Nebula")
{
    setRotation(random(0, 360));
    radar_visual = irandom(1, 3);

    // I would have liked to use uint64_t here, but SeriousProton is missing serialization functions for that :(
    random_seed = (static_cast<std::uint32_t>(irandom(0, 256 * 256 - 1)) << 16)
                 | static_cast<std::uint32_t>(irandom(0, 256 * 256 - 1));

    registerMemberReplication(&radar_visual);
    registerMemberReplication(&random_seed);

    nebula_list.push_back(this);

    // As we're using random_seed to create the nebula's look, we have to do a little hack here:
    // Clients do not have the server's random_seed at this point - we have to wait for the first update-triggered setSize(), so we set the size to 0.
    setSize(getMultiplayerId() == -1 ? 0 : size);
}

void Nebula::draw3DTransparent()
{
    ShaderRegistry::ScopedShader shader(ShaderRegistry::Shaders::Billboard);

    std::array<VertexAndTexCoords, 4> quad{
        glm::vec3{}, {0.f, 1.f},
        glm::vec3{}, {1.f, 1.f},
        glm::vec3{}, {1.f, 0.f},
        glm::vec3{}, {0.f, 0.f}
    };

    gl::ScopedVertexAttribArray positions(shader.get().attribute(ShaderRegistry::Attributes::Position));
    gl::ScopedVertexAttribArray texcoords(shader.get().attribute(ShaderRegistry::Attributes::Texcoords));

    auto model_matrix = getModelMatrix();
    for(int n=0; n<cloud_count; n++)
    {
        NebulaCloud& cloud = clouds[n];

        glm::vec3 position = glm::vec3(getPosition().x, getPosition().y, 0) + glm::vec3(cloud.offset.x, cloud.offset.y, 0);
        float size = cloud.size;

        float distance = glm::length(camera_position - position);
        float alpha;
        if (distance < 10000.0f)
        {
            alpha = 1.0f - 0.9f * (distance / 10000.0f);
        }
        else if (distance < 20000.f)
        {
            // slight hint of the nebula rather than just clear space
            alpha = (1.0f - ((distance - 10000.0f) / 10000.0f)) * 0.1f;
        }
        else
        {
            // too far away
            continue;
        }

        // setup our quad.
        for (auto& point : quad)
        {
            point.vertex = position;
        }

        textureManager.getTexture("Nebula" + string(cloud.texture) + ".png")->bind();
        glUniform4f(shader.get().uniform(ShaderRegistry::Uniforms::Color), alpha * 0.8f, alpha * 0.8f, alpha * 0.8f, size);
        //auto model_matrix = glm::translate(getModelMatrix(), { cloud.offset.x, cloud.offset.y, 0 }); // this causes the nebula to render at twice its radius, but not respect culling properly. wth?
        glUniformMatrix4fv(shader.get().uniform(ShaderRegistry::Uniforms::Model), 1, GL_FALSE, glm::value_ptr(model_matrix));

        glVertexAttribPointer(positions.get(), 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)quad.data());
        glVertexAttribPointer(texcoords.get(), 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndTexCoords), (GLvoid*)((char*)quad.data() + sizeof(glm::vec3)));
        std::initializer_list<uint16_t> indices = { 0, 3, 2, 0, 2, 1 };
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, std::begin(indices));
    }
}

void Nebula::setSize(float size)
{
    SpaceObjectWithSize::setSize(size);

    // we sync the nebula look by making sure the RNG is synced
    // TODO: could there be floating point differences between systems, resulting in unsynced nebulas?
    // We can't use any built-in RNGs or distributions here since they produce different results between Linux and Windows. Bummer.

    // We're also using a dedicated random seed instead of the objects's other properties:
    // - getMultiplayerId() would return only quite a small range of options, so nebula looks may repeat across playthroughs/scenarios
    // - the nebula's radius/size is bad, because when scenarios dynamically change the size of the nebula, that would cause it to flicker instead of shrinking
    // This way the nebula will always have the same look, but scale itself based on its size.
    PCG32 rng(random_seed);
    //LOG(Info, "Creating Nebula: size: ", size, " multiplayerid: ", getMultiplayerId());

    float relative_size = size / 5000.f;
    setRadarSignatureInfo(0.0f, 0.8f * relative_size, -1.0f * relative_size);

    // new cloud logic:
    // - divide circle into 3 zones: inner, middle (rotated by 1/2 steps compared to inner) and outer
    // - inner and middle zones each have 8 spokes, one cloud in each
    // - outer circle has 16 spokes, one cloud in each
    std::vector<NebulaCloud> clouds;

    const float min_size = 1000.f * relative_size;
    const float max_size = 4000.f * relative_size;
    auto createCloud = [&rng, &clouds, min_size, max_size, size](float min_dist, float max_dist, float min_angle, float max_angle)
    {
        NebulaCloud c;
        c.texture = rng.irandom(1, 3);
        c.size = rng.random(min_size, max_size);
        c.offset = vec2FromAngle(rng.random(min_angle, max_angle)) * rng.random(min_dist, max_dist) * size;
        clouds.push_back(c);
    };

    auto createRing = [&createCloud](float min_dist, float max_dist, float angle_offset, int num_sections)
    {
        auto angle_per_section = 360.f / num_sections;
        for (int i=0;i<num_sections;i++)
        {
            auto angle_start = i * angle_per_section + angle_offset;
            createCloud(min_dist, max_dist, angle_start, angle_start + angle_per_section);
        }
    };

    constexpr float END_INNER = 0.45f;
    constexpr float END_MIDDLE = 0.3f + END_INNER;
    createRing(0, END_INNER, 360.f/16.f, 8); // inner
    createRing(END_INNER, END_MIDDLE, 0, 8); // middle
    createRing(END_MIDDLE, 1.f, 0, 16); // outer

    // shuffle the clouds (does that do anything?)
    assert(clouds.size() == cloud_count);
    while(!clouds.empty())
    {
        auto index = rng.irandom(0, clouds.size() - 1);
        this->clouds[cloud_count - clouds.size()] = clouds[index];
        clouds.erase(clouds.begin() + index);
    }

    // old cloud logic - looks bad in general (random clouds that are quite small) and looks especially bad for large nebulae
    //for(int n=0; n<cloud_count; n++)
    //{
    //    clouds[n].size = rng.random(512, 1024 * 2);
    //    clouds[n].texture = rng.irandom(1, 3);
    //    float dist_min = clouds[n].size / 2.0f;
    //    float dist_max = std::max(dist_min, getRadius() - clouds[n].size);
    //    clouds[n].offset = vec2FromAngle(float(n * 360 / cloud_count)) * rng.random(dist_min, dist_max);
    //}
}

void Nebula::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawRotatedSpriteBlendAdd("Nebula" + string(radar_visual) + ".png", position, getRadius() * scale * 3.0f, getRotation()-rotation);
}

void Nebula::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawCircleOutline(position, getRadius() * scale, 2.0, glm::u8vec4(255, 255, 255, 64));
}

bool Nebula::inNebula(glm::vec2 position)
{
    foreach(Nebula, n, nebula_list)
    {
        if (glm::length2(n->getPosition() - position) < n->getRadius() * n->getRadius())
            return true;
    }
    return false;
}

bool Nebula::blockedByNebula(glm::vec2 start, glm::vec2 end, float radar_short_range)
{
    auto startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    if (startEndLength < radar_short_range)
        return false;

    foreach(Nebula, n, nebula_list)
    {
        //Calculate point q, which is a point on the line start-end that is closest to n->getPosition
        float f = glm::dot(startEndDiff, n->getPosition() - start) / startEndLength;
        if (f < 0.0f)
            f = 0.0f;
        if (f > startEndLength)
            f = startEndLength;
        auto q = start + startEndDiff / startEndLength * f;
        if (glm::length2(q - n->getPosition()) < n->getRadius()*n->getRadius())
        {
            return true;
        }
    }
    return false;
}

glm::vec2 Nebula::getFirstBlockedPosition(glm::vec2 start, glm::vec2 end)
{
    auto startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    P<Nebula> first_nebula;
    float first_nebula_f = startEndLength;
    glm::vec2 first_nebula_q{};
    foreach(Nebula, n, nebula_list)
    {
        float f = glm::dot(startEndDiff, n->getPosition() - start) / startEndLength;
        if (f < 0.0f)
            f = 0;
        glm::vec2 q = start + startEndDiff / startEndLength * f;
        if (glm::length2(q - n->getPosition()) < n->getRadius() * n->getRadius())
        {
            if (!first_nebula || f < first_nebula_f)
            {
                first_nebula = n;
                first_nebula_f = f;
                first_nebula_q = q;
            }
        }
    }
    if (!first_nebula)
        return end;

    float d = glm::length(first_nebula_q - first_nebula->getPosition());
    return first_nebula_q + glm::normalize(start - end) * sqrtf(first_nebula->getRadius() * first_nebula->getRadius() - d * d);
}

PVector<Nebula> Nebula::getNebulas()
{
    return nebula_list;
}

glm::mat4 Nebula::getModelMatrix() const
{
    return glm::identity<glm::mat4>();
}
