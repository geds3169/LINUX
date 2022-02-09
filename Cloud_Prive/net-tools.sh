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
# FONCTION INSTALLATION net-tools
#
##########################################################################################################################################
#########################
# Variables du script
#########################
CURRENTLOCATION="$(pwd)"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
exec 2>>$CURRENTLOCATION/Error_Install_tools.log


function net-tools(){
# Determine si le paquet est installé / installe
echo -e "net-tools\n"
echo -e "\nnet-tools a été installé, il contient des outils tel que:\n arp, ifconfig, netstat, rarp, nameif et route\n"
if [[ "$(dpkg --get-selections | grep net-tools)" =~ "install" ]]; then
                echo "net-tools est déjà présent"
else
  echo "Souhaitez-vous procéder à l'installation de net-tools"
  read q
  if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
    sudo apt-get install net-tools -y >> $CURRENTLOCATION/Install_tools.log
    echo -e "\n Un fichier $CURRENTLOCATION/Install_tools.log a été créé.\n"
  else
    echo "Vous avez annulé l'opération en cours [y/n] ? "
    read q
    if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
    ./SubMenuTools
    else
      ./net-tools.sh
    fi
  fi
fi

exit 0
}

net-tools
