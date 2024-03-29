#!/bin/bash
#
#				Easy Cloud Installer

#   GitHub: https://github.com/geds3169/EasyCloudInstaller
#   Requiert: bash, mv, cp, rm, grep, pgrep, sed, wget, tar, 
#
#   En cours d'élaboration
#  
#   Ce script permet de simplifier l'installation d'un cloud privé
#
#
#   Niveau:
#          Débutant (avancé) à confirmer
#
#   Présrequis :
#          nécessite des privilèges d'execution sudo ou root
#          Un nom de domaine et un certificat pour avoirun cloud disponible sur Internet
#
#   Basé sur des solutions totalement ou partiellement Open Source:
#          - ownCloud https://owncloud.com/
#          - Nextcloud https://nextcloud.com/
#
#   Testé sur Debian 11
#
#
#   Usage :
#			cd Téléchargments
#
#			$ wget https://github.com/geds3169/EasyCloudInstaller/EasyCloudInstaller.sh
#
#           $ chmod +x EasyCloudInstaller.sh
#
#           $ ./EasyCloudInstaller.sh
#
#
#   Il permet d'automatiser l'installation au sein de l'environnement.
#
#   Choisissez dans le menu la solution voulu, laissez-vous guider en répondant aux différentes questions
#
##################################################################################################################
clear

echo "
  ______                   _____ _                 _   _____           _        _ _             
 |  ____|				  / ____| |               | | |_   _|         | |      | | |            
 | |__   __ _ ___ _   _  | |    | | ___  _   _  __| |   | |  _ __  ___| |_ __ _| | | ___ _ __   
 |  __| / _  / __| | | | | |    | |/ _ \| | | |/ _  |   | | |  _ \/ __| __/ _  | | |/ _ \  __|  
 | |___| (_| \__ \ |_| | | |____| | (_) | |_| | (_| |  _| |_| | | \__ \ || (_| | | |  __/ |     
 |______\__,_|___/\__, |  \_____|_|\___/ \__,_|\__,_| |_____|_| |_|___/\__\__,_|_|_|\___|_|     
                  __/ /                                                                          
                 |___/                                                                         
"
sleep 3

########################################################################################################################
# Vérification des droits d'execution
########################################################################################################################

if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

clear

####################################################################################################################################################
# Variables d'environnement
####################################################################################################################################################
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


####################################################################################################################################################
# FONCTIONS
####################################################################################################################################################

# Mise à jour repos. et packets
######################################
function update(){

echo "Souhaitez-vous procéder à la mise à jour du systeme et des packets [y/n] ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	echo -e "\nLa mise à jour va débuter \n"
	sudo apt-get update && apt-get upgrade -y -qq >> update.log
	echo -e "\nMise à jour terminé, un fichier de log nommé update.log se trouve dans le répertoire courant.\n"
fi

}


# installation d'outils complémentaires
#######################################
function tools(){

#Variables
#################
#Réseau
tools1="net-tools"
tools2="dnsutils"
tools3="ifupdown2"
#Indexation/Recherche
tools4="locate"
tools5="tree"

clear

# Determine si le paquet est installé / installe
echo -e "Outils réseau\n"
if [[ "$(dpkg --get-selections | grep $tools1)" =~ "install" ]]; then
                echo "$tools1 est déjà présent"
else
        echo "$tools1 n'est pas installé"
        echo "Souhaitez-vous procéder à son installation [y/n] ? "
        read q
        if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
            sudo apt-get install $tools1 -y >> tools.log
			echo -e "$tools1 a été installé, il contient des outils tel que:\n arp, ifconfig, netstat, rarp, nameif et route"
			echo -e "\n Un fichier tools.log a été créé dans le répertoire courant.\n"
        fi
fi

if [[ "$(dpkg --get-selections | grep $tools2)" =~ "install" ]]; then
	echo "$tools2 est déjà présent"
else
    echo "$tools2 n'est pas installé"
    echo "Souhaitez-vous procéder à son installation [y/n] ? "
    read q
    if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
            sudo apt-get install $tools2 -y >> tools.log
            echo -e "$tools2 a été installé, il contient des outils permettant d'implémenter un serveur de nom de domaine."
            echo -e "\n Un fichier tools.log a été créé dans le répertoire courant.\n"
    fi
fi

echo -e "Outils réseau\n"
if [[ "$(dpkg --get-selections | grep $tools3)" =~ "install" ]]; then
	echo "$tools3 est déjà présent"
else
    echo "$tools3 n'est pas installé"
    echo "Souhaitez-vous procéder à son installation [y/n] ? "
    read q
    if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
        sudo apt-get install $tools3 -y >> tools.log
		echo -e "$tools3 a été installé, il contient des outils de gestion des interfaces réseau"
		echo -e "\n Un fichier tools.log a été créé dans le répertoire courant.\n"
    fi
fi


echo -e "Outil de d'indexation/recherche de fichier\n"
if [[ "$(dpkg --get-selections | grep $tools4)" =~ "install" ]]; then
                echo "$tools4 est déjà présent"
else
        echo "$tools4 n'est pas installé"
        echo "Souhaitez-vous procéder à son installation [y/n] ? "
        read q
        if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
                sudo apt-get install $tools4 -y >> tools.log
		echo -e "$tools4 a été installé, il permet de rechercher des fichiers. \nUsage, passez au préalable la commande suivante: \n (! sudo si nécessaire !) updatedb \n Enfin utiliser la recherche avec la commande suivante: \nlocate fichier.txt | less | more \n Pensez à passer la commande: updatedb avant toutes recherche."
		echo -e "Le retour d'erreur suivant: \n/usr/sbin/find: '/run/user/1000/gvfs': Permission denied  --> n'est pas une erreur (comportement attendu/normal) \nVoir: https://dev.getsol.us/T5545 \nCela n'empêche nullement son utilisation."
		echo -e "\n Un fichier tools.log a été créé dans le répertoire courant.\n"
        fi
fi

if [[ "$(dpkg --get-selections | grep $tools5)" =~ "install" ]]; then
                echo "$tools5 est déjà présent"
else
	echo "$tools5 n'est pas installé"
	echo "Souhaitez-vous procéder à son installation [y/n] ? "
	read q
        if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
                sudo apt-get install $tools5 -y >> tools.log
		echo -e "$tools5 a été installé, il permet la visualisation de l'arborescence, des répertoire, dossier ...\n"
		echo -e "La commande est : tree -a ou tree -f ou encore tree -dfp"
		echo -e "\n Un fichier tools.log a été créé dans le répertoire courant.\n"
	fi
fi

echo -e "\nInstallation des outils terminé le fichier tools.log comportant les informations sur les outils, \nse trouve dans le repertoire courant se trouve dans le répertoire courant.\n"

}


# Récupération des information destinées à la base de données de la solution
#####################################################################################
function database(){

clear
echo "Collecte d'informations en vue de la création de la base de données de la solution\n"
sleep 5
echo -e "\n! Les mots de passes ne s'afficheront pas !"
echo -e "\nVérifiez au préalable que votre verrouillage numérique soit fonctionnel (cas de VM)"
sleep 2
clear
echo -e "\nVeuillez confirmer le nom d'utilisateur Root (en minuscule) : "
read root_name
#Hidden password
echo "Renseignez le mot de passe associé au compte Root : "
stty -echo
read root_passwd
stty echo
echo -e "\n! Vous allez à présent entrer les information d'utilisateur (Administrateur de la solution). !"
echo -e "\n! Le compte doit être un utilisateur autre que Root, par sécurité !\n"
sleep 1
clear
echo -e "\nEntrez un nom d'utilisateur (Admin de la solution) : "
read user_name
echo "Entrez le mot de passe associé au compte utilisateur (Admin de la solution) : "
stty -echo
read user_passwd
stty echo
echo -e "\nEntrez le nom souhaité pour la base de donnée (e.g: ownclouddb)"
read database_name
echo -e "\nAjout de l'utilisateur $user_name au groupe d'administration du serveur Web"
id -u $user_name &>/dev/null || useradd $user_name
/usr/sbin/adduser www-data $user_name
echo -e "\nCréation de la base de donnée $database_name"
echo -e "\nSi l'utilisateur $user_name n'existe pas il sera alors créé avec le mot de passe associé"

set -e
mysql -u $root_name -p$root_passwd << EOF
CREATE USER IF NOT EXISTS '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
CREATE DATABASE IF NOT EXISTS $database_name;
GRANT ALL PRIVILEGES ON *.* TO '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
GRANT ALL PRIVILEGES ON $database_name.* TO '$user_name'@'localhost';
FLUSH PRIVILEGES;
EOF
sleep 0.5

echo -e "\nOpération effectué"
mysql --batch --skip-column-names -e "SHOW DATABASES LIKE '$database_name'" | grep $database_name

}


# Installation / Démarrage / activation du service  Apache2
###########################################################
function Install_Apache2(){

#Variables
#################
APACHE2_STATUS="$(sudo systemctl is-active apache2.service)"
APACHE2_SERVICE="$(sudo systemctl is-enabled apache2.service)"
FLAG_ACTIVE="active"
FLAG_ENABLED="enabled"
VERSION="$(sudo apachectl -V | grep Server version | cut -d ":" -f2 | cut -d "/" -f2 | cut -d "/" -f )"

clear


echo -e "\nMise en place du serveur Web\n"
sleep 5
# Determine si le service apache est installé et s'il fonctionne, si le service est actif au démarrage
if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]; then
		echo "Apache2 est installé la version est : $VERSION"
		echo -e "\nVoici les information sur le processus"
		sudo pgrep -lf apache2
		sleep 3
		echo -e "\nInformation complémentaires (nécessite l'installation préalable  de l'outil net-tools):"
		sudo netstat -anp | grep apache2
		sleep 3
		# Determine si le seveur web est fonctionnel.
		if [ "${APACHE2_STATUS}" == "${FLAG_ACTIVE}" ]; then
			echo "Apache2 est démarré"
		else
			echo "Apache2 n'est pas démarré"
			echo "Voulez-vous démarrer Apache2 [y/n] ? "
			read activeApache2
			if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ]; then
				sudo systemctl start apache2
			sleep 2
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
				sleep 2
			fi
		fi
else
	echo "Apache 2 n'est pas installé"
	echo "Le serveur apache2 doit être installé, souhaitez-vous procéder [y/n] ? "
	read installApache2
	if [ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ]; then
		sudo apt-get install apache2 -y
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo -e "\nApache2 est à présent installé/démarré la version est : $VERSION"
		sleep 1
		echo -e "\nVoici les information sur le processus"
		sudo pgrep -lf apache2
		sleep 1
		echo -e "\nInformation complémentaires (nécessite l'installation préalable  de l'outil net-tools):"
		sudo netstat -nluwpat | grep apache2
		sleep 5
	fi
fi

}

# Création des règles de firewall locale (si présent)
############################################################
function Firewall_rules(){

echo -e "\nMise en place des règle de pare-feu\n"
sleep 5

echo "Recherche de la présence du pare-feu Iptables sur le système"
/usr/sbin/iptables status >/dev/null/ 2&1
if [ $? = 0 ]; then
	echo "Iptables est démarré, une régle va être créé pour le trafic entrant, port ${port}"
	iptables -I INPUT -p tcp --dport $port -j ACCEPT
else
	echo "Iptables ne semble pas démarré ou installé"
fi

echo "Recherche de la présence du pare-feu UFW sur le système"
if systemctl status ufw.service >/dev/null; then
	echo "Le pare-feu UFW est démarré, une régle va être créé pour le trafic entrant, port ${port}"
else
	echo "Le pare-feu UFW ne semble pas démarré ou installé"
fi

sleep 1
echo -e "\nLe script n'a pu déceler la présence d'un pare-feu, si aucun pare-feu n'est présent en amont, \nsi le serveur cloud est accessible depuis l'extérieur, vous êtes sujet à des risques."
echo -e "\nSi un autre firewall est installé sur le système ou en amont, il sera nécessaire d'ouvrir les flux manuellement, \nvoire configurer un reverse proxy dans le cas d'hébergement multiples"
sleep 3

}


# Installation de PHP et des dépendances
########################################
function Install_PHP(){

# Variables
############
REQUIRED="7.4"
MAJOR_CURRENTVERS="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d "." | cut -d '.' -f1)"
MINOR_CURRENTVERS="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d "." | cut -d '.' -f2)"
CURRENT_VERSION= "$MAJOR_CURRENTVERS"."$MINOR_CURRENTVERS)"
MAJOR_REQ="$(echo "$REQUIRED" | cut -d " " -f 2 | cut -f1-2 -d"." | cut -d '.' -f1)"
MINOR_REQ="$(echo "$REQUIRED" | cut -d " " -f 2 | cut -f1-2 -d"." | cut -d '.' -f2)"
AVAILABLE="$(apt-owbcache policy php | cut -d " " -f6 | cut -f2-3 -d ":" | grep "." | cut -f1 -d "+" )"
VERSION="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d "." | cut -d ' ')"
clear


echo -e "\nInstallation de PHP"
sleep 5
# Vérification de la présence de PHP sur la distribution
if [[  "$(dpkg --get-selections | grep "php")" =~ "install" ]]; then
	echo -e "\nPHP est déjà présent sur votre distribution, la version est $VERSION"
	sleep 3
	# Vérification des attendus de version PHP 
	if [ $MAJOR_CURRENTVERS -ge $MAJOR_REQ ] && [ $MINOR_CURRENTVERS -ge $MINOR_REQ ] || [ $MAJOR_CURRENTVERS -gt $MAJOR_REQ ] ; then
		echo -e "\nLa version actuelle correspond aux attentes de la solution"
	else
		echo -e "\nLa version actuelle ne correspond pas aux attentes de la solution \nelle nécessite la version minimum la version $REQUIRED "
		# Vérification de l'existance de version supérieure PHP sur la distribution
		if [[ -d /etc/php && "$(echo find /etc/php -mindepth 1 -maxdepth 1 -type d | wc -l)" -gt 1 ]]; then
			echo -e "\nVoici a présent les versions de PHP disponible localement sur votre distribution:\n"
			cd /etc/php
			dir
			echo -e "\nVoulez-vous changer de version [y/n] ?"
			read q
			if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
				echo -e "\nRenseignez le numéro de version souhaitez (retourné précédemment): "
				read new_php_version
				echo -e "\nDésactivation de PHP $CURRENT_VERSION"
				sudo /usr/bin/a2dismod $CURRENT_VERSION >> Mods.log
				echo -e "\nActivation de la version $new_php_version"
				sudo /usr/bin/a2enmod $new_php_version >> Mods.log
				echo -e "\n L'ancienne version de PHP à été désactivé, \nun fichier Mods.log a été créé dans le dossier courant\n"
				echo -e "\nLe redémarrage du serveur Apche2 est nécessaire, voulez-vous procéder [y/n] ?"
				read q
				if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
					sudo systemctl restart apache2
				else
					echo -e "\nPensez à redémarrer le serveur afin de ne pas avoir d'erreur de version PHP \n lorsque vous terminerez la configuration de la solution."
					echo -e "\n En passant la commande suivante: sudo systemctl restart apache2"
				fi
			fi
			# Installation des dépendances PHP nécessaire à la solution
			echo -e "\nInstallation des dépendances requises pour la mise en place de la solution\n"
			echo -e "\nCertaines dépendances PHP sont nécessaires, souhaitez-vous les installer [y/n] ?"
			read q
			if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
				sudo apt-get install php libapache2-mod-php$new_php_version php$new_php_version-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ldap} -y -qq >> PHP.log
				sudo apt-get install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y -qq >> PHP.log
				echo -e "\nLes paquets ont été installés, le fichier PHP.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
				echo -e "\nLe redémarrage du serveur Apche2 est nécessaire, voulez-vous procéder [y/n] ?"
				read q
				if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
					sudo systemctl restart apache2
				else
					echo -e "\nPensez à redémarrer le serveur afin de ne pas avoir d'erreur de version PHP \n lorsque vous terminerez la configuration de la solution."
					echo -e "\n En passant la commande suivante: sudo systemctl restart apache2"
				fi
			else
				echo "La solution ne peut fonctionner sans l'installation des dépendances"
			fi
		else
			echo -e "\nIl n'existe pas d'autre version PHP en local\n"
			echo "Souhaitez-vous vérifier s'il existe une version plus récente sur les dépôts Debian [y/n] ?"
			read q
			if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
				echo "La version la plus récente est :"
				echo "$AVAILABLE"
				echo "Souhaitez-vous installer la nouvelle version [y/n] ?"
				read q
				if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
					echo "Renseignez le numéro de la version souhaité :"
					read vers
					sudo apt-get install php$vers -y -qq >> PHP.log
					echo -e "\nLe paquet a été installé, le fichier PHP.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
					# Installation des dépendances PHP nécessaire à la solution
					echo -e "\nInstallation des dépendances requises pour la mise en place de la solution\n"
					echo -e "\nCertaines dépendances PHP sont nécessaires, souhaitez-vous les installer [y/n] ?"
					read q
					if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
						apt install php libapache2-mod-php$new_php_version php$new_php_version-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ldap} -y
						apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y
						echo -e "\nLes paquets ont été installés, le fichier PHP.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
						echo -e "\nLe redémarrage du serveur Apche2 est nécessaire, voulez-vous procéder [y/n] ?"
						read q
						if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
							sudo systemctl restart apache2
						else
							echo -e "\nPensez à redémarrer le serveur afin de ne pas avoir d'erreur de version PHP \n lorsque vous terminerez la configuration de la solution."
							echo -e "\n En passant la commande suivante: sudo systemctl restart apache2"
							sleep 2
						fi
					else
						echo "La solution ne peut fonctionner sans l'installation des dépendances"
						sleep 2
					fi
				fi
			fi
		fi		
	fi
else
	echo -e "\nPHP n'est pas présent sur votre distribution.\n"
	echo -e "Souhaitez-vous installer PHP [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo apt-get install php -y -q >> PHP.log
		echo "La mise à jour de PHP a été faite, un fichier nommé PHP.log a été créé/mis à jour \nil se trouve dans le répertoire courant"
	fi
	# Installation des dépendances PHP nécessaire à la solution
	echo -e "\nInstallation des dépendances requises pour la mise en place de la solution\n"
	echo -e "\nCertaines dépendances PHP sont nécessaires, souhaitez-vous les installer [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo apt-get install php libapache2-mod-php php-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ldap} -y -qq >> PHP.log
		sudo apt-get install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y -qq >> PHP.log
		echo -e "\nLes paquets ont été installés, le fichier PHP.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
		echo -e "\nLe redémarrage du serveur Apche2 est nécessaire, voulez-vous procéder [y/n] ?"
		read q
		if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
			sudo systemctl restart apache2
		else
			echo -e "\nPensez à redémarrer le serveur afin de ne pas avoir d'erreur de version PHP \n lorsque vous terminerez la configuration de la solution."
			echo -e "\n En passant la commande suivante: sudo systemctl restart apache2"
			sleep 2
		fi
	else
		echo "La solution ne peut fonctionner sans l'installation des dépendances !"
		sleep 2
	fi
fi

}


# Installation / Activation du service / Démarrage Serveur MySQL
################################################################
function InstallMariaDB(){

#Variables
############
MARIADB_STATUS="$(sudo systemctl is-active mariadb)"
MARIADB_SERVICE="$(sudo systemctl is-enabled mariadb.service)"
MYSQL_STATUS="$(sudo systemctl is-active mysqld.service)"
MYSQL_SERVICE="$(sudo systemctl is-enabled mysqld.service)"
FLAG_ACTIVE="active"
FLAG_ENABLED="enabled"
VERSION="$(sudo mariadb --version| awk '{print $2,$3}' || sudo mysqld --version | cut -d "-" -f1-2)"

clear

echo -e "\nMise en place du serveur de bases de données\n"
sleep 5
# Determine si le service Mariadb est installé et s'il fonctionne, si le service est actif au démarrage
if [[ "$(dpkg --get-selections | grep mariadb | grep -v "mariadb-")" =~ "install" ]]; then
	echo -e "\nMariaDB est installé, la version est $VERSION"
	echo -e "\nVoici les information sur le processus"
	sudo pgrep -lf "mariadb" | head -1 | awk '{print $_}'
	sleep 1
	echo -e "\nInformation complémentaires (nécessite l'installation préalable  de l'outil net-tools):"
	sudo netstat -anp mysqld || sudo netstat -anp mariadb
	sleep 3
	# Determine si le serveur de base de données est fonctionnel.
	if [ "${MARIADB_STATUS}" == "${FLAG_ACTIVE}" ]; then
		echo -e "\nMariaDB est démarré"
	else
		echo -e "\nMariaDB n'est pas démarré"
		echo -e "\nVoulez-vous démarrer MariaDB [y/n] ? "
		read activeMariadb
		if [ "${activeMariadb}" == "yes" ] || [ "${activeMariadb}" == "y" ]; then
			sudo systemctl start mariadb
			sleep 2
		fi
	fi
	# Determine si le service est actif au démarrage.
	if [ "${MARIADB_SERVICE}" == "${FLAG_ENABLED}" ]; then
		echo -e "\nLe service MariaDB est activé"
	else
		echo -e "\nLe service MariaDB n'est pas activé"
		echo -e "\nVoulez-vous activer le service MariaDB [y/n] ?"
		read enableMariaDB
		if [ "${enableMariaDB}" == "yes" ] || [ "${enableMariaDB}" == "y" ]; then
			sudo systemctl enable mariadb
			sleep 2
		fi
	fi
elif [[ "$(dpkg --get-selections | grep mysqld)" =~ "install" ]]; then
        echo -e "\nMySQL est installé"
        # Determine si le serveur de base de données est fonctionnel.
        if [ ! "${MYSQL_STATUS}" = "${FLAG_ACTIVE}" ]; then
			echo -e "\nMySQL est démarré"
        else
            echo -e "\nMySQL n'est pas démarré"
            echo -e "\nVoulez-vous démarrer MySQL [y/n] ? "
            read activeMySQL
            if [ "${activeMySQL}" == "yes" ] || [ "${activeMySQL}" == "y" ]; then
				sudo systemctl start mysqld
				sleep 2
            fi
        fi
        # Determine si le service est actif au démarrage.
        if [ "${MySQL_SERVICE}" == "${FLAG_ENABLED}" ]; then
			echo -e "\nLe service MySQL est activé"
			sleep 2
        else
			echo -e "\nLe service MySQL n'est pas activé"
            echo -e "\nVoulez-vous activer le service MySQL [y/n] ?"
            read enableMySQL
            if [ "${enableMySQL}" == "yes" ] || [ "${enableMySQL}" == "y" ]; then
			sudo systemctl enable mysqld.service
			sleep 2
            fi
        fi
		# Creation de la base de donnée (pour la solution)
		###################################################
		database # Appel de la fonction database
else
	echo -e "\nAucune serveur de base de données n'est installé"
	echo -e "\nUn serveur de base de données est requis, souhaitez-vous procéder [y/n] ?"
	read InstallDBserver
	if [ "${InstallDBserver}" == "yes" ] || [ "${InstallDBserver}" == "y" ]; then
		echo -e "\nMySQL n'est plus supporté, MariaDB sera donc installé"
		sleep 2
		sudo apt-get install mariadb-server -y -qq >> MariaDB.log
		echo -e "Un fichier MariaDB.log a été créé, il se trouve dans le répertoire courant."
		echo -e "\nDémarrage du service"
		sudo systemctl start mariadb
		echo -e "\nActivation du service"
		sudo systemctl enable mariadb
		echo -e "\nMariaDB est à présent installé et démarré, la version est $VERSION"
		echo -e "\nVoici les information sur le processus"
		sudo pgrep -lf "mariadb" | head -1 | awk '{print $_}'
		sleep 2
		echo -e "\nInformation complémentaires (nécessite l'installation préalable  de l'outil net-tools):"
		sudo netstat -anp mysqld || sudo netstat -anp mariadb
		sleep 2
	fi
	# Creation de la base de donnée (pour la solution)
	##################################################
	database # Appel de la fonction database
fi

}


# Téléchargement de l'archive de la solution
############################################
function DownloadOwncloud(){

#Variables
#############
file="owncloud-complete-latest.tar.bz2"

clear

echo -e "Téléchargement de l'archive de la solution\n"
sleep 2
cd /tmp/
# check si l'archive tar de la solution existe dans /tmp/
if [ -f "$file" ]; then
	echo -e "\nL'archive $file est déja présente dans le répertoire courant et sera utilisé"
else
	echo -e "\nTéléchargement en cours de l'archive depuis le dépot officiel https://download.owncloud.org "
	sudo wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-latest.tar.bz2
	echo "La ressource à été téléchargé, elle est prête a être traité"
	sleep 2
fi

}


# Collecte d'informations pour création du répertoire de la solution et Virtual host
#####################################################################################
function InformationsWeb(){

sleep 5
clear
echo -e "\nReccueil des informations pour l' installation/configuration\n"
echo -e "\n\tCollecte d'informations répertoires: \n\tcomptes/nom du site pour la configuration VirtualHost...\n"
echo "##########################################"
echo "#         !!! AVERSTISSEMENT !!!         #"
echo "##########################################"
echo ""
echo -e" \nSi vous souhaitez mettre en place un site HTTPS, \nimportez au préalable le(s) certificat(s)/clé privé"
echo -e "\nRenseignez-vous pour l'obtention d'un \ncertificat/clé et leurs installations sur le serveur.\n"
sleep 5
echo -e "\nVous allez à présent renseigner l'alias du site,"
echo -e "\nil permet d'interroger le site via l'Alias (uniquement dans un réseau local), \nsans pour autant faire succéder le nom de domaine mais également,"
echo -e" exemple http://owncloud\n"
echo -e "\nPour plus de clarté (multiples configuration) ajoutez _SSL au nom du serveur souhaité pour les site en HTTPS\n"
sleep 5
clear
echo -e "\nEntrez le nom du serveur/alias souhaité (sans le www) : "
read srv_name
echo -e "\nVous allez à présent renseigner votre CNAME \n(e.g: www. ou exemple.com) :"
read cname
echo -e "\nRenseigner à présent le chemin du répertoire d'installation de la solution.\n"
echo "Celui-ci peut être dans /var/www/$srv_name ou /var/www/html/$srv_name"
echo "Renseignez le chemin complet : "
read dir
echo -e "\nRenseignez l'adresse de contact de l'administrateur de la solution (e.g: admin@outlook.com) : "
read mailto
echo -e "\nRenseignez à présent le port d'écoute du service Apache2, \n(e.g: 80 par defaut, 443 sécurisé) : "
read port 
echo -e "\nEntrer l'adresse  d'écoute du serveur web, \n(e.g. : * or listen, or local IP, IP loopback) : "
read listen
echo -e "\nRenseignez l'emplacement et nom du certificat, \nexemple: /etc/ssl/certs/_.exemple.com_ssl_certificate.pem (ou .cert) | (laissez vide pour du HTTP) :"
read PATH_CERT
echo -e "\nRenseignez l'emplacement et nom de la clé privé, \nexemple: /etc/ssl/private/exemple.com_private_key.key | (laissez vide pour du HTTP) :"
read PATH_PRIVATE_KEY
echo -e "\nRenseignez l'emplacement du certificat intermédiaire, \n(certificate chain file) | (laissez vide pour du HTTP) :"
read PATH_CERTIFICATE_CHAIN

}


# Création du répertoire de la solution ownCloud
################################################
function MkdirDownlodUnzipOwncloud(){

echo "Création du répertoire, installation de la solution, mise en place de la  configuration"
sleep 5

# Cherche si le répertoire et existant ou vide
if [ -d "$dir" ]
then
	if [ "$(ls -a $dir)" ]; then
		echo -e "\n$dir n'est pas vide"
		echo -e "\nVoulez vous supprimer le contenu et décompresser l'archive dans le répertoire $dir [y/n] ?"
		read DelInstall
		if [ "${DelInstall}" == "yes" ] || [ "${DelInstall}" == "y" ]; then
			sudo rm -r $dir/*
			sudo tar xvf owncloud-complete-latest.tar.bz2 --strip-components=1 -C $dir
			echo -e"\nTâche effectué"
			sudo ls $dir
		fi
	else
		echo -e "\n$dir existe cependant il est vide et peut donc être utilisé"
		echo -e "\nVoulez vous décompresser l'archive dans le répertoire $dir [y/n] ?"
		read Install
		if [ "${Install}" == "yes" ] || [ "${Install}" == "y" ]; then
			sudo tar xvf owncloud-complete-latest.tar.bz2 --strip-components=1 -C $dir
			echo -e "\nTâche effectué"
			sudo ls $dir
		else
			echo -e "\nLe dossier $dir est resté dans son état d'origine et devra donc être utilisé"
		fi
	fi
else
	echo -e "\nLe répertoire $dir n'existe pas."
	echo -e "\nVoulez vous créer le répertoire $dir [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo mkdir $dir
		echo -e "\nLe répertoire a été créé"
		sudo ls $dir
		echo -e "\nVoulez vous décompresser l'archive dans le répertoire $dir [y/n] ?"
		read Install
		if [ "${Install}" == "yes" ] || [ "${Install}" == "y" ]; then
			sudo tar xvf owncloud-complete-latest.tar.bz2 --strip-components=1 -C $dir
			echo -e "\nTâche effectué"
			sudo ls $dir
		fi
	fi
fi

}


# Nettoyage des répertoire utilisés durant l'execution du script
################################################################
function CleanDownload(){

echo "Voulez-vous nettoyez les éléments téléchargés [y/n] ?"
read Clean
if [ "${Clean}" == "yes" ] || [ "${Clean}" == "y" ]; then
	rm -R /tmp/owncloud-complete-latest.tar.bz2
	sudo ls /tmp/
fi

}


# Sécurisation du répertoire et des fichiers de configuration
#############################################################
function SecureDirOwnCloud(){

# Variables
htuser='www-data'
htgroup='www-data'
rootuser='root'

clear


echo -e "Sécurisation du répertoire et des fichiers de configuration\n"
echo -e "Modification des droits d'accès sur le répertoire\n"
find ${dir}/ -type f -print0 | xargs -0 chmod 0640
find ${dir}/ -type d -print0 | xargs -0 chmod 0750
echo -e "\nModification des droits utilisateurs/groupes/propriétaire des répertoires et sous répertoire\n"
chown -R ${rootuser}:${htgroup} ${dir}/
chown -R ${htuser}:${htgroup} ${dir}/apps/
#chown -R ${htuser}:${htgroup} ${dir}/assets/
chown -R ${htuser}:${htgroup} ${dir}/config/
chown -R ${htuser}:${htgroup} ${dir}/core/
chown -R ${htuser}:${htgroup} ${dir}/lib/
chown -R ${htuser}:${htgroup} ${dir}/ocs/
chown -R ${htuser}:${htgroup} ${dir}/ocs-provider/
chown -R ${htuser}:${htgroup} ${dir}/resources/
chown -R ${htuser}:${htgroup} ${dir}/settings/
#chown -R ${htuser}:${htgroup} ${dir}/data/
#chown -R ${htuser}:${htgroup} ${dir}/themes/
chown -R ${htuser}:${htgroup} ${dir}/updater/
#chmod +x ${dir}/occ
sleep 0.5
echo -e "\nmodification des droits sur le fichier .htaccess s'il existe \nCelui-ci permet de renforcer la configuration du serveur web\n"
if [ -f ${dir}/.htaccess ]; then
  chmod 0644 ${dir}/.htaccess
  chown ${rootuser}:${htgroup} ${dir}/.htaccess
fi
if [ -f ${dir}/data/.htaccess ]; then
  chmod 0644 ${dir}/data/.htaccess
  chown ${rootuser}:${htgroup} ${dir}/data/.htaccess
fi

}


# Création configuration VirtualHost HTTP
#############################################################
function BuildConfigVHost(){

echo -e "\nSouhaitez-vous créer un site HTTP (80) non sécurisé [y/n] ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	HTTP;
elif
	# Création configuration VirtualHost HTTPS
	echo -e "\nSouhaitez-vous créer un site HTTPS (443) non sécurisé [y/n] ?"; then
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		HTTPS;
	fi
else
	echo -e "\nVous venez d'annuler l'action en cours, l'édition du fichier de configuration n'a pu être faite. \nDe ce fait la solution n'est pas entièrement paramétré, \nveuillez éditer un fichier de configuration HTTP ou HTTPS manuellement. \nActiver les modules Apache nécessaire dans le cas d'une configuration HTTPS. \nPensez à relancer le service Apache2 par la suite."
	echo -e "\nretour au menu principal"
		show_menu
fi

}


# Création de la configuration du virtual host en http
#############################################################
function HTTP(){
echo -e "\nVérification de la présence d'une configuration antérieure"
if [ -f /etc/apache2/available/$srv_name.conf ]; then
	echo -e "\nUn fichier de configuration avec ce nom existe déjà"
	echo -e "\nVoulez vous la conserver [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	
		# Sauvegarde de l'ancienne configuration HTTP et édition de la nouvelle
		
		sudo mv /etc/apache2/site-available/$srv_name.conf /etc/apache2/site-available/$srv_name.conf.old
		echo "Renommage de l'ancienne configuration (ajout .old)"
		echo "La configuration a été renommé !"S
		ls /etc/apache2/site-available/
		echo "Désactivation de l'ancienne configuration"
		/usr/sbin/a2dissite $srv_name.conf
		/usr/sbin/a2dissite 000-default.conf
		echo "Redémarrage du service Apache2"
		systemctl restart apache2
		clear
		echo "Pour restaurer les paramêtres antérieur,"
		echo -e "\neffectuez les commandes :"
		echo "(sudo) /usr/sbin/a2dissite $srv_name.conf"
		echo "(sudo)rm /etc/apache2/site-available/$srv_name.conf"
		echo "(sudo) mv /etc/apache2/site-available/$srv_name.conf.old /etc/apache2/site-available/$srv_name.conf"
		echo "(sudo) systemctl restart apache2"
		sleep 3
		echo -e "\nCréation de la nouvelle configuration"
		
		# Édition du VirtualHost en HTTP
		
		echo "#### $srv_name.

		<VirtualHost $listen:$port>
		ServerAdmin $mailto
		ServerName $srv_name
		ServerAlias $srv_name.$cname
		DocumentRoot $dir
		DirectoryIndex index.php
		LogLevel warn
		ErrorLog ${APACHE_LOG_DIR}/$srv_name.log
		CustomLog ${APACHE_LOG_DIR}/$srv_name.log combined
		<Directory $dir>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Require all granted
		</Directory>
		</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf
		
		# Test de configuration HTTP, apache
		
		echo -e "Vérification de la configuration en cours...\n"
		sudo apachectl configtest
		echo ""
		/usr/sbin/apache2ctl -t
		echo ""
		/usr/sbin/apache2ctl -S
		echo ""
		echo "activation de la configuration"
		echo ""
		if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
			echo -e "\nLe fichier n'a pas pu être édité!"
		else
			echo -e "\nLe fichier a été créé avec succés !\n"
			echo -e "\nActivation de la configuration"
			/usr/sbin/a2ensite $srv_name.conf
			/usr/sbin/a2enmod rewrite
			/usr/sbin/a2enmod headers
			/usr/sbin/a2enmod env
			/usr/sbin/a2enmod dir
			/usr/sbin/a2enmod mime
			/usr/sbin/a2dissite 000-default.conf
			echo -e "\nLe serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n]?"
			read q
			if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
				systemctl restart apache2
				echo -e "\nLe serveur Cloud est à présent opérationnel !"
			else
				echo "Pensez à redémarrer le service Apache2 sans quoi la configuration ne sera pas prise en compte !"
				echo "commande : systemctl restart apache2"
			fi
		fi
	fi
else
	# Suppression de l'ancienne configuration HTTP et édition
	
	echo -e "\nSuppression de l'ancienne configuration $srv_name.conf"
	sudo rm /etc/apache2/sites-available/$srv_name.conf
	
	echo -e "\nCréation de la nouvelle configuration"
	# Édition du VirtualHost en HTTP
	
	echo "#### $srv_name.

	<VirtualHost $listen:$port>
	ServerAdmin $mailto
	ServerName $srv_name
	ServerAlias $srv_name.$cname
	DocumentRoot $dir
	DirectoryIndex index.php
	LogLevel warn
	ErrorLog ${APACHE_LOG_DIR}/$srv_name.log
	CustomLog ${APACHE_LOG_DIR}/$srv_name.log combined
	<Directory $dir>
	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Require all granted
	</Directory>
	</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf
	
	# Test de configuration HTTP, apache
	echo -e "Vérification de la configuration en cours...\n"
	sudo apachectl configtest
	echo ""
	/usr/sbin/apache2ctl -t
	echo ""
	/usr/sbin/apache2ctl -S
	echo ""
	echo "activation de la configuration"
	echo ""
	if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
		echo -e "\nLe fichier n'a pas pu être édité!"
	else
		echo -e "\nLe fichier a été créé avec succés !\n"
		echo -e "\nActivation de la configuration"
		/usr/sbin/a2ensite $srv_name.conf
		/usr/sbin/a2enmod rewrite
		/usr/sbin/a2enmod headers
		/usr/sbin/a2enmod env
		/usr/sbin/a2enmod dir
		/usr/sbin/a2enmod mime
		/usr/sbin/a2dissite 000-default.conf
		echo -e "\nLe serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n]?"
		read q
		if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
			systemctl restart apache2
			echo -e "\nLe serveur Cloud est à présent opérationnel !"
		else
			echo "Pensez à redémarrer le service Apache2 sans quoi la configuration ne sera pas prise en compte !"
			echo "commande : systemctl restart apache2"
		fi
	fi
fi

}


# Création de la configuration du virtual host en https
#############################################################
function HTTPS(){

echo -e "\nVérification de la présence d'une configuration antérieure"
if [ -f /etc/apache2/available/$srv_name.conf ]; then
	echo -e "\nUn fichier de configuration avec ce nom existe déjà"
	echo -e "\nVoulez vous la conserver [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	
		# Sauvegarde de l'ancienne configuration HTTPS et édition de la nouvelle
		
		sudo mv /etc/apache2/site-available/$srv_name.conf /etc/apache2/site-available/$srv_name.conf.old
		echo "Renommage de l'ancienne configuration (ajout .old)"
		echo "La configuration a été renommé !"
		ls /etc/apache2/site-available/
		echo "Désactivation de l'ancienne configuration"
		/usr/sbin/a2dissite default-ssl.conf
		/usr/sbin/a2dissite $srv_name.conf
		/usr/sbin/a2dissite 000-default.conf
		echo "Redémarrage du service Apache2"
		systemctl restart apache2
		clear
		echo "Pour restaurer les paramêtres antérieur,"
		echo -e "\neffectuez les commandes :"
		echo "(sudo) /usr/sbin/a2dissite $srv_name.conf"
		echo "(sudo)rm /etc/apache2/site-available/$srv_name.conf"
		echo "(sudo) mv /etc/apache2/site-available/$srv_name.conf.old /etc/apache2/site-available/$srv_name.conf"
		echo "(sudo) systemctl restart apache2"
		sleep 3
		
		# Édition du VirtualHost en HTTP
		
		echo -e "\nCréation de la nouvelle configuration"
		

		echo "#### $srv_name.       
		
		<VirtualHost $listen:$port>

		ServerAdmin $mailto
		ServerName $srv_name
		ServerAlias $srv_name.$cname

		DocumentRoot $dir

		<Directory $dir>

		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all

		</Directory>

		SSLEngine on
		SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
		SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
		SSLHonorCipherOrder On

		SSLCertificateFile $PATH_CERT
		SSLCertificateKeyFile $PATH_PRIVATE_KEY
		SSLCertificateChainFile $PATH_CERTIFICATE_CHAIN

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		</VirtualHost>
					
		<VirtualHost *:80>

		ServerAdmin $mailto
		ServerName $srv_name
		ServerAlias $srv_name.$cname

		DocumentRoot $dir

		<Directory $dir>

		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all

		</Directory>

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined
		
		</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf
		
		# Test de configuration HTTPS, apache
		
		echo -e "Vérification de la configuration en cours...\n"
		sudo apachectl configtest
		echo ""
		/usr/sbin/apache2ctl -t
		echo ""
		/usr/sbin/apache2ctl -S
		echo ""
		echo "activation de la configuration"
		echo ""
		if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
			echo -e "\nLe fichier n'a pas pu être édité!"
		else
			echo -e "\nLe fichier a été créé avec succés !\n"
			echo -e "\nActivation de la configuration"
			/usr/sbin/a2ensite $srv_name.conf
			/usr/sbin/a2enmod rewrite
			/usr/sbin/a2enmod headers
			/usr/sbin/a2enmod env
			/usr/sbin/a2enmod dir
			/usr/sbin/a2enmod mime
			/usr/sbin/a2dissite default-ssl.conf
			echo -e "\nLe serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n]?"
			read q
			if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
				systemctl restart apache2
				echo -e "\nLe serveur Cloud est à présent opérationnel !"
			else
				echo "Pensez à redémarrer le service Apache2 sans quoi la configuration ne sera pas prise en compte !"
				echo "commande : systemctl restart apache2"
			fi
		fi
	fi
else
	# Suppression de l'ancienne configuration HTTPS et édition
	
	echo -e "\nSuppression de l'ancienne configuration $srv_name.conf"
	sudo rm /etc/apache2/sites-available/$srv_name.conf
	
	# Édition du VirtualHost en HTTP
	
	echo -e "\nCréation de la nouvelle configuration"
	
	echo "#### $srv_name.       
	
	<VirtualHost $listen:$port>

	ServerAdmin $mailto
	ServerName $srv_name
	ServerAlias $srv_name.$cname

	DocumentRoot $dir

	<Directory $dir>

	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Order allow,deny
	allow from all

	</Directory>

	SSLEngine on
	SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
	SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
	SSLHonorCipherOrder On

	SSLCertificateFile $PATH_CERT
	SSLCertificateKeyFile $PATH_PRIVATE_KEY
	SSLCertificateChainFile $PATH_CERTIFICATE_CHAIN

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

	</VirtualHost>
				
	<VirtualHost *:80>

	ServerAdmin $mailto
	ServerName $srv_name
	ServerAlias $srv_name.$cname

	DocumentRoot $dir

	<Directory $dir>

	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Order allow,deny
	allow from all

	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
	
	</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf
	
	# Test de configuration HTTPS, apache
	echo -e "Vérification de la configuration en cours...\n"
	sudo apachectl configtest
	echo ""
	/usr/sbin/apache2ctl -t
	echo ""
	/usr/sbin/apache2ctl -S
	echo ""
	echo "activation de la configuration"
	echo ""
	if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
		echo -e "\nLe fichier n'a pas pu être édité!"
	else
		echo -e "\nLe fichier a été créé avec succés !\n"
		echo -e "\nActivation de la configuration"
		/usr/sbin/a2ensite $srv_name.conf
		/usr/sbin/a2enmod rewrite
		/usr/sbin/a2enmod headers
		/usr/sbin/a2enmod env
		/usr/sbin/a2enmod dir
		/usr/sbin/a2enmod mime
		/usr/sbin/a2enmod ssl
		/usr/sbin/a2dissite default-ssl.conf
		echo -e "\nLe serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n]?"
		read q
		if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
			systemctl restart apache2
			echo -e "\nLe serveur Cloud est à présent opérationnel !"
		else
			echo "Pensez à redémarrer le service Apache2 sans quoi la configuration ne sera pas prise en compte !"
			echo "commande : systemctl restart apache2"
		fi
	fi
fi

}


# ownCloud Install / Mkdir / Make / Download / Secure / Rules
####################################################
function owncloud(){

echo -e "Installation de la solution ownCloud\n"
managehostfile
sleep 2
clear
Install_Apache2
sleep 2
clear
Firewall_rules
sleep2
clear
Install_PHP
sleep 2
clear
InstallMariaDB
sleep 2
clear
DownloadOwncloud
sleep 2
clear
InformationsWeb
sleep 2
clear
MkdirDownlodUnzipOwncloud
sleep 2
clear
CleanDownload
sleep 2
clear
SecureDirOwnCloud
sleep 2
clear
InformationsWeb
sleep 2
clear
BuildConfigVHost
sleep 2
clear
show_browser
sleep 2
show_menu

}


# Add/change IP local / hostname/ domain name --> /etc/host
############################################################
function managehostfile(){.

echo "Modification du nom du serveur"
sleep 5
#Variables
############
PATH="/etc/hosts"
matches_in_hosts="$(grep -n $srv_name /etc/hosts | cut -f1 -d:)"
clear


echo "Sauvegarde de la configuration initiale en host.bak"
cp /etc/hosts /etc/hosts.bak

echo "Veuillez renseigner l'adresse IP statique defini sur ce serveur (sans le CIDR) : "
read IP
echo "Veuillez renseigner le nom de la machine (e.g : ownCloud) : "
srv_name
host_enty="${IP} ${srv_name}.${cname}"
if [ ! -z "$matches_in_hosts" ]
then
    echo "Updating existing hosts entry."
    # recherche l'occurence IP et  nom de machine.nom_de_domaine '
    while read -r line_number; do
        # Modification de la ligne par le nom de machine et domaine
        sudo sed -i '' "${line_number}s/.*/${host_entry} /" /etc/hosts
    done <<< "$matches_in_hosts"
else
    echo -e "La modification est effective, cependant un redémarrage de la machine peut être nécessaire"
    echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
fi
}

# fonction ouverture du navigateur
###################################
function show_browser(){
# Ne fonctionne pas sans environnement graphique

echo -e "\nSi vous disposez d'une interface graphique il est possible de procéder à la configuration du serveur cloud"

echo -e "\n Souhaitez-vous accéder à l'interface de configuration finale [y/n]?"
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
	echo -e "\nLe navigateur va a présent s'ouvrir."
	echo -e "\nRenseignez le nom d'utilisateur administrateur; "
	echo -e "\n Renseignez le mot de passe associé; "
	echo -e "\n Renseignez le chemin d'installation (e.g: /var/www/owncloud) "
	echo -e "\n Renseignez le nom d'administrateur de la base de données"
	echo -e "\n Renseignez le mot de passe associé; "
	echo -e "\n Renseignez la nom de la base de donnée précédemment configuré"
	echo -e "\n Laissez par defaut localhost"

	sleep 5
	xdg-open http://127.0.0.1
	sleep 5
else
	echo "Veuillez vous rendre sur la page http://${srv_name}.${cname}"
	sleep 1
	echo -e "\nRenseignez le nom d'utilisateur administrateur; "
	echo -e "\n Renseignez le mot de passe associé; "
	echo -e "\n Renseignez le chemin d'installation (e.g: /var/www/owncloud) "
	echo -e "\n Renseignez le nom d'administrateur de la base de données"
	echo -e "\n Renseignez le mot de passe associé; "
	echo -e "\n Renseignez la nom de la base de donnée précédemment configuré"
	echo -e "\n Laissez par defaut localhost"
	sleep 5
fi
}

# fonction menu
####################################
function show_menu(){

# Variables
############
mytitle="Installation d'une solution cloud privé"

title=`echo "\033[35m"` #Purple
normal=`echo "\033[m"`
menu=`echo "\033[36m"` #Cyan
number=`echo "\033[33m"` #Yellow
validation=`echo "\033[32m"` #Green
bgred=`echo "\033[41m"`
fgred=`echo "\033[31m"`

# Optionnal colors
# `echo "\033[37m"` white
# `echo "\033[30m"` Black

mytitle="Installation d'une solution cloud"
echo -e "${title} ##################################### ${normal}\n"
echo -e "${title} # ${mytitle} #${normal}\n"
echo -e "${title} ##################################### ${normal}\n\v"

echo -e "\n${menu}*********************************************${normal}\n"
echo -e "${menu}**${number} 1)${menu} Mise à jour du systeme et des logiciels (Recommandé) ${normal}\n"
echo -e "${menu}**${number} 2)${menu} Installation des outils (optionnels) ${normal}\n"
echo -e "${menu}**${number} 3)${menu} Installation de ownCloud ${normal}\n"
echo -e "${menu}**${number} 4)${menu} Installation de Nextcloud ${normal}\n"
echo -e "${menu}*********************************************${normal}\n"
echo -e "Sélectionnez une option pressez ${fgred}x pour quitter. ${normal}"
read opt
}

function option_picked(){
msgcolor=`echo "\033[01;31m"` # bold red
normal=`echo "\033[00;00m"` # normal white
message=${@:-"${normal}Error: No message passed"}
echo -e "${msgcolor}${message}${normal}\n"
}

clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
	1) clear;
            option_picked "Mise à jour du systeme et des logiciels";
            update | tee -a tools.log; #appel de la function
            show_menu;
	;;
        2) clear;
            option_picked "Tools";
            tools; #appel de la function
            show_menu;
        ;;
        3) clear;
            option_picked "ownCloud";
            owncloud; #appel de la function
            show_menu;
        ;;
        4) clear;
            option_picked "Nextcloud";
            nextcloud; #appel de la function
            show_menu;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Sélectionnez une option dans le menu";
            show_menu;
        ;;
      esac
    fi
done

exit 0

