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
    virtual void onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet) override;
	void equipFighter(P<PlayerSpaceship> ship, sp::io::DataBuffer& packet);
};

#endif//GM_ACTIONS
