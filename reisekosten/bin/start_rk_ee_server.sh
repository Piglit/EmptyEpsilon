./rk_log
echo "please start rk_storage on netboot machine, press Enter to continue"
echo "please start rk_display on other machine, press Enter to continue"
./rk_display.py &
./rk_server.py &
./rk_http.py &
./pdu.py &

