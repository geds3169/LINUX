#!/bin/bash

# Reprise du Projet d'installation d'une solution cloud ownCloud
# Testé sur Debian 11
# En cours d'élaboration

#
#Code permettant la mise en place d'une solution, test du script pas à pas
#

file="owncloud-complete-20220112.tar.bz2"

cd /tmp/
# check si l'archive de la solution existe dans /tmp/
if [ -f /root/tmp/$file ]; then
	echo "L'archive existe déja et va être décompréssé dans ${dir}"
else
	echo "Téléchargement de l'archive depuis le dépot officiel https://download.owncloud.org "
	wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-20211220.tar.bz2
fi

echo "Entrez le nom du serveur souhaité (sans le www) : "
read srv_name

# Teste si le répertoire existe
echo "Renseignez le chemin du répertoire d'installation de la solution :"
echo "Celui-ci peut dans /var/www/$srv_name ou /var/www/html/$srv_name"
read dir
if [ - d "dir" ]; then
	echo "Le répertoire $dir existe déjà"
	ls > [ -s $dir ]
	if [ -s $dir ]; then
		echo "Le répertoire n'est pas vide"
		echo "Voulez vous supprimer le contenu et décompresser l'archive dans le répertoire $dir ?"
		read DelInstall
		if [ "${DelInstall}" == "yes" ] || [ "${DelInstall}" == "y" ]; then
			sudo rm -r $dir/*
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
		elif 
			echo "est vide, voulez-vous décompresser l'archive dans le répertoire $dir ?"
			read Install
			if [ "${Install}" == "yes" ] || [ "${Install}" == "y" ]; then
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
		else 
			echo "Vous avez choisi d'utiliser le répertoire existant"
		fi
	fi
fi

# Nettoyage des répertoire utilisés durant l'execution du script
echo "Nettoyage des fichiers téléchargés"
rm -R /tmp/owncloud-complete-*
ls /tmp/

exit 0