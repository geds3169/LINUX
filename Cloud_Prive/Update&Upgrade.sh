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
# FONCTION INSTALLATION UPDATE & UPGRADE DU SYSTEME
#
##########################################################################################################################################

# Met à ajout à jour les listes de paquetages, pour une éventuelle mise à niveau des paquetages disponibles, installé et nécessitant une mise à jour.
#Met à jour les nouveaux paquetages venant d'être ajoutés.
#Met à jour la listes de référentiels.
#Installe gère, supprime, remplace les paquets obsolètes 


CURRENTLOCATION="$(pwd)"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
exec 2>>$CURRENTLOCATION/Error_Install_Update.log

function Update&Upgrade(){

echo -e "\nMise à jour des référentiels des paquets et leurs mises à jour\n"
echo "Souhaitez-vous mettre à jour les référentiels des paquets ? [y/n] ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	echo -e "\nLa mise à jour des référentiels de paquets va débuter \n"
  	sudo apt-get update -y -qq >> $CURRENTLOCATION/update.log
	echo -e "\nMise à jour terminé, un fichier d$CURRENTLOCATION/updade.log a été créé.\n"
elif
	echo "Souhaitez-vous procéder à la mise à jour des paquets ? [y/n] ?"
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo apt-get update -y -qq >> $CURRENTLOCATION/upgrade.log
		echo -e "\nMise à jour terminé, un fichier d$CURRENTLOCATION/upgrade.log a été créé.\n"
	fi
else
	echo "Vous avez annulé l'opération en cours [y/n] ? "
	read action1
	if [ "${action1}" == "yes" ] || [ "${action1}" == "y" ]; then
		echo "Opération annulé, retour au menu principal"
		./Installeur.sh
	fi
fi

exit 0

}

Update&Upgrade
