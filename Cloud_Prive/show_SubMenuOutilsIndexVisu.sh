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
# Installation d'outils
#########################################
show_SubMenuOutilsIndexVisu(){

mytitle="Outils d'indexation et visualisation d'arborescence"
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
echo -e "${menu}**${number} 1)${menu} Installation de locate : permet de rechercher des fichiers. \nUsage, passez au préalable la commande suivante: \n\t (! sudo si nécessaire !) updatedb Enfin utiliser la recherche avec la commande suivante: \n\tlocate fichier.txt | less | more \n\tPensez à passer la commande: updatedb avant toutes recherche. ${normal}\n"
echo -e "${menu}**${number} 2)${menu} Installation de tree : permet la visualisation de l'arborescence, des répertoire, dossier ...\n\tLa commande est : tree -a ou tree -f ou encore tree -dfp${normal}\n"
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
show_SubMenuOutilsIndexVisu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
	1) clear;
            option_picked "Installation de locate";
            source ./locate.sh; #appel du script
            locate;
	;;
        2) clear;
            option_picked "Installation de tree";
            source ./tree.sh; #appel du script
            tree;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Sélectionnez une option dans le menu";
            source ./show_SubMenuOutils.sh;
	    show_SubMenuOutils;;
        ;;
      esac
    fi
done

exit 0
