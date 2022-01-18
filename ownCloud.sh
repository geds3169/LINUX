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

# Vérification des permissions d'execution du script
if [ "$(whoami)" != "root" ]; then
	echo "Les privilèges Root sont requis pour exécuter ce script, essayez de l'exécuter avec sudo..."
	exit 2
fi

###################################################################################
# Mise à jour de la distribution et installation des différent services et modules
###################################################################################
echo "Mise à jour du système"
apt update && apt upgrade -y

# Installation du serveur Web apache2
##################################
echo "Installation du serveur Web"
apt install apache2 -y

# Mise en place du service dès le démarrage du serveur physique
systemctl start apache2
systemctl enable apache2
if [[ ! "$(systemctl is-active apache2.service )" =~ "active" ]]
then
        echo "Une erreur est apparue lors de l'opération"
		echo $?
fi
apache2 -v

# Installation du serveur de base de données
#############################################
echo "Installation du serveur de base de données"
apt install mariadb-server -y

# Mise en place du service dès le démarrage du serveur physique
if [[ ! "$(systemctl is-active mariadb.service )" =~ "active" ]]
then
        echo "Une erreur est apparue lors de l'opération"
		echo $?
fi
systemctl start mariadb
systemctl enable mariadb

# Installe PHP et d'autres modules nécessaires
##############################################
echo "Installation des dépendances"
apt install php libapache2-mod-php php-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ladap} -y
apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y


##################################################################################################################
# Questions en vue de sécurisation de la base de données et la création du comptes d'administration du cloud privé
##################################################################################################################
echo "Confirmer le nom d'utilisateur Root (en minuscule)"
read root_name

#Hidden password
echo "Renseignez le mot de passe du compte Root"
y -echo
read root_passwd

stty echo
echo "Entrez le nom de l'utilisateur qui sera amené à administrer la solution (autre que Root, question de sécurité)"
read user_name

echo "Entrez le mot de passe associé au compte d'administration de la solution"
stty -echo
read user_passwd

stty echo
echo "Entrez le nom souhaité pour la base de donnée (ownclouddb)"
read database_name

id -u $user_name &>/dev/null || useradd $user_name
adduser www-data $user_name


################################################
# Securisation du serveur de base de données
################################################

echo "Sécurisation de la base de données, suppression de l'accès root depuis l'extérieur, suppression des comptes anonymes et de la base de données test"
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

echo "Si l'utilisateur $user_name n'existe pas il sera alors créé "
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
echo "Téléchargement de l'archive depuis le dépot officiel https://download.owncloud.org "
wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-20211220.tar.bz2

echo "renseignez le chemin ou sera installé la solution(/var/www/html/owncloud ou /var/www/owncloud):"
read dir
mkdir $dir
cd /tmp/
tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
chown -R www-data $dir

#################################################################################
# Configuration du virtual host (apache2)
#################################################################################
echo "Entrez le nom du serveur souhaité (sans le www) : "
read srv_name

echo "Entrez le nom de domaine : "
read tld 

echo "Entrez le port d'écoute (80 - 443) : "
read port 

echo "Entrez le chemin du répertoire ownCloud ( /var/www/owncloud/, ne pas oublier le / "
read directory

echo "Enter the listened IP for the server (e.g. : * or listen, or local IP, IP loopback):"
read listen

echo "#### $srv_name.$tld
<VirtualHost $listen:$port>
ServerName $srv_name
ServerAlias $srv_name.$tld
DocumentRoot $directory
<Directory $directory>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
allow from all
</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$srv_name.$tld.conf

if ! echo -e /etc/apache2/sites-available/$srv_name.$tld.conf; then
echo "Le fichier n'a pas pu être édité!"
else
echo "Le fichier a été créé avec succés !"
fi

/usr/sbin/a2ensite $srv_name.$tld.conf

echo "Le serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n]?"
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
systemctl restart apache2
fi

#################################################################################
# Conseils & recommandations
#################################################################################

echo "Afin de terminer la configuration, ouvrez un navigateur Web et entrez l'addresse suivante http://127.0.0.1 si vous êtes en local"
echo "ou http://<ip-publique-serveur> http://<ip-privé-serveur> si vous effectuer la configuration depuis une autre machine"
echo "Renseignez le nom d'administration $user_name, le mot de passe associé, par defaut le répertoire des données est /var/www/owncloud/data "
echo "La configuration de l'outil est en soit ergonomique et intuitif "
echo "La mise en place de l'authentification avec LDAP https://kifarunix.com/configure-owncloud-openldap-authentication/ "
echo "Dans la cas de l'utilisation du port 443, la mise en place d'un certificat SSL est plus que recommandé."

exit 0
