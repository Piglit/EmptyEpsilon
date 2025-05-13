#!/bin/bash
apt install snapd
snap install typst

wget "https://dl.dafont.com/dl/?f=cyberfall" -O cyberfall.zip
wget "https://dl.dafont.com/dl/?f=vipnagorgialla" -O vipnagorgialla.zip
wget "https://upload.wikimedia.org/wikipedia/commons/8/82/Republic_credit_symbol.svg" -O credit.svg
unzip cyberfall.zip
unzip vipnagorgialla.zip
mv "Vipnagorgialla Rg.otf" vipnagorgialla.regular.otf

echo "TODO: export PATH=$PATH:/snap/bin"
