#ifndef GAME_GLOBAL_INFO_HPP
#define GAME_GLOBAL_INFO_HPP

/* Define script conversion function for the EScanningComplexity enum. */
template<> void convert<EScanningComplexity>::param(lua_State* L, int& idx, EScanningComplexity& es)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "simple")
        es = SC_Simple;
    else if (str == "normal")
        es = SC_Normal;
    else if (str == "advanced")
        es = SC_Advanced;
    else
        es = SC_None;
}

template<> int convert<EScanningComplexity>::returnType(lua_State* L, EScanningComplexity complexity)
{
    switch(complexity)
    {
    case SC_None:
        lua_pushstring(L, "none");
        return 1;
    case SC_Simple:
        lua_pushstring(L, "simple");
        return 1;
    case SC_Normal:
        lua_pushstring(L, "normal");
        return 1;
    case SC_Advanced:
        lua_pushstring(L, "advanced");
        return 1;
    default:
        return 0;
    }
}

/* Define script conversion function for the EHackingGames enum. */
template<> void convert<EHackingGames>::param(lua_State* L, int& idx, EHackingGames& eh)
{
    string str = string(luaL_checkstring(L, idx++)).lower();

    // can give a list of game names separated by "," or "all", to get all games
    auto split = str.split(",");
    eh = 0;
    for (auto& game_name : split)
    {
        if (game_name == "all")
        {
            eh = HackingGame::All;
        }
        else
        {
            for (auto i = 0; i < available_hacking_games.size(); i++)
            {
                if (available_hacking_games[i].name == game_name)
                {
                    eh |= 1 << i;
                    break;
                }
            }
        }
    }
}

template<> int convert<EHackingGames>::returnType(lua_State* L, EHackingGames game)
{
    // returns "all", if all available games are selected, otherwise returns a list of game names concatenated with "," - may be empty, if no games are selected

    // this is bad, let's give the Lua code the actual list, so that they can do something with it
    //const EHackingGames all_games_available_mask = (1 << num_available_hacking_games) - 1;
    //if ((game & all_games_available_mask) == all_games_available_mask)
    //{
    //    // all available games are selected, so just return "all"
    //    lua_pushstring(L, "all");
    //    return 1;
    //}

    string buffer = "";
    for (auto i = 0; i < available_hacking_games.size(); i++)
    {
        if (game & (1 << i))
        {
            if (!buffer.empty())
            {
                buffer += ",";
            }
            buffer += available_hacking_games[i].name;
        }
    }
    lua_pushstring(L, buffer.c_str());
    return 1;
}

#endif//GAME_GLOBAL_INFO_HPP
