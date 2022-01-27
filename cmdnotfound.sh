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

cho "This script must be run as root, it requires root identification and the creation of a user."

#######################
# Adveritssment
#######################

if [ "$(whoami)" != 'root' ]; then
echo "You are not root, This script must be run as root."
exit 1;
fi

#######################
# Add line to bashrc
#######################

echo "Add export PATH=$PATH:/bin:/sbin:/usr/sbin:usr/local/sbin:/usr/bin:/usr/local/bin:/usr/local/games:/usr/games:/usr/local/sbin:/usr/lib/lightdm/lightdm to bashrc "

sed -i -e '$a export PATH="$PATH:/bin:/sbin:/usr/sbin:usr/local/sbin:/usr/bin:/usr/local/bin:/usr/local/games:/usr/games:/usr/local/sbin:/usr/lib/lightdm/lightdm"' ~/.bashrc

#update source
alias brc='source ~/.bashrc'

echo "Work done, have a nice day"

exit 0;
