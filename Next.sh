#!/bin/bash

#####################################################################
# Ce script � pour but la mise en place d'un cloud priv� Nextcloud
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
echo ""
sleep 1.0
apt update && apt upgrade -y

apt-get install net-tools

echo ""

sleep 1.0
###################################################################################
# Installation du serveur Web Apache2
###################################################################################
# Determine si le serveur web est install�, d�marr�
if [[ "$(dpkg --get-selections | grep apache2 | grep -v "apache2-" )" =~ "install" ]]
then
		echo "Apache2 est install�"
else
	echo "Apache 2 n'est pas install�"
	echo "Le serveur apache2 doit �tre install�, souhaitez-vous proc�der [y/n] ? "
	read installApache2
	if [ "${installApache2}" == "yes" ] || [ "${installApache2}" == "y" ];
	then
		apt install apache2 -y
		systemctl enable apache2
	fi
fi

echo ""

sleep 1.0
# Determine si le seveur web est fonctionnel.
if [ "${APACHE2_STATUS}" = "${FLAG_STATUS}" ] 
then
	echo "Apache2 est d�marr�"
else
	echo "Apache 2 n'est pas d�marr�"
	echo "Voulez-vous d�marrer Apache2 [y/n] ? "
	read activeApache2
	if [ "${activeApache2}" == "yes" ] || [ "${activeApache2}" == "y" ];
	then
		systemctl start apache2
	fi
fi

echo ""

sleep 1.0
# Determine si le service est actif au d�marrage.
if [ "${APACHE2_SERVICE}" == "enabled" ] 
then
	echo "Le service Apache2 est activ�"
else
	echo "Le service Apache2 n'est pas activ�"
	echo "Voulez-vous activer le service Apache2 [y/n] ? "
	read enableApache2
	if [ "${enableApache2}" == "yes" ] || [ "${enableApache2}" == "y" ];
	then
		systemctl enable apache2
	fi
fi

echo ""

sleep 1.0
# Retour d'information sur le processus Apache2 et port utilis�
echo "Apache2 est activ� et op�rationnel, le(s) PID du processus est/sont : "
pgrep -lf apache2
echo ""
echo "et le protocole et le(s) port(s) d'�coute actuel est/sont :"
netstat -pat | grep apache2

echo ""

sleep 1.0
###################################################################################
# Installation du serveur de base de donn�es Mysql ou Mariadb
###################################################################################

# D�termine si le serveur de base de donn�es est install�, d�marr�.
if [[ "$(dpkg --get-selections | grep mariadb )" =~ "install" ]]
then
		echo "MariaDB est d�j� install�"
		dpkg --get-selections | grep mariadb
else
	echo "Aucun serveur de base de donn�es n'est install�"
	echo "Un serveur de base de donn�es est requis, souhaitez-vous proc�der [y/n] ? "
	read installMariaDB
	if [ "${installMariaDB}" == "yes" ] || [ "${installMariaDB}" == "y" ];
	then
		echo "MySQL-server n'�tant plus support� par Debian, Mariadb sera donc install�'"
		apt install mariadb-server -y
		systemctl enable mariadb
	fi
fi

echo ""

sleep 1.0
# Determine si le seveur de base de donn�es est fonctionnel.
if [ "${MARIADB_STATUS}" = "${FLAG_STATUS}" ] 
then
	echo "Le serveur de base de donn�es est d�marr�"
else
	echo "Le serveur de base de donn�es n'est pas d�marr�"
	echo "Le serveur de base de donn�es doit �tre activ�, souhaitez-vous proc�der [y/n] ? "
	read activeMariaDB
	if [ "${activeMariaDB}" == "yes" ] || [ "${activeMariaDB}" == "y" ];
	then
		systemctl start mariadb
	fi
fi

echo ""

sleep 1.0
# Determine si le service est actif au d�marrage.
if [ "${MARIADB_SERVICE}" == "enabled" ] 
then
	echo "Le service MariaDB est activ�"
else
	echo "Le service MariaDB n'est pas activ�"
	echo "Voulez-vous activer le service MariaDB [y/n] ? "
	read enableMariaDB
	if [ "${enableMariaDB}" == "yes" ] || [ "${enableMariaDB}" == "y" ];
	then
		systemctl enable apache2
	fi
fi

echo ""

sleep 1.0
# Retour d'information sur le processus Apache2 et port utilis�
echo "MariaDB est activ� et op�rationnel, le(s) PID du processus est/sont : "
pgrep -lf mariadb
echo ""
echo "et le protocole et le port d'�coute actuel sont :"
netstat -pat | grep mariadb

echo ""

sleep 1.0
###################################################################################
# Installation de PHP et d'autres modules n�cessaires
###################################################################################

echo "Installation du d�p�t php8.0 et de la cl� GPG associ�"
echo ""
apt-get install apt-transport-https lsb-release ca-certificates -y
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list
echo ""
echo "Mise � jour des nouveaux packets depuis les d�p�ts et t�l�chargement"
apt-get update
echo ""
echo "Installation de PHP et de ses d�pendances"
apt install php8.0 libapache2-mod-php8.0 php8.0-{xml,cli,fpm,cgi,mysql,mbstring,gd,curl,zip} -y
apt install openssl redis-server wget ssh bzip2 rsync curl jq inetutils-ping coreutils imagemagick -y

echo ""

sleep 1.0
##################################################################################################################################
# Collecte des informations en vue de s�curisation de la base de donn�es et la cr�ation du comptes d'administration du cloud priv�
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
echo "Entrez le nom de l'utilisateur qui sera amen� � administrer la solution (autre que Root, question de s�curit�)"
read user_name
echo ""
echo "Entrez le mot de passe associ� au compte d'administration de la solution"
stty -echo
read user_passwd
echo ""
stty echo
echo "Entrez le nom souhait� pour la base de donn�e (e.g: nextclouddb)"
read database_name
echo ""
echo "Ajout de l'utilisateur $user_name au groupe d'administration du serveur Web"
id -u $user_name &>/dev/null || useradd $user_name
/usr/sbin/adduser www-data $user_name

echo ""

sleep 1.0
################################################
# Securisation du serveur de base de donn�es
################################################
echo "S�curisation de la base de donn�es, suppression de l'acc�s root depuis l'ext�rieur, suppression des comptes anonymes et de la base de donn�es test"
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

echo ""

sleep 1.0
#################################################################################
# Cr�ation de l'utilisateur et de la base de donn�e associ� au cloud priv�
#################################################################################
echo ""
echo "Cr�ation de la base de donn�e $database_name"
echo "Si l'utilisateur $user_name n'existe pas il sera alors cr�� avec le mot de passe associ�"
set -e
mysql -u $root_name -p$root_passwd << EOF
CREATE USER IF NOT EXISTS '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
CREATE DATABASE IF NOT EXISTS $database_name;
GRANT ALL PRIVILEGES ON *.* TO '$user_name'@'localhost' IDENTIFIED BY '$user_passwd';
GRANT ALL PRIVILEGES ON $database_name.* TO '$user_name'@'localhost';
FLUSH PRIVILEGES;
EOF

echo ""

sleep 1.0
echo "Op�ration effectu�"
mysql --batch --skip-column-names -e "SHOW DATABASES LIKE '$database_name'" | grep $database_name

echo ""
sleep 1.0

#################################################################################
# T�l�chargement et installation de Nextcloud
#################################################################################
echo "renseignez le chemin ou sera install� la solution "
echo "(e.g: /var/www/html/nextcloud ou /var/www/nextcloud ):"
read dir

echo ""
sleep 1.0

# Cr�ation du dossier contenant la solution (/var/www)
if [ - d "dir" ]; then
	echo "Le r�pertoire ${dir} existe d�j�"
else
	echo "Le r�pertoire ${dir} n'existe pas et va donc �tre cr��"
	mkdir $dir
	echo "le r�pertoire a �t� cr��"
	echo ""
	ls $dir
	echo ""
fi

echo ""
sleep 1.0
# T�l�chargement de la solution et extraction
############
# Variables
############
file="nextcloud-23.0.0.tar.bz2"

echo ""
echo "Changement de r�pertoire"
cd /tmp/
echo ""

# check si l'archive existe ou t�lecharge
if [ -f /root/tmp/$file ]; then
	echo "L'archive existe d�ja et va �tre d�compr�ss� dans ${dir}"
	echo ""
	echo "Extraction de la solution dans le dossier ${dir}"
	echo ""
	tar xvf nextcloud-23.0.0.tar.bz2 --strip-components=1 -C $dir
	echo ""
	echo "Extraction de la solution a �t� effectu�"
	ls -al $dir
	echo ""
	sleep 1
	# Nettoyage des r�pertoire utilis�s durant l'execution du script
	echo "Nettoyage des fichiers t�l�charg�s"
	rm -R /tmp/nextcloud-complete-*
	ls /tmp/
	echo ""
	sleep 1.0
else
	echo "T�l�chargement de l'archive depuis le d�pot officiel https://download.nextcloud.com/ "
	wget -P /tmp/ https://download.nextcloud.com/server/releases/nextcloud-23.0.0.tar.bz2
	echo ""
	echo "Extraction de la solution dans le dossier ${dir}"
	echo ""
	tar xvf nextcloud-23.0.0.tar.bz2 --strip-components=1 -C $dir
	echo ""
	echo "Extraction de la solution a �t� effectu�"
	ls -al $dir
	echo ""
	sleep 1.0
	# Nettoyage des r�pertoire utilis�s durant l'execution du script
	echo "Nettoyage des fichiers t�l�charg�s"
	rm -R /tmp/nextcloud-*
	ls /tmp/
fi

echo ""
sleep 1.0
#################################################################################
# S�curisation du r�pertoire et des fichiers de configuration
#################################################################################
############
# Variables
############
htuser='www-data'
htgroup='www-data'
rootuser='root'


echo "Modification des droits d'acc�s sur le r�pertoire"
echo ""
find ${dir}/ -type f -print0 | xargs -0 chmod 0640
find ${dir}/ -type d -print0 | xargs -0 chmod 0750
echo""
echo "Modification des droits utilisateurs/groupes/propri�taire des r�pertoires et sous r�pertoire"
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
sleep 1.0
############
# htaccess
############
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
sleep 1.0
#################################################################################
# Configuration du virtual host (apache2)
#################################################################################
echo "Configuration du VirtualHost"
echo ""
echo "Entrez le nom du serveur souhait� (sans le www) : "
read srv_name
echo ""

echo "Entrez le nom de domaine : "
read tld 
echo ""
echo "!!! AVERTISSEMENT !!!"
echo "Vous allez � pr�sent entrez le port d'�coute (80 HTTP - 443 HTTPS ),"
echo "si votre serveur doit �tre utilis� dans un environnement de production,"
echo "il est recommand� d'utiliser un certificat sign� par une autorit� de certification,"
echo "il n'est pas recommand� d'utiliser un certificat auto-sign�."
echo "Dans le doute utilisez le port 80, renseignez-vous ensuite pour l'obtention d'un certificat et modification de la configuration du site dans apache2. :"
sleep 0.1
echo ""
echo "Renseignez le port d'�coute du server Web:"
read port 
echo ""
echo "Entrer l'adresse  d'�coute du serveur web (e.g. : * or listen, or local IP, IP loopback): "
read listen
echo ""
echo "Renseignez l'adresse de contact de l'administrateur de la solution : "
read mailto

echo ""
sleep 1.0
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
</Directory>
ErrorLog ${APACHE_LOG_DIR}/$srv_name.log
CustomLog ${APACHE_LOG_DIR}/$srv_name.log combined
LogLevel warn
ServerSignature Off
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*) index.php [PT,L]
</VirtualHost>" > /etc/apache2/sites-available/$srv_name.conf
echo""
echo "La configuration a �t� �dit� "


echo ""
sleep 1.0
# Test de configuration apache
echo "Test de la configuration "
echo ""
sudo apachectl configtest
echo ""
/usr/sbin/apache2ctl -t
echo ""
/usr/sbin/apache2ctl -S

echo ""
sleep 1
# Activation de la configuration et des modules apache2
echo "activation de la configuration"
echo ""
if ! echo -e /etc/apache2/sites-available/$srv_name.conf; then
echo "Le fichier n'a pas pu �tre �dit�!"
else
echo "Le fichier a �t� cr�� avec succ�s et va �tre activ� !"
/usr/sbin/a2dissite 000-default.conf
/usr/sbin/a2ensite $srv_name.conf
echo ""
ls /etc/apache2/site-enabled/
fi
echo ""
sleep 1.0
echo "Activation et d�sactivation de module Apache2 et PHP optionnel "
/usr/sbin/a2enmod proxy_fcgi
/usr/sbin/a2enmod setenvif
/usr/sbin/a2dismod php8.0 mpm_prefork
/usr/sbin/a2enmod mpm_event
/usr/sbin/a2enmod rewrite
/usr/sbin/a2enmod headers
/usr/sbin/a2enmod env
/usr/sbin/a2enmod dir
/usr/sbin/a2enmod mime
/usr/sbin/a2enmod ssl
/usr/sbin/a2enmod http2
/usr/sbin/a2enconf php8.0-fpm
echo ""
echo "Le serveur apache2 doit �tre red�marrer, souhaitez-vous continuer [y/n]?"
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]];
then
systemctl restart apache2
fi
echo ""
echo "Le serveur Cloud est op�rationnel !"

echo ""
sleep 1.0
#################################################################################
# Configuration du firewall de la machine
#################################################################################
echo "Recherche d''un pare-feu est cr�ation des r�gles de flux sur le $port d�fini dans la configuration du serveur Web pourt Iptables et UFW"
echo ""
/usr/sbin/iptables status >/dev/null 2>&1
if [ $? = 0 ]; then
        echo "Le pare-feu Iptable est en cours d'ex�cution, nous pouvons cr�er les r�gles entrantes pour les protocoles HTTP (80) et HTTPS (443)"
        iptables -I INPUT -p tcp --dport 80 -j ACCEPT
        iptables -I INPUT -p tcp --dport 443 -j ACCEPT
else
        echo "Le pare-feu Iptable ne fonctionne pas ou n'est pas install�"
fi

echo ""

if systemctl status ufw.service >/dev/null; then
        echo "le pare-feu ufw est en cours d'ex�cution, nous pouvons cr�er la r�gle entrante pour les protocoles HTTP (80) et HTTPS (443)"
        ufw allow http
        ufw allow https
else
        echo "Le pare-feu  ufw ne fonctionne pas ou n'est pas install�"
fi

echo ""
sleep 1
#################################################################################
# Conseils & recommandations
#################################################################################
echo "Afin de terminer la configuration, ouvrez un navigateur Web et entrez l'addresse suivante http://127.0.0.1 si vous �tes en local"
echo""
echo "ou http://<ip-publique-serveur> http://<ip-priv�-serveur> si vous effectuer la configuration depuis une autre machine"
echo ""
echo "Renseignez le nom d'administration $user_name, le mot de passe associ�, par defaut le r�pertoire des donn�es est /var/www/nextcloud/data "
echo ""
echo "La configuration de l'outil est en soit ergonomique et intuitif "
echo ""
echo "La mise en place de l'authentification avec LDAP https://docs.nextcloud.com/server/latest/admin_manual/configuration_user/user_auth_ldap.html "
echo ""
echo "Dans la cas de l'utilisation du port 443, la mise en place d'un certificat SSL est plus que recommand�."

exit 0