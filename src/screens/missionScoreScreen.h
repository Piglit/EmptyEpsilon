#ifndef MISSION_SCORE_SCREEN_H
#define MISSION_SCORE_SCREEN_H 
#include <map>
#include <vector>
#include "Updatable.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_button.h"
class MissionScoreScreen: public GuiCanvas, public Updatable
{
private:
	std::map<string, string> score;
    GuiElement* layout;
    void loadScore();
    GuiKeyValueDisplay* score_progress;
    GuiProgressbar* score_progress_bar;
    GuiKeyValueDisplay* score_progress_best;
    GuiKeyValueDisplay* score_progress_fleet;
    GuiKeyValueDisplay* score_time;
    GuiKeyValueDisplay* score_time_best;
    GuiKeyValueDisplay* score_time_fleet;
    GuiKeyValueDisplay* score_artifacts;
    GuiKeyValueDisplay* score_artifacts_best;
    GuiKeyValueDisplay* score_artifacts_fleet;
    GuiKeyValueDisplay* score_reputation;
    GuiButton* button_continue;
    std::vector<GuiElement*> score_elements;
    size_t next_index;
    float next_time;
public:
    MissionScoreScreen(RenderLayer* render_layer);
    virtual void update(float delta) override;
};

#endif//MISSION_SCORE_SCREEN_H
