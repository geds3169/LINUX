#!/bin/sh

#####################################################################
# Ce script à pour but la mise en place d'un cloud privé ownCloud
#
# testé sur Debian 11
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
# Customisation, coloration du texte pour plus de clarté
###################################################################################
#Couleurs
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

# Remise à 0 de la couleur après utilisation
clear='\033[0m'

# Utilisation
# echo -e "The color is: ${red}Mon texte en rouge ${clear}!"

###################################################################################
# Vérification des droits d'execution
###################################################################################
# Vérification des permissions d'execution du script
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

###################################################################################
# Mise à jour de la distribution et installation des différent services et modules
###################################################################################
echo "${red} Mise à jour du système ${clear}"
apt update && apt upgrade -y

# Installation du serveur Web apache2
##################################
echo "${red} Installation du serveur Web ${clear}"
apt install apache2 -y

# Mise en place du service dès le démarrage du serveur physique
systemctl start apache2
systemctl enable apache2
if [[ ! "$(systemctl is-active apache2.service )" =~ "active" ]]
then
        echo "${red} Une erreur est apparue lors de l'opération ${clear}"
		echo $?
fi
apache2 -v

# Installation du serveur de base de données
#############################################
echo "${green} Installation du serveur de base de données ${clear}"
apt install mariadb-server -y

# Mise en place du service dès le démarrage du serveur physique
if [[ ! "$(systemctl is-active mariadb.service )" =~ "active" ]]
then
        echo "${red} Une erreur est apparue lors de l'opération ${clear}"
		echo $?
fi
systemctl start mariadb
systemctl enable mariadb

# Installe PHP et d'autres modules nécessaires
##############################################
echo "${green} Installation des dépendances ${clear}"
apt install php libapache2-mod-php php-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ldap} -y
apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y


##################################################################################################################
# Questions en vue de sécurisation de la base de données et la création du comptes d'administration du cloud privé
##################################################################################################################
echo "${cyan} Confirmer le nom d'utilisateur Root ${clear} ${red}(en minuscule) ${clear}"
read root_name

#Hidden password
echo "${cyan}Renseignez le mot de passe du compte Root ${clear} ${red}(Il ne s'affiche pas)${clear}"
stty -echo
read root_passwd

stty echo
echo "${cyan} Entrez le nom de l'utilisateur qui sera amené à administrer la solution ${clear} ${red}(autre que Root, question de sécurité)${clear}"
read user_name

echo "${cyan) Entrez le mot de passe du compte administrateur de la solution ${clear} ${red}(il ne s'affiche pas)${clear}"
stty -echo
read user_passwd

stty echo
echo "${cyan} Entrez le nom souhaité pour la base de donnée (e.g: ownclouddb ) ${clear}"
read database_name

id -u $user_name &>/dev/null || useradd $user_name
adduser www-data $user_name


################################################
# Securisation du serveur de base de données
################################################

echo "${green}Sécurisation de la base de données, suppression de l'accès root depuis l'extérieur, suppression des comptes anonymes et de la base de données test${clear}"
set -e
mysql_secure_installation << EOF
n
$root_passwd
$root_passwd
y
y
y
y
y
EOF

#################################################################################
# Création de l'utilisateur et de la base de donnée associé au cloud privé
#################################################################################

echo "${green}Si l'utilisateur $user_name n'existe pas dans la base de donnée, il sera alors créé ${clear}"
set -e
mysql -u $root_name -p$root_passwd << EOF
CREATE USER IF NOT EXISTS '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
CREATE DATABASE IF NOT EXISTS $database_name;
GRANT ALL PRIVILEGES ON *.* TO '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
GRANT ALL PRIVILEGES ON $database_name.* TO '$user_name'@'localhost';
FLUSH PRIVILEGES;
EOF

#################################################################################
# Téléchargement et installation de ownCloud
#################################################################################
echo "${green}Téléchargement de l'archive depuis le dépot officiel https://download.owncloud.org ${clear}"
wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-20211220.tar.bz2

echo -e "${cyan}renseignez le chemin ou sera installé la solution \n (e.g: ${magenta}/var/www/${clear}${yellow}html${clear}/owncloud ou ${magenta}/var/www/${clear}owncloud):"
read dir

# Teste si le dossier existe
############################
if [ -d "$dir" ]; then
echo "${red}$dir Le répertoire existe déjà ${clear}" ;
else
`mkdir -p $dir`;
echo "$dir ${green} Le répertoire $dir à été créé ${clear}"
fi
cd /tmp/
tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
chown -R www-data $dir

#################################################################################
# Configuration du virtual host (apache2)
#################################################################################
echo "${cyan}Entrez le nom du serveur souhaité ${clear}${red}(sans le www, il peut être identique au nom de la machine) : ${clear}"
read srv_name

echo "${cyan}Entrez le nom de domaine (e.g: exemple.com ) :${clear}"
read tld 

echo "${cyan}Entrez le port d'écoute du serveur Web (e.g: 80 (http) ou 443 (https) ) : ${clear}"
read port 

echo "${cyan}Entrez le chemin du répertoire ownCloud ${clear}(e.g: /var/www/owncloud/, ${red}ne pas oublier le${clear}${yellow} /${clear} ) "
read directory

dir = $directory | sed -e "s/\/[^\/]*$//"

echo "${cyan}Entrer l'adresse IP d'écoute pour le serveur${clear} (e.g. : ${yellow}*${clear} ou ${yellow}IP locale${clear}, ${yellow}IP loopback${clear}):"
read listen

echo "${green} Création du fichier VirtualHost avec les paramêtres renseignés ${clear}"

echo "#### $srv_name.
<VirtualHost $listen:$port>
ServerName $srv_name.$tld
ServerAlias $srv_name.$tld
DocumentRoot $dir
<Directory $dir>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
allow from all
</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf

echo "${green} Test de la configuration avant redémarrage du service Apache2${clear}"
sudo apachectl configtest

if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
echo "${red}Le fichier n'a pas pu être édité!${clear}"
else
echo "${green}Le fichier a été créé avec succés !${clear}"
fi

/user/sbin/a2dissite 000-default.conf
/usr/sbin/a2ensite $srv_name.conf

echo "${red}Le serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n]?${clear}"
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
systemctl restart apache2
fi

#################################################################################
# Conseils & recommandations
#################################################################################

echo "${cyan}Afin de terminer la configuration, ouvrez un navigateur Web et entrez l'addresse suivante http://127.0.0.1 si vous êtes en local${clear}"
echo "ou http://<ip-publique-serveur> http://<ip-privé-serveur> si vous effectuer la configuration depuis une autre machine"
echo "${blue}Renseignez le nom d'administration $user_name, le mot de passe associé, par defaut le répertoire des données est /var/www/owncloud/data ${clear}"
echo "${magenta}La configuration de l'outil est en soit ergonomique et intuitif ${clear}"
echo "${yellow}La mise en place de l'authentification avec LDAP est faisable un petit lien \n https://kifarunix.com/configure-owncloud-openldap-authentication/ ${clear}"
echo "${red}Dans la cas de l'utilisation du port 443, la mise en place d'un certificat SSL est plus que recommandé.${clear}"
echo "${Cyan}J'espère que ce script vous aura été utile :)= ${clear}"

exit 0
