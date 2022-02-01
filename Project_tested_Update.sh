#!/bin/bash
#
# Reprise du Projet d'installation d'une solution cloud ownCloud
# Testé sur Debian 11
# En cours d'élaboration
#
#
#Code permettant la mise en place d'une solution, test du script pas à pas
#
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
file="owncloud-complete-20220112.tar.bz2"
mytitle="Installation de la solution cloud privé ownCloud"
clear
######################################
# Vérification des droits d'execution
######################################
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

######################################
# Titre
######################################
mytitle="Installation simplifié d'un cloud privé: Solution ownCloud"
echo -e '\033k'$mytitle'\033\\'
sleep 5
echo ""
######################################
# Mise à jour systeme et packets
######################################
echo "Mise à jour du systeme et des packets"
echo ""
sudo apt update && apt upgrade -y
sleep 5
clear
echo "Installation d'outils réseau"
echo ""
echo "net-tools: qui contient des outils: arp, ifconfig, netstat, rarp, nameif et route"
echo "dnsutils: implémente un serveur de noms de domaines Internet: dig, nslookup, nsupdate"
echo "ifupdown2: permet de configurer les interfaces réseau: iproute2, bridge-utils, ethtool ..."
sleep 5
echo ""
sudo apt install net-tools -y
sudo apt install dnsutils -y
sudo apt install ifupdown2 -y
sleep 5
clear
echo "Installation d'outil dédié à la recherche de fichiers"
echo ""
echo "locate: permet de rechercher un fichier: locate fichier.txt | less | more"
echo "Pensez à passer la commande: updatedb avant la recherche "
sleep 1
echo ""
sudo apt install locate -y
echo ""
sudo updatedb
echo ""
# /usr/bin/find: '/run/user/1000/gvfs': Permission denied --> erreur normale
echo -e "Il ne s'agit pas d'une erreur updatedb s'est terminé avec succés, \nmais n'a pas pu lire cet emplacement voir: \nhttps://dev.getsol.us/T5545"
sleep 5
clear
echo "Installation d'un outil de visualisation de l'arborescence,des répertoire, dossier ..."
echo "visualiser une arborescence avec tree: tree -a  ou -f ou encore -dfp"
sleep 5
echo ""
sudo apt install tree -y
sleep 5
clear
echo "Mise en place du serveur Web"
echo ""
sleep 5
# Determine si le service apache est installé et s'il fonctionne, si le service est actif au démarrage
if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]
then
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
		sudo apt install apache2 -y
		sudo systemctl start apache2
		sudo systemctl enable apache2
	fi

fi

sleep 5
clear
echo "Mise en place du serveur de base de données"
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
else
	echo "Aucune serveur de base de données n'est installé"
	echo "Un serveur de base de données est requis, souhaitez-vous procéder [y/n] ?"
	read InstallDBserver
	if [ "${InstallDBserver}" == "yes" ] || [ "${InstallDBserver}" == "y" ]; then
		echo "MySQL n'est plus supporté, MariaDB sera donc installé"
		sleep 2
		sudo apt install mariadb-server -y
		echo ""
		echo "Démarrage du service"
		sudo systemctl start mariadb
		echo ""
		echo "Activation du service"
		sudo systemctl enable mariadb
	fi
fi

sleep 5
clear
echo "Création du répertoire de la solution Web"
echo ""
cd /tmp/
# check si l'archive tar de la solution existe dans /tmp/
if [ ! -f /tmp/$file ]; then
	echo "L'archive $file est déja présente dans le répertoire courant et sera utilisé"
	sleep 2
else
	echo "Téléchargement en cours de l'archive depuis le dépot officiel https://download.owncloud.org "
	sudo wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-20211220.tar.bz2
	sleep 2
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
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
			echo "Tâche effectué"
			sudo ls $dir
		fi
	else
		echo "$dir existe cependant il est vide et peut donc être utilisé"
		echo "Voulez vous décompresser l'archive dans le répertoire $dir [y/n] ?"
		read Install
		if [ "${Install}" == "yes" ] || [ "${Install}" == "y" ]; then
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
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
	rm -R /tmp/owncloud-complete-*
	sudo ls /tmp/
fi

exit 0
