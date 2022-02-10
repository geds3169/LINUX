#!/bin/bash
#
#
# Script permettant la mise en place d'une solution Cloud Privé
#
# owncloud ou Nextcloud
#
# https://owncloud.com/
#
# https://nextcloud.com/
#
# Testé sur Debian 11
#
# 02/2022
#
#
#
#
######################################

#########################
# Variables du script
#########################
CURRENTLOCATION="$(pwd)"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
exec 2>>$CURRENTLOCATION/Error_Install_Apache2.log

############################

##########################################
# Installation d'outils réseau
#########################################
show_SubMenuOutilsReseau(){

mytitle="Outils Réseau"
echo -e "${title} ##################################### ${normal}\n"
echo -e "${title} # ${mytitle} #${normal}\n"
echo -e "${title} ##################################### ${normal}\n\v"

	title=`echo "\033[35m"` #Purple
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
echo -e "${menu}**${number} 1)${menu} Installation de net-tools \nt\t- outils importants pour contrôler le sous-système réseau du noyau Linux \n\t- inclut arp, ifconfig, netstat, rarp, nameif et route \n\t- contient des utilitaires qui touchent à la configuration d'équipements réseaux spécifiques : \n\t\tplipconfig ; \nslattach ; \nmii-tool ; \niptunnel; \nipmaddr. ${normal}\n"
echo -e "${menu}**${number} 2)${menu} Installation de dnsutils \n\t- dig : effectue des requêtes DNS de différentes façons ; \n\t- nslookup : ancienne façon de procéder ; \n\t- nsupdate : fait des mises à jour dynamiques (voir RFC2136). ${normal}\n"
echo -e "${menu}**${number} 3)${menu} Installation de ifupdown2 \n\t- fournit les outils ifup et ifdown ; \n\t- permet de configurer ou reconfigurer des interfaces réseau ; \n\t- Il se base sur les noms des interfaces présentes dans le fichier /etc/network/interfaces ${normal}\n"
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
            option_picked "Installation de net-tools";
            ./net-tools.sh; #appel du script
            show_SubMenuOutilsReseau;
	;;
        2) clear;
            option_picked "Installation de dnsutils";
            ./dnsutils.sh; #appel du script
            show_SubMenuOutils;
        ;;
        3) clear;
            option_picked "ifupdown2";
            ./ifupdown2.sh; #appel du script
            show_SubMenuOutilsReseau;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Sélectionnez une option dans le menu";
            ./show_SubMenuOutils.sh;
	    show_SubMenuOutils;
        ;;
      esac
    fi
done

exit 0
