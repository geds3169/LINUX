# En cours de réalisation
#############################
#!/bin/bash

###########################
# Variables
###########################
# Major.Minor version PHP
#CURRENT_VERSION="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")"
#Alternative Commande similaire
CURRENT_VERSION="$(php -v | grep --only-matching --perl-regexp "(PHP )\d+\.\\d+\.\\d+" | cut -c 5-7)"

MINI_VERSION="7.4"
PACKAGE_NAME="php"

AVAILABLE="$(sudo apt-cache show php | grep Version | cut -d ':' -f 4 | cut --d '-' -f 1 | cut -d '+' -f1)"

clear

############################
# Functions
############################
function install_bc(){
echo -e "Le paquet bc est nécessaire afin de comparer les versions de PHP\t"
echo -e "\nSouaitez-vous installer le paquet bc  [y/n] ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	sudo apt-get install bc -y -q >> tools.log
	echo -e "\nLe fichier tools.log a été créé/mis à jour, il se trouve dans le répertoire courant."
fi
}

# Non utilisé
#function check apt-show-versions(){
#echo -e "Le paquet apt-show-versions est nécessaire pour comparer les version PHP sur les dépôts\t"
#echo -e "Souhaitez-vous installer le paquet apt-show-version [y/n] ?"
#read -q
#if  [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
#sudo apt-get install apt-show-versions - y -q >> tools.log
#echo -e "\nLe paquet a été installé, le fichier tool.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
fi
}


############################
# Code
############################

# Vérification de la présence de PHP sur la distribution
if [[  "$(dpkg --get-selections | grep "php*")" =~ "install" ]]; then
	echo -e "\nPHP est déjà présent sur votre distribution, la version est  $CURRENT_VERSION"
	
	# Vérification de la présence du paquet bc
	if [[  "$(dpkg --get-selections | grep "bc")" =~ "install" ]]; then
		
		# Vérification des attendus de version PHP
		if [ $(echo " $CURRENT_VERSION >= $MINI_VERSION" | bc) -eq 1 ]; then
			echo -e "\nLa version actuelle correspond aux attentes de la solution"
		else
			echo -e "\nLa version actuelle ne correspond aux attentes de la solution"
		fi
	else
		# Installation du paquet bc par appel de la fonction
		install_bc
		# Vérification des attendus de version PHP 
		if [ $(echo " $CURRENT_VERSION >= $MINI_VERSION" | bc) -eq 1 ]; then
			echo -e "\nLa version actuelle correspond aux attentes de la solution"
		else
			echo -e "\nLa version actuelle ne correspond aux attentes de la solution"
			
			# Vérification de l'existance de version supérieure PHP sur la distribution
			if [[ -d /etc/php ]]; then
				echo -e "\nVoici a présent les versions de PHP disponible localement sur votre distribution:\n"
				dir
				echo -e "\nVoulez-vous changer de version [y/n] ?"
				read q
				if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
					echo -e "\nRenseignez le numéro de version souhaitez (retourné précédemment): "
					read new_php_version
					echo -e "\nDésactivation de PHP $CURRENT_VERSION"
					sudo /usr/bin/a2dismod $CURRENT_VERSION
					echo -e "\nActivation de la version $new_php_version"
					sudo /usr/bin/a2enmod $new_php_version
					echo -e "\nLe redémarrage du serveur Apche2 est nécessaire, voulez-vous procéder [y/n] ?"
					read q
					if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
						sudo systemctl restart apache2
					else
						echo -e "\nPensez à redémarrer le serveur afin de ne pas avoir d'erreur de version PHP \n lorsque vous terminerez la configuration de la solution."
						echo -e "\n En passant la commande suivante: sudo systemctl restart apache2"
					fi
				fi
			else
				echo -e "\nIl n'existe pas d'autre version PHP en local\n"
				echo "Souhaitez-vous vérifier s'il existe une version plus récente sur les dépôts Debian [y/n] ?
				if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
					"La version la plus récente est :"
					$AVAILABLE
					echo "Souhaitez-vous installer la nouvelle version [y/n] ?
					if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
						sudo apt-get install php$AVAILABLE -y -q >> PHP.log
						echo -e "\nLe paquet a été installé, le fichier PHP.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
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
fi