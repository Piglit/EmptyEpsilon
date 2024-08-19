#ifndef SERVER_CREATION_SCREEN_H
#define SERVER_CREATION_SCREEN_H

#include <vector>

#include "gui/gui2_canvas.h"
#include "Updatable.h"
#include "screenComponents/helpOverlay.h"

class GuiScrollText;
class GuiSelector;
class GuiTextEntry;
class GuiListbox;
class GuiButton;
class GuiLabel;
class GuiHelpOverlay;


class ServerSetupScreen : public GuiCanvas
{
public:
    ServerSetupScreen();

private:
    GuiTextEntry* server_name;
    GuiTextEntry* server_password;
    GuiTextEntry* gm_password;
    GuiSelector* server_visibility;
    GuiTextEntry* server_port;
};

class ServerSetupMasterServerRegistrationScreen : public GuiCanvas, Updatable
{
public:
    ServerSetupMasterServerRegistrationScreen();

    virtual void update(float delta) override;

private:
    GuiLabel* info_label;
    GuiButton* continue_button;
};

class ServerScenarioSelectionScreen : public GuiCanvas
{
public:
    ServerScenarioSelectionScreen();

private:
    void loadScenarioList(const string& category);
    GuiListbox* category_list;
    GuiListbox* scenario_list;
    GuiScrollText* description_text;
    GuiButton* start_button;
    GuiHelpOverlay* splash_briefing;
};

class ServerScenarioOptionsScreen : public GuiCanvas
{
public:
    ServerScenarioOptionsScreen(string filename);

private:
    GuiButton* start_button;
    std::unordered_map<string,string> scenario_settings;
    std::unordered_map<string, GuiScrollText*> description_per_setting;
};

class ServerCampaignScreen: public GuiCanvas, Updatable
{
public:
    ServerCampaignScreen();
    virtual void update(float delta) override;

private:
    void loadCampaign();
    void displayDetails(std::vector<std::pair<string, string> > details);
    GuiElement* right;
    GuiElement* layout;
    GuiListbox* first_list;
    GuiListbox* scenario_list;
    GuiButton* start_button;
    GuiHelpOverlay* splash_briefing;
	GuiLabel* crew_text_label = nullptr;
    string crew_text;
    string briefing_text;
	std::map<string, string> score;
};


#endif//SERVER_CREATION_SCREEN_H
