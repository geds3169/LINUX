#!/bin/sh

##########################################
#
# Script made by Geds3169
#
# 13/09/2021
#
# Change the PATH environment variable in Debian 10
#
# Because cmd adduser not found
#
# Work in Debian 10.2.0
#
##########################################

###############################
# Check user running the script
###############################

cho -e "Default \e[41m \n This script must be run as root, it requires root identification and the creation of a user."

#######################
# Adveritssment
#######################

if [ "$(whoami)" != 'root' ]; then
echo -e "Default \e[101m \n You are not root, This script must be run as root."
exit 1;
fi

#######################
# Add line to bashrc
#######################

echo -e "Default \e[34m \n Add PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games to bashrc "

sed -i -e '$a export PATH="PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"' ~/.bashrc

#update source
source ~/.bashrc

echo -e "Default \e[34m \n Work done, have a nice day"

exit 0;
