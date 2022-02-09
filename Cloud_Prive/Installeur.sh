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
# Vérification des droits d'execution
######################################
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

#########################
# Variables du script
#########################
CURRENTLOCATION="$(pwd)"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
exec 2>>$CURRENTLOCATION/Error_Install_Apache2.log

############################
# Averstissement
############################
clear
echo -e "\nCe script fait appel à des scripts contenuent dans ce même dossier"
sleep 3
echo -e "\nCe script vise une installation simplifié d'une solution de Cloud privé Open Source, \nMerci de prendre le temps de vous renseigner sur l'une ou l'autre des solutions, \navant de procéder à une mise en place."
echo -e "\Ce script ne remplace pas le concours d'un professionnel, assurez-vous d'avoir les connaissances/compétences requises, pour la mises en oeuvre/maintien en condition/sécurisation."
clear

############################
# Variables d'environnement
############################
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#####################################
# fonction menu
####################################
show_Installeur(){

mytitle="Installeur de solution cloud privé"
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
echo -e "${menu}**${number} 1)${menu} Mise à jour du systeme et des logiciels (Recommandé) ${normal}\n"
echo -e "${menu}**${number} 2)${menu} Installation d'outils (optionnels) ${normal}\n"
echo -e "${menu}**${number} 3)${menu} Installation de ownCloud ${normal}\n"
echo -e "${menu}**${number} 4)${menu} Installation de Nextcloud ${normal}\n"
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
show_Installeur
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
	1) clear;
            option_picked "Mise à jour des référenciels et des paquets";
            ./Update&Upgrade.sh; #appel du script
            show_Installeur;
	;;
        2) clear;
            option_picked "Installation d'outils";
            tools; #appel de la function
            show_Installeur;
        ;;
        3) clear;
            option_picked "Installation de la solution ownCloud";
            owncloud; #appel de la function
            show_Installeur;
        ;;
        4) clear;
            option_picked "Installation de la solution Nextcloud";
            nextcloud; #appel de la function
            show_Installeur;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Sélectionnez une option dans le menu";
            show_Installeur;
        ;;
      esac
    fi
done

exit 0
