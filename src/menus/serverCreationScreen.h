#ifndef SERVER_CREATION_SCREEN_H
#define SERVER_CREATION_SCREEN_H

#include <vector>

#include "gui/gui2_canvas.h"
#include "Updatable.h"
#include "screenComponents/helpOverlay.h"
#include "io/network/address.h"

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
    void displayDetails(string caption, std::vector<std::pair<string, string> > details);
    GuiElement* right = nullptr;
    GuiElement* layout = nullptr;
    GuiElement* score_layout = nullptr;
    GuiListbox* first_list = nullptr;
    GuiListbox* scenario_list = nullptr;
    GuiListbox* proxy_list = nullptr;
    GuiButton* start_button = nullptr;
    GuiHelpOverlay* splash_briefing = nullptr;
	GuiLabel* crew_text_label = nullptr;
	GuiLabel* crew_amount_label = nullptr;
    string crew_text;
    string briefing_text;
	std::map<string, string> score;
	std::map<string, string> proxies;
	float update_timer = 10.0f;
};

class ProxyJoinScreen: public GuiCanvas//, Updatable
{
private:
    GuiSelector* ship_template_selector;
    GuiSelector* ship_drive_selector;
    GuiButton* ship_create_button;
    sp::io::network::Address host;
    int listenPort;
public:
    ProxyJoinScreen(sp::io::network::Address host, int listenPort);
//    virtual void update(float delta) override;
    bool proxySpawn(string templ, string drive);
};

class ProxyConnectedScreen: public GuiCanvas, Updatable
{
private:
    sp::io::network::Address host;
    int listenPort;
    GuiLabel* status_label;
    string callsign;
public:
    ProxyConnectedScreen(sp::io::network::Address host, int listenPort, string callsign);
    //virtual void update(float delta) override;
};

#endif//SERVER_CREATION_SCREEN_H
