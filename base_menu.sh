#!/bin/bash
#
#######################################
#
# Par Guilhem SCHLOSSER
#	alias geds3169
#
#	janvier 2021
# Script permettant d'installer:
# Un cloud privé, ownCloud | Nextcloud
#
# Testé sur Debian 11
#
######################################
#
#
########################
# Menu
########################
show_menu(){

mytitle="Installation d'une solution cloud"
echo -e "${title} #################################### ${normal}\n"
echo -e "${title} # ${mytitle} #${normal}\n"
echo -e "${title} #################################### ${normal}\n\v"

	title=`echo "\033[35m"` Purple
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Cyan
    number=`echo "\033[33m"` #Yellow
	validation=`echo "\033[32m"` #Green
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
 
  # Optionnal colors
	# `echo "\033[37m"` white	
	# `echo "\033[30m"` Black

	
    echo -e "\n${menu}*********************************************${normal}\n"
    echo -e "${menu}**${number} 1)${menu} Installation des outils optionnels ${normal}\n"
    echo -e "${menu}**${number} 2)${menu} Installation de ownCloud ${normal}\n"
    echo -e "${menu}**${number} 3)${menu} Installation de Nextcloud ${normal}\n"
    echo -e "${menu}*********************************************${normal}\n"
    echo -e "Sélectionnez une option pressez ${fgred}x pour quitter. ${normal}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    echo -e "${msgcolor}${message}${normal}\n"
}

clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        1) clear;
            option_picked "Option 1 sélectionné";
            outils; #appel de la function
            show_menu;
        ;;
        2) clear;
            option_picked "Option 2 sélectionné";
            owncloud; #appel de la function
            show_menu;
        ;;
        3) clear;
            option_picked "Option 3 sélectionné";
            nextcloud; #appel de la function
            show_menu;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Sélectionnez une option dans le menu";
            show_menu;
        ;;
      esac
    fi
done
