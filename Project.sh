#!/bin/sh
###################################################################################
#
#
# Script en cours de r�alisation
# Remaniement complet du code initial Next.sh
# 
###################################################################################
# 
#####################################
# V�rification des droits d'execution
#####################################
if [ "$(whoami)" != "root" ]; then
	echo "Les privil�ges Root sont requis pour ex�cuter ce script, essayez de l'ex�cuter avec sudo..."
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
# Mise � jour du syst�me et des packets
#######################################
echo "Mise � jour du syst�me et des sources logicielles"
sudo apt update && apt upgrade -y
echo ""
echo "Installation d'outils d�di� au r�seau"
sudo apt-get install net-tools -y
echo "le systeme est a pr�sent � jour"
echo ""
echo "Installation d'outil de recherche dans le systeme (locate)"
sudo apt-get install locate -y
sudo updatedb
sleep 2

#######################################
# Phase de test
#######################################
echo "Phase de test des pr�requis � la solution Nextcloud"
echo "test des diff�rents services"
sleep 2

#######################################
# Teste la pr�sence de Apache2 & MariaDB
#######################################
if [[ "${APACHE2_SERVICE}" =~ "install" ]]
then
		echo "Apache2 est install�"
else
	echo "Apache 2 n'est pas install�"
	echo "Le serveur apache2 doit �tre install�, souhaitez-vous proc�der [y/n] ? "
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
		echo "MariaDB est install�"
else
	echo "MariaDB n'est pas install�"
	echo "MariaDB doit �tre install�, souhaitez-vous proc�der [y/n] ? "
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
	echo "Apache2 est d�marr�"
else
	echo "Apache 2 n'est pas d�marr�"
	echo "Voulez-vous d�marrer Apache2 [y/n] ? "
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
	echo "MariaDB est d�marr�"
else
	echo "MariaDB n'est pas d�marr�"
	echo "Voulez-vous d�marrer MariaDB [y/n] ? "
	read activeApache2
	if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ];
	then
		systemctl start MariaDB |grep "mariadb" ${FLAG_ACTIVE} && echo "$FLAG_ACTIVE"
		sudo systemctl enable apache2 -q | grep "mariadb" ${FLAG_ENABLED} && echo "$FLAG_ENABLED"
	fi
fi
sleep 5

#########################################################
# Determine si le service Apache2 est actif au d�marrage.
#########################################################
if [ "${APACHE2_SERVICE}" == "enabled" ] 
then
	echo "Le service Apache2 est activ�"
else
	echo "Le service Apache2 n'est pas activ�"
	echo "Voulez-vous activer le service Apache2 [y/n] ? "
	read enableApache2
	if [ "${enableApache2}" == "yes" ] || [ "${enableApache2}" == "y" ];
	then
		sudo systemctl enable apache2 -q | grep 
	fi
fi
sleep 5

#########################################################
# Determine si le service MariaDB est actif au d�marrage.
#########################################################
if [ "${APACHE2_SERVICE}" == "enabled" ] 
then
	echo "Le service Apache2 est activ�"
else
	echo "Le service Apache2 n'est pas activ�"
	echo "Voulez-vous activer le service Apache2 [y/n] ? "
	read enableMariaDB
	if [ "${enableMariaDB}" == "yes" ] || [ "${enableMariaDB}" == "y" ];
	then
		systemctl enable mariadb
	fi
fi
sleep 5

#########################################################
# Determine si PHP 8 est install�
#########################################################
:'
if [ $(dpkg -l | grep php) -eq 0 ] || [ ${PHPVERSION} >= 7.0 ] ;
then
	# Installation des packets
	echo "Installation du d�p�t php8.0 et de la cl� GPG associ�"
	echo ""
	apt-get install apt-transport-https lsb-release ca-certificates -y
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list
	echo ""
	echo "Mise � jour des nouveaux packets depuis les d�p�ts et t�l�chargement"
	apt-get update
	echo ""
	echo "Installation de PHP et de ses d�pendances requises"
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
# Retour d'information sur le processus Apache2, MariaDB et ports utilis�s
pgrep -lf apache2
pgrep -lf mariadb
echo ""
echo "Protocole et ports d'�coute sont :"
netstat -pat | grep apache2|grep mariadb
echo ""

# !!!!!!!!!!!!!! voir � impl�menter la d�sactivation des versions ant�rieures e.g: sudo a2dismod php5 / sudo a2enmod php8.1 / systemctl restart apache2 et voir a combiner avec la mise en fonction des versions install� localement mais non actives
# locate -i -e  "php.*"  puis sudo update-alternatives --config php et enfin sudo update-alternatives --set php /usr/bin/php8 si existant
#https://stackoverflow.com/questions/42619312/switch-php-versions-on-commandline-ubuntu-16-04