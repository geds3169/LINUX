#!/bin/bash

#############################################
# This script is a SAMBA tools for Administrator
#
# For Debian 10 (buster)/ 11 (bullseye)
#
# Based on native CMD https://samba.tranquil.it/doc/en/samba_config_server/samba_commands_utils.html
#
# Created by geds3169
#
# guilhemETkarine@hotmail.fr
#
# 26/11/2021
#
##############################################


###############################
# Check user running the script
###############################

if [ "$(whoami)" != 'root' ]; then
echo "$Red \n You are not root, This script must be run as root $Color_Off"
exit 1;
fi

########################################
# Custosm Color
########################################
# Color  Variables
green='\e[32m'
blue='\e[34m'
clear='\e[0m'

#########################################
# fonctions
#########################################
ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

#-------------------
# TEMPLATE FUNCTION

function NAME_FUNCTION(){ 
echo "THIS FUNCTION DO BLABLABLA"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
         echo "THAT IS A QUESTION"
         read VARIABLE
         
         echo "Task accomplished, have a good day"
else
 (echo "Goodbye!"; menu)
fi
}

#-------------------

#-------------------
#########################################
# SHOW SAMBA4 DOMAIN CONTENT
#########################################
function SHOW_SAMBA4_DOMAIN(){ 
echo "SHOW DOMAIN CONTENT"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
         echo "What is the ip or FQDN of the SAMBA : "
         read SAMBA
         samba-tool domain info $SAMBA
         echo "Task accomplished, have a good day"
else
 (echo "Goodbye!"; menu)
fi
}

#-------------------

#########################################
# LIST USERS INSIDE SAMBA
#########################################
function lIST_USERS_SAMBA(){ 
echo "lIST USERS SAMBA"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
         samba-tool user list
         echo "Task accomplished, have a good day"
else
 (echo "Goodbye!"; menu)
fi
}

#-------------------

#########################################
# ADD USER TO SAMBA
#########################################
function ADD_USER_SAMBA(){ 
echo "ADD USER TO SAMBA"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
         echo "What is the user name : "
         read USER
         samba-tool user create $USER
         echo "Task accomplished, have a good day"
else
 (echo "Goodbye!"; menu)
fi
}

#-------------------

#########################################
# ADD USER TO SAMBA WITH RANDOM PASSWORD
#########################################
function ADD_USER_SAMBA_R_PASSWD(){ 
echo "ADD USER TO SAMBA"
sleep 1
read -rp "Do you want continue ? [y/n/c] "
[[ ${REPLY,,} =~ ^(c|cancel)$ ]] && { echo "Selected Cancel"; exit 1; }
if [[ ${REPLY,,} =~ ^(y|yes|j|ja|s|si|o|oui)$ ]]; then
         echo "What is the user name : "
         read USER
         samba-tool user create $USER
         echo "Task accomplished, have a good day"
else
 (echo "Goodbye!"; menu)
fi
}

#-------------------

#########################################
# menu
#########################################
menu(){
echo -ne "
Multi Tools Administrator
$(ColorGreen '1)') Display some information of the SAMBA4 AD
$(ColorGreen '2)') List users inside SAMBA
$(ColorGreen '3)') Add new user SAMBA
$(ColorGreen '4)') Add new user SAMBA with a random password 
$(ColorGreen '5)') EXPLAIN THE FUNCTION DO
$(ColorGreen '6)') EXPLAIN THE FUNCTION DO
$(ColorGreen '7)') EXPLAIN THE FUNCTION DO
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) SHOW_SAMBA4_DOMAIN ; menu ;;
	        2) lIST_USERS_SAMBA ; menu ;;
          2) ADD_USER_SAMBA ; menu ;;
	        3) ADD_USER_SAMBA_R_PASSWD ; menu ;;
	        4) CALL_THE_FUNCTION ; menu ;;
	        5) CALL_THE_FUNCTION ; menu ;;
          6) CALL_THE_FUNCTION ; menu ;;
          7) CALL_THE_FUNCTION ; menu ;;
			0) exit 0 ;;
			*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}

#########################################
# Call the menu function
#########################################
menu
