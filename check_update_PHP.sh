# En cours de réalisation
#############################
#!/bin/bash

# Major.Minor version PHP
#CURRENT_VERSION="$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")"
#Alternative Commande similaire
CURRENT_VERSION="$(php -v | grep --only-matching --perl-regexp "(PHP )\d+\.\\d+\.\\d+" | cut -c 5-7)"

MINI_VERSION="7.4"
PACKAGE_NAME="php"

List_PHP_V="$(cd /etc/php && dir)"


echo -e "L' installation du paquet bc est absolument nécessaire afin de peremettre la comparaison des versions\n"
sleep 1
echo -e "\nSouaitez-vous installer le paquet ?"
read q
if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
	sudo apt-get install bc -y -q >> tools.log
	echo -e "\nLe fichier tools.log a été créé/mis à jour, il se trouve dans le répertoire courant."
	sleep 2
	clear

	echo -e "\nVérification de la présence de PHP et des modules\t"
	# Determine si PHP est installé sur le système, la version minimale requise
	# Determine si PHP est installé sur le système, la version minimale requise
	if [[  "$(dpkg --get-selections | grep "php*")" =~ "install" ]]; then
		echo "PHP est déjà présent sur le systeme, la version est  $CURRENT_VERSION"
		
		# check si la version minimale requise est installé et utilisé
		if [ $(echo " $CURRENT_VERSION >= $MINI_VERSION" | bc) -eq 1 ]; then
			echo "La version actuelle correspond aux attentes de la solution"
			echo -e "\nVoulez-vous vérifier s'il existe une version plus récente ?"
			read q
			if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
				if [[  "$(dpkg --get-selections | grep "apt-show-versions")" =~ "install" ]]; then
					echo -e "\nVoici la liste des versions disponible pour votre distribution \n" 
					sudo apt list --upgradable -V
				else
					echo -e "\nle paquet apt-show-versions n'est pas installé, il est requis pour la vérification des versions"
					echo -e "Souhaitez-vous installer le paquet ?"
					read -q
					if  [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
						sudo apt-get install apt-show-versions - y -q >> tools.log
						echo -e "\nLe paquet a été installé, le fichier tool.log a été mis à jour, \nil se trouve dans le répertoire courant\n"
						echo -e "\nVoici la liste des versions disponible pour votre distribution \n"
						sudo apt list --upgradable -V
					else
						echo "Vous avez choisi de refuser l'installation, le script va donc poursuite."
					fi
				fi
			else
				echo -e "\nCe choix et de votre responsabilité, il est recommandé de consultez les CVE"
				echo "http://www.cvedetails.com/product/128/PHP-PHP.html?vendor_id=74"
			fi
		fi
		
		# check des versions disponible localement
		echo -e "\nVoici a présent les version de PHP disponible localement sur votre distribution:\n"
		List_PHP_V
		echo -e "\nVoulez-vous changer de version ?"
		read q
		if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
			echo -e "\nRenseignez le numéro de version souhaitez (retourné précédemment): "
			read new_php_version
			echo -e "\nDésactivation de PHP $CURRENT_VERSION"
			sudo /usr/bin/a2dismod $CURRENT_VERSION
			echo -e "\nActivation de la version $new_php_version"
			sudo /usr/bin/a2enmod $new_php_version
			echo -e "\nLe redémarrage du serveur Apche2 est nécessaire, voulez-vous procéder ?"
			read q
			if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
				sudo systemctl restart apache2
			else
				echo -e "\nPensez à redémarrer le serveur afin de ne pas avoir d'erreur de version PHP \n lorsque vous terminerez la configuration de la solution."
			fi
		else
			echo "La version de PHP n'a pas été vous utilisé la version modifié $CURRENT_VERSION \nL'installation va poursuivre  mais le succès de l'installation n'est pas garanti\n"
		fi
		
	else
		echo -e "\nPHP n'est pas présent sur votre distribution.\n"
		echo -e "Souhaitez-vous installer PHP ?"
		read q
		if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
			sudo apt-get install php -y -q >> PHP.log
			echo "La mise à jour de PHP a été faite, un fichier nommé PHP.log a été créé/mis à jour \nil se trouve dans le répertoire courant"
		fi
	fi
else
	echo -e "\nVotre refus d'installer le paquet ne permet pas de confirmer la présence de PHP et s''il respecte la version requise\n"
	echo "Le bon fonctionnement de l'installation dès lors, ne peut être garanti."
fi


exit 0