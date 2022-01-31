#!/bin/bash

# Reprise du Projet d'installation d'une solution cloud ownCloud
# Test� sur Debian 11
# En cours d'�laboration

#
#Code permettant la mise en place d'une solution, test du script pas � pas
#

file="owncloud-complete-20220112.tar.bz2"

cd /tmp/
# check si l'archive de la solution existe dans /tmp/
if [ -f /root/tmp/$file ]; then
	echo "L'archive existe d�ja et va �tre d�compr�ss� dans ${dir}"
else
	echo "T�l�chargement de l'archive depuis le d�pot officiel https://download.owncloud.org "
	wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-20211220.tar.bz2
fi

echo "Entrez le nom du serveur souhait� (sans le www) : "
read srv_name

# Teste si le r�pertoire existe
echo "Renseignez le chemin du r�pertoire d'installation de la solution :"
echo "Celui-ci peut dans /var/www/$srv_name ou /var/www/html/$srv_name"
read dir
if [ - d "dir" ]; then
	echo "Le r�pertoire $dir existe d�j�"
	ls > [ -s $dir ]
	if [ -s $dir ]; then
		echo "Le r�pertoire n'est pas vide"
		echo "Voulez vous supprimer le contenu et d�compresser l'archive dans le r�pertoire $dir ?"
		read DelInstall
		if [ "${DelInstall}" == "yes" ] || [ "${DelInstall}" == "y" ]; then
			sudo rm -r $dir/*
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
		elif 
			echo "est vide, voulez-vous d�compresser l'archive dans le r�pertoire $dir ?"
			read Install
			if [ "${Install}" == "yes" ] || [ "${Install}" == "y" ]; then
			sudo tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
		else 
			echo "Vous avez choisi d'utiliser le r�pertoire existant"
		fi
	fi
fi

# Nettoyage des r�pertoire utilis�s durant l'execution du script
echo "Nettoyage des fichiers t�l�charg�s"
rm -R /tmp/owncloud-complete-*
ls /tmp/