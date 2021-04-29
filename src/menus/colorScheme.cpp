#include <i18n.h>
#include "engine.h"
#include "colorScheme.h"
#include "main.h"

#include "gui/gui2_image.h"
#include "gui/gui2_label.h"
#include "gui/gui2_button.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_autolayout.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_button.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_keyvaluedisplay.h"

#include "gui/colorConfig.h"

#include <string>

#include <stdio.h>

ColorSelector::ColorSelector(GuiContainer * canvas)
{
    int x = 460, y = 400;
    colorptr = NULL;
    color_preview = new GuiButton(canvas, "", tr(""), [](){});
    color_preview->setPosition(x+330,y)->setSize(150,150)->setActive(true);

    (new GuiLabel(canvas, "RED", "RED", 18))->setAlignment(ACenterLeft)->setPosition(x, y)->setSize(0, 18);
    slider_red = new GuiSlider(canvas, "RED", 0.0f, 255.0f, 0, [this](float _r){
        if (colorptr) colorptr->r = _r;
        update_preview();
    });
    slider_red->setPosition(sf::Vector2f(x + 20, y), ATopLeft)->setSize(300, 50);;
   
    (new GuiLabel(canvas, "GREEN", "GREEN", 18))->setAlignment(ACenterLeft)->setPosition(x, y+50)->setSize(0, 18);
    slider_green = new GuiSlider(canvas, "GREEN", 0.0f, 255.0f, 0, [this](float _g){
        if (colorptr) colorptr->g = _g;
        update_preview();
    });
    slider_green->setPosition(sf::Vector2f(x + 20, y+50), ATopLeft)->setSize(300, 50);;

    (new GuiLabel(canvas, "BLUE", "BLUE", 18))->setAlignment(ACenterLeft)->setPosition(x, y+100)->setSize(0, 18);
    slider_blue = new GuiSlider(canvas, "BLUE", 0.0f, 255.0f, 0, [this](float _b){
        if (colorptr != NULL) colorptr->b = _b;
        update_preview();
    });
    slider_blue->setPosition(sf::Vector2f(x + 20, y+100), ATopLeft)->setSize(300, 50);;
}

void ColorSelector::set_color(sf::Color * newcolor)
{
    colorptr = newcolor;
    if (newcolor){
        slider_red->setValue(newcolor->r);
        slider_green->setValue(newcolor->g);
        slider_blue->setValue(newcolor->b);
        update_preview();
    }
}

void ColorSelector::update_preview(void)
{
    WidgetColorSet cs = {};
    if (colorptr) {
        cs.background.active = sf::Color(colorptr->r, colorptr->g, colorptr->b);
    }
    color_preview->setColors(cs);
}

void update_buttons( std::unordered_map<string, GuiButton * > * btns , string selection)
{
    for (auto &b : *btns){
        b.second->setActive(b.second->getText() == selection);
    }
}

bool color_has_children(string a)
{
    for (auto i: colorConfig.color_mapping) {
        if (a.compare(i.first) == 0) continue;
        if (i.first.find(a) == 0) return true;
    }
    return false;
}

WidgetColorManager::WidgetColorManager(GuiContainer * my_canvas)
{
    canvas = my_canvas;
    color_selector = new ColorSelector(my_canvas);

    // widget internals
    for (auto i: colorConfig.color_mapping) {
        string color_name = i.first;

        if (color_has_children(color_name)) continue;

        int pos = color_name.find(".");
        if (pos <= 0) continue;

        string sub_name = color_name.substr(pos+1);
        string parent_node = color_name.substr(0, pos);

        sub_buttons[parent_node][sub_name] = new GuiButton(canvas, sub_name, tr(sub_name), [this, color_name, sub_name, parent_node](){
            color_selector->set_color(colorConfig.color_mapping[color_name][0]);
            update_buttons(&(sub_buttons[parent_node]), sub_name);
        });
        sub_buttons[parent_node][sub_name]->setPosition(sf::Vector2f(480, (1 + sub_buttons[parent_node].size()) * 30 + 10), ATopLeft)->setSize(300, 30)->setActive(false)->setVisible(false);
    }

    // simple colors and widget names
    for (auto i: colorConfig.color_mapping){
      string color_name = i.first;
        if (color_name.find(".") > 0){
            continue;
        }

        primary_buttons[color_name] = new GuiButton(canvas, i.first, tr(i.first), [this, color_name](){
            color_selector->set_color(colorConfig.color_mapping[color_name][0]);
            update_buttons(&primary_buttons, color_name);
            for (auto &b: sub_buttons) for (auto &sub : b.second) sub.second->setVisible(false);
            if (color_has_children(color_name)) {
                for (auto c : sub_buttons[color_name]){
                    c.second->setVisible(true);
                }
            }
        });
        primary_buttons[color_name]->setPosition(sf::Vector2f(80, primary_buttons.size() * 30 + 10), ATopLeft)->setSize(300, 30)->setActive(false);
    }

    update_buttons(&primary_buttons, "");
}

ColorSchemeMenu::ColorSchemeMenu()
{
    new GuiOverlay(this, "", colorConfig.background);
    (new GuiOverlay(this, "", sf::Color::White))->setTextureTiled("gui/BackgroundCrosses");

    P<WindowManager> windowManager = engine->getObject("windowManager");

    (new WidgetColorManager(this));

    (new GuiButton(this, "BACK", tr("BACK"), [this]() {
        //delete color_manager; // FIXME: delete this properly
        colorConfig.save();
        destroy();
        returnToMainMenu();
    }))->setPosition(50, -50, ABottomLeft)->setSize(150, 50);
}
