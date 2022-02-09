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
echo "Souhaitez-vous mettre à jour les référentiels des paquets ? [y/n] ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	echo -e "\nLa mise à jour des référentiels de paquets va débuter \n"
  	sudo apt-get update -y -qq >> $CURRENTLOCATION/update.log
	echo -e "\nMise à jour terminé, un fichier d$CURRENTLOCATION/updade.log a été créé.\n"
	echo -e "\nSouhaitez-vous procéder à la mise à jour des paquets ? [y/n] ?"; then
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo apt-get update -y -qq >> $CURRENTLOCATION/upgrade.log
		echo -e "\nMise à jour terminé, un fichier d$CURRENTLOCATION/upgrade.log a été créé.\n"
		echo -e "\nVous vous retourner à l'accueil [y/n] ? "
	else
		UpdateUpgrade
	fi
elif
	echo -e "\nSouhaitez-vous procéder à la mise à jour des paquets ? [y/n] ?"; then
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo apt-get update -y -qq >> $CURRENTLOCATION/upgrade.log
		echo -e "\nMise à jour terminé, un fichier d$CURRENTLOCATION/upgrade.log a été créé.\n"
		echo -e "\nVous vous retourner à l'accueil [y/n] ? "
	else
		UpdateUpgrade
	fi
else
	echo -e "\nVous vous retourner à l'accueil [y/n] ? "
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		echo "Retour au menu principal"
		source ./Installeur.sh;
		how_Installeur;
	else
		UpdateUpgrade
	fi

fi

exit 0

}

UpdateUpgrade
