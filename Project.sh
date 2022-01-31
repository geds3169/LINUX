#!/bin/bash

# Reprise du Projet d'installation d'une solution cloud ownCloud
# Testé sur Debian 11
# En cours d'élaboration

:'
Code permettant la mise en place d'une solution, test du script pas à pas
'


# Teste si le répertoire est vide
echo "Chemin du répertoire :"
read dir
cd $dir
ls > /tmp/test
if [ -s /tmp/test ]
then
echo "n'est pas vide"
echo "Voulez vous supprimer le contenu et décompresser l'archive dans le répertoire $dir ?"
	read Install
	if [ "${Install}" == "yes" ] || [ "${Install" == "y"} ]; then
	sudo rm -r $dir/*
	tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
elif
echo "est vide, voulez-vous décompresser l'archive dans le répertoire $dir ?"
	if [ "${Install}" == "yes" ] || [ "${Install" == "y"} ]; then
	tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
else
echo "Vous avez choisi d'utiliser le répertoire existant"
fi
