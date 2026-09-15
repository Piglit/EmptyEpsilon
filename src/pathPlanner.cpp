#include "pathPlanner.h"
#include "spaceObjects/spaceObject.h"
#include "spaceObjects/spaceObjectWithSize.h"


const float small_object_grid_size = 5000.0f;
const float small_object_max_size = 1000.0f;

static uint32_t hashSector(uint32_t x, uint32_t y)
{
    return (x) ^ (y << 16);
}

static uint32_t positionToSector(float f)
{
    return std::lrint(f / small_object_grid_size);
}

static uint32_t hashPosition(glm::vec2 position)
{
    return hashSector(positionToSector(position.x), positionToSector(position.y));
}

#define getSector(size, source) (size <= 0.f ? sectorSize0Objs : hashPosition(source->getPosition()));

P<PathPlannerManager> PathPlannerManager::instance;

// a sector dedicated to objects that have a size of 0 or negative - we still want to recheck their size (it might change!), but they should be out of the way
// if they want to be removed permanently (or until they call ensureIsInAvoidList() again) they should return REMOVE_ME_FROM_AVOID_LIST in getAvoidSize()
const uint32_t sectorSize0Objs = ((1 << 15) - 1); // X = 32767, Y = 0

//#define DEBUG_DYNAMIC_AVOID

#ifndef DEBUG
#undef DEBUG_DYNAMIC_AVOID
#endif

void PathPlannerManager::addAvoidObject(P<SpaceObject> source, float size)
{
    if (size == REMOVE_ME_FROM_AVOID_LIST)
    {
#ifdef DEBUG_DYNAMIC_AVOID
        LOG(Info, source->getMultiplayerId(), " not adding object, doesn't want to be here after all");
#endif
        return;
    }

    auto avoidable_object = dynamic_cast<IAvoidableSpaceObject*>(*source);
    if (avoidable_object)
    {
        if (avoidable_object->_is_in_avoid_list)
        {
            // these objects are guarded - other objects could potentially be added multiple times - be careful!
#ifdef DEBUG_DYNAMIC_AVOID
            LOG(Info, source->getMultiplayerId(), " NOT added (guarded)");
#endif
            return;
        }
        avoidable_object->_is_in_avoid_list = true;
#ifdef DEBUG_DYNAMIC_AVOID
        LOG(Info, source->getMultiplayerId(), " added (guarded)");
#endif
    }
    else if(size <= 0.f)
    {
        // this is not an IAvoidableSpaceObject (so it cannot change its avoid size after adding)
        // -> adding it makes no sense!
#ifdef DEBUG_DYNAMIC_AVOID
        LOG(Info, source->getMultiplayerId(), " NOT added (size = ", size, ")");
#endif
        return;
    }

    // Size is used for objects NOT implementing ISpaceObjectWithSize, which has a getSize() method that is used each frame to update the size.

    // Make a classification for small objects which fit in a grid, so the checkToAvoid function does not has to iterate on all objects.
    // Until then, astroids and mines should not generate avoidAreas to prevent performance issues.
    if (size < small_object_max_size)
    {
        auto sector = getSector(size, source);
        small_objects[sector].push_back(PathPlannerAvoidObject(source, size));
#ifdef DEBUG_DYNAMIC_AVOID
        LOG(Info, source->getMultiplayerId(), " SMALL object added, sector: ", sector);
#endif
    }
    else
    {
#ifdef DEBUG_DYNAMIC_AVOID
        LOG(Info, source->getMultiplayerId(), " BIG object added");
#endif
        big_objects.push_back(PathPlannerAvoidObject(source, size));
    }
}

void PathPlannerManager::update(float delta)
{
    std::vector<PathPlannerAvoidObject> add_list;

    for (std::list<PathPlannerManager::PathPlannerAvoidObject>::iterator i = big_objects.begin(); i != big_objects.end(); )
    {
        if (!(i->source))
        {
            // object is no more
#ifdef DEBUG_DYNAMIC_AVOID
            LOG(Info, "BIG object deleted");
#endif
            i = big_objects.erase(i);
            continue;
        }

        auto avoidable_object = dynamic_cast<IAvoidableSpaceObject*>(*i->source);
        if (avoidable_object)
        {
            auto new_size = avoidable_object->getAvoidSize();

            if (new_size == REMOVE_ME_FROM_AVOID_LIST)
            {
                // the call to getAvoidSize() returned the magic valid to remove the object from the check list altogether
                avoidable_object->_is_in_avoid_list = false;
                i = big_objects.erase(i);
                continue;
            }

            if (new_size != i->size)
            {
                i->size = new_size;

                // check if new size still fits the list
                if (new_size < small_object_max_size)
                {
                    // nope, must go into the small list
#ifdef DEBUG_DYNAMIC_AVOID
                    LOG(Info, i->source->getMultiplayerId(), " Object moved from BIG to SMALL");
#endif
                    add_list.push_back(*i);
                    i = big_objects.erase(i);
                    continue;
                }
            }
        }

        // nothing changed, next!
        i++;
    }

    for(auto h_it = small_objects.begin(); h_it != small_objects.end(); h_it++)
    {
        for (auto it = h_it->second.begin(); it != h_it->second.end();)
        {
            if (!(it->source))
            {
                // object is no more
#ifdef DEBUG_DYNAMIC_AVOID
                LOG(Info, "SMALL object deleted (sector: ", h_it->first, ")");
#endif
                it = h_it->second.erase(it);
                continue;
            }

            auto avoidable_object = dynamic_cast<IAvoidableSpaceObject*>(*it->source);
            if (avoidable_object)
            {
                auto new_size = avoidable_object->getAvoidSize();

                if (new_size == REMOVE_ME_FROM_AVOID_LIST)
                {
                    // the call to getAvoidSize() returned the magic valid to remove the object from the check list altogether
                    avoidable_object->_is_in_avoid_list = false;
                    it = h_it->second.erase(it);
                    continue;
                }

                if (new_size != it->size)
                {
                    it->size = new_size;

                    // check if new size still fits the list
                    if (new_size >= small_object_max_size)
                    {
                        // nope, must go into the big list
#ifdef DEBUG_DYNAMIC_AVOID
                        LOG(Info, it->source->getMultiplayerId(), " Object moved from SMALL (sector: ", h_it->first, ") to BIG");
#endif
                        big_objects.push_back(*it);
                        it = h_it->second.erase(it);
                        continue;
                    }
                }
            }

            auto sector = getSector(it->size, it->source);
            if (sector == h_it->first)
            {
                // still the same sector
                it++;
            }
            else
            {
                // object moved, sector has changed
#ifdef DEBUG_DYNAMIC_AVOID
                LOG(Info, it->source->getMultiplayerId(), " SMALL Object moved from sector: ", h_it->first, " to sector: ", sector);
#endif
                add_list.push_back(*it);
                it = h_it->second.erase(it);
            }
        }
    }

    // re-add objects that either moved from big to small or within small
    for(PathPlannerAvoidObject& obj : add_list)
    {
        SDL_assert(obj.source);
        auto sector = getSector(obj.size, obj.source);
        small_objects[sector].push_back(obj);
#ifdef DEBUG_DYNAMIC_AVOID
        LOG(Info, obj.source->getMultiplayerId(), " SMALL Object inserted into sector: ", sector);
#endif
    }
}

PathPlanner::PathPlanner(float my_size)
: my_size(my_size)
{
    manager = PathPlannerManager::getInstance();
}

void PathPlanner::plan(glm::vec2 start, glm::vec2 end)
{
    if (route.size() == 0 || glm::length(route.back() - end) > 2000)
    {
        route.clear();
        int recursion_counter = 0;
        recursivePlan(start, end, recursion_counter);
        route.push_back(end);

        insert_idx = 0;
        remove_idx = 1;
        remove_idx2 = 1;
    }else{
        route.back() = end;

        glm::vec2 p0 = start;
        if (insert_idx < route.size())
        {
            if (insert_idx > 0)
                p0 = route[insert_idx - 1];
            glm::vec2 p1 = route[insert_idx];

            glm::vec2 new_point{};
            if (checkToAvoid(p0, p1, new_point))
            {
                route.insert(route.begin() + insert_idx, new_point);
            }
            insert_idx++;
        }else if (remove_idx < route.size())
        {
            if (remove_idx > 1)
                p0 = route[remove_idx - 2];
            glm::vec2 p1 = route[remove_idx];
            glm::vec2 new_position{};
            glm::vec2 alt_position{};
            if (!checkToAvoid(p0, p1, new_position, &alt_position))
            {
                route.erase(route.begin() + remove_idx - 1);
            }else{
                if (glm::length2(route[remove_idx-1] - new_position) > 200.0f*200.0f && glm::length2(route[remove_idx-1] - alt_position) > 200.0f * 200.0f)
                    route[remove_idx-1] = new_position;
                remove_idx++;
            }
        }else if (remove_idx2 < route.size())
        {
            glm::vec2 new_point{};
            glm::vec2 p1 = route[remove_idx2];
            if (!checkToAvoid(p0, p1, new_point))
            {
                route.erase(route.begin(), route.begin() + remove_idx2);
            }else{
                remove_idx2++;
            }
        }else{
            insert_idx = 0;
            remove_idx = 1;
            remove_idx2 = 1;
        }
    }
}

void PathPlanner::clear()
{
    route.clear();
}

void PathPlanner::recursivePlan(glm::vec2 start, glm::vec2 end, int& recursion_counter)
{
    glm::vec2 new_point{};
    if (recursion_counter < 100 && checkToAvoid(start, end, new_point))
    {
        recursion_counter += 1;
        recursivePlan(start, new_point, recursion_counter);
        recursivePlan(new_point, end, recursion_counter);
    }else{
        route.push_back(end);
    }
}

bool PathPlanner::checkToAvoid(glm::vec2 start, glm::vec2 end, glm::vec2& new_point, glm::vec2* alt_point)
{
    glm::vec2 startEndDiff = end - start;
    float startEndLength = glm::length(startEndDiff);
    if (startEndLength < 100.0f)
        return false;
    float firstAvoidF = startEndLength;
    PathPlannerManager::PathPlannerAvoidObject avoidObject(NULL, 0);
    glm::vec2 firstAvoidQ{};

    for(std::list<PathPlannerManager::PathPlannerAvoidObject>::iterator i = manager->big_objects.begin(); i != manager->big_objects.end(); )
    {
        if (i->source)
        {
            if (i->size > 0.f)
            {
                auto position = i->source->getPosition();
                float f = glm::dot(startEndDiff, position - start) / startEndLength;
                if (f > 0 && f < startEndLength - i->size)
                {
                    glm::vec2 q = start + startEndDiff / startEndLength * f;
                    if (glm::length2(q - position) < (i->size + my_size) * (i->size + my_size))
                    {
                        if (f < firstAvoidF)
                        {
                            avoidObject = *i;
                            firstAvoidF = f;
                            firstAvoidQ = q;
                        }
                    }
                }
            }
            i++;
        }else{
            i = manager->big_objects.erase(i);
        }
    }

    {
        // Bresenham's line algorithm to
        int x1 = positionToSector(start.x);
        int y1 = positionToSector(start.y);
        int x2 = positionToSector(end.x);
        int y2 = positionToSector(end.y);

        const bool steep = abs(y2 - y1) > abs(x2 - x1);
        if(steep)
        {
            std::swap(x1, y1);
            std::swap(x2, y2);
        }

        if(x1 > x2)
        {
            std::swap(x1, x2);
            std::swap(y1, y2);
        }

        const int dx = x2 - x1;
        const int dy = abs(y2 - y1);

        int error = dx / 2;
        const int ystep = (y1 < y2) ? 1 : -1;
        int y = y1;

        for(int x=x1; x<=x2; x++)
        {
            uint32_t hash;
            if(steep)
            {
                hash = hashSector(y, x);
            }
            else
            {
                hash = hashSector(x, y);
            }

            for(std::list<PathPlannerManager::PathPlannerAvoidObject>::iterator i = manager->small_objects[hash].begin(); i != manager->small_objects[hash].end(); )
            {
                if (i->source)
                {
                    if (i->size > 0.f)
                    {
                        glm::vec2 position = i->source->getPosition();
                        float f = glm::dot(startEndDiff, position - start) / startEndLength;
                        if (f > 0 && f < startEndLength - i->size)
                        {
                            glm::vec2 q = start + startEndDiff / startEndLength * f;
                            if (glm::length2(q - position) < (i->size + my_size) * (i->size + my_size))
                            {
                                if (f < firstAvoidF)
                                {
                                    avoidObject = *i;
                                    firstAvoidF = f;
                                    firstAvoidQ = q;
                                }
                            }
                        }
                    }
                    i++;
                }else{
                    i = manager->small_objects[hash].erase(i);
                }
            }

            error -= dy;
            if(error < 0)
            {
                y += ystep;
                error += dx;
            }
        }
    }

    if (firstAvoidF < startEndLength)
    {
        glm::vec2 position = avoidObject.source->getPosition();
        if (firstAvoidQ.x == position.x && firstAvoidQ.y == position.y)
            firstAvoidQ.x += 0.1f;
        new_point = position + glm::normalize(firstAvoidQ - position) * (avoidObject.size * 1.1f + my_size);
        if (alt_point)
            *alt_point = position - glm::normalize(firstAvoidQ - position) * (avoidObject.size * 1.1f + my_size);
        return true;
    }
    return false;
}
