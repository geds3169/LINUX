#!/bin/sh

#####################################################################
# Ce script � pour but la mise en place d'un cloud priv� ownCloud
#
# test� sur Debian 11
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
# V�rification des droits d'execution
###################################################################################
# V�rification des permissions d'execution du script
if [ "$(whoami)" != "root" ]; then
	echo "Les privil�ges Root sont requis pour ex�cuter ce script, essayez de l'ex�cuter avec sudo..."
	exit 2
fi

###################################################################################
# Mise � jour de la distribution et installation des diff�rent services et modules
###################################################################################
echo ""
echo ""
echo "Mise � jour du syst�me"
sleep 1
apt update && apt upgrade -y

###################################################################################
# Installation du serveur Web Apache2
###################################################################################
# Determine si le serveur web est install�
if [[ ! "$(dpkg --get-selections | grep apache )"~ "install" ]]; then
        echo "Apache2 est d�j� install�"
		# Determine si le seveur web est fonctionnel
		if [[ ! "$(systemctl is-active apache2.service )" =~ "active" ]]; then
        		echo "Apache2 est fonctionnel"
		else echo "Apache 2 n'est pas fonctionnel"
			echo "Voulez-vous d�marrer Apache2 et activer le service [y/n] ? "
			read activeApache2
			if [[ "${activeApache2}" == "yes" ]] || [[ "${activeApache2}" == "y" ]]; then
				systemctl start apache2
				systemctl enable apache2
				if [[ ! "$(systemctl is-active apache2.service )" =~ "active" ]]; then
					echo "Apache2 est � pr�sent fonctionnel"
				else echo "Apache 2 semble rencontrer un probl�me"
				fi
			fi
		fi
else echo "Apache 2 n'est pas install�"
	echo "Le serveur apache2 doit �tre install�, souhaitez-vous proc�der [y/n] ? "
	read installApache2
	if [[ "${installApache2}" == "yes" ]] || [[ "${installApache2}" == "y" ]]; then
		apt install apache2 -y
	fi
fi

exit 0