#ifndef PATH_PLANNER_H
#define PATH_PLANNER_H

#include "spaceObjects/spaceObject.h"
#include <list>

static const float REMOVE_ME_FROM_AVOID_LIST = -12345678.f;

class PathPlannerManager : public Updatable
{
    static P<PathPlannerManager> instance;

    class PathPlannerAvoidObject
    {
    public:
        P<SpaceObject> source;
        float size;

        PathPlannerAvoidObject(P<SpaceObject> source, float size) : source(source), size(size) {}
    };
    std::list<PathPlannerAvoidObject> big_objects;
    std::unordered_map<uint32_t, std::list<PathPlannerAvoidObject> > small_objects;

public:
    virtual void update(float delta) override;

    void addAvoidObject(P<SpaceObject> source, float size);

    static P<PathPlannerManager> getInstance() { if (!instance) instance = new PathPlannerManager(); return *instance; }

    friend class PathPlanner;
};

//The path planner is used to plan a route trough the world map without hitting any objects.
class PathPlanner : sp::NonCopyable
{
private:
    unsigned int insert_idx, remove_idx, remove_idx2;
    float my_size = 0.0f;
    P<PathPlannerManager> manager;
public:
    PathPlanner(float my_size);

    std::vector<glm::vec2> route;

    void plan(glm::vec2 start, glm::vec2 end);
    void clear();
private:
    void recursivePlan(glm::vec2 start, glm::vec2 end, int& recursion_counter);
    bool checkToAvoid(glm::vec2 start, glm::vec2 end, glm::vec2& new_point, glm::vec2* alt_point=NULL);
};

// These objects have additional capabilities compared to regular SpaceObjects calling addAvoidObject():
// - Automatically updates its avoid size on each tick by calling getAvoidSize()
// - Ensures that it cannot be added to the avoid list multiple times via a built-in boolean
// - You can completely remove it from the avoid list by providing a special value in getAvoidSize()
// - Otherwise, if <= 0 is provided as the size, the object will still be checked
class IAvoidableSpaceObject
{
public:
    virtual ~IAvoidableSpaceObject() {}
    virtual float getAvoidSize() = 0;
private:
    bool _is_in_avoid_list = false;

    friend class PathPlannerManager;

protected:
    template<typename T>
    static void ensureIsInAvoidList(T* object)
    {
        static_assert(std::is_base_of_v<SpaceObject, T>);
        static_assert(std::is_base_of_v<IAvoidableSpaceObject, T>);

        if (object->_is_in_avoid_list)
        {
            return;
        }

        PathPlannerManager::getInstance()->addAvoidObject(object, object->getAvoidSize());
    }
};

#endif//PATH_PLANNER_H
