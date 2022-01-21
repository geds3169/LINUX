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
APACHE2_SERVICE="$(systemctl is-enabled apache2.service)"
#
MARIADB_STATUS="$(systemctl is-active mariadb-service)"
MARIADB_SERVICE="$(systemctl is-enabled mariadb.service)"

#
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

apt-get install net-tools

echo ""

###################################################################################
# Installation du serveur Web Apache2
###################################################################################
# Determine si le serveur web est installé, démarré
if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]
then
		echo "Apache2 est installé"
else
	echo "Apache 2 n'est pas installé"
	echo "Le serveur apache2 doit être installé, souhaitez-vous procéder [y/n] ? "
	read installApache2
	if [ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ];
	then
		apt install apache2 -y
		systemctl enable apache2
	fi
fi

echo ""

# Determine si le seveur web est fonctionnel.
if [ $APACHE2_STATUS = $FLAG_STATUS ] 
then
	echo "Apache2 est démarré"
else
	echo "Apache 2 n'est pas démarré"
	echo "Voulez-vous démarrer Apache2 [y/n] ? "
	read activeApache2
	if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ];
	then
		systemctl start apache2
	fi
fi

echo ""

# Determine si le service est actif au démarrage.
if [ $APACHE2_SERVICE == "enabled" ] 
then
	echo "Le service Apache2 est activé"
else
	echo "Le service Apache2 n'est pas activé"
	echo "Voulez-vous activer le service Apache2 [y/n] ? "
	read activeApache2
	if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ];
	then
		systemctl enable apache2
	fi
fi

echo ""

# Retour d'information sur le processus Apache2 et port utilisé
echo "Apache2 est activé et opérationnel, le(s) PID du processus est/sont : "
pgrep -lf apache2
echo ""
echo "et le protocole et le port d'écoute actuel sont :"
netstat -pat | grep apache2

echo ""

###################################################################################
# Installation du serveur de base de données Mysql ou Mariadb
###################################################################################

# Détermine si le serveur de base de données est installé, démarré.
if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]
then
		echo "MariaDB est déjà installé"
		dpkg --get-selections | grep mariadb
else
	echo "Aucun serveur de base de données n'est installé"
	echo "Un serveur de base de données est requis, souhaitez-vous procéder [y/n] ? "
	read dataServer
	if [[ "${dataServer}" == "yes" ] || [ "${dataServer}" == "y" ]];
	then
		echo "MySQL-server n'étant plus supporté par Debian, Mariadb sera donc installé'"
		apt install mariadb-server -y
		systemctl enable mariadb
	fi
fi

echo ""

# Determine si le seveur de base de données est fonctionnel.
if [ $MARIADB_STATUS = $FLAG_STATUS ] 
then
	echo "Le serveur de base de données est démarré"
else
	echo "Le serveur de base de données n'est pas démarré"
	echo "Le serveur de base de données doit être activé, souhaitez-vous procéder [y/n] ? "
	read activeDataServer
	if [ "${activeDataServer}" == "yes" ] || [ "${activeDataServer}" == "y" ];
	then
		systemctl start mariadb
	fi
fi

echo ""

# Determine si le service est actif au démarrage.
if [ $MARIADB_SERVICE == "enabled" ] 
then
	echo "Le service MariaDB est activé"
else
	echo "Le service MariaDB n'est pas activé"
	echo "Voulez-vous activer le service MariaDB [y/n] ? "
	read activeMariaDB
	if [ "${activeMariaDB}" == "yes" ] || [ "${activeMariaDB}" == "y" ];
	then
		systemctl enable apache2
	fi
fi

echo ""

# Retour d'information sur le processus Apache2 et port utilisé
echo "MariaDB est activé et opérationnel, le(s) PID du processus est/sont : "
pgrep -lf mariadb
echo ""
echo "et le protocole et le port d'écoute actuel sont :"
netstat -pat | grep mariadb

echo ""


exit 0