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
echo ""
echo ""
echo "Mise à jour du système"
sleep 1
apt update && apt upgrade -y

# Installation du serveur Web apache2
##################################
sleep 1
echo ""
echo "Installation du serveur Web"
sleep 1
apt install apache2 -y

sleep 0.2
echo ""
# Installe PHP et d'autres modules nécessaires
##############################################
echo "Installation des dépendances PHP"
sleep 1
apt install php libapache2-mod-php php-{mysql,intl,curl,json,gd,xml,mbstring,zip,imagick,common,curl,imap,ssh2,xml,apcu,redis,ldap} -y
apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y

echo "Redémarrage du service Apache2"
sleep 1
echo ""
# Mise en place du service dès le démarrage du serveur physique
systemctl start apache2
systemctl enable apache2
if [[ ! "$(systemctl is-active apache2.service )" =~ "active" ]]
then
        echo "Il y a un soucis avec le serveur Web Apache2"
fi
apache2 -v
echo ""
systemctl status Apache2
sleep 1

# Installation du serveur de base de données
#############################################
echo ""
echo "Installation du serveur de base de données "
sleep 1
apt install mariadb-server -y

echo ""
# Mise en place du service dès le démarrage du serveur physique
systemctl start mariadb
systemctl enable mariadb
if [[ ! "$(systemctl is-active mariadb.service )" =~ "active" ]]
then
        echo "Il y a un soucis avec le serveur de base de donnée MariaDB"
fi

echo ""
systemctl status mariadb-server

##################################################################################################################
# Questions en vue de sécurisation de la base de données et la création du comptes d'administration du cloud privé
##################################################################################################################
sleep 1
echo ""
echo "Confirmer le nom d'utilisateur Root (en minuscule)"
read root_name

#Hidden password
echo ""
echo "Renseignez le mot de passe du compte Root (Attention, Il ne s'affiche pas)"
stty -echo
read root_passwd

stty echo
echo ""
echo "Entrez le nom de l'utilisateur qui sera amené à administrer la solution (autre que Root, question de sécurité)"
read user_name

echo""
echo "Entrez le mot de passe du compte administrateur de la solution (Attention, il ne s'affiche pas)"
stty -echo
read user_passwd

stty echo
echo ""
echo "Entrez le nom souhaité pour la base de donnée (e.g: ownclouddb )"
read database_name

id -u $user_name &>/dev/null || useradd $user_name
adduser www-data $user_name


################################################
# Securisation du serveur de base de données
################################################
echo ""
sleep 1
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
sleep 1
echo ""
echo "Si l'utilisateur $user_name n'existe pas dans la base de donnée, il sera alors créé"
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
sleep 1
echo ""
echo "Téléchargement de l'archive depuis le dépot officiel https://download.owncloud.org, dans le répertoire /tmp/"
wget -P /tmp/ https://download.owncloud.org/community/owncloud-complete-20211220.tar.bz2

sleep 1

echo ""
echo "Renseignez le chemin ou sera installé la solution"
echo "(e.g: /var/www/html/owncloud ou /var/www/owncloud):"
read dir

sleep 1
echo ""

# Teste si le dossier existe
############################
if [ -d "$dir" ]; then
echo "$dir Le répertoire existe déjà" ;
else
`mkdir -p $dir`;
echo "Le répertoire $dir à été créé"
fi

echo "Changement de répertoire"
cd /tmp/

echo ""
sleep 0.5
echo "Extraction des fichiers dans le repertoire final"
tar xvf owncloud-complete-20211220.tar.bz2 --strip-components=1 -C $dir
chown -R www-data $dir

sleep 1

#################################################################################
# Configuration du virtual host (apache2)
#################################################################################

echo ""
echo "Entrez le nom du serveur souhaité (sans le www, il peut être identique au nom de la machine) : "
read srv_name

echo ""
echo "Entrez le nom de domaine (e.g: exemple.com ) : "
read tld 

echo ""
echo "Entrez le port d'écoute du serveur Web (e.g: 80 (http) ou 443 (https)) : "
read port 

echo ""
echo "Entrez le chemin du répertoire ownCloud (e.g: /var/www/owncloud/, ne pas oublier le / à la fin ) :"
read directory

dir = $directory | sed -e "s/\/[^\/]*$//"

echo ""
echo "Entrer l'adresse IP d'écoute pour le serveur ( e.g. : * (pour toutes les interfaces) ou IP locale, IP loopback ) : "
read listen

echo ""
echo "Renseignez l'adresse de courriel de l'administrateur"
red mail
sleep 0.5

echo ""
echo "Création du fichier VirtualHost avec les paramêtres renseignés : "

echo "#### $srv_name.
<VirtualHost $listen:$port>
ServerName $srv_name.$tld
ServerAlias $srv_name.$tld
ServerAdmin $mail
DocumentRoot $dir
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
<Directory $dir>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
allow from all
</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf

echo ""
echo "Test de la configuration avant redémarrage du service Apache2"
sudo apachectl configtest

sleep 0.5

echo""
if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
echo "Le fichier n'a pas pu être édité !"
else
echo "Le fichier a été créé avec succés !"
fi

echo ""
echo "Activation du site"
a2ensite $srv_name.conf

sleep 0.5

echo ""
echo "Le serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n] ? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
systemctl restart apache2
fi

#################################################################################
# Conseils & recommandations
#################################################################################
echo ""

echo "Afin de terminer la configuration, ouvrez un navigateur Web, "
echo "entrez l'addresse suivante http://127.0.0.1 si vous êtes en local,"
echo "http://<ip-publique-serveur> ou encore,"
echo "http://<ip-privé-serveur> si vous effectuer la configuration depuis une autre machine"
sleep 0.2
echo ""
echo "Renseignez le nom d'administration $user_name, le mot de passe associé, par defaut le répertoire des données est /var/www/owncloud/data "
sleep 0.2
echo ""
echo "La configuration de l'outil est en soit ergonomique et intuitif "
sleep 0.2
echo ""
echo "La mise en place de l'authentification avec LDAP peut être mis en place "
echo " suivre le tutoriel https://kifarunix.com/configure-owncloud-openldap-authentication/ "
sleep 0.2
echo ""
echo "Dans la cas de l'utilisation du port 443, la mise en place d'un certificat SSL est plus que recommandé. "
sleep 0.2
echo ""
echo "J'espère que ce script vous aura été utile :)= "

exit 0
