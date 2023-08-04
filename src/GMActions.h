#ifndef GM_ACTIONS
#define GM_ACTIONS

#include "multiplayer.h"
#include "spaceObjects/playerSpaceship.h"

class GameMasterActions;
extern P<GameMasterActions> gameMasterActions;

class GameMasterActions : public MultiplayerObject
{

public:

    GameMasterActions();

    void commandRunScript(string code);
    void commandSendGlobalMessage(string message);
    void commandCreateFighter(string ship_template, int32_t parent_id, string callsign, string password, string color, string model, string equipment);
    void commandEquipFighter(int32_t ship_id, string callsign, string password, string color, string model, string equipment);
    virtual void onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet) override;
private:
    void equipFighter(P<PlayerSpaceship> ship, sp::io::DataBuffer& packet);
};

#endif//GM_ACTIONS
