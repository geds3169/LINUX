#!/bin/sh
###################################################################################
#
#
# Script en cours de réalisation
# Remaniement complet du code initial Next.sh
# 
###################################################################################
# 
#####################################
# Vérification des droits d'execution
#####################################
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

#####################################
#variables
#####################################
# Packages installed
APACHE2_INSTALL="$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )"
MARIADB_INSTALL="$(dpkg --get-selections | grep mariadb )"
PHP_MODULES="$(dpkg --get-selections | grep -i php)"
# Services on startup
APACHE2_SERVICE="$(systemctl is-enabled apache2.service)"
MARIADB_SERVICE="$(systemctl is-enabled mariadb.service)"
# Running Services
MARIADB_STATUS="$(systemctl is-active mariadb)"
APACHE2_STATUS="$(systemctl is-active apache2.service)"
# PHP
PHP_VERSION="$(grep -ioP "php version\s\K\d.\d")"
PHP_STATUS="$(systemctl status php8.1-fpm)"

# Flags
START_SCRIPT_DEBUG="true"
FLAG_ACTIVE="active"
FLAG_ENABLED="enabled"

#######################################
# Mise à jour du système et des packets
#######################################
echo "Mise à jour du système et des sources logicielles"
sudo apt update && apt upgrade -y
echo ""
echo "Installation d'outils dédié au réseau"
sudo apt-get install net-tools -y
echo "le systeme est a présent à jour"
echo ""
echo "Installation d'outil de recherche dans le systeme (locate)"
sudo apt-get install locate -y
sudo updatedb
sleep 2

#######################################
# Phase de test
#######################################
echo "Phase de test des prérequis à la solution Nextcloud"
echo "test des différents services"
sleep 2

#######################################
# Teste la présence de Apache2 & MariaDB
#######################################
if [[ "${APACHE2_SERVICE}" =~ "install" ]]
then
		echo "Apache2 est installé"
else
	echo "Apache 2 n'est pas installé"
	echo "Le serveur apache2 doit être installé, souhaitez-vous procéder [y/n] ? "
	read installApache2
	if [ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ];
	then
		sudo apt install apache2 -y -q
		echo "Activation du service"
		sudo systemctl enable apache2 -q | grep "apache2" ${FLAG_ENABLED} && echo "$FLAG_ENABLED"
		sudo Systemctl status apache2 -q |grep "apache2" ${FLAG_ACTIVE} && echo "$FLAG_ACTIVE"
	fi
fi
sleep 5

if [[ "${MARIADB_INSTALL}" =~ "install" ]]
then
		echo "MariaDB est installé"
else
	echo "MariaDB n'est pas installé"
	echo "MariaDB doit être installé, souhaitez-vous procéder [y/n] ? "
	read installMariaDB
	if [ "${installMariaDB}" == "yes" ] || [ "${installMariaDB}" == "y" ];
	then
		sudo apt install mariadb-server -y
		echo "Activation du service"
		sudo Systemctl status apache2 -q |grep "mariadb" ${FLAG_ACTIVE} && echo "$FLAG_ACTIVE"
	fi
fi
sleep 5

#############################################
# Determine si Apache2 est fonctionnel.
#############################################
if [ "${APACHE2_STATUS}" = "${FLAG_ACTIVE}" ] 
then
	echo "Apache2 est démarré"
else
	echo "Apache 2 n'est pas démarré"
	echo "Voulez-vous démarrer Apache2 [y/n] ? "
	read activeApache2
	if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ];
	then
	sudo Systemctl status apache2 -q |grep "mariadb" ${FLAG_ACTIVE} && echo "$FLAG_ACTIVE"
	sudo systemctl enable apache2 -q | grep "mariadb" ${FLAG_ENABLED} && echo "$FLAG_ENABLED"
	fi
fi
sleep 5

#############################################
# Determine si Apache2 est fonctionnel.
#############################################
if [ "${MARIADB_STATUS}" = "${FLAG_ACTIVE}" ] 
then
	echo "MariaDB est démarré"
else
	echo "MariaDB n'est pas démarré"
	echo "Voulez-vous démarrer MariaDB [y/n] ? "
	read activeApache2
	if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ];
	then
		systemctl start MariaDB |grep "mariadb" ${FLAG_ACTIVE} && echo "$FLAG_ACTIVE"
		sudo systemctl enable apache2 -q | grep "mariadb" ${FLAG_ENABLED} && echo "$FLAG_ENABLED"
	fi
fi
sleep 5

#########################################################
# Determine si le service Apache2 est actif au démarrage.
#########################################################
if [ "${APACHE2_SERVICE}" == "enabled" ] 
then
	echo "Le service Apache2 est activé"
else
	echo "Le service Apache2 n'est pas activé"
	echo "Voulez-vous activer le service Apache2 [y/n] ? "
	read enableApache2
	if [ "${enableApache2}" == "yes" ] || [ "${enableApache2}" == "y" ];
	then
		sudo systemctl enable apache2 -q | grep 
	fi
fi
sleep 5

#########################################################
# Determine si le service MariaDB est actif au démarrage.
#########################################################
if [ "${APACHE2_SERVICE}" == "enabled" ] 
then
	echo "Le service Apache2 est activé"
else
	echo "Le service Apache2 n'est pas activé"
	echo "Voulez-vous activer le service Apache2 [y/n] ? "
	read enableMariaDB
	if [ "${enableMariaDB}" == "yes" ] || [ "${enableMariaDB}" == "y" ];
	then
		systemctl enable mariadb
	fi
fi
sleep 5

#########################################################
# Determine si PHP 8 est installé
#########################################################
:'
if [ $(dpkg -l | grep php) -eq 0 ] || [ ${PHPVERSION} >= 7.0 ] ;
then
	# Installation des packets
	echo "Installation du dépôt php8.0 et de la clé GPG associé"
	echo ""
	apt-get install apt-transport-https lsb-release ca-certificates -y
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list
	echo ""
	echo "Mise à jour des nouveaux packets depuis les dépôts et téléchargement"
	apt-get update
	echo ""
	echo "Installation de PHP et de ses dépendances requises"
	apt install php8.0 libapache2-mod-php8.0 php8.0-{xml,cli,fpm,cgi,mysql,mbstring,gd,curl,zip} -y
	apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y
	echo ""
	sleep 1
	# Status de php
	$PHP_VERSION
	sleep 2
	$PHP_STATUS
	sleep 5
fi
'

echo ""

sleep 1.0
# Retour d'information sur le processus Apache2, MariaDB et ports utilisés
pgrep -lf apache2
pgrep -lf mariadb
echo ""
echo "Protocole et ports d'écoute sont :"
netstat -pat | grep apache2|grep mariadb
echo ""

# !!!!!!!!!!!!!! voir à implémenter la désactivation des versions antérieures e.g: sudo a2dismod php5 / sudo a2enmod php8.1 / systemctl restart apache2 et voir a combiner avec la mise en fonction des versions installé localement mais non actives
# locate -i -e  "php.*"  puis sudo update-alternatives --config php et enfin sudo update-alternatives --set php /usr/bin/php8 si existant
#https://stackoverflow.com/questions/42619312/switch-php-versions-on-commandline-ubuntu-16-04


exit 2