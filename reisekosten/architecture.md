Services (port, name, description):
---
7999    ee_launcher
8002    rk_http:    http interface where EmptyEpsilon connects to. Runs on the same machine as EE-Server.
8003    rk_log:     log sink, where all logs get displayed. Should be visible to GM without efford.
8001    rk_server:  data processing. the heart of all this.
8004    rk_storage: data is saved in files here. Should be on a machine with persistent storage.
8005    rk_display: plots, compiles shows the pdf to players. Connected to a display.
9001  	reactor 

Applications:
gm_interface:   dialog interface for the gm. Income is set here, damagereport can be adjusted.
hm_interface:   dialog interface for the hafenmeisterei. cost points can be manipulated.
rk_plot:        plots the fuel/damage figure. wrapper around matplotlib, callable from command line

Files:
rk_models:  shared enums. does not run as a service.

Communication:
---
EE -> rk_http -> rk_server
gm_interface -> rk_server
hm_interface -> rk_server?
rk_storage -> rk_server -> rk_log, rk_storage, rk_display


Setup:
---
Order in which services should be started:
0. pyro nameserver
1. rk_log
2. rk_storage, rk_display
3. rk_server
4. rk_http
5. gm_interface, hm_interface

TODO:
make lots of functions one-way with @Pyro4.oneway, so the client does not wait.
