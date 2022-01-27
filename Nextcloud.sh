#!/bin/bash

#####################################################################
# Ce script à pour but la mise en place d'un cloud privé Nextcloud
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
# 27/01/2022
#
######################################################################

###################################################################################
# Variables
###################################################################################
APACHE2_STATUS="$(systemctl is-active apache2.service)"
APACHE2_SERVICE="$(systemctl is-enabled apache2.service)"
#
MARIADB_STATUS="$(systemctl is-active mariadb)"
MARIADB_SERVICE="$(systemctl is-enabled mariadb.service)"

#
START_SCRIPT_DEBUG="true"
FLAG_STATUS="active"


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
echo ""
sleep 1
apt update && apt upgrade -y

apt-get install net-tools

echo ""

sleep 1
###################################################################################
# Installation du serveur Web Apache2
###################################################################################
# Determine si le serveur web est installé, démarré
if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]
then
		echo "Apache2 est installé"
else
	echo "Apache 2 n'est pas installé"
	echo "Le serveur apache2 doit être installé, souhaitez-vous procéder [y/n] ? "
	read installApache2
	if [ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ];
	then
		apt install apache2 -y
		systemctl enable apache2
	fi
fi

echo ""

sleep 0.5
# Determine si le seveur web est fonctionnel.
if [ "${APACHE2_STATUS}" = "${FLAG_STATUS}" ] 
then
	echo "Apache2 est démarré"
else
	echo "Apache 2 n'est pas démarré"
	echo "Voulez-vous démarrer Apache2 [y/n] ? "
	read activeApache2
	if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ];
	then
		systemctl start apache2
	fi
fi

echo ""

sleep 0.5
# Determine si le service est actif au démarrage.
if [ "${APACHE2_SERVICE}" == "enabled" ] 
then
	echo "Le service Apache2 est activé"
else
	echo "Le service Apache2 n'est pas activé"
	echo "Voulez-vous activer le service Apache2 [y/n] ? "
	read enableApache2
	if [ "${enableApache2}" == "yes" ] || [ "${enableApache2}" == "y" ];
	then
		systemctl enable apache2
	fi
fi

echo ""

sleep 0.5
# Retour d'information sur le processus Apache2 et port utilisé
echo "Apache2 est activé et opérationnel, le(s) PID du processus est/sont : "
pgrep -lf apache2
echo ""
echo "et le protocole et le(s) port(s) d'écoute actuel est/sont :"
netstat -pat | grep apache2

echo ""

sleep 1
###################################################################################
# Installation du serveur de base de données Mysql ou Mariadb
###################################################################################

# Détermine si le serveur de base de données est installé, démarré.
if [[ "$(dpkg --get-selections | grep mariadb )" =~ "install" ]]
then
		echo "MariaDB est déjà installé"
		dpkg --get-selections | grep mariadb
else
	echo "Aucun serveur de base de données n'est installé"
	echo "Un serveur de base de données est requis, souhaitez-vous procéder [y/n] ? "
	read installMariaDB
	if [ "${installMariaDB}" == "yes" ] || [ "${installMariaDB}" == "y" ];
	then
		echo "MySQL-server n'étant plus supporté par Debian, Mariadb sera donc installé'"
		apt install mariadb-server -y
		systemctl enable mariadb
	fi
fi

echo ""

sleep 0.5
# Determine si le seveur de base de données est fonctionnel.
if [ "${MARIADB_STATUS}" = "${FLAG_STATUS}" ] 
then
	echo "Le serveur de base de données est démarré"
else
	echo "Le serveur de base de données n'est pas démarré"
	echo "Le serveur de base de données doit être activé, souhaitez-vous procéder [y/n] ? "
	read activeMariaDB
	if [ "${activeMariaDB}" == "yes" ] || [ "${activeMariaDB}" == "y" ];
	then
		systemctl start mariadb
	fi
fi

echo ""

sleep 0.5
# Determine si le service est actif au démarrage.
if [ "${MARIADB_SERVICE}" == "enabled" ] 
then
	echo "Le service MariaDB est activé"
else
	echo "Le service MariaDB n'est pas activé"
	echo "Voulez-vous activer le service MariaDB [y/n] ? "
	read enableMariaDB
	if [ "${enableMariaDB}" == "yes" ] || [ "${enableMariaDB}" == "y" ];
	then
		systemctl enable apache2
	fi
fi

echo ""

sleep 0.5
# Retour d'information sur le processus Apache2 et port utilisé
echo "MariaDB est activé et opérationnel, le(s) PID du processus est/sont : "
pgrep -lf mariadb
echo ""
echo "et le protocole et le port d'écoute actuel sont :"
netstat -pat | grep mariadb

echo ""

sleep 1
###################################################################################
# Installation de PHP et d'autres modules nécessaires
###################################################################################

echo "Installation du dépôt php8.0 et de la clé GPG associé"
echo ""
apt-get install apt-transport-https lsb-release ca-certificates -y
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list
echo ""
echo "Mise à jour des nouveaux packets depuis les dépôts et téléchargement"
apt-get update
echo ""
echo "Installation de PHP et de ses dépendances"
apt install php8.0 libapache2-mod-php8.0 php8.0-{xml,cli,fpm,cgi,mysql,mbstring,gd,curl,zip} -y
apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y

echo ""

sleep 1
##################################################################################################################################
# Collecte des informations en vue de sécurisation de la base de données et la création du comptes d'administration du cloud privé
##################################################################################################################################
echo "Confirmer le nom d'utilisateur Root (en minuscule)"
read root_name
echo ""
#Hidden password
echo "Renseignez le mot de passe du compte Root"
stty -echo
read root_passwd
echo ""
stty echo
echo "Entrez le nom de l'utilisateur qui sera amené à administrer la solution (autre que Root, question de sécurité)"
read user_name
echo ""
echo "Entrez le mot de passe associé au compte d'administration de la solution"
stty -echo
read user_passwd
echo ""
stty echo
echo "Entrez le nom souhaité pour la base de donnée (e.g: nextclouddb)"
read database_name
echo ""
echo "Ajout de l'utilisateur $user_name au groupe d'administration du serveur Web"
id -u $user_name &>/dev/null || useradd $user_name
/usr/sbin/adduser www-data $user_name

echo ""
sleep 1
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

sleep 1
#################################################################################
# Création de l'utilisateur et de la base de donnée associé au cloud privé
#################################################################################
echo ""
echo "Création de la base de donnée $database_name"
echo "Si l'utilisateur $user_name n'existe pas il sera alors créé avec le mot de passe associé"
set -e
mysql -u $root_name -p$root_passwd << EOF
CREATE USER IF NOT EXISTS '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
CREATE DATABASE IF NOT EXISTS $database_name;
GRANT ALL PRIVILEGES ON *.* TO '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
GRANT ALL PRIVILEGES ON $database_name.* TO '$user_name'@'localhost';
FLUSH PRIVILEGES;
EOF

sleep 0.5
echo "Opération effectué"
mysql --batch --skip-column-names -e "SHOW DATABASES LIKE '$database_name'" | grep $database_name

echo ""
sleep 1

#################################################################################
# Téléchargement et installation de Nextcloud
#################################################################################
echo "renseignez le chemin ou sera installé la solution "
echo "(e.g: /var/www/html/nextcloud ou /var/www/nextcloud ):"
read dir
echo""

# Création du dossier contenant la solution (/var/www)
if [ - d "dir" ]; then
	echo "Le répertoire $dir existe déjà"
else
	echo "Le répertoire ${dir} n'existe pas et va donc être créé"
	mkdir $dir
	echo "le répertoire a été créé"
	echo ""
	ls $dir
	echo ""
fi

sleep 1

# Téléchargement de la solution et extraction
	
############
# Variables
############
file="nextcloud-23.0.0.tar.bz2"

echo ""
echo "Changement de répertoire"
cd /tmp/
echo ""

# check si l'archive existe ou télecharge
if [ -f /root/tmp/$file ]; then
	echo "L'archive existe déja et va être décompréssé dans ${dir}"
	echo ""
	echo "Extraction de la solution dans le dossier ${dir}"
	echo ""
	tar xvf nextcloud-23.0.0.tar.bz2 --strip-components=1 -C $dir
	echo ""
	echo "Extraction de la solution a été effectué"
	ls -al $dir
	sleep 1
	# Nettoyage des répertoire utilisés durant l'execution du script
	echo "Nettoyage des fichiers téléchargés"
	rm -R /tmp/nextcloud-complete-*
	ls /tmp/
else
	echo "Téléchargement de l'archive depuis le dépot officiel https://download.nextcloud.com/ "
	wget -P /tmp/ https://download.nextcloud.com/server/releases/nextcloud-23.0.0.tar.bz2
	echo ""
	echo "Extraction de la solution dans le dossier ${dir}"
	echo ""
	tar xvf nextcloud-23.0.0.tar.bz2 --strip-components=1 -C $dir
	echo ""
	echo "Extraction de la solution a été effectué"
	ls -al $dir
	sleep 1
	# Nettoyage des répertoire utilisés durant l'execution du script
	echo "Nettoyage des fichiers téléchargés"
	rm -R /tmp/nextcloud-*
	ls /tmp/
fi

#################################################################################
# Sécurisation du répertoire et des fichiers de configuration
#################################################################################

############
# Variables
############
htuser='www-data'
htgroup='www-data'
rootuser='root'

echo ""
echo "Modification des droits d'accès sur le répertoire"
find ${dir}/ -type f -print0 | xargs -0 chmod 0640
find ${dir}/ -type d -print0 | xargs -0 chmod 0750


echo""
echo "Modification des droits utilisateurs/groupes/propriétaire des répertoires et sous répertoire"
chown -R ${rootuser}:${htgroup} ${dir}/
chown -R ${htuser}:${htgroup} ${dir}/apps/
chown -R ${htuser}:${htgroup} ${dir}/config/
chown -R ${htuser}:${htgroup} ${dir}/core/
chown -R ${htuser}:${htgroup} ${dir}/lib/
chown -R ${htuser}:${htgroup} ${dir}/ocs/
chown -R ${htuser}:${htgroup} ${dir}/ocs-provider/
chown -R ${htuser}:${htgroup} ${dir}/resources/
chown -R ${htuser}:${htgroup} ${dir}/themes/
chown -R ${htuser}:${htgroup} ${dir}/updater/
chmod +x ${dir}/occ
echo ""
sleep 0.5
echo "modification des droits sur le fichier .htaccess s'il existe"
echo "Celui-ci permet de renforcer la configuration du serveur web"
if [ -f ${dir}/.htaccess ]
 then
  chmod 0644 ${dir}/.htaccess
  chown ${rootuser}:${htgroup} ${dir}/.htaccess
fi
if [ -f ${dir}/data/.htaccess ]
 then
  chmod 0644 ${dir}/data/.htaccess
  chown ${rootuser}:${htgroup} ${dir}/data/.htaccess
fi

echo ""
sleep 1
#################################################################################
# Configuration du virtual host (apache2)
#################################################################################
echo "Configuration du VirtualHost"
echo ""
sleep 0.5
echo "Entrez le nom du serveur souhaité (sans le www) : "
read srv_name
echo ""
echo "Entrez le nom de domaine : "
read tld 
echo ""
echo "!!! AVERTISSEMENT !!!"
echo "Vous allez à présent entrez le port d'écoute (80 HTTP - 443 HTTPS ),"
echo "si votre serveur doit être utilisé dans un environnement de production,"
echo "il est recommandé d'utiliser un certificat signé par une autorité de certification,"
echo "il n'est pas recommandé d'utiliser un certificat auto-signé."
echo "Dans le doute utilisez le port 80, renseignez-vous ensuite pour l'obtention d'un certificat et modification de la configuration du site dans apache2. :"
sleep 0.1
echo ""
echo "Renseignez le port d'écoute du server Web:"
read port 
echo ""
#echo "Entrez le chemin du répertoire Nextcloud ( /var/www/nextcloud/, ne pas oublier le / "
#read directory

#dir = $directory | sed -e "s/\/[^\/]*$//"
echo ""
echo "Entrer l'adresse  d'écoute du serveur web (e.g. : * or listen, or local IP, IP loopback): "
read listen
echo ""

echo "Renseignez l'adresse de contact de l'administrateur de la solution : "
read mailto

# Création du répertoire (des logs apache2) répondant au nom du dossier créé (/var/log/apache2/nextcloud/)
echo "Création d'un répertoire dédié aux logs apache2 pour la solution ${srv_name} "
echo ""
if [ - d "srv_name" ]; then
	echo "Le répertoire $srv_name existe déjà dans le répertoire des logs apache2"
else
	echo "Le répertoire ${srv_name} n'existe pas et va donc être créé dans le répertoire des logs apache2"
	mkdir $srv_name
	echo "le répertoire dédié au log apache pour la solution a été créé"
	echo ""
	ls /var/log/apache2/$srv_name
fi
	echo ""

# Creation de la configuration
echo "#### $srv_name.
<VirtualHost $listen:$port>
ServerAdmin $mailto
ServerName $srv_name.$tld
ServerAlias $srv_name.$tld
DocumentRoot $dir
DirectoryIndex index.php
LogLevel warn
ErrorLog ${APACHE_LOG_DIR}/$srv_name.log
CustomLog ${APACHE_LOG_DIR}/$srv_name.log combined
<Directory $dir>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Require all granted
<IfModule mod_dav.c>
Dav off
</IfModule>
SetEnv HOME $dir/
SetEnv HTTP_HOME $dir/
</Directory>
ErrorLog ${APACHE_LOG_DIR}/$srv_name/error.log
CustomLog ${APACHE_LOG_DIR}/$srv_name/access.log combined
LogLevel warn
ServerSignature Off
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*) index.php [PT,L]
</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf
echo ""

# Test de configuration apache
sudo apachectl configtest
echo ""
/usr/sbin/apache2ctl -t
echo ""
/usr/sbin/apache2ctl -S
echo ""

sleep 1

echo "activation de la configuration"
echo ""
if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
echo "Le fichier n'a pas pu être édité!"
else
echo "Le fichier a été créé avec succés !"
fi
echo ""
echo "Activation de la configuration"
/usr/sbin/a2enmod proxy_fcgi
/usr/sbin/a2enmod setenvif
/usr/sbin/a2dismod php8.0 mpm_prefork
/usr/sbin/a2enmod mpm_event
/usr/sbin/a2ensite $srv_name.conf
/usr/sbin/a2enmod rewrite
/usr/sbin/a2enmod headers
/usr/sbin/a2enmod env
/usr/sbin/a2enmod dir
/usr/sbin/a2enmod mime
/usr/sbin/a2enmod ssl
/usr/sbin/a2enmod http2
/usr/sbin/a2dissite 000-default.conf


/usr/sbin/a2enconf php8.0-fpm

echo ""
echo "Le serveur apache2 doit être redémarrer, souhaitez-vous continuer [y/n]?"
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
systemctl restart apache2
fi
echo ""
echo "Le serveur Cloud est opérationnel !"
echo ""

#################################################################################
# Configuration du firewall de la machine
#################################################################################

echo "Recherche d''un pare-feu est création des règles de flux sur le $port défini dans la configuration du serveur Web"
/usr/sbin/iptables status >/dev/null 2>&1
if [ $? = 0 ]; then
        echo "Le pare-feu Iptable est en cours d'exécution, nous pouvons créer les règles entrantes pour les protocoles HTTP (80) et HTTPS (443)"
        iptables -I INPUT -p tcp --dport 80 -j ACCEPT
        iptables -I INPUT -p tcp --dport 443 -j ACCEPT
else
        echo "Le pare-feu Iptable ne fonctionne pas ou n'est pas installé"
fi

if systemctl status ufw.service >/dev/null; then
        echo "le pare-feu ufw est en cours d'exécution, nous pouvons créer la règle entrante pour les protocoles HTTP (80) et HTTPS (443)"
        ufw allow http
        ufw allow https
else
        echo "Le pare-feu  ufw ne fonctionne pas ou n'est pas installé"
fi

sleep 1

#################################################################################
# Sécurisation de la faille pwnkit 
#################################################################################
chmod 0755 /usr/bin/pkexec

#################################################################################
# Conseils & recommandations
#################################################################################
echo ""
echo ""
echo "Afin de terminer la configuration, ouvrez un navigateur Web et entrez l'addresse suivante http://127.0.0.1 si vous êtes en local"
echo""
echo "ou http://<ip-publique-serveur> http://<ip-privé-serveur> si vous effectuer la configuration depuis une autre machine"
echo ""
echo "Renseignez le nom d'administration $user_name, le mot de passe associé, par defaut le répertoire des données est /var/www/nextcloud/data "
echo ""
echo "La configuration de l'outil est en soit ergonomique et intuitif "
echo ""
echo "La mise en place de l'authentification avec LDAP https://docs.nextcloud.com/server/latest/admin_manual/configuration_user/user_auth_ldap.html "
echo ""
echo "Dans la cas de l'utilisation du port 443, la mise en place d'un certificat SSL est plus que recommandé."

exit 0