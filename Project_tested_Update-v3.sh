#!/bin/bash
#
# Reprise du Projet d'installation d'une solution cloud ownCloud
# Testé sur Debian 11
# En cours d'élaboration
#
#
#Code permettant la mise en place d'une solution, test du script pas à pas
#
##########################################################################
######################################
# Vérification des droits d'execution
######################################
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

#########################
# Variables
#########################
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

######################################
# Mise à jour systeme et packets
######################################
function update(){
echo "Souhaitez-vous procéder à la mise à jour du systeme et des packets [y/n] ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	echo -e "La mise à jour va débuter \n"
	sudo apt-get update && apt-get upgrade -y -qq >> update.log
	echo -e "\nMise à jour terminé, un fichier de log nommé update.log se trouve dans le répertoire courant.\n"
fi

sleep 2
clear
}

#####################################
# fonction Tools
#####################################
function tools(){

#Réseau
tools1="net-tools"
tools2="dnsutils"
tools3="ifupdown2"

#Indexation/Recherche
tools4="locate"
tools5="tree"

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
sleep 3
clear
}

########################
# fonctions
########################
function database(){
echo "Collecte d'informations en vue de la création de la base de données de la solution\t"

echo "\n! Les mots de passes ne s'afficheront pas !"
echo "\nVérifiez au préalable que votre verrouillage numérique soit fonctionnel (cas de VM)"

echo -e "\nVeuillez confirmer le nom d'utilisateur Root (en minuscule)"
read root_name
#Hidden password
echo "Renseignez le mot de passe associé au compte Root"
stty -echo
read root_passwd
stty echo
echo "Entrez le nom de l'utilisateur qui sera amené à administrer la solution (autre que Root, question de sécurité)"
read user_name
echo "Entrez le mot de passe associé au compte d'administration de la solution"
stty -echo
read user_passwd
stty echo
echo "Entrez le nom souhaité pour la base de donnée (e.g: ownclouddb)"
read database_name
echo "Ajout de l'utilisateur $user_name au groupe d'administration du serveur Web"
id -u $user_name &>/dev/null || useradd $user_name
/usr/sbin/adduser www-data $user_name

echo -e "Création de la base de donnée $database_name"
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
echo "Opération effectué"

SHOW DATABASES;
SELECT user FROM mysql.user; 


mysql --batch --skip-column-names -e "SHOW DATABASES LIKE '$database_name'" | grep $database_name
}

function owncloud(){

echo -e "Installation de la solution ownCloud\n"
echo ""
echo "\nMise en place du serveur Web"
echo ""
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
		sudo apt-get install apache2 -y
		sudo systemctl start apache2
		sudo systemctl enable apache2
	fi
fi

#Installation de PHP
# Variables
sleep 5
clear
echo "Installation de PHP"
echo ""
sleep 5
REQUIRED="7.4"
MAJOR_CURRENTVERS="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d "." | cut -d '.' -f1)"
MINOR_CURRENTVERS="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d "." | cut -d '.' -f2)"
CURRENT_VERSION= "$MAJOR_CURRENTVERS"."$MINOR_CURRENTVERS"
MAJOR_REQ="$(echo "$REQUIRED" | cut -d " " -f 2 | cut -f1-2 -d"." | cut -d '.' -f1)"
MINOR_REQ="$(echo "$REQUIRED" | cut -d " " -f 2 | cut -f1-2 -d"." | cut -d '.' -f2)"
AVAILABLE="$(apt-cache policy php | cut -d " " -f6 | cut -f2-3 -d ":" | grep "." | cut -f1 -d "+" )"

# Vérification de la présence de PHP sur la distribution
if [[  "$(dpkg --get-selections | grep "php")" =~ "install" ]]; then
	echo -e "\nPHP est déjà présent sur votre distribution, la version est $CURRENT_VERSION"
	
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
			echo -e "\nInstallation des dépendances requises pour la mise en place de la solution\t"
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
					sudo apt-get install php$vers -y -q >> PHP.log
					echo -e "\nLe paquet a été installé, le fichier PHP.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
					# Installation des dépendances PHP nécessaire à la solution
					echo -e "\nInstallation des dépendances requises pour la mise en place de la solution\t"
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
						fi
					else
						echo "La solution ne peut fonctionner sans l'installation des dépendances"
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
	echo -e "\nInstallation des dépendances requises pour la mise en place de la solution\t"
	echo -e "\nCertaines dépendances PHP sont nécessaires, souhaitez-vous les installer [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		apt install php libapache2-mod-php php-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ldap} -y
		apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y
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
fi


sleep 5
clear
echo "Mise en place du serveur de bas de base de données"
echo ""
sleep 5
# Determine si le service Mariadb est installé et s'il fonctionne, si le service est actif au démarrage
if [[ "$(dpkg --get-selections | grep mariadb | grep -v "mariadb-")" =~ "install" ]]; then
	echo "MariaDB est installé"
	# Determine si le serveur de base de données est fonctionnel.
	if [ "${MARIADB_STATUS}" == "${FLAG_ACTIVE}" ]; then
		echo "MariaDB est démarré"
	else
		echo "MariaDB n'est pas démarré"
		echo "Voulez-vous démarrer MariaDB [y/n] ? "
		read activeMariadb
		if [ "${activeMariadb}" == "yes" ] || [ "${activeMariadb}" == "y" ]; then
			sudo systemctl start mariadb
		fi
	fi
	# Determine si le service est actif au démarrage.
	if [ "${MARIADB_SERVICE}" == "${FLAG_ENABLED}" ]; then
		echo "Le service MariaDB est activé"
	else
		echo "Le service MariaDB n'est pas activé"
		echo "Voulez-vous activer le service MariaDB [y/n] ?"
		read enableMariaDB
		if [ "${enableMariaDB}" == "yes" ] || [ "${enableMariaDB}" == "y" ]; then
			sudo systemctl enable mariadb
		fi
	fi
elif [[ "$(dpkg --get-selections | grep mysqld)" =~ "install" ]]; then
        echo "MySQL est installé"
        # Determine si le serveur de base de données est fonctionnel.
        if [ ! "${MYSQL_STATUS}" = "${FLAG_ACTIVE}" ]; then
                echo "MySQL est démarré"
        else
                echo "MySQL n'est pas démarré"
                echo "Voulez-vous démarrer MySQL [y/n] ? "
                read activeMySQL
                if [ "${activeMySQL}" == "yes" ] || [ "${activeMySQL}" == "y" ]; then
                        sudo systemctl start mysqld
                fi
        fi
        # Determine si le service est actif au démarrage.
        if [ "${MySQL_SERVICE}" == "${FLAG_ENABLED}" ]; then
                echo "Le service MySQL est activé"
        else
                echo "Le service MySQL n'est pas activé"
                echo "Voulez-vous activer le service MySQL [y/n] ?"
                read enableMySQL
                if [ "${enableMySQL}" == "yes" ] || [ "${enableMySQL}" == "y" ]; then 
                        sudo systemctl enable mysqld.service
                fi
        fi
		# Création de la base de données
		# Appel de la fonction database
		database
else
	echo "Aucune serveur de base de données n'est installé"
	echo "Un serveur de base de données est requis, souhaitez-vous procéder [y/n] ?"
	read InstallDBserver
	if [ "${InstallDBserver}" == "yes" ] || [ "${InstallDBserver}" == "y" ]; then
		echo "MySQL n'est plus supporté, MariaDB sera donc installé"
		sleep 2
		sudo apt-get install mariadb-server -y
		echo ""
		echo "Démarrage du service"
		sudo systemctl start mariadb
		echo ""
		echo "Activation du service"
		sudo systemctl enable mariadb
	fi
	# Création de la base de données
	# Appel de la fonction database
	database
fi

sleep 5
clear
echo "Création du répertoire de la solution Web"
echo ""
cd /tmp/
# check si l'archive tar de la solution existe dans /tmp/
if [ -f "$file" ]; then
	echo "L'archive $file est déja présente dans le répertoire courant et sera utilisé"
else
	echo "Téléchargement en cours de l'archive depuis le dépot officiel https://download.owncloud.org "
	sudo wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-latest.tar.bz2
fi

sleep 5
clear
echo "Collecte d'informations (répertoires/comptes/nom du site...)"
sleep 5
echo ""
echo ""
echo "Entrez le nom du serveur/alias souhaité (sans le www) : "
read srv_name
echo ""
echo "Renseigner à présent le chemin du répertoire d'installation de la solution :"
echo "Celui-ci peut être dans /var/www/$srv_name ou /var/www/html/$srv_name"
echo "Renseignez le chemin complet : "
read dir

sleep 5
clear
echo "Création du répertoire, installation de la solution, mise en place de la  configuration"
echo ""
sleep 5
# Cherche si le répertoire et existant ou vide
if [ -d "$dir" ]
then
	if [ "$(ls -A $dir)" ]; then
		echo "$dir n'est pas vide"
		echo "Voulez vous supprimer le contenu et décompresser l'archive dans le répertoire $dir [y/n] ?"
		read DelInstall
		if [ "${DelInstall}" == "yes" ] || [ "${DelInstall}" == "y" ]; then
			sudo rm -r $dir/*
			sudo tar xvf owncloud-complete-latest.tar.bz2 --strip-components=1 -C $dir
			echo "Tâche effectué"
			sudo ls $dir
		fi
	else
		echo "$dir existe cependant il est vide et peut donc être utilisé"
		echo "Voulez vous décompresser l'archive dans le répertoire $dir [y/n] ?"
		read Install
		if [ "${Install}" == "yes" ] || [ "${Install}" == "y" ]; then
			sudo tar xvf owncloud-complete-latest.tar.bz2 --strip-components=1 -C $dir
			echo "Tâche effectué"
			sudo ls $dir
		else
			echo "Le dossier $dir est resté dans son état d'origine et devra donc être utilisé"
		fi
	fi
else
	echo "Le répertoire $dir n'existe pas."
	echo "Voulez vous créer le répertoire $dir [y/n] ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo mkdir $dir
		echo "Le répertoire a été créé"
		sudo ls $dir
	fi
fi

# Nettoyage des répertoire utilisés durant l'execution du script
sleep 5
clear
echo "Voulez-vous nettoyez le fichier téléchargés [y/n] ?"
read Clean
if [ "${Clean}" == "yes" ] || [ "${Clean}" == "y" ]; then
	rm -R /tmp/owncloud-complete-latest.tar.bz2
	sudo ls /tmp/
fi
}

#####################################
# fonction menu
####################################
show_menu(){

mytitle="Installation d'une solution cloud"
echo -e "${title} ##################################### ${normal}\n"
echo -e "${title} # ${mytitle} #${normal}\n"
echo -e "${title} ##################################### ${normal}\n\v"

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

echo -e "\n${menu}*********************************************${normal}\n"
echo -e "${menu}**${number} 1)${menu} Mise à jour du systeme et des logiciels (Recommandé) ${normal}\n"
echo -e "${menu}**${number} 2)${menu} Installation des outils (optionnels) ${normal}\n"
echo -e "${menu}**${number} 3)${menu} Installation de ownCloud ${normal}\n"
echo -e "${menu}**${number} 4)${menu} Installation de Nextcloud ${normal}\n"
echo -e "${menu}*********************************************${normal}\n"
echo -e "Sélectionnez une option pressez ${fgred}x pour quitter. ${normal}"
read opt
}

option_picked(){
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

echo "Bye bye !"

exit 0
