#include <unordered_map>
#include <sys/stat.h>
#include <sys/types.h>
#include <iostream>
#include <fstream>
#include "colorConfig.h"
#include "resources.h"

//Lots of simple macros to reduce the amount of typing and place for error when defining extra colors.
#define MAP_COLOR(color_name, color_variable) color_mapping[ string( color_name ).lower() ].push_back(&(color_variable));
#define MAP_COLORSET(color_name, color_variable) do { \
        MAP_COLOR(color_name, color_variable.normal); \
        MAP_COLOR(color_name, color_variable.hover); \
        MAP_COLOR(color_name, color_variable.focus); \
        MAP_COLOR(color_name, color_variable.disabled); \
        MAP_COLOR(color_name, color_variable.active); \
    } while(0)

#define DEF_COLOR(color_name) do { MAP_COLOR( #color_name, color_name); color_name = sf::Color(255, 0, 255); } while(0)
#define DEF_COLORSET(color_name) do { \
        MAP_COLORSET( #color_name, color_name); \
        DEF_COLOR( color_name.normal ); \
        DEF_COLOR( color_name.hover ); \
        DEF_COLOR( color_name.focus ); \
        DEF_COLOR( color_name.disabled ); \
        DEF_COLOR( color_name.active ); \
    } while(0)
#define DEF_WIDGETCOLORSET(color_name) do { \
        MAP_COLORSET( #color_name, color_name.forground); \
        MAP_COLORSET( #color_name, color_name.background); \
        DEF_COLORSET( color_name.forground ); \
        DEF_COLORSET( color_name.background ); \
    } while(0)

ColorConfig colorConfig;

void ColorConfig::populate_color_mapping()
{
    DEF_COLOR(background);
    DEF_COLOR(radar_outline);
    DEF_COLOR(log_generic);
    DEF_COLOR(log_send);
    DEF_COLOR(log_receive_friendly);
    DEF_COLOR(log_receive_enemy);
    DEF_COLOR(log_receive_neutral);
    DEF_WIDGETCOLORSET(button);
    DEF_WIDGETCOLORSET(button_red);
    DEF_WIDGETCOLORSET(button_green);
    DEF_WIDGETCOLORSET(button_blue);
    DEF_WIDGETCOLORSET(label);
    DEF_WIDGETCOLORSET(text_entry);
    DEF_WIDGETCOLORSET(slider);
    DEF_WIDGETCOLORSET(textbox);
    DEF_COLOR(overlay_damaged);
    DEF_COLOR(overlay_jammed);
    DEF_COLOR(overlay_hacked);
    DEF_COLOR(overlay_no_power);
    DEF_COLOR(overlay_low_energy);
    DEF_COLOR(overlay_low_power);
    DEF_COLOR(overlay_overheating);

    DEF_COLOR(ship_waypoint_background);
    DEF_COLOR(ship_waypoint_text);
}

void ColorConfig::parse_line(string line){
        if (line.find("//") > -1)
            line = line.substr(0, line.find("//")).strip();
        if (line.find("=") > -1)
        {
            string key = line.substr(0, line.find("=")).strip().lower();
            string value = line.substr(line.find("=") + 1).strip();

            sf::Color color = sf::Color(255, 0, 255);
            if (value.startswith("#"))
                value = value.substr(1);

            if (value.length() == 6)
                color = sf::Color((value.toInt(16) << 8) | 0xFF);
            else if (value.length() == 8)
                color = sf::Color(value.substr(0, 4).toInt(16) << 16 | value.substr(4).toInt(16));  //toInt(16) fails with 8 bytes, so split the convertion in 2 sections.
            else
                LOG(WARNING) << "Failed to parse color: " << key << " " << value;

            if (color_mapping.find(key) != color_mapping.end())
            {
                for(sf::Color* ptr : color_mapping[key])
                    *ptr = color;
            }else{
                LOG(WARNING) << "Unknown color definition: " << key;
            }
    }
}

void ColorConfig::load()
{
    populate_color_mapping();

    /* sigh... the Resource manager can only load in the resource dir. Thus we have to handle the stream with basic c++ */
    string usercolorpath = string(getenv("HOME")) + "/.emptyepsilon/usercolors.ini";
    std::ifstream userstream(usercolorpath.c_str());
    if (userstream.is_open()){
        //printf("using USER colors\n");
        string line;
        while (std::getline(userstream, line)) parse_line(line);
        userstream.close();
    } else {
        //printf("using DEFAULT colors\n");
        P<ResourceStream> stream = getResourceStream("gui/colors.ini");

        if(!stream)
            return;
        while(stream->tell() < stream->getSize())
        {
            string line = stream->readLine();
            parse_line(line);
        }
    }
}

void ColorConfig::save()
{
#ifdef __WIN32__
    mkdir((string(getenv("HOME")) + "/.usercolor.ini").c_str());
#else
    mkdir((string(getenv("HOME")) + "/.usercolor.ini").c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
#endif
    string fpath = string(getenv("HOME")) + "/.emptyepsilon/usercolors.ini";
    //printf("trying to save usercolors to %s\n", fpath.c_str());
    FILE* f = fopen(fpath.c_str(), "w");
    if (f)
    {
        fprintf(f, "// *** User color overrides ***\n");
        fprintf(f, "// If this file is missing, the game will default to the default colors\n");
        std::vector<string> keys;
        for(std::unordered_map<std::string, std::vector<sf::Color*>>::iterator i = color_mapping.begin(); i != color_mapping.end(); i++)
        {
            if (i->second.size() != 1) continue;
            sf::Color* col = i->second[0];
            fprintf(f, "%s = #%02X%02X%02X%02X\n", i->first.c_str(), col->r, col->g, col->b, col->a);
        }
    } else {
        printf("unable to save usercolors.\n");
    }
    fclose(f);
}
