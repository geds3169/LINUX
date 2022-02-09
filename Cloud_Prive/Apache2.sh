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
# FONCTION INSTALLATION APACHE2
#
##########################################################################################################################################
#########################
# Variables du script
#########################
CURRENTLOCATION="$(pwd)"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
exec 2>>$CURRENTLOCATION/Error_Install_Apache2.log


##########################
# Variables de la fonction
##########################

APACHE2_STATUS="$(systemctl is-active apache2.service)"
APACHE2_SERVICE="$(systemctl is-enabled apache2.service)"
#
MARIADB_STATUS="$(systemctl is-active mariadb)"
MARIADB_SERVICE="$(systemctl is-enabled mariadb.service)"
#
MYSQL_STATUS="$(systemctl is-active mysqld.service)"
MYSQL_SERVICE="$(systemctl is-enabled mysqld.service)"
#
#START_SCRIPT_DEBUG="true"
FLAG_ACTIVE="active"
FLAG_ENABLED="enabled"
#
file="owncloud-complete-latest.tar.bz2"
mytitle="Installation d'une solution cloud privé"
#
clear

###########################################################
# Installation / Démarrage / activation du service  Apache2
###########################################################
function Install_Apache2(){

echo "Souhaitez-vous installer le serveur Web Apache2 [y/n] ? "
read ServerWeb
if [ "${ServerWeb}" == "yes" ] || [ "${ServerWeb}" == "y" ]; then
	echo -e "\nMise en place du serveur Web Apache 2\n"
	# Determine si le service apache est installé et s'il fonctionne, si le service est actif au démarrage
	if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]; then
			echo "Apache2 est installé"
			# Determine si le seveur web est fonctionnel.
			if [ "${APACHE2_STATUS}" == "${FLAG_ACTIVE}" ]; then
				echo "Apache2 est démarré"
			else
				echo "Apache2 n'est pas démarré"
				echo "Voulez-vous démarrer Apache2 [y/n] ? "
				read activeApache2
				if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ]; then
					sudo systemctl start apache2
				fi
			fi
			# Determine si le service est actif au démarrage.
			if [  "${APACHE2_SERVICE}" == "${FLAG_ENABLED}" ]; then
				echo "Le service Apache2 est activé"
			else
				echo "Le service Apache2 n'est pas activé"
				echo "Voulez-vous activer le service Apache2 [y/n] ? "
				read enableApache2
				if [ "${enableApache2}" == "yes" ] || [ "${enableApache2}" == "y" ]; then
					sudo systemctl enable apache2
				fi
			fi
	else
		echo "Apache 2 n'est pas installé"
		echo "Le serveur apache2 doit être installé, souhaitez-vous procéder [y/n] ? "
		read installApache2
		if [ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ]; then
			sudo apt-get install apache2 -y > ./Install_Apache2.log
			sudo systemctl start apache2
			sudo systemctl enable apache2
		fi
	fi
else
	echo "Vous avez annulé l'opération en cours [y/n] ? "
	read action1
	if [ "${action1}" == "yes" ] || [ "${action1}" == "y" ]; then
		echo "Opération annulé, retour au menu principal"
		Installeur.sh
	else
		echo "Vous souhaitez reprendre l'installation du serveur Web Apache2 [y/n] ? "
		read action2
		if [ "${action2}" == "yes" ] || [ "${action2}" == "y" ]; then
			Install_Apache2
		fi
	fi
fi

exit 0

}
