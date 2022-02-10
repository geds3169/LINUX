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

function UpdateUpgrade(){

echo -e "\nMise à jour des référentiels des paquets et leurs mises à jour\n"
echo "Souhaitez-vous mettre à jour les référentiels des paquets [y/n] ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	echo -e "\nLa mise à jour des référentiels de paquets va débuter \n"
  	sudo apt-get update -y -qq >> $CURRENTLOCATION/update.log
	echo -e "\nMise à jour terminé, un fichier $CURRENTLOCATION/updade.log a été créé.\n"
	sleep 1
	echo -e "\nSouhaitez-vous procéder à la mise à jour des paquets [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo apt-get upgrade -y -qq >> $CURRENTLOCATION/upgrade.log
                echo -e "\nMise à jour terminé, un fichier $CURRENTLOCATION/upgrade.log à été créé.\n"
		sleep 1
	else
		echo "Souhaitez vous revenir au menu principal ? [y/n]"
        	read q
        	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
			source ./Installeur.sh;
		else
			UpdateUpgrade;
		fi
	fi
	echo -e "\nVoulez vous retourner à l'accueil [y/n] ? "
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		echo "Retour au menu principal"
		source ./Installeur.sh;
	else
		UpdateUpgrade;
	fi
else
	echo "Voulez vous procéder à la mise à jour des paquets [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		echo -e "\nLa mise à jour des paquets va débuter \n"
		sudo apt-get upgrade -y -qq >> $CURRENTLOCATION/upgrade.log
		echo -e "\nMise à jour terminé, un fichier $CURRENTLOCATION/upgrade.log à été créé.\n"
		sleep 1
		echo "Souhaitez vous revenir au menu principal ? [y/n]"
        	read q
        	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
			source ./Installeur.sh;
		else
			UpdateUpgrade;
		fi
	else
		echo "Souhaitez vous revenir au menu principal ? [y/n]"
        	read q
        	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
			source ./Installeur.sh;
		else
			UpdateUpgrade;
		fi
	fi
fi

exit 0

}

UpdateUpgrade
