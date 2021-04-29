#ifndef COLOR_SCHEME_H
#define COLOR_SCHEME_H

#include "gui/gui2_canvas.h"
#include "gui/gui2_element.h"

#include <vector>

class GuiButton;
class GuiSlider;
class GuiLabel;

class ColorSchemeMenu;

class ColorSelector
{
private:
    sf::Color * colorptr;
    sf::FloatRect * preview;
    GuiSlider* slider_red = NULL;
    GuiSlider* slider_green = NULL;
    GuiSlider* slider_blue = NULL;
    GuiContainer * container;
    GuiButton * color_preview; // abuse a activated button for colorpreview.
public:
    ColorSelector(GuiContainer *);
    void set_color(sf::Color *);
    void update_preview(void);
};

class WidgetColorManager
{
private:
    ColorSelector * color_selector;
    GuiContainer * canvas = NULL;
    std::unordered_map<string, GuiButton * > primary_buttons;
    std::unordered_map<string, std::unordered_map<string, GuiButton * > > sub_buttons;
public:
    WidgetColorManager(GuiContainer *);
};


class ColorSchemeMenu : public GuiCanvas
{
public:
    ColorSchemeMenu();
};

#endif//COLOR_SCHEME_H
