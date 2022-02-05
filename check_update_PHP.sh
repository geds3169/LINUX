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


echo -e "Installation du paquet bc qui permet de faire des calculs (versions)\n"
sleep 3
sudo apt-get install bc -y -q >> tools.log
echo -e "\nLe fichier tools.log a été créé/mis à jour, il se trouve dans le répertoire courant."
clear
echo -e "\nVérification de la présence de PHP et des modules\n"
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
				sudo apt list --upgradable -V
			else
				echo -e "\nle paquet apt-show-versions n'est pas installé, il est requis pour la vérification des versions"
				echo -e "Souhaitez-vous installer le paquet ?"
				read -q
				if  [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
					sudo apt-get install apt-show-versions
				else
					echo "Il est impossible de tester si une version plus récente existe sans ce paquet"
				fi
			fi
	else
		echo -e "\nCe choix et de votre responsabilité, il est recommandé de consultez les CVE"
		echo "http://www.cvedetails.com/product/128/PHP-PHP.html?vendor_id=74"
	fi
else
    echo "La version actuelle $CURRENT_VERSION de PHP ne correspond pas au minimum requis"
	echo -e "Voulez-vous installer une version plus récente de PHP ?"
	read q
	if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
		sudo apt-get install php -y -q >> PHP.log
		echo "La mise à jour de PHP a été faite, un fichier nommé PHP.log a été créé/mis à jour \nil se trouve dans le répertoire courant"
		echo -e "Voici a présent les version de PHP disponible sur votre distribution:\n"
		List_PHP_V
		echo -e "\nVoulez-vous changer la version ?"
		read q
		if [ "${q}" == "yes" ] || [ "${q}" == "y" ]; then
			echo -e "\nRenseignez le numéro de version souhaitez (retourné précédemment): "
			read new_php_version
			echo -e "\nDésactivation de PHP $CURRENT_VERSION"
			sudo /usr/bin/a2dismod $CURRENT_VERSION"
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
	fi
fi

exit 0