#!/bin/sh

#############################################
# This script install a complete structure folder
#
# for Ansible
#
# For Debian 10 (buster)
#
# Created by geds3169
#
# guilhemETkarine@hotmail.fr
#
# 03/09/2021
#
##############################################

######################
# Customize the shell
######################

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

#######################
# Adveritssment
#######################

echo "$Cyan \n This script must be run as root or sudoers,  $Color_Off"
echo "$Cyan \n elevation of privileges is required to create the folder tree in the /etc/ansible directory.  $Color_Off"
echo "$Cyan \n He then created a symbolic link to in the / home / user of your choice.  $Color_Off"

###############################
# Check user running the script
###############################

if [ "$(whoami)" != 'root' ]; then
echo "$Red \n You are not root or sudoers, try: $Color_Off"
echo "$Yellow \n sudo bash ansible_tree.sh $Color_Off"
exit 1;
fi

#################################################
# Request user confirmation but dont leave prompt
#################################################

read -p "Do you want proceed with the creation of the structure, in the / etc / ansible directory and create a symbolic link in the home directory of a user? " -n 1 -r
echo  "You canceled the operation a doubt, a script error, thank you for giving me a little feedback :)"  # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi


