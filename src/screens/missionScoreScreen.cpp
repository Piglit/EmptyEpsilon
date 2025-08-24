#include "missionScoreScreen.h"
#include "menus/serverCreationScreen.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"

#include "campaign_client.h"
#include <i18n.h>

MissionScoreScreen::MissionScoreScreen(RenderLayer* render_layer): GuiCanvas(render_layer)
{
    loadScore();
    if (score.empty()) {
       destroy();
       new ServerCampaignScreen();
    } else {
        new GuiOverlay(this, "", colorConfig.background);
        (new GuiOverlay(this, "", glm::u8vec4{255,255,255,255}))->setTextureTiled("gui/background/crosses.png");

        auto panel = (new GuiPanel(this , ""))->setSize(650, 350)->setPosition(0,0, sp::Alignment::Center);
        layout = new GuiElement(panel, "");
        layout->setMargins(25)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

        (new GuiLabel(layout, "SCORE_HEADING", tr("Score of ") + score["current_scenario_name"], 30))->addBackground()->setSize(GuiElement::GuiSizeMax, 50);
        if (score.find("current_progress") != score.end())
        {
            auto line = new GuiElement(layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            score_progress = new GuiKeyValueDisplay(line, "SCORE_PROGRESS", 0.5, tr("Progress:"), "0%");
            score_progress->setSize(600, 50)->hide();
            score_progress_bar = new GuiProgressbar(score_progress, "SCORE_PROGRESS_BAR", 0, 100, 0);
            score_progress_bar->setDrawBackground(false)->setSize(600, 50)->setPosition(0,0)->hide();
            line = new GuiElement(layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            score_progress_best = new GuiKeyValueDisplay(line, "SCORE_PROGRESS_BEST", 0.5, tr("Your best progress:"), score["best_progress"]);
            score_progress_best->setSize(300, 50)->hide();
            if (score.find("reputation") != score.end())
            {
                score_reputation = new GuiKeyValueDisplay(line, "SCORE_REPUTATION", 0.8, tr("Reputation Bonus:"), score["reputation"]);
                score_reputation->setSize(300, 50)->hide();
            }
            line = new GuiElement(layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            score_progress_fleet = new GuiKeyValueDisplay(line, "SCORE_PROGRESS_FLEET", 0.15, tr("Fleet best:"), score["fleet_progress"] + score["fleet_progress_name"]);
            score_progress_fleet->setSize(600, 50)->hide();
            score_elements.push_back(score_progress);
            score_elements.push_back(score_progress_bar);
            score_elements.push_back(score_progress_best);
            score_elements.push_back(score_reputation);
            score_elements.push_back(score_progress_fleet);
        }
        if (score.find("current_time") != score.end())
        {
            auto line = new GuiElement(layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            score_time = new GuiKeyValueDisplay(line, "SCORE_TIME", 0.6, tr("Time:"), score["current_time"]);
            score_time->setSize(150, 50)->hide();
            score_time_best = new GuiKeyValueDisplay(line, "SCORE_TIME_BEST", 0.5, tr("Best:"), score["best_time"]);
            score_time_best->setSize(125, 50)->hide();
            score_time_fleet = new GuiKeyValueDisplay(line, "SCORE_TIME_FLEET", 0.3, tr("Fleet best:"), score["fleet_time"] + score["fleet_time_name"]);
            score_time_fleet->setSize(325, 50)->hide();
            score_elements.push_back(score_time);
            score_elements.push_back(score_time_best);
            score_elements.push_back(score_time_fleet);
        }
        if (score.find("current_artifacts") != score.end())
        {
            auto line = new GuiElement(layout, "");
            line->setMargins(0,-10,0,0)->setSize(600, 50)->setAttribute("layout", "horizontal");
            score_artifacts = new GuiKeyValueDisplay(line, "SCORE_ARTIFACTS", 0.6, tr("Artifacts:"), score["current_artifacts"]);
            score_artifacts->setSize(150, 50)->hide();
            score_artifacts_best = new GuiKeyValueDisplay(line, "SCORE_ARTIFACTS_BEST", 0.5, tr("Best:"), score["best_artifacts"]);
            score_artifacts_best->setSize(125, 50)->hide();
            score_artifacts_fleet = new GuiKeyValueDisplay(line, "SCORE_ARTIFACTS_FLEET", 0.3, tr("Fleet best:"), score["fleet_artifacts"] + score["fleet_artifacts_name"]);
            score_artifacts_fleet->setSize(325, 50)->hide();
            score_elements.push_back(score_artifacts);
            score_elements.push_back(score_artifacts_best);
            score_elements.push_back(score_artifacts_fleet);
        }

        button_continue = new GuiButton(layout, "QUIT", tr("Continue"), [this]() {
           destroy();
           new ServerCampaignScreen();
        });
        button_continue->setSize(GuiElement::GuiSizeMax, 50)->hide();
        next_time = 1.0f;
        next_index = 0;
        engine->setGameSpeed(1.0);
    }
}

void MissionScoreScreen::loadScore()
{
    nlohmann::json campaign = campaign_client->getCampaign();
    LOG(DEBUG) << campaign.dump();

    auto score_json = campaign["score"];
    for (auto const& [key, value]: score_json.items())
    {
        score[key] = value;
    }
}

void MissionScoreScreen::update(float delta)
{
    if (score.empty()) return;
    next_time -= delta;
    if (next_time < 0.0f)
    {
        if (next_index == 1 && score.find("current_progress") != score.end())
        {
            score_progress_bar->show();
            if (next_time > -3.0f && score["current_progress"] != "0%")
            {
                float t = -next_time / 3.0f;
                float h = -2*t*t*t + 3*t*t; //cubic hermite splite h01
                int interpolated = h * std::stof(score["current_progress"]);
                char buf[4];
                std::snprintf(buf, 4, "%02d%%", interpolated);
                score_progress->setValue(buf);
                score_progress_bar->setValue(interpolated);
            }
            else
            {
                score_progress->setValue(score["current_progress"]);
                score_progress_bar->setValue(std::stof(score["current_progress"]));
                next_index ++;
                next_time = 1.5f;
                button_continue->show();
            }
        }
        else if (score_elements.size() > next_index) 
        {
            score_elements[next_index]->show();
            next_index ++;
            if (next_index == 1)
                next_time = 1.0f;
            else
                next_time = 1.5f;
        }
    }
}
