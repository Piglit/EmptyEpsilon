#!/bin/bash
set -e
set -x
apt update 
apt install silversearcher-ag wget htop tree file zsh tcpdump sudo
wget -O /etc/zsh/zshrc "https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc"
echo "alias -g ip='ip --color'" >> /etc/zsh/zshrc
sed -i "0,/    host\( *\)''/s//    host\1'%F{cyan}'/" /etc/zsh/zshrc
sed -i "0,/    host\( *\)''/s//    host\1'%f'/" /etc/zsh/zshrc
sed -i "0,/salias ag=/s//#salias ag=/" /etc/zsh/zshrc
chsh root -s /bin/zsh
#useradd -g sudo -m -s /bin/zsh user
chsh user -s /bin/zsh
gpasswd -a user sudo
#echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
#systemctl restart ssh.service
