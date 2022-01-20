#!/bin/bash

#####################################################################
# Ce script à pour but la mise en place d'un cloud privé ownCloud
#
# testé sur Debian 11
#
# Il utilise
# (Apache2 & Mariadb)
#
# Created by geds3169
#
# guilhemETkarine@hotmail.fr
#
# 17/01/2022
#
######################################################################

###################################################################################
# Variables
###################################################################################
APACHE2_STATUS="$(systemctl is-active apache2.service)"
MYSQL_STATUS="$(systemctl is-active mariadb.service)"
START_SCRIPT_DEBUG="true"
FLAG_STATUS="active"


###################################################################################
# Vérification des droits d'execution
###################################################################################
# Vérification des permissions d'execution du script
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

###################################################################################
# Mise à jour de la distribution et installation des différent services et modules
###################################################################################
echo ""
echo ""
echo "Mise à jour du système"
sleep 1
apt update && apt upgrade -y

###################################################################################
# Installation du serveur Web Apache2
###################################################################################
# Determine si le serveur web est installé, démarré
if [[ ! "$(dpkg --get-selections | grep apache )"~ "install" ]] 
then
	echo "Apache2 est déjà installé"
		# Determine si le seveur web est fonctionnel
		if [ $APACHE2_STATUS = $FLAG_STATUS ] 
		then
			echo "Apache2 est démarré et opérationnel"
		else
			echo "Apache 2 n'est pas démarré"
			echo "Voulez-vous démarrer Apache2 et activer le service [y/n] ? "
			read activeApache2
			if [[ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ]
			then
				systemctl start apache2
				systemctl enable apache2
				# Test à nouveau si le service est actif
				if [ $APACHE2_STATUS = $FLAG_STATUS ] 
				then
					echo "Apache2 est à présent fonctionnel"
				else
					echo "Il semble y avoir un soucis avec Apache2"
				fi
			fi
		fi
else
	echo "Apache 2 n'est pas installé"
	echo "Le serveur apache2 doit être installé, souhaitez-vous procéder [y/n] ? "
	read installApache2
	if [[ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ]]
	then
		apt install apache2 -y
	fi
fi


exit 0