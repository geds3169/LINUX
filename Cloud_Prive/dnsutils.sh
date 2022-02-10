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
# FONCTION INSTALLATION dnsutils
#
##########################################################################################################################################
#########################
# Variables du script
#########################
CURRENTLOCATION="$(pwd)"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
exec 2>>$CURRENTLOCATION/Error_Install_tools.log


function dnsutils(){
# Determine si le paquet est installé / installe
echo -e "dnsutils\n"
echo -e "\ndnsutils a été installé, il contient des outils tel que:\n arp, ifconfig, netstat, rarp, nameif et route\n"
if [[ "$(dpkg --get-selections | grep dnsutils)" =~ "install" ]]; then
                echo "dnsutils est déjà présent"
else
  echo "Souhaitez-vous procéder à l'installation de dnsutils"
  read q
  if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
    sudo apt-get install dnsutils -y >> $CURRENTLOCATION/Install_tools.log
    echo -e "\n Un fichier $CURRENTLOCATION/Install_tools.log a été créé.\n"
  else
    echo "Vous avez annulé l'opération en cours [y/n] ? "
    read q
    if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
      source ./show_SubMenuOutilsReseau.sh;
      show_SubMenuOutilsReseau;
    else
      dnsutils
    fi
  fi
fi

exit 0
}

dnsutils
