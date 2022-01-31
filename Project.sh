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
START_SCRIPT_DEBUG="true"
FLAG_ACTIVE="active"
FLAG_ENABLED="enabled"
#
file="owncloud-complete-20220112.tar.bz2"

######################################
# Vérification des droits d'execution
######################################
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

######################################
# Mise à jour systeme et packets
######################################
echo "Mise à jour du systeme et des packets"
sudo apt update && apt upgrade -y -q
echo ""
echo "Installation d'outils"
sudo apt install net-tools -y -q
sudo apt install locate -y -q
sudo updatedb
echo ""
echo "On passe dans l'install d'Apache2"
# Determine si le service apache est installé et s'il fonctionne, si le service est actif au démarrage
if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]
then
		echo "Apache2 est installé"
		# Determine si le seveur web est fonctionnel.
		if [ "${APACHE2_STATUS}" = "${FLAG_STATUS}" ]; then
			echo "Apache2 est démarré"
		else
			echo "Apache 2 n'est pas démarré"
			echo "Voulez-vous démarrer Apache2 [y/n] ? "
			read activeApache2
			if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ]; then
				sudo systemctl start apache2
			fi
		fi
		# Determine si le service est actif au démarrage.
		if [ "${APACHE2_SERVICE}" == "enabled" ] 
		then
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
	if [ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ];
	then
		sudo apt install apache2 -y -q
		sudo systemctl start apache2
		sudo systemctl enable apache2
	fi
fi
echo ""
echo "On vérifie si tar existe dans le répertoire courant et on créé le répertoire dans /var/www"
echo ""
cd /tmp/
# check si l'archive tar de la solution existe dans /tmp/
if [ -f /tmp/$file ]; then
	echo "L'archive existe déja et pourra être décompréssé dans ${dir}"
else
	echo "Téléchargement de l'archive depuis le dépot officiel https://download.owncloud.org "
	wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-20211220.tar.bz2
fi

echo "Entrez le nom du serveur souhaité (sans le www) : "
read srv_name

# Teste si le répertoire existe
echo "Renseignez le chemin du répertoire d'installation de la solution :"
echo "Celui-ci peut être dans /var/www/$srv_name ou /var/www/html/$srv_name"
read dir
# Cherche si le répertoire et existant ou vide
if [ -d "$dir" ]
then
	if [ "$(ls -A $dir)" ]; then
		echo "$dir n'est pas vide"
		echo "Voulez vous supprimer le contenu et décompresser l'archive dans le répertoire $dir ?"
		read DelInstall
		if [ "${DelInstall}" == "yes" ] || [ "${DelInstall}" == "y" ]; then
			sudo rm -r $dir/*
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
			echo "Tâche effectué"
			sudo ls $dir
		fi
	else
		echo "$dir existe cependant il est vide et peut donc être utilisé"
		echo "Voulez vous décompresser l'archive dans le répertoire $dir ?"
		read Install
		if [ "${Install}" == "yes" ] || [ "${Install}" == "y" ]; then
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
			echo "Tâche effectué"
			sudo ls $dir
		fi
	fi
else
	echo "Le répertoire $dir n'existe pas."
	echo "Voulez vous créer le répertoire $dir ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo mkdir $dir
		echo "Le répertoire a été créé"
		sudo ls $dir
	fi
fi

# Nettoyage des répertoire utilisés durant l'execution du script
echo "Voulez-vous nettoyez le fichier téléchargés ?"
read Clean
if [ "${Clean}" == "yes" ] || [ "${Clean}" == "y" ]; then
rm -R /tmp/owncloud-complete-*
sudo ls /tmp/

return $?
exit 0
